-- course information
local CourseSetup = {}
local CurrentHole = 0
local CleanupClasses = {}
local IntermissionStart = 0
GM.CurrentPlayers = 0
GM.Queue = {}

require("stats")

function GM:GenerateCourse()
	-- clear setup
	CourseSetup = {}
	local TempCourse = {}

	for k, v in pairs(ents.GetAll()) do
		-- gather cups
		if v:GetClass() == "zing_cup" then
			-- find out which hole this cup belongs to
			local holeNum = v:GetHole()

			TempCourse[holeNum] = TempCourse[holeNum] or {}

			TempCourse[holeNum].Cup = v
			TempCourse[holeNum].Tee = {}
			TempCourse[holeNum].Rings = {}
			TempCourse[holeNum].RingCount = 0
			TempCourse[holeNum].SupplyNodes = {}
			TempCourse[holeNum].PadEntities = {}
			TempCourse[holeNum].AverageSupplyRadius = 0

			print("Found cup of hole: "..holeNum)
		end
	end

	for k, v in pairs(ents.GetAll()) do
		-- gather tees
		if v:GetClass() == "zing_tee_red" then
			-- find out which hole this tee belongs to
			local holeNum = v:GetHole()

			if TempCourse[holeNum] then
				TempCourse[holeNum].Tee[TEAM_ORANGE] = v
			end
		end
		if v:GetClass() == "zing_tee_blue" then
			-- find out which hole this tee belongs to
			local holeNum = v:GetHole()

			if TempCourse[holeNum] then
				TempCourse[holeNum].Tee[TEAM_PURPLE] = v
			end
		end

		-- gather rings
		if v:GetClass() == "zing_ring" or v:GetClass() == "zing_ring_air" then
			-- find out which hole this ring belongs to
			local holeNum = v:GetHole()

			if TempCourse[holeNum] then
				local ringents = TempCourse[holeNum].Rings
				ringents[#ringents + 1] = v
			end
		end

		-- gather supply nodes
		if v:GetClass() == "zing_supply_node" then
			-- find out which hole this node belongs to
			local holeNum = v:GetHole()

			if TempCourse[holeNum] then
				local nodeents = TempCourse[holeNum].SupplyNodes
				nodeents[#nodeents + 1] = v
			end
		end

		-- gather pads
		if v:GetClass() == "zing_jump_pad" or v:GetClass() == "zing_tele_pad" then
			-- find out which hole this pad belongs to
			local holeNum = v:GetHole()

			if TempCourse[holeNum] then
				local padents = TempCourse[holeNum].PadEntities
				padents[#padents + 1] = v
			end
		end
	end

	-- iterate through temporary course and add it to the real course table
	-- this will fix the issue created when a mapper skips a hole number
	for i = 1, #TempCourse do
		if TempCourse[i] then
			CourseSetup[#CourseSetup + 1] = TempCourse[i]
		end
	end

	-- iterate through each hole and finalize
	for i = #CourseSetup, 1, -1 do
		local hole = CourseSetup[i]

		-- validate amount of tees
		if hole.Tee[TEAM_ORANGE] and hole.Tee[TEAM_PURPLE] then
			-- count rings
			hole.RingCount = #hole.Rings
			hole.AllEntities = {hole.Tee[TEAM_ORANGE], hole.Tee[TEAM_PURPLE]}
			table.Add(hole.AllEntities, hole.Rings)
			table.Add(hole.AllEntities, hole.SupplyNodes)
		else
			-- remove hole
			table.remove(CourseSetup, i)
		end
	end

	-- setup the first hole
	self:PrepareNextHole()
end

function GM:PrepareNextHole()
	-- increment hole
	CurrentHole = CurrentHole + 1

	-- update round controller
	self:SetCurrentHole(CurrentHole)
	self:SetTeamProgress(TEAM_ORANGE, 0)
	self:SetTeamProgress(TEAM_PURPLE, 0)

	-- move the time along
	self:NextSky()

	-- clear all stats
	self:ClearBattleStats()

	-- pick the battle rules for this hole
	rules.Clear()
	rules.Pick()

	-- reset the stats
	stats.Clear()
end

function GM:ValidateQueue(t) -- hmm
	if not self.Queue[t] then return end

	-- cycle through queue
	for i = #self.Queue[t], 1, -1 do
		-- get valid player
		local ply = self.Queue[t][i]
		if not (IsValid(ply) and ply:IsPlayer() and ply:Team() == t) then
			-- remove invalid player
			table.remove(self.Queue[t], i)
		end
	end
end

function GM:CreateQueues()
	self.Queue[TEAM_ORANGE] = {}
	self.Queue[TEAM_PURPLE] = {}

	-- queue and assign players a random value
	for _, ply in pairs(player.GetAll()) do
		if ply:Team() == TEAM_ORANGE or ply:Team() == TEAM_PURPLE then
			self:AddToQueue(ply)
		end
	end

	-- get total player count
	self.PlayerCount = #self.Queue[TEAM_ORANGE] + #self.Queue[TEAM_PURPLE]

	-- randomize players
	table.sort(self.Queue[TEAM_ORANGE], function(a, b) return math.random(1, 2) == 1 end)
	table.sort(self.Queue[TEAM_PURPLE], function(a, b) return math.random(1, 2) == 1 end)
end

function GM:AddToQueue(ply, cango)
	-- get team and validate queue
	local t = ply:Team()
	self:ValidateQueue(t)

	-- make sure they arent already in queue
	if table.HasValue(self.Queue[t], ply) then
		return
	end

	-- insert into table queue
	table.insert(self.Queue[t], ply)

	-- go if we can
	if cango and #self.Queue[t] == 1 then
		rules.Call("TeePlayer", ply:Team())
	end
end

function GM:GetTee(t)
	return CourseSetup[CurrentHole].Tee[t]
end

function GM:TeeBall(ball, safe)
	-- restore position
	local tee = GAMEMODE:GetTee(ball:Team())
	ball:SafePosition(tee:GetPos() + (tee:GetUp() * (20 + ball.Size + 0.5)), true)
	ball:SetAngles(tee:GetAngles())
	ball.OnTee = true
	ball.TeedAt = CurTime()
	rules.Call("BallOnTee", ball)

	-- reset view
	net.Start("Zing_ResetView")
	net.Send(ball:GetOwner())

	-- notify them
	net.Start("Zing_TeeTime")
		net.WriteBit(1)
	net.Send(ball:GetOwner())
end

function GM:GetQueue(t)
	-- if no team supplied, return both teams queue
	if not (t and self.Queue[t]) then
		return table.Add(table.Copy(self.Queue[TEAM_ORANGE]), self.Queue[TEAM_PURPLE])
	end

	return self.Queue[t]
end

function GM:Cleanup()
	-- clean up all particles and ents in cleanupclasses
	for _, e in pairs(ents.GetAll()) do
		e:StopParticles()
		if CleanupClasses[e:GetClass()] then
			SafeRemoveEntity(e)
		end
	end

	-- clean up the course clientside
	net.Start("Zing_Cleanup")
	net.Broadcast()
end

function AddCleanupClass(class)
	-- add to list
	CleanupClasses[class] = true
end

function GM:GetRandomHoleEntity()
	local holeents = CourseSetup[CurrentHole].AllEntities
	return holeents[math.random(1, #holeents)]
end

function GM:GetHoleRings()
	return CourseSetup[CurrentHole].Rings
end

function GM:GetHolePads()
	return CourseSetup[CurrentHole].PadEntities
end

function GM:GetHoleCup()
	return CourseSetup[CurrentHole].Cup
end

function GM:GetRandomSupplyNode()
	local nodes = CourseSetup[CurrentHole].SupplyNodes
	if #nodes == 0 then return end

	return nodes[math.random(1, #nodes)]
end

function GM:GetSupplyNodes()
	return CourseSetup[CurrentHole].SupplyNodes
end

function GM:GetMaxHoles()
	return #CourseSetup
end

function GM:AddPoints(ply, amt)
	ply:AddFrags(amt)
	self:AddPointsTeam(ply:Team(), amt)
end

function GM:AddPointsTeam(t, amt)
	team.AddScore(t, amt)
end

function GM:StartIntermission()
	IntermissionStart = CurTime()
	self:SetRoundState(ROUND_INTERMISSION)
end

function GM:UpdateGameplay()
	local state = self:GetRoundState()

	-- waiting
	if state == ROUND_WAITING then
		-- see if we need to wait for players
		if team.NumPlayers(TEAM_ORANGE) == 0 or team.NumPlayers(TEAM_PURPLE) == 0 then
			self:SetRoundEndTime(CurTime() + (self.GameLength * 60) + GAME_WAIT_TIME)
		end

		-- how many seconds left to start
		local waiting = math.floor(self:GetGameTimeLeft() - (self.GameLength * 60))
		if waiting <= 0 then
			-- gooo!
			self:SetRoundEndTime(CurTime() + (self.GameLength * 60))
			rules.Call("StartHole")
		end
	-- active
	elseif state == ROUND_ACTIVE then
		-- let the battle rules update
		rules.Call("Update")
	-- intermission
	elseif state == ROUND_INTERMISSION then
		-- check if intermisison is over
		if CurTime() > IntermissionStart + INTERMISSION_LENGTH then
			rules.Call("EndHole")
		end
	end
end

function GM:CheckTeamBalance()
	-- why, fretta! why, do you kill the player when changing teams!?
	local highest

	for id, _ in pairs(team.GetAllTeams()) do
		if id ~= TEAM_SPECTATOR and team.Joinable(id) then
			-- found a new highest team?
			if (not highest) or team.NumPlayers(id) > team.NumPlayers(highest) then
				highest = id
			elseif team.NumPlayers(id) < team.NumPlayers(highest) then
				while team.NumPlayers(id) < team.NumPlayers(highest) - 1 do
					local ply = self:FindLeastCommittedPlayerOnTeam(highest)
					-- switch their team for the next hole
					ply:SetTeam(id)

					-- send message
					net.Start("fretta_teamchange")
						net.WriteEntity(pl)
						net.WriteUInt(highest, 16)
						net.WriteUInt(id, 16)
					net.Broadcast()
				end
			end
		end
	end
end

function GM:FindLeastCommittedPlayerOnTeam(t)
	local worst

	-- find the player with the lowest score on the team
	for _, ply in pairs(team.GetPlayers(t)) do
		if (not worst) or ply:Frags() < worst:Frags() then
			worst = pl
		end
	end

	return worst
end
