if not SERVER then return end

module("stats", package.seeall)

-- handlers table
local StatHandlers = {}
local MatchStats = {}
local HoleStats = {}


function Clear()
	-- reset hole stats
	HoleStats = {}
end

function GetHoleStart()
	return HoleStats.Started or 0
end

function Call(name, ...)
	-- dprint("Stat Event", name)

	-- validate event
	if StatHandlers[name] then
		dprint("Stat Event", name)

		StatHandlers[name](unpack({...}))
	end
end

function AddStat(name, amt)
	MatchStats[name] = (MatchStats[name] or 0) + amt
	HoleStats[name] = (HoleStats[name] or 0) + amt
end

function GetHoleStat(name)
	return HoleStats[name] or 0
end

function AddPlayerStat(ply, name, amt)
	MatchStats.Players = MatchStats.Players or {}
	MatchStats.Players[ply] = MatchStats.Players[ply] or {}
	MatchStats.Players[ply][name] = (MatchStats.Players[ply][name] or 0) + amt

	HoleStats.Players = HoleStats.Players or {}
	HoleStats.Players[ply] = HoleStats.Players[ply] or {}
	HoleStats.Players[ply][name] = (HoleStats.Players[ply][name] or 0) + amt
end

function SetPlayerStat(ply, name, amt)
	HoleStats.Players = HoleStats.Players or {}
	HoleStats.Players[ply] = HoleStats.Players[ply] or {}
	HoleStats.Players[ply][name] = amt
end

function GetPlayerStat(ply, name)
	HoleStats.Players = HoleStats.Players or {}
	return HoleStats.Players[ply][name] or 0
end


function StatHandlers.StartHole()
	HoleStats.Started = CurTime()
	HoleStats.TotalRings = #GAMEMODE:GetHoleRings()
end

function StatHandlers.CrateSpawned(ent)
	AddStat("CratesSpawned", 1)
end

function StatHandlers.RingPassed(ring, ball)
	local ply = ball:GetOwner()

	if GetHoleStat("RingsPassed" .. ply:Team()) + GetHoleStat("RingsPassed" .. util.OtherTeam(ply:Team())) == 0 then
		rules.Call("FirstRingPassed", ring, ball)
	end

	AddStat("RingsPassed" .. ply:Team(), 1)
	AddPlayerStat(ply, "RingsPassed", 1)
	AddPlayerStat(ply, "RingsThisTurn", 1)

	local c = GetPlayerStat(ply, "RingsThisTurn")
	if c > 1 then
		rules.Call("MultiRingsPassed", ring, ball, c)
	end

	GAMEMODE:SetTeamProgress(ply:Team(), math.Clamp(GetHoleStat("RingsPassed" .. ply:Team()) / HoleStats.TotalRings, 0, 1))
end

function StatHandlers.PadTouched(pad, ball)
	local ply = ball:GetOwner()

	if GetHoleStat("PadsTouched" .. ply:Team()) + GetHoleStat("PadsTouched" .. util.OtherTeam(ply:Team())) == 0 then
		rules.Call("FirstPadTouched", pad, ball)
	end

	AddStat("PadsTouched" .. ply:Team(), 1)
	AddPlayerStat(ply, "PadsTouched", 1)
end

function StatHandlers.SupplyCratePicked(crate, ball)
	local ply = ball:GetOwner()

	if GetHoleStat("SupplyCratesPicked" .. ply:Team()) + GetHoleStat("SupplyCratesPicked" .. util.OtherTeam(ply:Team())) == 0 then
		rules.Call("FirstSupplyCratePicked", crate, ball)
	end

	AddStat("SupplyCratesPicked" .. ply:Team(), 1)
	AddPlayerStat(ply, "SupplyCratesPicked", 1)
	AddPlayerStat(ply, "CratesThisTurn", 1)

	local c = GetPlayerStat(ply, "CratesThisTurn")
	if c > 1 then
		rules.Call("MultiSupplyCratesPicked", crate, ball, c)
	end
end

function StatHandlers.BallHit(ply, power)
	AddPlayerStat(ply, "BallHit", 1)
	AddPlayerStat(ply, "BallHitPower", power)

	SetPlayerStat(ply, "RingsThisTurn", 0)
	SetPlayerStat(ply, "CratesThisTurn", 0)
end

function StatHandlers.BallHitBall(ball1, ball2)
	AddPlayerStat(ball1:GetOwner(), "BallHitBall", 1)
end

function StatHandlers.BallSunk(cup, ball)
	AddPlayerStat(ball:GetOwner(), "BallSunk", 1)
end

function StatHandlers.OutOfBounds(ball)
	AddPlayerStat(ball:GetOwner(), "OutOfBounds", 1)
end
