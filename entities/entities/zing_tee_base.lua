if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Base Tee"
ENT.Model		= Model("models/zinger/tee.mdl")
ENT.IsTee		= true

if SERVER then
	function ENT:Initialize()
		-- setup
		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		-- raise mass
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	function ENT:TeeOff(dir, power)
		-- create a fake tee
		local ent = ents.Create("prop_physics_multiplayer")
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetModel(self:GetModel())
		ent:SetColor(self:GetColor())
		ent:SetSolid(SOLID_VPHYSICS)
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetOwner(self)
		ent:Spawn()
		-- give it a forward motion and a spin
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			-- apply force
			phys:Wake()
			phys:ApplyForceCenter((dir * (50 + power)) + Vector(0, 0, 100 + power))
			-- this gives it a spin
			phys:ApplyForceOffset((dir * -power), self:GetPos() - Vector(0, 0, 10))
		end

		-- remove entities
		SafeRemoveEntityDelayed(ent, 3)
		SafeRemoveEntityDelayed(self, 0)
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self:SetRenderBounds(Vector(-28, -28, 0), Vector(28, 28, 4))
	end

	function ENT:Draw()
		-- hide when not needed
		if self.CurrentHole ~= self.dt.Hole then return end

		-- calculate outline width
		local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
		width = 1.6 + ((width / 600) * 0.075)
		self:DrawModelOutlined(Vector(width, width, 1.05))
	end

	function ENT:DrawOnRadar(x, y, ang)
		self:RadarDrawCircle(x, y, 6, self:GetColor(), ang)
	end
end
