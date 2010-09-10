
// course information
local CourseSetup = {};
local CurrentHole = 0;
local CleanupClasses = {};
local IntermissionStart = 0;
GM.CurrentPlayers = 0;
GM.Queue = {};

// modules
require( "stats" );


/*------------------------------------
	GenerateCourse()
------------------------------------*/
function GM:GenerateCourse()

	// clear setup
	CourseSetup = {};
	local TempCourse = {};
	
	// gather cups
	local cups = ents.FindByClass( "zing_cup" );
	for _, cup in pairs( cups ) do
	
		// find out which hole this cup belongs to
		local holeNum = cup:GetHole();
		
		// validate storage
		TempCourse[ holeNum ] = TempCourse[ holeNum ] or {};
		
		// save it
		TempCourse[ holeNum ].Cup = cup;
		TempCourse[ holeNum ].Tee = {};
		TempCourse[ holeNum ].Rings = {};
		TempCourse[ holeNum ].RingCount = 0;
		TempCourse[ holeNum ].SupplyNodes = {};
		TempCourse[ holeNum ].PadEntities = {};
		TempCourse[ holeNum ].AverageSupplyRadius = 0;
	
	end
	
	// gather tees
	local tees = ents.FindByClass( "zing_tee_red" );
	for _, tee in pairs( tees ) do
	
		// find out which hole this tee belongs to
		local holeNum = tee:GetHole();
		
		// validate hole
		if ( TempCourse[ holeNum ] ) then
			
			TempCourse[ holeNum ].Tee[ TEAM_ORANGE ] = tee;
			
		end
	
	end
	local tees = ents.FindByClass( "zing_tee_blue" );
	for _, tee in pairs( tees ) do
	
		// find out which hole this tee belongs to
		local holeNum = tee:GetHole();
		
		// validate hole
		if ( TempCourse[ holeNum ] ) then
			
			TempCourse[ holeNum ].Tee[ TEAM_PURPLE ] = tee;
			
		end
	
	end
		
	// gather rings
	local rings = ents.FindByClass( "zing_ring" );
	rings = table.Add( rings, ents.FindByClass( "zing_ring_air" ) );
	for _, ring in pairs( rings ) do
	
		// find out which hole this ring belongs to
		local holeNum = ring:GetHole();
		
		// validate hole
		if ( TempCourse[ holeNum ] ) then
		
			// add it
			table.insert( TempCourse[ holeNum ].Rings, ring );
			
		end
	
	end
	
	// gather supply nodes
	local nodes = ents.FindByClass( "zing_supply_node" );
	for _, node in pairs( nodes ) do
	
		// find out which hole this node belongs to
		local holeNum = node:GetHole();
		
		// validate hole
		if ( TempCourse[ holeNum ] ) then
		
			// add it
			table.insert( TempCourse[ holeNum ].SupplyNodes, node );
			
		end
	
	end
	
	// gather pads
	local pads = table.Add( ents.FindByClass( "zing_jump_pad" ), ents.FindByClass( "zing_tele_pad" ) );
	for _, pad in pairs( pads ) do
	
		// find out which hole this pad belongs to
		local holeNum = pad:GetHole();
		
		// validate hole
		if ( TempCourse[ holeNum ] ) then
		
			// add it
			table.insert( TempCourse[ holeNum ].PadEntities, pad );
			
		end
	
	end
	
	// iterate through temporary course and add it to the real course table
	// this will fix the issue created when a mapper skips a hole number
	for i = 1, #TempCourse do
	
		// validate
		if ( TempCourse[ i ] ) then
		
			// add it
			table.insert( CourseSetup, TempCourse[ i ] );
		
		end
	
	end
	
	// iterate through each hole and finalize
	for i = #CourseSetup, 1, -1 do
	
		// grab hole
		local hole = CourseSetup[ i ];
		
		// validate amount of tees
		if ( hole.Tee[ TEAM_ORANGE ] && hole.Tee[ TEAM_PURPLE ] ) then
						
			// count rings
			hole.RingCount = #hole.Rings;
			hole.AllEntities = { hole.Tee[ TEAM_ORANGE ], hole.Tee[ TEAM_PURPLE ] };
			table.Add( hole.AllEntities, hole.Rings );
			table.Add( hole.AllEntities, hole.SupplyNodes );
			
		else
		
			// remove hole
			table.remove( CourseSetup, i );
		
		end
	
	end
	
	// setup the first hole
	self:PrepareNextHole();

end


