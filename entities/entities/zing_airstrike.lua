if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= ""

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Think()
	end

	function ENT:Draw()
	end
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetNoDraw(true)

		self.FlyBySound = CreateSound(self.Entity, Sound("zinger/items/airstrikeflyby.mp3"))
		self.FlyBySound:SetSoundLevel(0.5)
		self.FlyBySound:Play()

		self.NextShot = CurTime() + 3
		self.ShotCount = 0

		timer.Simple(3, function()
			util.ScreenShake(self:GetPos(), 2, 15, 3, 3072)
		end)

		SafeRemoveEntityDelayed(self, 8.1)
	end

	function ENT:OnRemove()
		self.FlyBySound:Stop()
	end

	function ENT:FireWeapon()
		local dir = self:GetAngles():Forward()

		local pos = self:GetPos() - (dir * (500 - (self.ShotCount * 100))) + (VectorRand() * 40)

		local tr = util.TraceLine({
			start = pos,
			endpos = pos + Vector(0, 0, 1048),
		})
		pos = tr.HitPos - Vector(0, 0, 16)

		if not self.AimDir then
			self.AimDir = (self.TargetPos - pos)
		end

		-- create bomb and drop it
		local bomb = ents.Create("zing_bomb")
		bomb:SetModel(Model("models/zinger/rocket.mdl"))
		bomb:SetOwner(self:GetOwner())
		bomb:SetPos(pos)
		bomb:SetAngles(self.AimDir:Angle())
		bomb:Spawn()
		bomb.Damage = 500
		bomb.FuseTime = 0

		local phys = bomb:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableDrag(false)
			phys:SetMass(80)
			phys:SetDamping(0, 0)
			phys:ApplyForceCenter(self.AimDir * (phys:GetMass()))
		end
	end

	function ENT:Think()
		-- fire a shot if its time
		if self.NextShot > 0 and CurTime() > self.NextShot then

			self.ShotCount = self.ShotCount + 1
			if self.ShotCount < 5 then
				self.NextShot = CurTime() + 0.15
			else
				self.NextShot = -1
			end

			self:FireWeapon()
		end
	end
end
