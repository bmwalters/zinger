
local BaseRule = {};

/*------------------------------------
	Create()
------------------------------------*/
function BaseRule:Create()

	local obj = table.Inherit( {}, self );
	
	setmetatable( obj, self );
	
	// defaults
	obj.Name = "Base";
	obj.Description = "none";
	obj.NextCrate = 0;
	obj.CrateFrequency = 10;
	obj.CrateRatio = 1.5
	obj.CrateLifetime = 60;
	
	return obj;

end


/*------------------------------------
	CreateRule()
------------------------------------*/
function CreateRule()

	return BaseRule:Create();

end


/*------------------------------------
	ResetPlayers()
------------------------------------*/
function BaseRule:ResetPlayers()

	// reset players
	for _, pl in pairs( player.GetAll() ) do
	
		pl:SetStrokes( 0 );
		pl.Sunk = false;
		pl:SetDSP( 0 );
	
	end
	
end


/*------------------------------------
	StartHole()
------------------------------------*/
function BaseRule:StartHole()

	// set round state
	GAMEMODE:SetRoundState( ROUND_ACTIVE );
	
	// cleaup junk
	GAMEMODE:Cleanup();
	
	// reset players
	rules.Call( "ResetPlayer" );
	
	// create team queues
	GAMEMODE:CreateQueues();
	
	// set camera for red team
	local tee = GAMEMODE:GetTee( TEAM_ORANGE );
	for _, pl in pairs( GAMEMODE.Queue[ TEAM_ORANGE ] ) do
	
		pl:SetCamera( tee );
	
	end
	
	// set camera for blue team
	tee = GAMEMODE:GetTee( TEAM_PURPLE );
	for _, pl in pairs( GAMEMODE.Queue[ TEAM_PURPLE ] ) do
	
		pl:SetCamera( tee );
	
	end
	
	// add 1 second delay
	timer.Simple( 1, function()
	
		// start both teams
		rules.Call( "TeePlayer", TEAM_ORANGE );
		rules.Call( "TeePlayer", TEAM_PURPLE );
		
	end );
	
	// initial crate
	items.SpawnCrate();
	
	// start battle music
	umsg.Start( "BeginBattleMusic" );
	umsg.End();
	
end


/*------------------------------------
	TeePlayer()
------------------------------------*/
function BaseRule:TeePlayer( t )
	
	// validate queue
	GAMEMODE:ValidateQueue( t );
	
	// get valid player
	local pl = GAMEMODE.Queue[ t ][ 1 ];
	if ( !IsValid( pl ) ) then
	
		return;
		
	end
	
	// spawn their ball and position it
	local ball = pl:SpawnBall();
	GAMEMODE:TeeBall( ball );
	pl:SetCamera( ball );
	
	// freeze balls (lol blue balls)
	local phys = ball:GetPhysicsObject();
	if ( IsValid( phys ) ) then
		
		phys:Sleep();
	
	end
	
	// enable hitting
	pl:SetCanHit( true );
	
	// handle bots
	if ( pl:IsBot() ) then
	
		GAMEMODE:BotHit( pl );
	
	end
	
	// remove
	table.remove( GAMEMODE.Queue[ t ], 1 );
	
	// handle the players loadout
	if ( pl:GetLoadoutState() == LOADOUT_NEW ) then
	
		rules.Call( "Loadout" );
		
	elseif ( pl:GetLoadoutState() == LOADOUT_RESTORE ) then
	
		rules.Call( "RestoreLoadout" );
		
	end
	
	// clear any flags
	pl:SetLoadoutState( LOADOUT_COMPLETE );
	
end


/*------------------------------------
	BallHit()
------------------------------------*/
function BaseRule:BallHit( pl, power )

	return power;
	
end


/*------------------------------------
	BallOnTee()
------------------------------------*/
function BaseRule:BallOnTee( ball )
end


/*------------------------------------
	FailedToTee()
------------------------------------*/
function BaseRule:FailedToTee( pl, ball )

	util.Explosion( ball:GetPos(), 0 );
	SafeRemoveEntity( ball );
	
	timer.Simple( rules.Call( "GetStopTime" ), function()
	
		GAMEMODE:AddToQueue( pl, true );
		
	end );
	
end


