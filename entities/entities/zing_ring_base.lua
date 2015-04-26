if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Ring"
ENT.Model		= Model("models/zinger/arch.mdl")
ENT.Size		= 48
ENT.NotifyColor	= Color(255, 240, 0, 255)

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Hole")
	self:DTVar("Bool", 0, "RedDone")
	self:DTVar("Bool", 1, "BlueDone")
end

function ENT:IsTeamDone(t)
	if t == TEAM_ORANGE then
		return self.dt.RedDone
	elseif t == TEAM_PURPLE then
		return self.dt.BlueDone
	end

	return false
end

if SERVER then
	local color_ringbase = Color(255, 255, 20)

	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		self:SetColor(color_ringbase)
		-- if we're parented use a physics shadow to keep us solid
		if IsValid(self:GetParent()) then
			self.IsParented = true
			self:MakePhysicsObjectAShadow(false, false)
		end

		-- freeze
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		-- create trigger
		local trigger = ents.Create("zing_ring_trigger")
		trigger:SetPos(self:GetPos())
		trigger:SetAngles(self:GetAngles())
		trigger:Spawn()
		trigger:SetParent(self)
		trigger:SetRing(self)
		self:DeleteOnRemove(trigger)
	end

	function ENT:SetTeamDone(t, bool)
		if t == TEAM_ORANGE then
			self.dt.RedDone = bool
		elseif t == TEAM_PURPLE then
			self.dt.BlueDone = bool
		end
	end

	function ENT:IsInGround()
		local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = self:GetPos() - Vector(0, 0, 32),
			filter = self,
		})
		return tr.Hit
	end

	function ENT:AlwaysSpawn()
		return self.KeyValues["spawnflags"] == "1"
	end

	function ENT:Think()
		if self.IsParented then
			-- update the physics object shadow to allow parenting
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:UpdateShadow(self:GetPos(), self:GetAngles(), FrameTime())
			end

			self:NextThink(CurTime())
			return true
		end
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	local ColorYellow = Color(color_yellow.r, color_yellow.g, color_yellow.b, 255)
	local ColorGold = Color(color_yellow_dark.r, color_yellow_dark.g, color_yellow_dark.b, 255)

	ENT.HintTopic = "Gameplay:Rings"

	function ENT:Initialize()
		self.Particles = false
		-- render bounds
		self:SetRenderBounds(self:OBBMins(), self:OBBMaxs())
	end

	local color_gray64 = Color(64, 64, 64)
	function ENT:Think()
		-- update hole
		self.CurrentHole = RoundController():GetCurrentHole()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		-- check if team is activated this ring
		local t = ply:Team()
		if self:IsTeamDone(ply:Team()) then
			-- gray
			self:SetColor(color_gray64)
			-- this hole is done, yet we haven't played the particle effect, so do so now.
			if not self.Particles then
				self.Particles = true
				-- particles
				ParticleEffectAttach("Zinger.RingExplode", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
				-- dynamic light
				local light = DynamicLight(self:EntIndex())
				light.Pos = self:GetPos()
				light.R = 255
				light.G = 240
				light.B = 0
				light.Brightness = 5
				light.Size = 512
				light.Decay = 2048
				light.DieTime = CurTime() + 1
			end
		else
			local percent = math.abs(math.sin(CurTime()))
			-- animate the color
			self:SetColor(Color(Lerp(percent, ColorGold.r, ColorYellow.r), Lerp(percent, ColorGold.g, ColorYellow.g), Lerp(percent, ColorGold.b, ColorYellow.b), 255))
		end

		self:HintThink()
		self:NextThink(CurTime() + 0.5)
		return true
	end

	function ENT:Draw()
		-- hide when not needed
		if self.CurrentHole ~= self.dt.Hole then return end

		-- calculate outline width
		local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
		local width2 = 0.95 - ((width / MAX_VIEW_DISTANCE) * 0.05)
		width = 1.05 + ((width / MAX_VIEW_DISTANCE) * 0.05)
		render.SuppressEngineLighting(true)
		self:DrawModelOutlined(Vector() * width, Vector() * width2)
		render.SuppressEngineLighting(false)
	end

	function ENT:DrawOnRadar(x, y, a)
		self:RadarDrawRect(x, y, 10, 4, self:GetColor(), a - 90)
	end
end
