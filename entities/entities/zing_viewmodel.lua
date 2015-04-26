if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Viewmodel"

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "PitchLocked")
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		self:DrawShadow(true)
		self:SetNoDraw(true)
	end

	self.ViewAngle = Angle(0, 0, 0)
end

function ENT:Think()
	local ball = self:GetOwner()
	if not IsValid(ball) then return end

	if CLIENT then
		local m = self:GetModel()

		if self:IsEffectActive(EF_NODRAW) or m ~= self.LastModel then
			self.ModelScale = 0
		end

		self.LastModel = m
	end

	-- we predict on the local player, but allow the server to calculate it for others
	if CLIENT and ball:GetOwner() ~= LocalPlayer() then return end

	-- lerp viewing angle
	self.ViewAngle = LerpAngle(FrameTime() * 6, self.ViewAngle, (ball.AimVec or vector_up):Angle())

	if self.dt.PitchLocked then
		self.ViewAngle.p = 0
	end

	local angle = self.ViewAngle
	local right = angle:Right()

	-- calculate the position of the model
	local pos = ball:GetPos()
	pos = pos + right * ball.Size * 1.1
	-- pos = pos + Vector(0, 0, 6)

	self:SetPos(pos)
	self:SetAngles(angle)

	self:NextThink(CurTime())
	return true
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:SetPitchLocked(value)
		self.dt.PitchLocked = value
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Draw()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local ply = owner:GetOwner()
		if not IsValid(ply) then return end

		-- pre draw, would really like some better way to do this, oh well.
		--[[
		local canSee = true
		for k, v in pairs(ply.ActiveItems) do
			local ret = GAMEMODE:ItemCall(ply, v, "PreDrawViewModel")
			if(ret ~= nil and ret ~= true) then
				canSee = false
			end
		end

		if not canSee then
			self:DrawShadow(false)
			return
		else
			self:DrawShadow(true)
		end
		]]--

		self.ModelScale = math.Approach(self.ModelScale or 0, 1, FrameTime() * 5)
		if self.ModelScale < 1 then
			-- render model
			self:SetModelScale(Vector() * self.ModelScale)
			self:SetupBones()
			self:DrawModel()
		else
			-- calculate outline width
			local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
			width = 1.025 + ((width / MAX_VIEW_DISTANCE) * 0.05)
			self:DrawModelOutlined(Vector() * width)
		end

		-- post draw
		--[[
		for k, v in pairs(ply.ActiveItems) do
			GAMEMODE:ItemCall(ply, v, "PostDrawViewModel")
		end
		]]--
	end
end
