local RoundControllerEnt

function RoundController()
	-- find it if needed
	if not IsValid(RoundControllerEnt) then
		RoundControllerEnt = ents.FindByClass("zing_round_controller")[1]
		print("Attempted to grab RoundControllerEnt: "..tostring(IsValid(RoundControllerEnt)))
	end

	return RoundControllerEnt
end

function GM:GetRoundState()
	return RoundController():GetRoundState()
end

function GM:GetRoundEndTime()
	return RoundController():GetRoundEndTime()
end

function GM:GetGameTimeLeft()
	return math.max(self:GetRoundEndTime() - CurTime(), 0)
end

function GM:GetRoundDuration()
	return RoundController():GetRoundDuration()
end

function GM:GetTeamProgress(t)
	return RoundController():GetProgress(t)
end

function GM:GetCurrentHole()
	return RoundController():GetCurrentHole()
end

function GM:GetCurrentRules()
	return RoundController():GetCurrentRules()
end

function GM:GetSky()
	local rc = RoundController()
	if IsValid(rc) then
		if rc:GetNWInt("Sky") == 0 then
			return 1
		end

		return rc:GetNWInt("Sky")
	end

	return SKY_DAY
end


if SERVER then
	function GM:SetRoundEndTime(time)
		local rc = RoundController()
		rc:SetRoundDuration(time - CurTime())
		rc:SetRoundEndTime(time)
	end

	function GM:SetRoundState(state)
		RoundController():SetRoundState(state)
	end

	function GM:SetCurrentHole(hole)
		RoundController():SetCurrentHole(hole)
	end

	function GM:SetCurrentRules(rules)
		RoundController():SetCurrentRules(rules)
	end

	function GM:SetTeamProgress(t, percent)
		RoundController():SetProgress(t, percent)
	end
end