/*------------------------------------
	PrepareNextHole()
------------------------------------*/
function GM:PrepareNextHole()
	
	// increment hole
	CurrentHole = CurrentHole + 1;
	
	// update round controller
	self:SetCurrentHole( CurrentHole );
	self:SetTeamProgress( TEAM_ORANGE, 0 );
	self:SetTeamProgress( TEAM_PURPLE, 0 );
	
	// move the time along
	self:NextSky();
	
	// clear all stats
	self:ClearBattleStats();
	
	// pick the battle rules for this hole
	rules.Clear();
	rules.Pick();
	
	// reset the stats
	stats.Clear();
	
end


/*------------------------------------
	ValidateQueue()
------------------------------------*/
function GM:ValidateQueue( t )

	// validate
	if ( !self.Queue[ t ] ) then
	
		return;
		
	end

	// cycle through queue
	for i = #self.Queue[ t ], 1, -1 do
	
		// get valid player
		local pl = self.Queue[ t ][ i ];
		if ( !IsValid( pl ) || !pl:IsPlayer() || pl:Team() != t ) then
		
			// remove invalid player
			table.remove( self.Queue[ t ], i );
			
		end
		
	end
	
end


/*------------------------------------
	CreateQueues()
------------------------------------*/
function GM:CreateQueues()

	// blank
	self.Queue[ TEAM_ORANGE ] = {};
	self.Queue[ TEAM_PURPLE ] = {};
	
	// queue and assign players a random value
	for _, pl in pairs( player.GetAll() ) do
	
		pl.SortValue = math.random( 1, 9999 );
		if ( pl:Team() == TEAM_ORANGE || pl:Team() == TEAM_PURPLE ) then
		
			self:AddToQueue( pl );
			
		end
		
	end
	
	// get total player count
	self.PlayerCount = #self.Queue[ TEAM_ORANGE ] + #self.Queue[ TEAM_PURPLE ];
	
	// randomize players
	table.sort( self.Queue[ TEAM_ORANGE ], function( a, b ) return ( a.SortValue < b.SortValue ); end );
	table.sort( self.Queue[ TEAM_PURPLE ], function( a, b ) return ( a.SortValue < b.SortValue ); end );
	
end


