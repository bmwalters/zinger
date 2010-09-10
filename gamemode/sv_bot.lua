
local BallMins = Vector( -10, -10, -10 );
local BallMaxs = Vector( 10, 10, 10 );

/*------------------------------------
	BotAdjustGoal()
------------------------------------*/
function GM:BotAdjustGoal( ball, goal )

	local pad = self:BotFindPad( ball, goal );
	if( IsValid( pad ) ) then
	
		return pad;
		
	end
	
	return goal;
	
end


/*------------------------------------
	BotFindPad()
------------------------------------*/
function GM:BotFindPad( ball, goal, ignore, ignoreLOS )

	local pads = self:GetHolePads();
	
	local ballPos = ball:GetPos();
	local goalPos = goal:GetPos();
	
	local winningPad = NULL;
	local distanceToBeat = ( ignore ) and math.huge or ( ballPos - goalPos ):Length();
	
	// see if a pad will get closer to the goal than we can if we hit directly
	for _, pad in pairs( pads ) do
	
		local pos = pad:GetPos();
		local target = pad:GetDestination();
		
		local dist1 = ( pos - ballPos ):Length();
		local dist2 = ( target - goalPos ):Length();
		local dist3 = ( target - ballPos ):Length();
		
		// did we beat the distance?
		if( ( dist1 + dist2 ) < distanceToBeat && dist3 > dist1 ) then
	
			if( ignoreLOS || ( !ignoreLOS && self:BotCheckLOS( ballPos, pos, { ball, pad } ) ) ) then
			
				distanceToBeat = ( dist1 + dist2 );
				winningPad = pad;
			
			end
	
		end
		
	end
	
	return winningPad;

end


