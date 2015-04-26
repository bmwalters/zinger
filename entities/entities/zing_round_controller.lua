if SERVER then AddCSLuaFile() end

ENT.Type			= "anim"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self:DTVar("Float", 0, "RoundEndTime")
	self:DTVar("Float", 1, "RedProgress")
	self:DTVar("Float", 2, "BlueProgress")
	self:DTVar("Float", 3, "RoundDuration")
	self:DTVar("Int", 0, "RoundState")
	self:DTVar("Int", 1, "CurrentHole")
	self:DTVar("Int", 2, "Sky")
	self:DTVar("Int", 3, "CurrentRules")

	-- self.dt.Sky = SKY_DAY
end

function ENT:GetRoundEndTime()
	return self.dt.RoundEndTime
end

function ENT:GetRoundDuration()
	return self.dt.RoundDuration
end

function ENT:GetRoundState()
	return self.dt.RoundState
end

function ENT:GetCurrentHole()
	return self.dt.CurrentHole
end

function ENT:GetCurrentRules()
	return self.dt.CurrentRules
end

function ENT:GetProgress(t)
	if t == TEAM_ORANGE then
		return self.dt.RedProgress
	elseif t == TEAM_PURPLE then
		return self.dt.BlueProgress
	end

	return 0
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Initialize()
		-- hide
		self:SetNoDraw(true)
		self:DrawShadow(false)
	end

	function ENT:SetRoundEndTime(time)
		self.dt.RoundEndTime = time
	end

	function ENT:SetRoundDuration(time)
		self.dt.RoundDuration = time
	end

	function ENT:SetRoundState(state)
		self.dt.RoundState = state
	end

	function ENT:SetCurrentHole(num)
		self.dt.CurrentHole = num
	end

	function ENT:SetCurrentRules(num)
		self.dt.CurrentRules = num
	end

	function ENT:SetProgress(t, float)
		if t == TEAM_ORANGE then
			self.dt.RedProgress = float
		elseif t == TEAM_PURPLE then
			self.dt.BlueProgress = float
		end
	end
end

if CLIENT then
	function ENT:Initialize()
	end

	function ENT:Draw()
	end

	function ENT:Think()
	end
end
