if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Shroom"
ENT.Model		= Model("models/zinger/mushroom.mdl")
ENT.Size		= 48

function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "Impact")
	self.dt.Impact = false
end

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionBounds(self:OBBMins(), self:OBBMaxs())
		self:SetTrigger(true)
		self:NextThink(-1)
	end

	function ENT:Think(ent)
		self.dt.Impact = false
	end

	function ENT:StartTouch(ent)
		if IsBall(ent) then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				local normal = phys:GetVelocity()
				local speed = 200 + normal:Length()
				normal:Normalize()
				local hitNormal = (ent:GetPos() - self:GetPos())
				hitNormal.z = 0
				hitNormal:Normalize()
				local dot = hitNormal:Dot(normal * -1)
				local reflect = (2 * hitNormal * dot) + normal
				local plane = hitNormal:Cross(vector_up)
				plane:Normalize()
				debugoverlay.Cross(ent:GetPos(), 8, 5, color_black)
				debugoverlay.Line(ent:GetPos(), ent:GetPos() - normal * 128, 5, Color(0, 255, 0, 255))
				debugoverlay.Line(ent:GetPos(), ent:GetPos() + reflect * 128, 5, Color(255, 0, 0, 255))
				debugoverlay.Line(ent:GetPos() - plane * 64, ent:GetPos() + plane * 64, 5, Color(255, 255, 255, 255))
				phys:SetVelocity(reflect * speed * 2)
				self.dt.Impact = true
				self:NextThink(CurTime() + 1)
				self:EmitSound("zinger/boing.wav")
			end
		end
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.BoingEndTime = CurTime()
		self.BoingActive = false
		self.RebuildShadow = true
		-- inflate the render bounds a little because we bloat out when something hits me
		self:SetRenderBounds(self:OBBMins() * 1.5, self:OBBMaxs() * 1.5)
		self.BaseClass.Initialize(self)
	end

	function ENT:BuildBonePositions(numBones)
		local percent = math.Clamp((self.BoingEndTime - CurTime()), 0, 1)
		-- scale the bones
		if self.BoingActive then
			local scale = 1 + (math.sin(CurTime() * 50) * percent * 0.25)
			for i = 0, numBones - 1 do
				local matrix = self:GetBoneMatrix(i)
				matrix:Scale(Vector(1, scale, scale))
				self:SetBoneMatrix(i, matrix)
			end

			-- we're animating our bones
			-- update the shadow to reflect them
			self.RebuildShadow = true
		end
	end

	function ENT:Think()
		if not self.BoingActive and self.dt.Impact then
			self.BoingActive = true
			self.BoingEndTime = CurTime() + 1
		end

		if self.BoingActive and self.BoingEndTime <= CurTime() then
			self.BoingActive = false
		end

		self.ModelScale = math.Approach(self.ModelScale or 0, 1, FrameTime() * 5)
		if self.ModelScale < 1 then
			self.RebuildShadow = true
		end
	end

	function ENT:Draw()
		if self.RebuildShadow then
			-- redraw the shadow
			self:MarkShadowAsDirty(true)
			self.RebuildShadow = false
		end

		if self.ModelScale < 1 then
			-- render model
			self:SetModelScale(Vector() * self.ModelScale)
			self:SetupBones()
			self:DrawModel()
		else
			-- calculate outline width
			local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
			width = 1.1 + ((width / MAX_VIEW_DISTANCE) * 0.1)
			self:DrawModelOutlined(Vector(width, width, 1.05))
		end
	end
end