/*------------------------------------
	BotCalculateStroke()
------------------------------------*/
function GM:BotCalculateStroke( ball )

	local rings = self:GetHoleRings();
	local pads = self:GetHolePads();
	
	local ballPos = ball:GetPos();
	
	local closestStroke = nil;
	local closestGoal = NULL;
	local closestDist = math.huge;
	
	local runnerUp = {};
	
	// they can get to the cup
	if( rules.Call( "CanBallSink", ball ) ) then

		local cup = self:GetHoleCup();
		local cupPos = cup:GetPos();
		local dist = ( cupPos - ballPos ):Length();
		
		// visible cup?
		if( self:BotCheckLOS( ballPos, cupPos, { ball, cup } ) ) then
		
			if( dist <= closestDist ) then
	
				closestDist = dist;
				closestGoal = cup;
				
			end
			
		else
			
			// find a pad that'll get us there?
			local pad = self:BotFindPad( ball, cup, true, true );
			if( IsValid( pad ) ) then
			
				local padPos = pad:GetPos();
				local dist = ( padPos - ballPos ):Length();
				if( self:BotCheckLOS( ballPos, padPos, { ball, pad } ) ) then
				
					if( dist <= closestDist ) then
			
						closestDist = dist;
						closestGoal = pad;
						
					end
				
				else
				
					table.insert( runnerUp, pad );
				
				end
			
			else

				table.insert( runnerUp, cup );
				
			end
			
		end
	
	else
		
		// find the closest visible ring
		for _, ring in pairs( rings ) do
		
			// ignore rings that are activated already
			if( !ring:IsTeamDone( ball:Team() ) ) then
			
				local ringPos = ring:GetPos();
				local dist = ( ringPos - ballPos ):Length();
				if( dist <= closestDist ) then
				
					if( ring:IsInGround() ) then
					
						// visible?
						if( self:BotCheckLOS( ballPos, ringPos, { ball, ring } ) ) then
							
							closestDist = dist;
							closestGoal = ring;
							
						else
						
							// find a pad that'll get us there?
							local pad = self:BotFindPad( ball, ring, true, true );
							if( IsValid( pad ) ) then
							
								local padPos = pad:GetPos();
								local dist = ( padPos - ballPos ):Length();
								if( self:BotCheckLOS( ballPos, padPos, { ball, pad } ) ) then
								
									if( dist <= closestDist ) then
							
										closestDist = dist;
										closestGoal = pad;
										
									end
								
								else
								
									table.insert( runnerUp, pad );
								
								end
							
							else

								table.insert( runnerUp, ring );
								
							end

						end
						
					else
					
						// find a pad that goes through this ring thats visible
						for _, pad in pairs( pads ) do
						
							if( IsJumpPad( pad ) ) then
							
								local padPos = pad:GetPos();
								local apex = pad:GetApexPosition();
								
								local apexDist = ( apex - ringPos ):Length();
								local dist = ( padPos - ballPos ):Length();
								
								// goes through?
								if( apexDist <= 48 ) then
								
									// visible?
									if( self:BotCheckLOS( ballPos, padPos, { ball, pad } ) ) then
									
										closestDist = dist;
										closestGoal = pad;
										
									else
									
										table.insert( runnerUp, pad );

									end
								
								end
							
							end
						
						end

					end
					
				end

			end
		
		end
		
	end
	
	
	local stroke = {};
	
	// if we have no goal see if a runner up can be obtained via jump pad
	if( !IsValid( closestGoal ) ) then
	
		// can a jump pad get us to any of the runners up?
		for i = #runnerUp, 1, -1 do
		
			local goal = runnerUp[ i ];
		
			// find a pad that'll get us there?
			local pad = self:BotFindPad( ball, goal, true, true );
			if( IsValid( pad ) ) then
			
				local padPos = pad:GetPos();
				local dist = ( padPos - ballPos ):Length();
				if( self:BotCheckLOS( ballPos, padPos, { ball, pad } ) ) then
				
					if( dist <= closestDist ) then
			
						closestDist = dist;
						closestGoal = pad;
						
					end
					
					table.remove( runnerUp, i );
					
				else
				
					table.insert( runnerUp, pad );
				
				end
				
			end
		
		end
		
	end
		
	
	// found a visible goal?
	if( IsValid( closestGoal ) ) then
	
		// adjust goal using pads
		closestGoal = self:BotAdjustGoal( ball, closestGoal );
		
	//	debugoverlay.Line( ballPos, closestGoal:GetPos(), 1, Color( 0, 0, 128 ) );
	
		// calculate stroke direction
		local dir = ( closestGoal:GetPos() - ballPos );
		local dist = dir:Length();
		dir.z = 0;
		dir:Normalize();
		
		stroke.dir = dir;
		stroke.power = math.min( ( ( 8 / BOT_STROKE_STRENGTH ) * dist ), 100 );
		
	else
	
		closestDist = math.huge;
		
		// will a single stroke get us to our goal?
		for i = #runnerUp, 1, -1 do
		
			local goal = runnerUp[ i ];
			
			local attemptedStroke = self:BotTryStroke( ball, goal );
			if( attemptedStroke ) then
			
				local goalPos = goal:GetPos();
				local dist = ( goalPos - ballPos ):Length();
				
				if( dist <= closestDist ) then
		
					closestDist = dist;
					closestStroke = attemptedStroke;
					
				end
			
			end
			
		end
		
		if( closestStroke ) then
		
			return closestStroke;
			
		else
		
			// random stroke
			local angle = math.rad( math.random( 0, 360 ) );
		
			stroke.dir = Vector( math.cos( angle ), math.sin( angle ), 0 );
			stroke.power = math.random( 10, 60 );
			
		end
		
	end
	
	return stroke;
	
end


/*------------------------------------
	IsOverGround()
------------------------------------*/
local function IsOverGround( pos )

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos - Vector( 0, 0, 15 ),
	} );
	
	return tr.Hit;

end


