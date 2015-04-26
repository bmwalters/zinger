local BaseRule = {}

function BaseRule:__index(k)
	return rawget(self, k) or BaseRule[k]
end

function BaseRule:Create()
	local obj = setmetatable({}, self)

	-- defaults
	obj.Name = "Base"
	obj.Description = "none"
	obj.NextCrate = 0
	obj.CrateFrequency = 10
	obj.CrateRatio = 1.5
	obj.CrateLifetime = 60

	return obj
end

function CreateRule()
	return BaseRule:Create()
end

function BaseRule:ResetPlayers()
	-- reset players
	for _, ply in pairs(player.GetAll()) do
		ply:SetStrokes(0)
		ply.Sunk = false
		ply:SetDSP(0)
	end
end

function BaseRule:StartHole()
	-- set round state
	GAMEMODE:SetRoundState(ROUND_ACTIVE)

	-- cleaup junk
	GAMEMODE:Cleanup()

	-- reset players
	rules.Call("ResetPlayer")

	-- create team queues
	GAMEMODE:CreateQueues()

	-- set camera for red team
	local tee = GAMEMODE:GetTee(TEAM_ORANGE)
	for _, ply in pairs(GAMEMODE.Queue[TEAM_ORANGE]) do
		ply:SetCamera(tee)
	end

	-- set camera for blue team
	tee = GAMEMODE:GetTee(TEAM_PURPLE)
	for _, ply in pairs(GAMEMODE.Queue[TEAM_PURPLE]) do
		ply:SetCamera(tee)
	end

	-- add 1 second delay
	timer.Simple(1, function()
		-- start both teams
		rules.Call("TeePlayer", TEAM_ORANGE)
		rules.Call("TeePlayer", TEAM_PURPLE)
	end)

	-- initial crate
	items.SpawnCrate()

	-- start battle music
	net.Start("Zing_BeginBattleMusic")
	net.Broadcast()
end

function BaseRule:TeePlayer(t)
	-- validate queue
	GAMEMODE:ValidateQueue(t)

	-- get valid player
	local ply = GAMEMODE.Queue[t][1]
	if not IsValid(ply) then return end

	-- spawn their ball and position it
	local ball = ply:SpawnBall()
	GAMEMODE:TeeBall(ball)
	ply:SetCamera(ball)

	-- freeze balls (lol blue balls)
	local phys = ball:GetPhysicsObject()
	if IsValid(phys) then
		phys:Sleep()
	end

	ply:SetCanHit(true)

	-- handle bots
	if ply:IsBot() then
		GAMEMODE:BotHit(ply)
	end

	-- remove
	table.remove(GAMEMODE.Queue[t], 1)

	-- handle the players loadout
	if ply:GetLoadoutState() == LOADOUT_NEW then
		rules.Call("Loadout")
	elseif ply:GetLoadoutState() == LOADOUT_RESTORE then
		rules.Call("RestoreLoadout")
	end

	-- clear any flags
	ply:SetLoadoutState(LOADOUT_COMPLETE)
end

function BaseRule:BallHit(ply, power)
	return power
end

function BaseRule:BallOnTee(ball)
end

function BaseRule:FailedToTee(ply, ball)
	util.Explosion(ball:GetPos(), 0)
	SafeRemoveEntity(ball)

	timer.Simple(rules.Call("GetStopTime"), function()
		GAMEMODE:AddToQueue(ply, true)
	end)
end

function BaseRule:Loadout(ply)
end

function BaseRule:RestoreLoadout(ply)
end

function BaseRule:UpdateCrates()
	if GAMEMODE:GetCurrentHole() == 0 then return end

	-- check timer
	if self.NextCrate <= CurTime() then
		self.NextCrate = CurTime() + self.CrateFrequency

		-- calculate how many we need to spawn
		local numCrates = #ents.FindByClass("zing_crate")

		-- spawn a crate if we haevn't reached the limit
		if numCrates < self:MaxCrates() then
			items.SpawnCrate()
		end
	end
end

function BaseRule:CrateSpawned(crate)
	crate:NextThink(CurTime() + self.CrateLifetime)
end

function BaseRule:MaxCrates()
	return math.ceil(math.Clamp(GAMEMODE.CurrentPlayers, 2, 8) * self.CrateRatio)
end

function BaseRule:SupplyCratePicked(crate, ball)
	local ply = ball:GetOwner()

	-- validate crate
	if IsValid(crate) then
		-- add points
		GAMEMODE:AddPoints(ply, POINTS_SUPPLY_CRATE)

		-- send notification
		net.Start("Zing_AddNotfication")
			net.WriteUInt(NOTIFY_CRATE, 4)
			net.WriteEntity(ply)
			net.WriteString(crate.Item.Key)
		net.Send(team.GetPlayers(ply:Team()))
	end
end

