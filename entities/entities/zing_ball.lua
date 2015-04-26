if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Zinger Ball"
ENT.Model		= Model("models/zinger/ball.mdl")
ENT.Size		= BALL_SIZE
ENT.IsBall		= true

AccessorFunc(ENT, "IsNinja", "Ninja")
AccessorFunc(ENT, "IsStone", "Stone")
AccessorFunc(ENT, "IsDisguise", "Disguise")
AccessorFunc(ENT, "IsSpy", "Spy")

function ENT:Team()
	local ply = self:GetOwner()
	if not IsValid(ply) then
		return TEAM_SPECTATOR
	end

	return ply:Team()
end


function ENT:GetWeaponPosition(item)
	-- does this ball have a view model?
	-- if not return the ball position and angles
	local viewmodel = self:GetNWEntity("ViewModel")
	if not IsValid(viewmodel) then
		return self:GetPos(), self.AimVec:Angle()
	end

	-- get the muzzle attachment on the view model
	-- if it doesn't exist just return the view models position and angles
	local attachment = viewmodel:GetAttachment(viewmodel:LookupAttachment("Muzzle"))
	if not attachment then
		return viewmodel:GetPos(), viewmodel:GetAngles()
	end

	return attachment.Pos, attachment.Ang
end

if SERVER then
	local BounceSounds = {
		Sound("zinger/ballbounce1.mp3"),
		Sound("zinger/ballbounce2.mp3"),
		Sound("zinger/ballbounce3.mp3"),
		Sound("zinger/ballbounce4.mp3")
	}

	local DriveSounds = {
		Sound("zinger/drive1.mp3"),
		Sound("zinger/drive2.mp3")
	}

	local PuttSounds = {
		Sound("zinger/putt1.mp3")
	}

	local CollideSounds = {
		Sound("zinger/ballcollide.mp3")
	}

	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetModel(self.Model)
		self:PhysicsInitSphere(self.Size, "grass")
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		self:SetCollisionBounds(Vector(-self.Size, -self.Size, -self.Size), Vector(self.Size, self.Size, self.Size))
		-- set mass and damping
		local phys = self:GetPhysicsObject()
		if not IsValid(phys) then
			phys:SetMass(30)
			phys:SetDamping(0.8, 0.8)
			phys:Wake()
		end

		-- store last movement
		self.LastMove = CurTime()
		-- spawn the view model
		local viewmodel = ents.Create("zing_viewmodel")
		viewmodel:SetPos(self:GetPos())
		viewmodel:Spawn()
		viewmodel:SetOwner(self.Entity)
		self:SetNWEntity("ViewModel", viewmodel)
		self:DeleteOnRemove(viewmodel)
	end

	function ENT:OutOfBounds()
		if self:WaterLevel() >= 3 or self.MakeWaterSplash then
			self.MakeWaterSplash = false
			local effect = EffectData()
			effect:SetOrigin(self:GetPos())
			util.Effect("Zinger.WaterSplash", effect)
		else
			util.Explosion(self:GetPos(), 0)
		end

		-- we went oob we should no longer be welded to anything
		constraint.RemoveConstraints(self, "Weld")
		-- get owner then destroy
		local ply = self:GetOwner()
		SafeRemoveEntityDelayed(self, 0)
		-- let them look at what they did wrong for 2 seconds
		timer.Simple(2, function()
			if not IsValid(ply) then return end

			-- add back to queue
			GAMEMODE:AddToQueue(pl, true)
		end)
	end

	function ENT:PhysicsCollide(data, physobj)
		-- not bouncing by default
		local bounce = false
		-- enable damping and drag again
		if self.HasJumped then
			self.HasJumped = false
			physobj:EnableDrag(true)
			physobj:SetDamping(self.LinearDamping or 0.8, self.LinearDamping or 0.8)
		end

		-- check for world
		local hitWorld = data.HitEntity:IsWorld() or data.HitEntity:GetMoveType() == MOVETYPE_PUSH
		if hitWorld then
			-- run trace of collision
			local trace = {}
			trace.start = self:GetPos()
			trace.endpos = data.HitPos + (data.HitNormal * (self.Size * 2))
			trace.filter = self
			local tr = util.TraceLine(trace)
			-- check if we're out of bounds
			if IsOOB(tr) then
				rules.Call("OutOfBounds", self)
			elseif self.OnTee then
				self.OnTee = false
				rules.Call("TeePlayer", self:Team())
			end
		end

		-- bounce off world surfaces if they are within our normal threshold
		if hitWorld and Vector(0, 0, 1):Dot(data.HitNormal) >= -0.35 then
			bounce = true
			-- particle effect on impact with world
			ParticleEffect("Zinger.BallImpact", data.HitPos, angle_zero, self.Entity)
			-- play the sound where the collision happened, not just on the ball!
			sound.Play(BounceSounds[math.random(1, #BounceSounds)], data.HitPos, 75, 100)
		elseif not hitWorld then
			-- bounce of other balls
			if IsBall(data.HitEntity) then
				bounce = true
				-- collision sound
				sound.Play(CollideSounds[math.random(1, #CollideSounds)], data.HitPos, 75, 100)
				-- call event
				GAMEMODE:BallHitBall(self, data.HitEntity)
			elseif not IsCup(data.HitEntity) and not IsCrate(data.HitEntity) and not IsMagnet(data.HitEntity) then
				-- particle effect on impact with world
				ParticleEffect("Zinger.BallImpact", data.HitPos, angle_zero, self.Entity)
				-- play the sound where the collision happened, not just on the ball!
				sound.Play(BounceSounds[math.random(1, #BounceSounds)], data.HitPos, 75, 100)
			end
		end

		-- bouncing?
		if bounce then
			-- calculate bounce normal
			local normal = data.OurOldVelocity:GetNormal()
			if not hitWorld then
				normal = (data.HitObject:GetPos() - physobj:GetPos()):GetNormal()
			end

			local dot = data.HitNormal:Dot(normal * -1)
			local reflect = (2 * data.HitNormal * dot) + normal
			local speed = math.max(data.OurOldVelocity:Length(), data.Speed)
			-- bounce me
			local scale = 1
			if self:GetStone() then
				scale = 0.2
			end

			physobj:SetVelocity(reflect * speed * 0.8 * scale)
			-- bounce other
			local scale = 1
			if IsBall(data.HitEntity) and data.HitEntity:GetStone() then
				scale = 0.2
			end

			data.HitObject:SetVelocity(reflect * -speed * 0.8 * scale)
		end
	end

	function ENT:Think()
		local ply = self:GetOwner()
		if not IsValid(ply) then return end

		-- measure speed
		local speed = self:GetVelocity():Length()
		-- check if we'ved stopped (or at least slowed down enough)
		if speed < 15 then
			-- make sure we've stopped for the minimal amount of time
			if CurTime() - self.LastMove > rules.Call("GetStopTime") then
				if not pl:CanHit() then
					-- call event
					rules.Call("EnableHit", pl, self)
				end
			end
		else
			-- only update if we aren't already delayed
			if CurTime() > self.LastMove then
				-- delay
				self.LastMove = CurTime()
			end

			ply:SetCanHit(false)
		end

		-- hit the water?
		if self:WaterLevel() >= 3 then
			rules.Call("OutOfBounds", self)
		end

		self:NextThink(CurTime())
		return true
	end

	function ENT:SafePosition(pos, stop)
		-- don't go inside other balls
		local mins, maxs = Vector(-self.Size, -self.Size, -self.Size), Vector(self.Size, self.Size, self.Size)
		local adjustedPos = pos
		for i = 1, 8 do
			if IsSpaceOccupied(adjustedPos, mins, maxs, self) then
				adjustedPos.z = adjustedPos.z + (maxs.z - mins.z)
			end
		end

		self:SetPos(adjustedPos)
		if stop then
			-- stop in place
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				-- disable then enable motion to kill any velocity
				phys:EnableMotion(false)
				phys:SetVelocity(vector_origin)
				phys:SetVelocityInstantaneous(vector_origin)
				timer.Simple(0, function()
					if IsValid(phys) then
						phys:EnableMotion(true)
					end
				end)
			end
		end
	end
end

if CLIENT then
	local CircleMaterial = Material("sgm/playercircle")

	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.BaseClass.Initialize(self)
		local inflatedSize = self.Size * 1.15
		self:SetRenderBounds(Vector() * -inflatedSize, Vector() * inflatedSize)
		self.MicModel = ClientsideModel(Model("models/extras/info_speech.mdl"), RENDERGROUP_OPAQUE)
		self.MicModel:SetMaterial("zinger/models/mic/mic")
		self.MicModel:SetNoDraw(true)
	end

	function ENT:Draw()
		local owner = self:GetOwner()
		if not IsValid(owner) then
			return
		end

		-- pre draw, would really like some better way to do this, oh well.
		--[[
		self.CanSee = true
		for k, v in pairs(owner.ActiveItems) do
			local ret = GAMEMODE:ItemCall(owner, v, "PreDrawBall")
			if ret ~= nil and ret ~= true then
				self.CanSee = false
			end
		end

		if not self.CanSee then
			return
		end
		]]--

		local pos = self:GetPos()

		--[[
		if owner == LocalPlayer() then
			self:DrawShadow(true)
		end
		]]--

		local tr = util.TraceLine({
			start = pos,
			endpos = pos - Vector(0, 0, 64),
			filter = self,
			mask = MASK_NPCWORLDSTATIC,
		})
		if tr.Hit then
			-- disguise
			local t = owner:Team()
			if self:GetDisguise() then
				t = util.OtherTeam(t)
			end

			local color = team.GetColor(t)
			-- draw team circle
			render.SetMaterial(CircleMaterial)
			render.DrawQuadEasy(tr.HitPos + tr.HitNormal * 0.2, tr.HitNormal, 64, 64, Color(color.r, color.g, color.b, (1 - tr.Fraction) * 255))
		end

		-- calculate outline width
		local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
		width = 1.1 + ((width / MAX_VIEW_DISTANCE) * 0.2)
		self:DrawModelOutlined(Vector() * width)
		if owner:IsSpeaking() then
			if IsValid(self.MicModel) then
				local ea = EyeAngles()
				self.MicModel:SetPos(pos + Vector(0, 0, self.Size * 2.5) + (ea:Right() * self.Size * 0.5))
				self.MicModel:SetAngles(Angle(0, ea.Yaw + 180, 0))
				render.SuppressEngineLighting(true)
				self.MicModel:DrawModel()
				render.SuppressEngineLighting(false)
			end
		end

		-- post draw
		--[[
		for k, v in pairs(owner.ActiveItems) do
			GAMEMODE:ItemCall(owner, v, "PostDrawBall")
		end
		]]--
	end

	function ENT:GetPos2D()
		return GetEntityPos2D(self, self.Size)
	end
end
