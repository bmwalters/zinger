if SERVER then AddCSLuaFile() end

ENT.Type					= "anim"
ENT.Base					= "zing_insect_base"
ENT.PrintName				= "Firefly"
ENT.AutomaticFrameAdvance	= true

if SERVER then
	function ENT:Initialize()
		self.BaseClass.Initialize(self)
	end

	function ENT:MoveToTarget(target)
		-- just slowly move toward target
		local dir = (target:GetPos() + self.Offset) - self:GetPos()
		dir:Normalize()
		local velocity = (dir * 20)
		self:SetLocalVelocity(velocity)
	end
end

if CLIENT then
	local GlowMaterial = Material("zinger/particles/glow2")

	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

	local num_x = function()
		return math.random(-200, 200)
	end

	function ENT:Initialize()
		-- generate some random points
		self.Points = {}
		for i = 1, math.random(5, 8) do
			local point = {}
			point.Position = Vector(num_x(), num_x(), 0)
			point.Mul = math.random(1, 10)
			point.FlareTime = CurTime() + math.random(10, 200) / 100
			point.FlarePower = 0
			self.Points[#self.Points + 1] = point
		end
	end

	function ENT:Think()
		if FrameTime() == 0 then return end

		for i = 1, #self.Points do
			local point = self.Points[i]
			-- allow each point to flare up
			if CurTime() > point.FlareTime then
				point.FlarePower = 255
				point.FlareTime = CurTime() + math.random(10, 200) / 100
			end
		end
	end

	function ENT:Draw()
		local dir = EyeVector() * -1
		local pos = self:GetPos()
		render.SetMaterial(GlowMaterial)
		mesh.Begin(MATERIAL_QUADS, #self.Points * 2)
		for i = 1, #self.Points do
			local point = self.Points[i]
			point.FlarePower = math.Approach(point.FlarePower, 0, FrameTime() * 300)
			if point.FlarePower > 0 then
				local p = pos + point.Position
				p.z = p.z + math.sin(CurTime() * (point.Mul / 10)) * 72
				p.x = p.x + math.cos(CurTime() * (point.Mul / 8)) * 48
				p.y = p.y + math.cos(CurTime() * (point.Mul / 15)) * 48
				mesh.QuadEasy(p, dir, 32, 32, Color(255, 255, 100, math.random(8, 16)))
				mesh.QuadEasy(p, dir, 4, 4, Color(255, 255, 100, point.FlarePower))
			end
		end
		mesh.End()
	end
end
