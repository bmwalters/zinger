if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Proximity Bomb"
ENT.Model		= Model("models/zinger/proxbomb.mdl")
ENT.IsBomb		= true

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:NextThink(-1)
		self.Team = TEAM_SPECTATOR
		-- wake and disable drag
		-- we calculate the throw vector as if we have none
		local phys = self:GetPhysicsObject()
		if not IsValid(phys) then
			phys:EnableDrag(false)
			phys:Wake()
		end

		self:SetNWBool("Active", false)
	end

	function ENT:PhysicsCollide()
		if not self:GetNWBool("Active") then
			self:SetNWBool("Active", true)
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableDrag(true)
				phys:SetDamping(0.1, 0.5)
			end

			-- start timer
			self:NextThink(CurTime())
		end
	end

	function ENT:Think()
		debugoverlay.Sphere(self:GetPos(), 96, 0.05, Color(255, 255, 255, 0))
		local owner = self:GetOwner()
		-- blow up?
		local entities = ents.FindInSphere(self:GetPos(), 96)
		for k, v in pairs(entities) do
			-- only attack the opposing team
			if IsBall(v) and v:Team() ~= self.Team and not (v:GetNinja() or v:GetDisguise()) then
				util.Explosion(self:GetPos(), 950, self.Team, self)
				self:Remove()
				return
			end
		end

		self:NextThink(CurTime())
		return true
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.NextAlert = CurTime()
	end

	function ENT:BuildBonePositions(numBones)
		if self:GetNWBool("Active") then
			local bone = self:GetBoneMatrix(1)
			if bone then
				bone:Rotate(Angle(0, 0, math.sin(CurTime() * 0.75) * 90))
				self:SetBoneMatrix(1, bone)
			end
		end
	end

	function ENT:Think()
		if not self:GetNWBool("Active") then return end
		if self.NextAlert > CurTime() then return end

		self.NextAlert = CurTime() + 1
		local owner = self:GetOwner()
		if IsValid(owner) then
			local attachment = self:GetAttachment(self:LookupAttachment("Light"))
			if attachment then
				-- sound
				self:EmitSound("Buttons.snd16")
				-- light
				local light = DynamicLight(self:EntIndex())
				light.Pos = attachment.Pos
				light.Size = 64
				light.Decay = 256
				if owner:Team() == TEAM_PURPLE then
					light.R = 64
					light.G = 64
					light.B = 255
				else
					light.R = 255
					light.G = 64
					light.B = 64
				end

				light.Brightness = 8
				light.DieTime = CurTime() + 0.5
			end
		end
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawOnRadar(x, y, a)
		self:RadarDrawRadius(x, y, 96, color_white_translucent, color_white_translucent2)
		self:RadarDrawCircle(x, y, 5, color_black)
	end
end
