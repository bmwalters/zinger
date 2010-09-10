
// server only 
if ( CLIENT ) then return; end

// start module
module( 'stats', package.seeall );

// handlers table
local StatHandlers = {};
local MatchStats = {};
local HoleStats = {};


/*------------------------------------
	Clear()
------------------------------------*/
function Clear()
	
	// reset hole stats
	HoleStats = {};
	
end


/*------------------------------------
	GetHoleStart()
------------------------------------*/
function GetHoleStart()

	return ( HoleStats.Started or 0 );
	
end


/*------------------------------------
	Call()
------------------------------------*/
function Call( name, ... )

	//dprint( "Stat Event", name );
	
	// validate event
	if ( StatHandlers[ name ] ) then
	
		dprint( "Stat Event", name );
	
		StatHandlers[ name ]( unpack( arg ) );
	
	end
	
end


/*------------------------------------
	AddStat()
------------------------------------*/
function AddStat( name, amt )

	MatchStats[ name ] = ( MatchStats[ name ] or 0 ) + amt;
	HoleStats[ name ] = ( HoleStats[ name ] or 0 ) + amt;

end


/*------------------------------------
	GetHoleStat()
------------------------------------*/
function GetHoleStat( name )
	
	return ( HoleStats[ name ] or 0 );

end


/*------------------------------------
	AddPlayerStat()
------------------------------------*/
function AddPlayerStat( pl, name, amt )

	MatchStats.Players = MatchStats.Players or {};
	MatchStats.Players[ pl ] = MatchStats.Players[ pl ] or {};
	MatchStats.Players[ pl ][ name ] = ( MatchStats.Players[ pl ][ name ] or 0 ) + amt;
	
	HoleStats.Players = HoleStats.Players or {};
	HoleStats.Players[ pl ] = HoleStats.Players[ pl ] or {};
	HoleStats.Players[ pl ][ name ] = ( HoleStats.Players[ pl ][ name ] or 0 ) + amt;

end


/*------------------------------------
	SetPlayerStat()
------------------------------------*/
function SetPlayerStat( pl, name, amt )
	
	HoleStats.Players = HoleStats.Players or {};
	HoleStats.Players[ pl ] = HoleStats.Players[ pl ] or {};
	HoleStats.Players[ pl ][ name ] = amt;

end


/*------------------------------------
	GetPlayerStat()
------------------------------------*/
function GetPlayerStat( pl, name )
	
	HoleStats.Players = HoleStats.Players or {};
	return ( HoleStats.Players[ pl ][ name ] or 0 );
	
end


/*------------------------------------
	StartHole()
------------------------------------*/
function StatHandlers.StartHole()

	HoleStats.Started = CurTime();
	HoleStats.TotalRings = #GAMEMODE:GetHoleRings();
	
end


/*------------------------------------
	CrateSpawned()
------------------------------------*/
function StatHandlers.CrateSpawned( ent )

	AddStat( "CratesSpawned", 1 );
	
end


/*------------------------------------
	RingPassed()
------------------------------------*/
function StatHandlers.RingPassed( ring, ball )

	local pl = ball:GetOwner();
	
	if ( GetHoleStat( "RingsPassed" .. pl:Team() ) + GetHoleStat( "RingsPassed" .. util.OtherTeam( pl:Team() ) ) == 0 ) then
	
		rules.Call( "FirstRingPassed", ring, ball );
	
	end
	
	AddStat( "RingsPassed" .. pl:Team(), 1 );
	AddPlayerStat( pl, "RingsPassed", 1 );
	AddPlayerStat( pl, "RingsThisTurn", 1 );
	
	local c = GetPlayerStat( pl, "RingsThisTurn" );
	if ( c > 1 ) then
	
		rules.Call( "MultiRingsPassed", ring, ball, c );
	
	end
	
	GAMEMODE:SetTeamProgress( pl:Team(), math.Clamp( GetHoleStat( "RingsPassed" .. pl:Team() ) / HoleStats.TotalRings, 0, 1 ) );
	
end


/*------------------------------------
	PadTouched()
------------------------------------*/
function StatHandlers.PadTouched( pad, ball )

	local pl = ball:GetOwner();
	
	if ( GetHoleStat( "PadsTouched" .. pl:Team() ) + GetHoleStat( "PadsTouched" .. util.OtherTeam( pl:Team() ) ) == 0 ) then
	
		rules.Call( "FirstPadTouched", pad, ball );
	
	end
	
	AddStat( "PadsTouched" .. pl:Team(), 1 );
	AddPlayerStat( pl, "PadsTouched", 1 );
	
end


/*------------------------------------
	SupplyCratePicked()
------------------------------------*/
function StatHandlers.SupplyCratePicked( crate, ball )

	local pl = ball:GetOwner();

	if ( GetHoleStat( "SupplyCratesPicked" .. pl:Team() ) + GetHoleStat( "SupplyCratesPicked" .. util.OtherTeam( pl:Team() ) ) == 0 ) then
	
		rules.Call( "FirstSupplyCratePicked", crate, ball );
	
	end
	
	AddStat( "SupplyCratesPicked" .. pl:Team(), 1 );
	AddPlayerStat( pl, "SupplyCratesPicked", 1 );
	AddPlayerStat( pl, "CratesThisTurn", 1 );
	
	local c = GetPlayerStat( pl, "CratesThisTurn" );
	if ( c > 1 ) then
	
		rules.Call( "MultiSupplyCratesPicked", crate, ball, c );
	
	end
	
end


/*------------------------------------
	BallHit()
------------------------------------*/
function StatHandlers.BallHit( pl, power )
	
	AddPlayerStat( pl, "BallHit", 1 );
	AddPlayerStat( pl, "BallHitPower", power );
	
	SetPlayerStat( pl, "RingsThisTurn", 0 );
	SetPlayerStat( pl, "CratesThisTurn", 0 );
	
end


/*------------------------------------
	BallHitBall()
------------------------------------*/
function StatHandlers.BallHitBall( balla, ballb )
	
	AddPlayerStat( balla:GetOwner(), "BallHitBall", 1 );
	
end


/*------------------------------------
	BallSunk()
------------------------------------*/
function StatHandlers.BallSunk( cup, ball )
	
	AddPlayerStat( ball:GetOwner(), "BallSunk", 1 );
	
end


/*------------------------------------
	OutOfBounds()
------------------------------------*/
function StatHandlers.OutOfBounds( ball )
	
	local pl = ball:GetOwner();
	
	AddPlayerStat( pl, "OutOfBounds", 1 );
	
end
