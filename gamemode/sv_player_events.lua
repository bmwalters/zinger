
/*------------------------------------
	PlayerInitialSpawn()
------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	// create the player information
	self:OnPlayerCreated( pl );
		
	// spectate
	pl:SetTeam( TEAM_SPECTATOR );
	
	// defaults
	pl:SetLoadoutState( LOADOUT_NEW );
	
	// check for reconnect
	self:CheckPlayerReconnected( pl );

end


/*------------------------------------
	PlayerSpawn()
------------------------------------*/
function GM:PlayerSpawn( pl )
	
	// this removes the player model issue
	pl:Spectate( OBS_MODE_ROAMING );
	pl:SpectateEntity( NULL );
	
	// turn off crosshair
	pl:CrosshairDisable();
	pl:SetMoveType( MOVETYPE_NOCLIP );
	
	// handle spectators
	if ( pl:Team() == TEAM_SPECTATOR ) then
		
		timer.Simple( 0.5, function()
		
			if ( pl:IsBot() ) then
		
				GAMEMODE:PlayerRequestTeam( pl, team.BestAutoJoinTeam() );
				
			end
		
		end );
		
	end

end


/*------------------------------------
	PlayerReconnected()
------------------------------------*/
function GM:PlayerReconnected( pl )

	// dont give them a new loadout
	pl:SetLoadoutState( LOADOUT_RESTORE );
	
end


/*------------------------------------
	PlayerSelectSpawn()
------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	// get random entity and validate
	local ent = self:GetRandomHoleEntity();
	if ( !IsValid( ent ) ) then
	
		return self.BaseClass.PlayerSelectSpawn( self, pl );
		
	end
	
	// create a temporary node for them to spawn at
	// we have to do this to randomize their angle
	local node = ents.Create( "info_target" );
	node:SetPos( ent:GetPos() );
	node:SetAngles( Angle( 0, math.random( -180, 180 ), 0 ) );
	node:Spawn();
	
	// delete shortly after they spawn
	SafeRemoveEntityDelayed( node, 1 );
	
	return node;

end


/*------------------------------------
	PlayerLoadout()
------------------------------------*/
function GM:PlayerLoadout( pl )
end


/*------------------------------------
	PlayerDisconnected()
------------------------------------*/
function GM:PlayerDisconnected( pl )

	local ball = pl:GetBall();
	if( IsValid( ball ) ) then
	
		if( ball.OnTee ) then
		
			// neuter them ;)
			ball:Remove();
			
			// tee next player
			rules.Call( "TeePlayer", pl:Team() );
		
		end
	
	end

	// base class
	self.BaseClass:PlayerDisconnected( pl );

end


/*------------------------------------
	PlayerDeath()
------------------------------------*/
function GM:PlayerDeath( victim, weapon, killer )
end


/*------------------------------------
	PlayerDeathThink()
------------------------------------*/
function GM:PlayerDeathThink( pl )
end


/*------------------------------------
	DoPlayerDeath()
------------------------------------*/
function GM:DoPlayerDeath( pl, attacker, dmginfo )
end


/*------------------------------------
	PlayerShouldTakeDamage()
------------------------------------*/
function GM:PlayerShouldTakeDamage( pl, attacker )
	
	return true;
	
end


/*------------------------------------
	CanPlayerSuicide()
------------------------------------*/
function GM:CanPlayerSuicide( pl )
	
	return false;
	
end


/*------------------------------------
	PlayerDeathSound()
------------------------------------*/
function GM:PlayerDeathSound()

	return true;
	
end


/*------------------------------------
	PlayerSwitchFlashlight()
------------------------------------*/
function GM:PlayerSwitchFlashlight( pl, on )
	
	return false;
	
end


/*------------------------------------
	OnPlayerChangedTeam()
------------------------------------*/
function GM:OnPlayerChangedTeam( pl, oldteam, newteam )

	// send message
	umsg.Start( "fretta_teamchange" );
		umsg.Entity( pl );
		umsg.Short( oldteam );
		umsg.Short( newteam );
	umsg.End();
	
	// why do I need to do this?
	pl:SetMoveType( MOVETYPE_NOCLIP );
	
	if ( self:GetRoundState() == ROUND_ACTIVE ) then
	
		self:AddToQueue( pl, true );
	
	end
	
end


/*------------------------------------
	PlayerCanJoinTeam()
------------------------------------*/
function GM:PlayerCanJoinTeam( pl, teamid )

	// store old team
	local oldteam = pl:Team();
	
	// get round state
	local state = self:GetRoundState();
	
	// first team assignments always allow
	if ( oldteam == TEAM_SPECTATOR || ( state == ROUND_WAITING || state == ROUND_INTERMISSION ) ) then
	
		// balance teams
		if ( team.NumPlayers( teamid ) > team.NumPlayers( util.OtherTeam( teamid ) ) ) then
		
			pl:ChatPrint( "There are too many players on " .. team.GetName( teamid ) .. "." );
			return false;
		
		end
		
		rules.Call( "PlayerJoinedTeam", pl, oldteam, teamid );
		
		return true;
		
	end
	
	return false;
	
end


/*------------------------------------
	PlayerCanHearPlayersVoice()
------------------------------------*/
function GM:PlayerCanHearPlayersVoice( pla, plb )

	// obey sv_alltalk
	if( GetConVarNumber( "sv_alltalk" ) != 0 ) then
	
		return true;
		
	end
	
	// when not active on a hole, let everyone talk
	local state = self:GetRoundState();
	if ( state != ROUND_ACTIVE ) then
	
		return true;
	
	end
	
	return ( pla:Team() == plb:Team() );
	
end


/*------------------------------------
	PlayerSpray()
------------------------------------*/
function GM:PlayerSpray( pl )

	return true;

end