/*------------------------------------
	Loadout()
------------------------------------*/
function BaseRule:Loadout( pl )
end


/*------------------------------------
	RestoreLoadout()
------------------------------------*/
function BaseRule:RestoreLoadout( pl )
end


/*------------------------------------
	UpdateCrates()
------------------------------------*/
function BaseRule:UpdateCrates()

	if( GAMEMODE:GetCurrentHole() == 0 ) then
	
		return;
		
	end
	
	// check timer
	if( self.NextCrate <= CurTime() ) then
	
		// delay timer
		self.NextCrate = CurTime() + self.CrateFrequency;
		
		// calculate how many we need to spawn
		local numCrates = #ents.FindByClass( "zing_crate" );
		
		// spawn a crate if we haevn't reached the limit
		if( numCrates < self:MaxCrates() ) then
		
			items.SpawnCrate();
			
		end
	
	end
	
end


/*------------------------------------
	CrateSpawned()
------------------------------------*/
function BaseRule:CrateSpawned( crate )

	crate:NextThink( CurTime() + self.CrateLifetime );

end


/*------------------------------------
	MaxCrates()
------------------------------------*/
function BaseRule:MaxCrates()

	return math.ceil( math.Clamp( GAMEMODE.CurrentPlayers, 2, 8 ) * self.CrateRatio );

end


/*------------------------------------
	SupplyCratePicked()
------------------------------------*/
function BaseRule:SupplyCratePicked( crate, ball )

	local pl = ball:GetOwner();
	
	// validate crate
	if ( IsValid( crate ) ) then
	
		// add points
		GAMEMODE:AddPoints( pl, POINTS_SUPPLY_CRATE );
		
		// send notification
		umsg.Start( "AddNotfication", util.TeamOnlyFilter( pl:Team() ) );
			umsg.Char( NOTIFY_CRATE );
			umsg.Entity( pl );
			umsg.String( crate.Item.Key );
		umsg.End();
		
	end
	
end


/*------------------------------------
	FirstSupplyCratePicked()
------------------------------------*/
function BaseRule:FirstSupplyCratePicked( crate, ball )
end


/*------------------------------------
	MultiSupplyCratesPicked()
------------------------------------*/
function BaseRule:MultiSupplyCratesPicked( crate, ball, count )
end


/*------------------------------------
	Update()
------------------------------------*/
function BaseRule:Update()

	if ( stats.GetHoleStart() == 0 ) then
	
		return;
		
	end
	
	//local balls = ents.FindByClass( "
	
	/*
	// ignore if we havent started yet
	if ( !HoleInfo.Started ) then
	
		return;
		
	end
	
	// ball storage
	local balls = {
		[ TEAM_ORANGE ] = {},
		[ TEAM_PURPLE ] = {}
	}
	
	// gather all in-play balls
	for _, pl in pairs( player.GetAll() ) do
	
		// validate
		local ball = pl:GetBall();
		if ( IsBall( ball ) ) then
		
			table.insert( balls[ pl:Team() ], ball );
		
		end
	
	end
	
	// check if no balls are left
	if ( #balls[ TEAM_ORANGE ] + #balls[ TEAM_PURPLE ] == 0 ) then
	
		// change round state
		self:SetRoundState( ROUND_INTERMISSION );
		HoleInfo.Intermission = CurTime();
		
		// has the hole been finished?
		if ( HoleInfo.BallSunk ) then
		
			if ( HoleInfo.LeastStrokes[ TEAM_ORANGE ] == 0 ) then
			
				// blue won
				self:AddPointsTeam( TEAM_PURPLE, POINTS_CUP_LEAST_STROKES );
				
			elseif ( HoleInfo.LeastStrokes[ TEAM_PURPLE ] == 0 ) then
			
				// red won
				self:AddPointsTeam( TEAM_ORANGE, POINTS_CUP_LEAST_STROKES );
				
			elseif ( HoleInfo.LeastStrokes[ TEAM_ORANGE ] == HoleInfo.LeastStrokes[ TEAM_PURPLE] ) then
			
				// tie
				
			elseif ( HoleInfo.LeastStrokes[ TEAM_ORANGE ] < HoleInfo.LeastStrokes[ TEAM_PURPLE ] ) then
			
				// red won
				self:AddPointsTeam( TEAM_ORANGE, POINTS_CUP_LEAST_STROKES );
				
			elseif ( HoleInfo.LeastStrokes[ TEAM_ORANGE ] > HoleInfo.LeastStrokes[ TEAM_PURPLE ] ) then	
			
				// blue won
				self:AddPointsTeam( TEAM_PURPLE, POINTS_CUP_LEAST_STROKES );
			
			end
		
		end
	
	end
	*/
