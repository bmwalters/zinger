
/*------------------------------------
	 GetCursorTrace()
------------------------------------*/
local function GetCursorTrace( pl )

	local pos = pl:GetShootPos();
	local dir = pl:GetCursorVector();
	
	return util.TraceLine( {
		start = pos,
		endpos = pos + ( dir * 2048 )
	} );

end


/*------------------------------------
	SpawnEntity()
------------------------------------*/
local function SpawnEntity( pl, class, model )

	// pretty much ripped from sandbox

	// get position and trace
	local pos = pl:GetShootPos();
	local trace = GetCursorTrace( pl );
	
	// attempt to create
	local ent = ents.Create( class );
	if ( !IsValid( ent ) ) then
	
		return;
		
	end
	
	// setup entity
	ent:SetModel( model );
	ent:SetAngles( vector_origin );
	ent:SetPos( trace.HitPos );
	ent:Spawn();
	ent:Activate();
	
	// find flush position
	local flush = trace.HitPos - ( trace.HitNormal * 512 );
		flush = ent:NearestPoint( flush );
		flush = ent:GetPos() - flush;
		flush = trace.HitPos + flush;
		
	// set position
	ent:SetPos( flush );
	
	return ent
	
end


/*------------------------------------
	ZingerDebug()
------------------------------------*/
local function ZingerDebug( pl, cmd, args )

	// just some basic debug shit
	
	// super admins only
	if ( !pl:IsSuperAdmin() || args[ 1 ] == nil || !Dev() ) then
	
		return;
		
	end
	
	// grab action
	local action = string.lower( args[ 1 ] or "" );
	
	// particle tests
	if ( action == "testparticle" ) then
	
		local trace = GetCursorTrace( pl );
		ParticleEffect( args[ 2 ] or "", trace.HitPos + ( trace.HitNormal * 24 ), vector_origin, pl );
		
	// effect tests
	elseif ( action == "testeffect" ) then
	
		local trace = GetCursorTrace( pl );
		
		local effect = EffectData();
		effect:SetOrigin( trace.HitPos + trace.HitNormal * 24 );
		effect:SetNormal( trace.HitNormal );
		util.Effect( args[ 2 ] or "", effect );
		
	// effect tests
	elseif ( action == "spawnent" ) then
	
		local trace = GetCursorTrace( pl );
		
		local ent = ents.Create( args[ 2 ] );
		ent:Spawn();
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z );
		
	// effect tests
	elseif ( action == "fish" ) then
	
		local trace = GetCursorTrace( pl );
		
		local ent = ents.Create( "func_fish_pool" );
		ent:SetKeyValue( "max_range", "200" );
		ent:SetKeyValue( "fish_count", "10" );
		ent:SetKeyValue( "model", "models/zinger/butterfly.mdl" );
		ent:SetPos( trace.HitPos - trace.HitNormal * 32 );
		ent:Spawn();
		ent:Activate();

	// match start
	elseif ( action == "forcestart" ) then
	
		rules.Call( "StartHole" );
		
	// next hole
	elseif ( action == "forcenext" ) then
	
		GAMEMODE:PrepareNextHole();
		rules.Call( "StartHole" );

	// give all item
	elseif ( action == "giveall" ) then
	
		// give all items
		for _, item in pairs( items.GetAll() ) do
		
			inventory.Give( pl, item, tonumber( args[ 2 ] ) );
		
		end
	
	// give item
	elseif ( action == "give" ) then
	
		// find item
		local item = items.Get( args[ 2 ] );
		if ( !item ) then
		
			return;
			
		end
		
		inventory.Give( pl, item, tonumber( args[ 3 ] ) );
		
	// spawn model
	elseif ( action == "spawnmodel" ) then
	
		// validate model
		local model = args[ 2 ];
		if ( !util.IsValidModel( model ) ) then
		
			return;
			
		end
		
		// spawn
		SpawnEntity( pl, "prop_physics", model );
		
	// used for updating the websites (we're lazy)
	elseif ( action == "dumpitems" ) then
	
		// bbcode or html
		local bbcode = ( args[ 2 ] == "bbcode" );
		
		// opening element
		local itemdata = ( ( !bbcode ) && "<ul>\n" || "[list]\n" );
		
		// iterate through all the items
		for _, item in pairs( GAMEMODE:GetItems() ) do
		
			// add to list
			itemdata = itemdata .. ( ( !bbcode ) && "<li>" || "[*]" );
			itemdata = itemdata .. item.Name .. " - " .. item.Description;
			itemdata = itemdata .. ( ( !bbcode ) && "</li>\n" || "\n" );
		
		end
		
		// closing element
		itemdata = itemdata .. ( ( !bbcode ) && "</ul>\n" || "[/list]\n" );
		
		// write to file
		file.Write( "zingeritems.txt", itemdata );
		
	// activate rings
	elseif ( action == "rings" ) then
	
		// activate all rings
		local rings = GAMEMODE:GetHoleRings();
		for _, ring in pairs( rings ) do
		
			rules.Call( "RingPassed", ring, pl:GetBall() );
		
		end
		
	// change sky
	elseif ( action == "sky" ) then
	
		// get time
		local time = args[ 2 ];
		if ( time == "dawn" ) then
		
			GAMEMODE:SetSky( SKY_DAWN );
		
		elseif ( time == "day" ) then
		
			GAMEMODE:SetSky( SKY_DAY );
		
		elseif ( time == "dusk" ) then
		
			GAMEMODE:SetSky( SKY_DUSK );
		
		elseif ( time == "night" ) then
		
			GAMEMODE:SetSky( SKY_NIGHT );
		
		end
		
	// suicide
	elseif ( action == "suicide" ) then
	
		rules.Call( "OutOfBounds", pl:GetBall() );
		
	end