function BaseRule:FirstSupplyCratePicked(crate, ball)
end

function BaseRule:MultiSupplyCratesPicked(crate, ball, count)
end

function BaseRule:Update()
	if stats.GetHoleStart() == 0 then return end

	-- local balls = ents.FindByClass("")

	--[[
	-- ignore if we havent started yet
	if not HoleInfo.Started then
		return
	end

	-- ball storage
	local balls = {
		[TEAM_ORANGE] = {},
		[TEAM_PURPLE] = {}
	}

	-- gather all in-play balls
	for _, ply in pairs(player.GetAll()) do
		-- validate
		local ball = ply:GetBall()
		if IsBall(ball) then
			table.insert(balls[ply:Team()], ball)
		end
	end

	-- check if no balls are left
	if #balls[TEAM_ORANGE] + #balls[TEAM_PURPLE] == 0 then
		-- change round state
		self:SetRoundState(ROUND_INTERMISSION)
		HoleInfo.Intermission = CurTime()

		-- has the hole been finished?
		if HoleInfo.BallSunk then
			if HoleInfo.LeastStrokes[TEAM_ORANGE] == 0 then
				-- blue won
				self:AddPointsTeam(TEAM_PURPLE, POINTS_CUP_LEAST_STROKES)
			elseif HoleInfo.LeastStrokes[TEAM_PURPLE] == 0 then
				-- red won
				self:AddPointsTeam(TEAM_ORANGE, POINTS_CUP_LEAST_STROKES)
			elseif HoleInfo.LeastStrokes[TEAM_ORANGE] == HoleInfo.LeastStrokes[TEAM_PURPLE] then
				-- tie
			elseif HoleInfo.LeastStrokes[TEAM_ORANGE] < HoleInfo.LeastStrokes[TEAM_PURPLE] then
				-- red won
				self:AddPointsTeam(TEAM_ORANGE, POINTS_CUP_LEAST_STROKES)
			elseif HoleInfo.LeastStrokes[TEAM_ORANGE] > HoleInfo.LeastStrokes[TEAM_PURPLE] then
				-- blue won
				self:AddPointsTeam(TEAM_PURPLE, POINTS_CUP_LEAST_STROKES)
			end
		end
	end
	]]--
end

function BaseRule:RingPassed(ring, ball)
	local ply = ball:GetOwner()
	if not IsValid(ply) then return end

	ring:EmitSoundTeam(ply:Team(), Sound("zinger/passring.mp3"), 85, 100)

	net.Start("Zing_AddNotfication")
		net.WriteUInt(NOTIFY_RING, 4)
		net.WriteEntity(ply)
		net.WriteEntity(ring)
	net.Send(team.GetPlayers(ply:Team()))
end

function BaseRule:FirstRingPassed(ring, ball)
end

function BaseRule:MultiRingsPassed(ring, ball, count)
end

function BaseRule:PadTouched(pad, ball)
end

function BaseRule:FirstPadTouched(pad, ball)
end

function BaseRule:OutOfBounds(ball)
	ball:OutOfBounds()
end

function BaseRule:BallHitBall(balla, ballb)
end

function BaseRule:BallSunk(cup, ball)
	local ply = ball:GetOwner()
	if not (IsValid(ply) and ply:IsPlayer()) then
		ply:DeactivateViewModel()
		ball:Remove()
		return
	end

	-- update camera
	ply:SetCamera(cup)

	-- destroy ball
	ply:DeactivateViewModel()
	ply:SetBall(NULL)

	net.Start("Zing_AddNotfication")
		net.WriteUInt(NOTIFY_SINKCUP, 4)
		net.WriteEntity(ply)
		net.WriteEntity(cup)
	net.Broadcast()

	-- update Sunk flag
	ply.Sunk = true

	-- play sound
	cup:EmitSound(Sound("zinger/ballsunk.mp3"), 100, 100)
end

function BaseRule:EnableHit(ply, ball)
	ply:SetCanHit(true)

	-- handle bots
	if ply:IsBot() then
		timer.Simple(math.random(0, 3), function()
			if IsValid(ply) then
				GAMEMODE:BotHit(ply)
			end
		end)
	end
end

function BaseRule:GetStopTime()
	return 2
end

function BaseRule:CanBallSink(ball)
	return GAMEMODE:GetTeamProgress(ball:Team()) == 1
end

function BaseRule:CanTeamSink(t)
	return GAMEMODE:GetTeamProgress(t) == 1
end

function BaseRule:EndHole()
	if GAMEMODE:GetCurrentHole() >= GAMEMODE:GetMaxHoles() then
		rules.Call("EndMatch")
		return
	end

	-- start next hole
	GAMEMODE:PrepareNextHole()

	rules.Call("StartHole")
end

function BaseRule:EndMatch()
	-- game is over, start a vote
	GAMEMODE:StartGamemodeVote()
end
