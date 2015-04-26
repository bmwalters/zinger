if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Supply Crate"
ENT.Model		= Model("models/zinger/crate.mdl")
ENT.IsCrate		= true

-- gib models
util.PrecacheModel("models/zinger/crategib.mdl")

if SERVER then
	function ENT:Initialize()
		self.Item = items.Random()
		self.Activated = false

		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetTrigger(true)
		-- spawn sound
		self:EmitSound("physics/wood/wood_box_impact_bullet4.wav")
		-- violently jolt the crate once it has emerged
		-- from the ground.
		timer.Simple(0.15, function()
			if IsValid(self.Entity) then
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
					phys:ApplyForceOffset(vector_up * phys:GetMass() * 75, self:GetPos() + VectorRand() * 40)
					phys:SetMass(5)
					self:SetGravity(2)
				end
			end
		end)
		rules.Call("CrateSpawned", self)
	end

	function ENT:Think(ply, ball)
		-- gibs
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		effect:SetAngles(self:GetAngles())
		util.Effect("Zinger.CrateBreak", effect)
		SafeRemoveEntity(self)
	end

	function ENT:DoPickup(ply, ball)
		if self.Activated then return end

		self.Activated = true
		inventory.Give(ply, self.Item)
		rules.Call("SupplyCratePicked", self, ball)
		-- gibs
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		effect:SetAngle(self:GetAngles())
		util.Effect("Zinger.CrateBreak", effect)
		-- sound
		sound.Play(Sound("physics/wood/wood_box_impact_bullet1.wav"), self:GetPos(), 100, 100)
		-- particle effect
		ParticleEffect("Zinger.CratePickup", self:GetPos(), angle_zero, ent)
		self:Remove()
	end

	function ENT:StartTouch(ent)
		if IsBall(ent) then
			local owner = ent:GetOwner()
			if not IsValid(owner) then return end

			self:DoPickup(owner, ent)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		-- check for world
		local hitWorld = data.HitEntity:IsWorld()
		if hitWorld then
			-- run trace of collision
			local trace = {}
			trace.start = self:GetPos()
			trace.endpos = data.HitPos - (vector_up * 32)
			trace.filter = self
			local tr = util.TraceLine(trace)
			-- check if we're out of bounds
			if IsOOB(tr) then
				-- gibs
				local effect = EffectData()
				effect:SetOrigin(self:GetPos())
				effect:SetAngle(self:GetAngles())
				util.Effect("Zinger.CrateBreak", effect)
				SafeRemoveEntityDelayed(self, 0)
			end
		end
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	ENT.HintTopic = "Gameplay:Supply Crates"
	ENT.HintOffset = Vector(0, 0, 50)

	function ENT:Initialize()
		self.PopTime = CurTime() + 0.15
		self.AnimTime = CurTime() + 0.5
		self.RebuildShadow = true
		-- keep track of bone velocities
		self.BoneVelocities = {}
		self.BoneScales = {}
		for i = 0, 4 do
			self.BoneVelocities[i] = math.random(0, 2)
			self.BoneScales[i] = 0.1
		end

		self.BaseClass.Initialize(self)
		-- bloat out render bounds because we pop the box out of the ground beyond its boundaries
		self:SetRenderBounds(self:OBBMins() * 1.1, self:OBBMaxs() * 1.1)
	end

	function ENT:BuildBonePositions(numbones)
		local percent = math.Clamp((self.PopTime - CurTime()) / 0.15, 0, 1)
		for i = 0, numbones - 1 do
			local bone = self:GetBoneMatrix(i)
			if bone then
				-- animate out of the ground
				bone:Translate(Vector(0, math.LerpNoClamp(percent, 0, -40), 0))
				-- animate the scale of the bone, for the explosion effect
				bone:Scale(Vector() * self.BoneScales[i])
				-- explode outward
				if self.PopTime <= CurTime() then
					local speed = FrameTime() * 8
					local dist = (1 - self.BoneScales[i])
					-- update bone scales and scale velocities
					self.BoneVelocities[i] = self.BoneVelocities[i] + speed * dist
					self.BoneScales[i] = self.BoneScales[i] + self.BoneVelocities[i] * speed
					self.BoneVelocities[i] = self.BoneVelocities[i] * (0.95 - FrameTime() * 8)
				end

				self:SetBoneMatrix(i, bone)
			end
		end

		self.RebuildShadow = true
		-- don't need to animate forever...
		if self.AnimTime <= CurTime() then
			self.BuildBonePositions = nil
		end
	end

	function ENT:Draw()
		if self.RebuildShadow then
			-- make sure the shadow updates
			self:MarkShadowAsDirty(true)
			self.RebuildShadow = false
		end

		-- calculate outline width
		local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
		width = 1.05 + ((width / MAX_VIEW_DISTANCE) * 0.1)
		self:DrawModelOutlined(Vector() * width)
	end

	function ENT:DrawOnRadar(x, y, a)
		self:RadarDrawRect(x, y, 6, 6, color_brown, a)
	end
end
