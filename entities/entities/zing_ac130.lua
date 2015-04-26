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

		self.EngineSound = CreateSound(self.Entity, Sound("zinger/items/airplane.wav"))
		self.EngineSound:SetSoundLevel(0.5)
		self.EngineSound:PlayEx(0, 100)
		self.WeaponSound = CreateSound(self.Entity, Sound("zinger/items/ac130cannon.mp3"))
		self.WeaponSound:SetSoundLevel(0.48)

		self.NextShot = CurTime() + 3
		self.Volume = 0
		self.Leaving = false
	end

	function ENT:OnRemove()
		self.EngineSound:Stop()
		self.WeaponSound:Stop()
	end

	function ENT:FireWeapon()
		local targets = {}

		for _, ply in pairs(player.GetAll()) do
			local ball = ply:GetBall()
			if IsBall(ball) and ball:Team() == self.Hunt and not ball:GetNinja() then
				table.insert(targets, {ball, ball:GetPos()})
			end
		end

		if #targets > 0 then
			-- select a random target
			local target = targets[math.random(1, #targets)]
			local ball = target[1]
			local pos = target[2]

			-- play the weapon sound
			self.WeaponSound:Stop()
			self.WeaponSound:PlayEx(1.2, math.random(96, 104))

			-- delay the shot
			timer.Simple(0.2, function()
				if IsBall(ball) then
					-- trace position for tracer (paradox?)
					local tr = util.TraceLine({
						start = pos,
						endpos = pos + Vector(0, 0, 4096),
						filter = ball,
					})

					-- tracer
					util.ParticleTracerEx("Zinger.AC130Tracer", tr.HitPos - Vector(0, 0, 16), pos, true, 0, -1)

					timer.Simple(0.2, function()
						util.Explosion(pos, 200, util.OtherTeam(self.Hunt), ball)
					end)
				end
			end)
		end
	end

	function ENT:Think()
		-- check if volume has reach max
		if self.Volume < 1 then
			-- slowly raise engine volume
			self.Volume = math.Approach(self.Volume, 1, 0.025)
			self.EngineSound:ChangeVolume(self.Volume)
		else
			-- time to leave?
			if not self.Leaving and self.DieTime - CurTime() < 2 then
				-- fade out engine
				self.Leaving = true
				self.EngineSound:FadeOut(2.0)
			end
		end

		-- fire a shot if its time
		local ct = CurTime()
		if ct > self.NextShot and not self.Leaving then
			self.NextShot = ct + 1
			self:FireWeapon()
		end
	end
end
