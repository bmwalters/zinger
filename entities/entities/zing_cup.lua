if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Cup"
ENT.Model		= Model("models/zinger/cup.mdl")
ENT.IsCup		= true
ENT.NotifyColor	= color_green

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
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
		local trigger = ents.Create("zing_cup_trigger")
		trigger:SetPos(self:GetPos())
		trigger:SetAngles(self:GetAngles())
		trigger:Spawn()
		trigger:SetParent(self)
		trigger:SetCup(self)
		self:DeleteOnRemove(trigger)
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
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

	local MIN_HEIGHT = 50
	local MAX_HEIGHT = 130

	function ENT:Initialize()
		-- this cup is locked so show that.
		self.Forcefield = ClientsideModel("models/zinger/cup_forcefield.mdl", RENDERGROUP_TRANSLUCENT)
		self.Forcefield:SetNoDraw(true)
		self.Forcefield:SetPos(self:GetPos())
		self.Forcefield:SetParent(self)
		-- the two flags
		self.RedFlag = ClientsideModel("models/zinger/cup_flag.mdl", RENDERGROUP_OPAQUE)
		self.RedFlag:SetNoDraw(true)
		self.RedFlag:SetPos(self:GetPos())
		self.RedFlag:SetColor(team.GetColor(TEAM_ORANGE))
		self.RedFlag.Speed = math.Rand(3, 5)
		self.RedFlag.CurrentHeight = MIN_HEIGHT
		self.RedFlag.BuildBonePositions = function(ent, numBones, numPhysBones)
			local height = MIN_HEIGHT + (MAX_HEIGHT / 1) * RoundController():GetProgress(TEAM_ORANGE)
			ent.TargetHeight = height
			ent.CurrentHeight = Lerp(FrameTime(), ent.CurrentHeight, ent.TargetHeight)
			for i = 0, numBones - 1 do
				local wave = 0
				if i > 0 then
					wave = math.sin((CurTime() + 17) * ent.Speed + i) * 8
				end

				local matrix = ent:GetBoneMatrix(i)
				matrix:Translate(Vector(ent.CurrentHeight, 0, wave))
				ent:SetBoneMatrix(i, matrix)
			end
		end

		self.BlueFlag = ClientsideModel("models/zinger/cup_flag.mdl", RENDERGROUP_OPAQUE)
		self.BlueFlag:SetNoDraw(true)
		self.BlueFlag:SetPos(self:GetPos())
		self.BlueFlag:SetColor(team.GetColor(TEAM_PURPLE))
		self.BlueFlag.Speed = math.Rand(3, 5)
		self.BlueFlag.CurrentHeight = MIN_HEIGHT
		self.BlueFlag.BuildBonePositions = function(ent, numBones, numPhysBones)
			local height = MIN_HEIGHT + (MAX_HEIGHT / 1) * RoundController():GetProgress(TEAM_PURPLE)
			ent.TargetHeight = height
			ent.CurrentHeight = Lerp(FrameTime(), ent.CurrentHeight, ent.TargetHeight)
			for i = 0, numBones - 1 do
				local wave = 0
				if i > 0 then
					wave = math.cos(CurTime() * ent.Speed + i) * 8
				end

				local matrix = ent:GetBoneMatrix(i)
				matrix:Translate(Vector(ent.CurrentHeight, 0, wave))
				ent:SetBoneMatrix(i, matrix)
			end
		end

		self:SetRenderBounds(self:OBBMins(), self:OBBMaxs())
		-- base class
		self.BaseClass.Initialize(self)
	end

	function ENT:Think()
		self.BaseClass.Think(self)

		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local angle = (self:GetPos() - EyePos()):Angle()
		angle.p = 0
		if ply:Team() == TEAM_ORANGE then
			angle.y = angle.y - 150
			self.RedFlag:SetAngles(angle)
			angle.y = angle.y - 60
			self.BlueFlag:SetAngles(angle)
		else
			angle.y = angle.y - 150
			self.BlueFlag:SetAngles(angle)
			angle.y = angle.y - 60
			self.RedFlag:SetAngles(angle)
		end
	end

	function ENT:Draw()
		-- hide when not needed
		if self.CurrentHole ~= self:GetNWInt("hole") then return end

		-- calculate outline width
		local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
		width = 1.05 + ((width / MAX_VIEW_DISTANCE) * 0.15)
		self:DrawModelOutlined(Vector(width, width, 1))
		render.SuppressEngineLighting(true)
		local col = self.RedFlag:GetColor()
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
		self.RedFlag:DrawModel()
		local col = self.BlueFlag:GetColor()
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
		self.BlueFlag:DrawModel()
		render.SuppressEngineLighting(false)

		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		-- hide when not needed
		if not rules.Call("CanTeamSink", ply:Team()) then
			local color = team.GetColor(ply:Team())
			render.SuppressEngineLighting(true)
			render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255)
			render.SetBlend(0.25)
			-- self.Forcefield:DrawModel()
			render.SuppressEngineLighting(false)
			render.SetColorModulation(1, 1, 1)
		end
	end

	function ENT:DrawOnRadar(x, y, ang)
		self:RadarDrawCircle(x, y, 8, color_white)
	end
--[[
	function ENT:OnRemove() - Zerf
		self.Forcefield:Remove()
		self.BlueFlag:Remove()
		self.RedFlag:Remove()

		self.BaseClass.OnRemove(self)
	end
--]]
end
