if SERVER then AddCSLuaFile() end

ENT.Type			= "anim"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:GetRoundEndTime()
	return self:GetNWFloat("RoundEndTime")
end

function ENT:GetRoundDuration()
	return self:GetNWFloat("RoundDuration")
end

function ENT:GetRoundState()
	return self:GetNWInt("RoundState")
end

function ENT:GetCurrentHole()
	return self:GetNWInt("CurrentHole")
end

function ENT:GetCurrentRules()
	return self:GetNWInt("CurrentRules")
end

function ENT:GetProgress(t)
	if t == TEAM_ORANGE then
		return self:GetNWFloat("RedProgress")
	elseif t == TEAM_PURPLE then
		return self:GetNWFloat("BlueProgress")
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
		self:SetNWFloat("RoundEndTime", time)
	end

	function ENT:SetRoundDuration(time)
		self:SetNWFloat("RoundDuration", time)
	end

	function ENT:SetRoundState(state)
		self:SetNWInt("RoundState", state)
	end

	function ENT:SetCurrentHole(num)
		self:SetNWInt("CurrentHole", num)
	end

	function ENT:SetCurrentRules(num)
		self:SetNWInt("CurrentRules", num)
	end

	function ENT:SetProgress(t, float)
		if t == TEAM_ORANGE then
			self:SetNWFloat("RedProgress", float)
		elseif t == TEAM_PURPLE then
			self:SetNWFloat("BlueProgress", float)
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