end
concommand.Add( "zd", ZingerDebug );


/*------------------------------------
	HitCommand()
------------------------------------*/
local function HitCommand( pl, cmd, args )
	
	// validate ball
	local ball = pl:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
		
	// not ready to hit
	elseif ( !pl:CanHit() ) then
	
		return;
		
	end
	
	// validate round state
	if ( GAMEMODE:GetRoundState() != ROUND_ACTIVE ) then
	
		return;
		
	end

	// get the direction
	local dir = Vector( tonumber( args[ 1 ] ), tonumber( args[ 2 ] ), 0 );
	
	// get power
	local power = math.Clamp( tonumber( args[ 3 ] ) or 0, 0, 100 );
	
	// when the player is on the tee, make sure they've hit it
	// hard enough to get the ball off
	if ( ball.OnTee ) then
	
		power = math.max( power, 5 );
		
	end
	
	// hit
	pl:HitBall( dir, power );
	
end
concommand.Add( "hit", HitCommand );


/*------------------------------------
	SprayCommand()
------------------------------------*/
local function SprayCommand( pl, cmd, args )

	// validate ball
	local ball = pl:GetBall();
	if( !IsBall( ball ) ) then
	
		return;
		
	end
		
	local pos = ball:GetPos();

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos - Vector( 0, 0, 48 ),
		mask = MASK_SOLID_BRUSHONLY,
		filter = ball,
	} );
	if( tr.Hit ) then

		if( pl.NextSprayTime <= CurTime() ) then
		
			pl.NextSprayTime = CurTime() + GetConVarNumber( "decalfrequency" );
			
			// sound
			WorldSound( Sound( "SprayCan.Paint" ), ball:GetPos(), 100, 100 );
			
			// decal
			pl:SprayDecal( tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal );

		end
		
	end
	
end
concommand.Add( "spray", SprayCommand );


/*------------------------------------
	ItemCommand()
------------------------------------*/
local function ItemCommand( pl, cmd, args )

	// validate ball
	local ball = pl:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
		
	end
	
	// validate round state
	if ( GAMEMODE:GetRoundState() != ROUND_ACTIVE ) then
	
		return;
		
	end
	
	// grab action
	local action = string.lower( args[ 1 ] or "" );
		
	// equipping
	if( action == "equip" ) then
	
		local item = items.Get( args[ 2 ] );
		if( item ) then
		
			inventory.Equip( pl, item );

		end
	
	// unequipping
	elseif( action == "unequip" ) then
	
		inventory.Unequip( pl );
	
	// using
	elseif( action == "use" ) then
	
		if ( ball.OnTee ) then
	
			return;
			
		end
		
		inventory.Activate( pl );
	
	end
	
end
concommand.Add( "item", ItemCommand );