/*------------------------------------
	AddToQueue()
------------------------------------*/
function GM:AddToQueue( pl, cango )

	// get team and validate queue
	local t = pl:Team();
	self:ValidateQueue( t );

	// make sure they arent already in queue
	if ( table.HasValue( self.Queue[ t ], pl ) ) then
	
		return;
		
	end
	
	// insert into table queue
	table.insert( self.Queue[ t ], pl );

	// go if we can
	if ( cango && #self.Queue[ t ] == 1 ) then
	
		rules.Call( "TeePlayer", pl:Team() );
	
	end

end


/*------------------------------------
	GetTee()
------------------------------------*/
function GM:GetTee( t )

	return CourseSetup[ CurrentHole ].Tee[ t ];

end


/*------------------------------------
	TeeBall()
------------------------------------*/
function GM:TeeBall( ball, safe )

	// restore position
	local tee = GAMEMODE:GetTee( ball:Team() );
	ball:SafePosition( tee:GetPos() + ( tee:GetUp() * ( 20 + ball.Size + 0.5 ) ), true );
	ball:SetAngles( tee:GetAngles() );
	ball.OnTee = true;
	ball.TeedAt = CurTime();
	rules.Call( "BallOnTee", ball );
		
	// reset view
	umsg.Start( "ResetView", ball:GetOwner() );
	umsg.End();
	
	// notify them
	umsg.Start( "TeeTime", ball:GetOwner() );
		umsg.Char( 1 );
	umsg.End();
	
end


/*------------------------------------
	GetQueue()
------------------------------------*/
function GM:GetQueue( t )

	// if no team supplied, return both teams queue
	if ( t == nil || !self.Queue[ t ] ) then
	
		return table.Add( table.Copy( self.Queue[ TEAM_ORANGE ] ), self.Queue[ TEAM_PURPLE ] );
		
	end
	
	return self.Queue[ t ];
	
end


/*------------------------------------
	Cleanup()
------------------------------------*/
function GM:Cleanup()
	
	// clean up all particles!
	for _, e in pairs( ents.GetAll() ) do
	
		e:StopParticles();
		
	end
	
	// check each class
	for _, class in pairs( CleanupClasses ) do
	
		// find all and remove
		for _, e in pairs( ents.FindByClass( class ) ) do
		
			SafeRemoveEntity( e );
			
		end
	
	end
	
	// clean up the course clientside
	umsg.Start( "CleanUp" );
	umsg.End();
	
end


/*------------------------------------
	AddCleanupClass()
------------------------------------*/
function AddCleanupClass( class )

	// make sure it doesnt exist already
	if ( table.HasValue( CleanupClasses, class ) ) then
	
		return;
		
	end
	
	// add to list
	table.insert( CleanupClasses, class )
	
end


/*------------------------------------
	GetRandomHoleEntity()
------------------------------------*/
function GM:GetRandomHoleEntity()

	// get a random entity
	return table.Random( CourseSetup[ CurrentHole ].AllEntities );

end


/*------------------------------------
	GetHoleRings()
------------------------------------*/
function GM:GetHoleRings()

	return CourseSetup[ CurrentHole ].Rings;

end


/*------------------------------------
	GetHolePads()
------------------------------------*/
function GM:GetHolePads()
	
	return CourseSetup[ CurrentHole ].PadEntities;

end


/*------------------------------------
	GetHoleCup()
------------------------------------*/
function GM:GetHoleCup()

	return CourseSetup[ CurrentHole ].Cup;

end


/*------------------------------------
	GetRandomSupplyNode()
------------------------------------*/
function GM:GetRandomSupplyNode()

	if( #CourseSetup[ CurrentHole ].SupplyNodes == 0 ) then
	
		return;
		
	end

	return table.Random( CourseSetup[ CurrentHole ].SupplyNodes );

end


/*------------------------------------
	GetSupplyNodes()
------------------------------------*/
function GM:GetSupplyNodes()

	return CourseSetup[ CurrentHole ].SupplyNodes;

end


/*------------------------------------
	GetMaxHoles()
------------------------------------*/
function GM:GetMaxHoles()

	return #CourseSetup;

end


/*------------------------------------
	AddPoints()
------------------------------------*/
function GM:AddPoints( pl, amt )

	pl:AddFrags( amt );
	self:AddPointsTeam( pl:Team(), amt );

end


/*------------------------------------
	AddPointTeam()
------------------------------------*/
function GM:AddPointsTeam( t, amt )
	
	team.AddScore( t, amt );

end


/*------------------------------------
	StartIntermission()
------------------------------------*/
function GM:StartIntermission()

	IntermissionStart = CurTime();
	self:SetRoundState( ROUND_INTERMISSION );

end


/*------------------------------------
	UpdateGameplay()
------------------------------------*/
function GM:UpdateGameplay()

	local state = self:GetRoundState();
	
	// waiting
	if ( state == ROUND_WAITING ) then
	
		// see if we need to wait for players
		if ( team.NumPlayers( TEAM_ORANGE ) == 0 || team.NumPlayers( TEAM_PURPLE ) == 0 ) then
		
			self:SetRoundEndTime( CurTime() + ( self.GameLength * 60 ) + GAME_WAIT_TIME );
		
		end
		
		// how many seconds left to start
		local waiting = math.floor( self:GetGameTimeLeft() - ( self.GameLength * 60 ) );
		if ( waiting <= 0 ) then
		
			// gooo!
			self:SetRoundEndTime( CurTime() + ( self.GameLength * 60 ) );
			rules.Call( "StartHole" );
		
		end
		
	// active
	elseif ( state == ROUND_ACTIVE ) then
	
		// let the battle rules update
		rules.Call( "Update" );
		
	// intermission
	elseif ( state == ROUND_INTERMISSION ) then
		
		// check if intermisison is over
		if ( CurTime() > IntermissionStart + INTERMISSION_LENGTH ) then
		
			rules.Call( "EndHole" );
		
		end
	
	end

end


/*------------------------------------
	CheckTeamBalance()
------------------------------------*/
function GM:CheckTeamBalance()

	// why fretta! why, do you kill the player when changing teams!?
	
	local highest;
	
	for id, _ in pairs( team.GetAllTeams() ) do
	
		if( id != TEAM_SPECTATOR && team.Joinable( id ) ) then
		
			// found a new highest team?
			if( !highest || team.NumPlayers( id ) > team.NumPlayers( highest ) ) then
			
				highest = id;
				
			elseif( team.NumPlayers( id ) < team.NumPlayers( highest ) ) then
			
				while( team.NumPlayers( id ) < team.NumPlayers( highest ) - 1 ) do
				
					local pl = self:FindLeastCommittedPlayerOnTeam( highest );
					
					// switch their team for the next hole
					pl:SetTeam( id );
					
					// send message
					umsg.Start( "fretta_teamchange" );
						umsg.Entity( pl );
						umsg.Short( highest );
						umsg.Short( id );
					umsg.End();
					
				end
			
			end
		
		end
	
	end

end


/*------------------------------------
	FindLeastCommittedPlayerOnTeam()
------------------------------------*/
function GM:FindLeastCommittedPlayerOnTeam( id )

	local worst;
	
	// find the player with the lowest score on the team
	for _, pl in pairs( team.GetPlayers( id ) ) do
	
		if( !worst || pl:Frags() < worst:Frags() ) then
		
			worst = pl;
		
		end
	
	end
	
	return worst;

end
