if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "base_anim"
ENT.PrintName	= nil

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:GetPathTarget(path)
		return ents.FindByName(path:GetKeyValues()["target"])[1]
	end

	function ENT:Initialize()
		self:DrawShadow(false)
		local pathEnt = ents.FindByName(self.Path)[1]
		local path = {}
		path[#path + 1] = pathEnt:GetPos()
		SafeRemoveEntityDelayed(pathEnt, 0)
		-- walk the path and find all the waypoints for us
		local nextEnt = self:GetPathTarget(pathEnt)
		while IsValid(nextEnt) and nextEnt ~= pathEnt do
			path[#path + 1] = nextEnt:GetPos()
			SafeRemoveEntityDelayed(nextEnt, 0)
			nextEnt = self:GetPathTarget(nextEnt)
		end

		-- end where they started?
		if nextEnt == pathEnt then
			path[#path + 1] = pathEnt:GetPos()
		end

		-- set the position to the exact center of our path
		local pos = Vector(0, 0, 0)
		for i = 1, #path do
			pos = pos + path[i]
		end

		pos = pos * (1 / #path)
		self:SetPos(pos)
		-- inflate the path a bit to take into account mapper error
		for i = 1, #path do
			path[i] = ((path[i] - pos) * 1.04) + pos -- + Vector(0, 0, 32)
		end

		-- send off to the client
		self:SetNWInt("NumWaypoints", #path)
		for i = 1, #path do
			self:SetNWVector(i, path[i])
		end

		self.BaseClass.Initialize(self)
	end

	function ENT:KeyValue(key, value)
		if key == "destination" then
			self.Path = value
		end

		return self.BaseClass.KeyValue(self, key, value)
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

	local MaterialPuff = Material("zinger/particles/puff")
	local CloudConVar = CreateClientConVar("cl_zing_clouds", "1", true, false)

	function ENT:Initialize()
		self.BaseClass.Initialize(self)
	end

	local CLOUDS_PER_128_UNITS = 4
	function ENT:Think()
		if self.Clouds then return end

		local valid = true
		local points = self:GetNWInt("NumWaypoints", 0)
		-- have all the waypoints required to build the cloud map?
		if points == 0 then
			valid = false
		else
			for i = 1, points do
				if not self:GetNWVector(i) then
					valid = false
				end
			end
		end

		if valid then
			-- fetch the path
			local path = {}
			for i = 1, points do
				path[#path + 1] = self:GetNWVector(i)
			end

			local clouds = {}
			local mins = Vector(32768, 32768, 32768)
			local maxs = Vector(-32768, -32768, -32768)
			-- build clouds between the segments
			for i = 1, #path - 1 do
				local a = path[i]
				local b = path[i + 1]
				local num = math.ceil((CLOUDS_PER_128_UNITS / 128) * (a - b):Length())
				for j = 1, num do
					local frac = (1 / num) * j
					local pos = LerpVector(frac, a, b)
					pos = pos + VectorRand() * math.random(0, 24)
					local cloud = {}
					cloud.Position = pos
					cloud.Size = math.random(96, 128) * 1.2
					cloud.Speed = math.Rand(0.2, 0.8)
					cloud.Delta = cloud.Size
					table.insert(clouds, cloud)
					-- calculate render bounds
					mins.x = math.min(mins.x, pos.x)
					mins.y = math.min(mins.y, pos.y)
					mins.z = math.min(mins.z, pos.z)
					maxs.x = math.max(maxs.x, pos.x)
					maxs.y = math.max(maxs.y, pos.y)
					maxs.z = math.max(maxs.z, pos.z)
				end
			end

			self.Clouds = clouds
			self:SetRenderBoundsWS(mins, maxs)
		end
	end

	function ENT:Draw()
		if self.Clouds and CloudConVar:GetBool() then
			local dir = EyeVector() * -1
			local shade = GAMEMODE:GetCloudShadeColor()
			local color = GAMEMODE:GetCloudColor()
			local numClouds = #self.Clouds
			render.SetMaterial(MaterialPuff)
			mesh.Begin(MATERIAL_QUADS, numClouds * 3)
			-- initial calculations and outline pass
			for i = 1, numClouds do
				local cloud = self.Clouds[i]
				cloud.Delta = cloud.Size + math.sin(CurTime() * cloud.Speed) * 8
				mesh.QuadEasy(cloud.Position, dir, cloud.Delta + 4, cloud.Delta + 4 - 24, color_black)
			end

			-- shade pass
			for i = 1, numClouds do
				local cloud = self.Clouds[i]
				mesh.QuadEasy(cloud.Position, dir, cloud.Delta, cloud.Delta - 24, shade)
			end

			-- color pass
			for i = 1, numClouds do
				local cloud = self.Clouds[i]
				mesh.QuadEasy(cloud.Position + Vector(0, 0, (cloud.Delta * 0.075) - 4), dir, cloud.Delta * 0.8, cloud.Delta * 0.9 - 24, color)
			end

			mesh.End()
		end
	end
end
