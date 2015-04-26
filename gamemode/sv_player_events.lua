function GM:PlayerInitialSpawn(ply)
	-- create the player information
	self:OnPlayerCreated(ply)

	-- spectate
	ply:SetTeam(TEAM_SPECTATOR)

	-- defaults
	ply:SetLoadoutState(LOADOUT_NEW)

	-- check for reconnect
	self:CheckPlayerReconnected(ply)
end

function GM:PlayerSpawn(ply)
	-- this removes the player model issue
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SpectateEntity(NULL)

	-- turn off crosshair
	ply:CrosshairDisable()
	ply:SetMoveType(MOVETYPE_NOCLIP)

	-- handle spectators
	if ply:Team() == TEAM_SPECTATOR then
		timer.Simple(0.5, function()
			if ply:IsBot() then
				GAMEMODE:PlayerRequestTeam(ply, team.BestAutoJoinTeam())
			end
		end)
	end
end

function GM:PlayerReconnected(ply)
	-- dont give them a new loadout
	ply:SetLoadoutState(LOADOUT_RESTORE)
end

function GM:PlayerSelectSpawn(ply)
	-- get random entity and validate
	local ent = self:GetRandomHoleEntity()
	if not IsValid(ent) then
		return self.BaseClass.PlayerSelectSpawn(self, ply)
	end

	-- create a temporary node for them to spawn at
	-- we have to do this to randomize their angle
	local node = ents.Create("info_target")
	node:SetPos(ent:GetPos())
	node:SetAngles(Angle(0, math.random(-180, 180), 0))
	node:Spawn()

	-- delete shortly after they spawn
	SafeRemoveEntityDelayed(node, 1)

	return node
end

function GM:PlayerLoadout(ply)
end

function GM:PlayerDisconnected(ply)
	local ball = ply:GetBall()
	if IsValid(ball) then
		if ball.OnTee then
			-- neuter them
			ball:Remove()

			-- tee next player
			rules.Call("TeePlayer", ply:Team())
		end
	end

	self.BaseClass:PlayerDisconnected(ply)
end

function GM:PlayerDeath(victim, weapon, killer)
end

function GM:PlayerDeathThink(ply)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	return true
end

function GM:CanPlayerSuicide(ply)
	return false
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerSwitchFlashlight(ply, on)
	return false
end

function GM:OnPlayerChangedTeam(ply, oldteam, newteam)
	net.Start("fretta_teamchange")
		net.WriteEntity(ply)
		net.WriteUInt(oldteam, 16)
		net.WriteUInt(newteam, 16)
	net.Broadcast()

	-- why do I need to do this?
	ply:SetMoveType(MOVETYPE_NOCLIP)

	if self:GetRoundState() == ROUND_ACTIVE then
		self:AddToQueue(ply, true)
	end
end

function GM:PlayerCanJoinTeam(ply, teamid)
	local oldteam = ply:Team()

	local state = self:GetRoundState()

	-- first team assignments always allow
	if oldteam == TEAM_SPECTATOR or (state == ROUND_WAITING or state == ROUND_INTERMISSION) then
		-- balance teams
		if team.NumPlayers(teamid) > team.NumPlayers(util.OtherTeam(teamid)) then
			ply:ChatPrint("There are too many players on " .. team.GetName(teamid) .. ".")
			return false
		end

		rules.Call("PlayerJoinedTeam", ply, oldteam, teamid)

		return true
	end

	return false
end

local alltalk = GetConVar("sv_alltalk")
function GM:PlayerCanHearPlayersVoice(ply1, ply2)
	-- obey sv_alltalk
	if alltalk:GetBool() then
		return true
	end

	-- when not active on a hole, let everyone talk
	local state = self:GetRoundState()
	if state ~= ROUND_ACTIVE then
		return true
	end

	return ply1:Team() == ply2:Team()
end

function GM:PlayerSpray(ply)
	return true
end
