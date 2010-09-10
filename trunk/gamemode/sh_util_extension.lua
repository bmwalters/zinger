
/*------------------------------------
	LerpColor()
------------------------------------*/
function LerpColor( percent, colorA, colorB )

	return Color(
		Lerp( percent, colorA.r, colorB.r ),
		Lerp( percent, colorA.g, colorB.g ),
		Lerp( percent, colorA.b, colorB.b ),
		Lerp( percent, colorA.a, colorB.a )
	);

end


/*------------------------------------
	IsBall()
------------------------------------*/
function IsBall( ent )

	return ( IsValid( ent ) && ent.IsBall == true );

end


/*------------------------------------
	IsCrate()
------------------------------------*/
function IsCrate( ent )

	return ( IsValid( ent ) && ent.IsCrate == true );

end


/*------------------------------------
	IsMagnet()
------------------------------------*/
function IsMagnet( ent )

	return ( IsValid( ent ) && ent.IsMagnet == true );

end


/*------------------------------------
	IsCup()
------------------------------------*/
function IsCup( ent )

	return ( IsValid( ent ) && ent.IsCup == true );

end


/*------------------------------------
	IsTee()
------------------------------------*/
function IsTee( ent )

	return ( IsValid( ent ) && ent.IsTee == true );

end


/*------------------------------------
	IsJumpPad()
------------------------------------*/
function IsJumpPad( ent )

	return ( IsValid( ent ) && ent.IsJumpPad == true );

end


/*------------------------------------
	IsTelePad()
------------------------------------*/
function IsTelePad( ent )

	return ( IsValid( ent ) && ent.IsTelePad == true );

end


/*------------------------------------
	IsOOB()
------------------------------------*/
function IsOOB( tr )

	return ( tr.MatType == MAT_SLOSH || ( util.PointContents( tr.HitPos ) & CONTENTS_WATER ) == CONTENTS_WATER || tr.HitSky );

end


/*------------------------------------
	IsWorldTrace()
------------------------------------*/
function IsWorldTrace( tr )

	// assume movetype_push is a brush
	return ( tr.HitWorld || ( IsValid( tr.Entity ) && tr.Entity:GetMoveType() == MOVETYPE_PUSH ) );

end


/*------------------------------------
	Dev()
------------------------------------*/
function Dev()

	return ( GetConVarNumber( "developer" ) > 0 );

end


/*------------------------------------
	dprint()
------------------------------------*/
function dprint( ... )

	if ( !Dev() ) then
	
		return;
		
	end
	
	local s = "~ " .. table.concat( arg, "\t" );
	MsgN( s );
	
end


/*------------------------------------
	InchesToFeet()
------------------------------------*/
function util.InchesToFeet( num )

	local feet = math.floor( num / 12 );
	local inches = num - ( feet * 12 );
	
	local text = ( feet > 0 ) && ( feet .. "'-" ) || "";
	text = text .. inches .. "\"";
	
	return text;

end


/*------------------------------------
	OtherTeam()
------------------------------------*/
function util.OtherTeam( t )

	if ( t == TEAM_ORANGE ) then
	
		return TEAM_PURPLE;
		
	else
	
		return TEAM_ORANGE;
		
	end
	
end


/*------------------------------------
	TraceLine()
------------------------------------*/
local TraceLine = util.TraceLine;
function util.TraceLine( trace )

	local tr = TraceLine( trace );
	
	if( trace.debug ) then
	
		debugoverlay.Trace( trace, tr, trace.duration or 1 );
		
	end

	return tr;
	
end


/*------------------------------------
	TraceHull()
------------------------------------*/
local TraceHull = util.TraceHull;
function util.TraceHull( trace )

	local tr = TraceHull( trace );
	
	if( trace.debug ) then
	
		debugoverlay.Trace( trace, tr, trace.duration or 1 );
		
	end

	return tr;
	
end


/*------------------------------------
	TraceEntity()
------------------------------------*/
local TraceEntity = util.TraceEntity;
function util.TraceEntity( trace, entity )

	local tr = TraceEntity( trace, entity );
	
	if( trace.debug ) then
	
		tr.mins = entity:OBBMins();
		tr.maxs = entity:OBBMaxs();
	
		debugoverlay.Trace( trace, tr, trace.duration or 1 );
		
	end

	return tr;
	
end


/*------------------------------------
	IsSpaceOccupied()
------------------------------------*/
function IsSpaceOccupied( pos, mins, maxs, entity )

	// ensure the area is empty
	local tr = util.TraceHull( {
		start = pos,
		endpos = pos,
		mins = mins,
		maxs = maxs,
		filter = entity,
	} );
	
	return tr.StartSolid;
	
end


/*------------------------------------
	table.RemoveValue
------------------------------------*/
function table.RemoveValue( t, value )

	for i = #t, 1, -1 do
	
		if ( t[ i ] == value ) then
		
			table.remove( i );
			
		end
	
	end

end


/*------------------------------------
	HasBall
------------------------------------*/
function HasBall( pl )

	local ent = pl:GetBall();
	if ( IsBall( ent ) ) then
	
		return true, ent;
		
	end
	
	return false;

end


if ( CLIENT ) then

	/*------------------------------------
		LPHasBall
	------------------------------------*/
	function LPHasBall()
	
		return HasBall( LocalPlayer() );
	
	end
	
	
	/*------------------------------------
		SND
	------------------------------------*/
	function SND( snd )
	
		surface.PlaySound( Sound( snd ) );
	
	end

end