/*------------------------------------
	BotTryStroke()
------------------------------------*/
function GM:BotTryStroke( ball, goal )

	local ballPos = ball:GetPos();
	local goalPos = goal:GetPos();

	local power = math.random( 10, 40 );
	local dist = power * ( BOT_STROKE_STRENGTH / 8 ) * 1.05;
	
	local closestStroke = nil;
	local closestDistance = math.huge;

	// go around in a 360 degree circle looking for a stroke that'll make the goal visible to us
	for i = 0, 360, 22.5 do
	
		local angle = math.rad( i );
		local dir = Vector( math.cos( angle ), math.sin( angle ), 0 );
		
		local tr = util.TraceHull( {
			start = ballPos,
			endpos = ballPos + dir * dist,
			filter = { ball, goal },
			mins = BallMins,
			maxs = BallMaxs,
		} );
		
		if( IsOverGround( tr.HitPos ) ) then
		
			debugoverlay.Line( tr.StartPos, tr.HitPos, 1, color_white );
			
			// is the goal visible from the newly selected area?
			if( self:BotCheckLOS( tr.HitPos, goalPos, { ball, goal } ) ) then
			
				local dist = ( tr.HitPos - goalPos ):Length();
				if( dist <= closestDistance ) then
					
					local stroke = {};
					stroke.dir = dir;
					stroke.power = power;
					
					closestStroke = stroke;
					closestDistance = dist;
					
				end
				
			/*
			else
			
				local dot = tr.HitNormal:Dot( tr.Normal * -1 );
				local reflect = ( 2 * tr.HitNormal * dot ) + tr.Normal;
			
				// one ricochet
				local trBounce = util.TraceHull( {
					start = tr.HitPos,
					endpos = tr.HitPos + reflect * dist * ( 1 - tr.Fraction ),
					filter = { ball, goal },
					mins = BallMins,
					maxs = BallMaxs,
				} );
			
				if( IsOverGround( trBounce.HitPos ) ) then
				
					debugoverlay.Line( tr.StartPos, tr.HitPos, 1, color_white );
				
					// goal visible?
					if( self:BotCheckLOS( trBounce.HitPos, goalPos, { ball, goal } ) ) then
	
						local dist = ( trBounce.HitPos - goalPos ):Length();
						if( dist <= closestDistance ) then
						
							debugoverlay.Line( trBounce.StartPos, trBounce.HitPos, 1, color_white );
					
							local stroke = {};
							stroke.dir = dir;
							stroke.power = power;
							
							closestStroke = stroke;
							closestDistance = dist;
							
						end
						
					end
					
				end
			*/
			
			end
			
		end
	
	end
	
	return closestStroke, closestDistance;

end


/*------------------------------------
	BotCheckLOS()
------------------------------------*/
function GM:BotCheckLOS( from, to, filter )

	local dir = ( to - from );
	local dist = dir:Length();
	
	// only allow level traces
	dir.z = 0;
	dir:Normalize();
	
	// see if the target is visible
	local tr = util.TraceHull( {
		start = from,
		endpos = from + dir * dist,
		mask = MASK_NPCSOLID,
		filter = filter,
		mins = BallMins,
		maxs = BallMaxs,
		//debug = true,
	} );
	if( tr.Fraction == 1 ) then
	
		local dir = tr.Normal;
		local dist = ( tr.HitPos - tr.StartPos ):Length() / 16;
	
		// this is a sad way to check if we're traversing water :(
		// would be better to check the middle
		// then if that fails divide and check the next two middles
		// lazy solution
		for i = 1, 16 do
		
			local pos = tr.StartPos + dir * dist * i;
			local tr = util.TraceLine( {
				start = pos,
				endpos = pos + Vector( 0, 0, -2048 ),
				mask = MASK_WATER,
			} );
			local tr2 = util.TraceLine( {
				start = pos,
				endpos = pos + Vector( 0, 0, -2048 ),
				mask = MASK_NPCWORLDSTATIC,
			} );
			if( tr2.HitSky || tr.Fraction < tr2.Fraction ) then
			
				return false;
				
			end
		
		end
	
		return true;
		
	end
	
	return false;

end


/*------------------------------------
	BotHit()
------------------------------------*/
function GM:BotHit( bot )

	// yea bots shouldn't hit in midair
	if( !bot:CanHit() ) then
	
		return;
		
	end

	local ball = bot:GetBall();

	// find the best stroke for the ball to take
	local stroke = self:BotCalculateStroke( bot:GetBall() );
	
	// add some noise to the stroke ( makes it more human )
	stroke.dir = ( stroke.dir + VectorRand() * math.random() * 0.025 ):GetNormal();
	stroke.dir.z = 0;
	stroke.power = math.Clamp( stroke.power + math.Rand( -10, 10 ), 5, 100 );
	
	// show the stroke
	local dist = stroke.power * ( BOT_STROKE_STRENGTH / 8 ) * 1.05;
	debugoverlay.Line( ball:GetPos(), ball:GetPos() + stroke.dir * dist, 1, Color( 0, 128, 0 ) );

	bot:HitBall( stroke.dir, stroke.power );

end