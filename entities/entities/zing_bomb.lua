if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Bomb"
ENT.Model		= Model("models/zinger/bomb.mdl")
ENT.IsBomb		= true

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(true)
		-- self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:NextThink(-1)
		-- wake and disable drag
		-- we calculate the throw vector as if we have none
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableDrag(false)
			phys:Wake()
		end

		self:SetNWBool("Active", false)

		-- fuse sound
		self.Sound = CreateSound(self.Entity, Sound("ambient/fire/fire_small_loop1.wav"))
		self.Damage = 700
		self.FuseTime = 1
	end

	function ENT:OnRemove()
		self.Sound:Stop()
	end

	function ENT:OnIgnite()
		self:SetNWBool("Active", true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableDrag(true)
			phys:SetDamping(0.1, 0.5)
		end

		-- start timer
		self:NextThink(CurTime() + self.FuseTime)
		-- effect and sound
		local effect = EffectData()
		effect:SetOrigin(self.Entity:GetPos())
		effect:SetAttachment(self:LookupAttachment("Fuse"))
		effect:SetEntity(self.Entity)
		util.Effect("Zinger.Fuse", effect)
		self.Sound:Play()
		self.Sound:ChangePitch(150)
	end

	function ENT:PhysicsCollide(data, physobj)
		if IsValid(data.HitEntity) and data.HitEntity.IsBomb then return end

		if not self:GetNWBool("Active") then
			self:SetNWBool("Active", true)
			-- do it on a delay
			timer.Simple(0, function() self:OnIgnite() end)
		end
	end

	function ENT:Think()
		local owner = self:GetOwner()
		if not IsValid(owner) then
			SafeRemoveEntityDelayed(self, 0)
			return
		end

		local pos = self:GetPos()
		local team = owner:Team()
		-- remove thyself
		SafeRemoveEntityDelayed(self, 0)
		self:SetNotSolid(true)
		-- blow up
		util.Explosion(pos, self.Damage, team)
	end

end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Think()
		if self:GetNWBool("Active") then
			-- if we're active, create a dynamic light at the Fuse attachment
			local attachment = self:GetAttachment(self:LookupAttachment("Fuse"))
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
	end

	function ENT:Draw()
		self:DrawModel()
	end
end