end


/*------------------------------------
	RingPassed()
------------------------------------*/
function BaseRule:RingPassed( ring, ball )

	// validate owner
	local pl = ball:GetOwner();
	if ( !IsValid( pl ) ) then
	
		return;
	
	end
	
	// play sound
	ring:EmitSoundTeam( pl:Team(), Sound( "zinger/passring.mp3" ), 85, 100 );
	
	umsg.Start( "AddNotfication", util.TeamOnlyFilter( pl:Team() ) );
		umsg.Char( NOTIFY_RING );
		umsg.Entity( pl );
		umsg.Entity( ring );
	umsg.End();

end


/*------------------------------------
	FirstRingPassed()
------------------------------------*/
function BaseRule:FirstRingPassed( ring, ball )
end


/*------------------------------------
	MultiRingsPassed()
------------------------------------*/
function BaseRule:MultiRingsPassed( ring, ball, count )
end


/*------------------------------------
	PadTouched()
------------------------------------*/
function BaseRule:PadTouched( pad, ball )
end


/*------------------------------------
	FirstPadTouched()
------------------------------------*/
function BaseRule:FirstPadTouched( pad, ball )
end


/*------------------------------------
	OutOfBounds()
------------------------------------*/
function BaseRule:OutOfBounds( ball )
	
	ball:OutOfBounds();

end


/*------------------------------------
	BallHitBall()
------------------------------------*/
function BaseRule:BallHitBall( balla, ballb )
end


/*------------------------------------
	BallSunk()
------------------------------------*/
function BaseRule:BallSunk( cup, ball )

	// validate owner
	local pl = ball:GetOwner();
	if ( !IsValid( pl ) || !pl:IsPlayer() ) then
	
		pl:DeactivateViewModel();
		ball:Remove();
		return;
	
	end
	
	// update camera
	pl:SetCamera( cup );
	
	// destroy ball
	pl:DeactivateViewModel();
	pl:SetBall( NULL );
	
	umsg.Start( "AddNotfication" );
		umsg.Char( NOTIFY_SINKCUP );
		umsg.Entity( pl );
		umsg.Entity( cup );
	umsg.End();
	
	// update Sunk flag
	pl.Sunk = true;
	
	// play sound
	cup:EmitSound( Sound( "zinger/ballsunk.mp3" ), 100, 100 );
	
end


/*------------------------------------
	EnableHit()
------------------------------------*/
function BaseRule:EnableHit( pl, ball )
	
	// enable flag
	pl:SetCanHit( true );
	
	// handle bots
	if ( pl:IsBot() ) then
	
		timer.Simple( math.random( 0, 3 ), function()
		
			if ( IsValid( pl ) ) then
			
				GAMEMODE:BotHit( pl );
				
			end
		
		end );
	
	end
	
end


/*------------------------------------
	GetStopTime()
------------------------------------*/
function BaseRule:GetStopTime()

	return 2;

end


/*------------------------------------
	CanBallSink()
------------------------------------*/
function BaseRule:CanBallSink( ball )

	return ( GAMEMODE:GetTeamProgress( ball:Team() ) == 1 );
	
end


/*------------------------------------
	CanTeamSink()
------------------------------------*/
function BaseRule:CanTeamSink( t )

	return ( GAMEMODE:GetTeamProgress( t ) == 1 );
	
end


/*------------------------------------
	EndHole()
------------------------------------*/
function BaseRule:EndHole()

	if ( GAMEMODE:GetCurrentHole() >= GAMEMODE:GetMaxHoles() ) then
	
		rules.Call( "EndMatch" );
		return;
	
	end

	// start next hole
	GAMEMODE:PrepareNextHole();
	
	rules.Call( "StartHole" );

end


/*------------------------------------
	EndMatch()
------------------------------------*/
function BaseRule:EndMatch()

	// game is over, start a vote
	GAMEMODE:StartGamemodeVote();

end
