if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Rocket"
ENT.Model		= Model("models/zinger/rocket.mdl")
ENT.IsBomb		= true

if SERVER then
	AccessorFunc(ENT, "Target", "Target")

	function ENT:Initialize()
		self.CurrentDir = self:GetAngles():Forward()
		self:SetTarget(NULL)

		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		-- wake and disable drag
		-- we calculate the throw vector as if we have none
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:Wake()
		end

		-- trail
		local effect = EffectData()
		effect:SetOrigin(self.Entity:GetPos())
		effect:SetAttachment(self:LookupAttachment("Exhaust"))
		effect:SetEntity(self.Entity)
		util.Effect("Zinger.RocketTrail", effect)
	end

	function ENT:Explode()
		if self.Exploded then return end

		self.Exploded = true
		local owner = self:GetOwner()
		if not IsValid(owner) then
			SafeRemoveEntityDelayed(self, 0)
			return
		end

		local pos = self:GetPos()
		local team = owner:Team()
		-- remove thyself
		SafeRemoveEntityDelayed(self, 0)
		-- blow up
		util.Explosion(pos, 700, team)
	end

	function ENT:PhysicsCollide()
		self:Explode()
	end

	function ENT:Think()
		local target = self:GetTarget()
		-- our target disappeared
		if not IsValid(target) then return end

		-- figure out direction
		local dir = (target:GetPos() - self:GetPos())
		dir:Normalize()
		-- is there an obstacle in my way?
		local tr = util.TraceEntity({
			start = self:GetPos(),
			endpos = target:GetPos(),
			filter = self,
		}, self)
		if tr.Entity ~= target then
			-- force the rocket to go upward in a hope of
			-- being able to avoid the obstacle
			dir.z = 1
			dir:Normalize()
		end

		self.CurrentDir = LerpVector(FrameTime() * 3, self.CurrentDir, dir)
		-- point toward them
		self:SetAngles(self.CurrentDir:Angle())
		-- track them
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self.CurrentDir * HOMING_ROCKET_SPEED)
		end

		self:NextThink(CurTime())
		return true
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Think()
		-- engine glow
		local attachment = self:GetAttachment(self:LookupAttachment("Exhaust"))
		if attachment then
			local light = DynamicLight(self:EntIndex())
			light.Pos = attachment.Pos
			light.Size = 128
			light.Decay = 512
			light.R = 255
			light.G = 230
			light.B = 0
			light.Brightness = 2
			light.DieTime = CurTime() + 1
		end
	end

	function ENT:Draw()
		self:DrawModel()
	end
end
