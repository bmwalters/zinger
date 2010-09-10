
/*------------------------------------
	math.sign()
------------------------------------*/
function math.sign( num )
	
	if( num < 0 ) then
	
		return -1;
		
	elseif( num > 0 ) then
	
		return 1;
		
	end
	
	return 0;
	
end


/*------------------------------------
	math.EaseOutElastic()
------------------------------------*/
function math.EaseOutElastic( t, a, p )

	return 1 - math.EaseInElastic( 1 - t, a, p );

end


/*------------------------------------
	math.EaseInElastic()
------------------------------------*/
function math.EaseInElastic( t, a, p )

	local s;
	
	p = p or 0.45;

	if( t <= 0 || t >= 1 ) then
	
		return t;
		
	end
	
	if( !a || a < 1 ) then
	
		a = 1;
		s = p / 4;
		
	else
	
		s = p / ( 2 * math.pi ) * math.asin( 1 / a );
	
	end
		
	t = t - 1;
	return -( a * math.pow( 2, 10 * t ) * math.sin( ( t - s ) * ( 2 * math.pi ) / p ) );

end


/*------------------------------------
	math.EaseInOutElastic()
------------------------------------*/
function math.EaseInOutElastic( t, a, p )

	if( t < 0.5 ) then
	
		return 0.5 * math.EaseInElastic( 2 * t, a, p );
		
	end
	
	return 0.5 * ( 1 + math.EaseOutElastic( 2 * t - 1, a, p ) );

end


/*------------------------------------
	math.EaseOutBounce()
------------------------------------*/
function math.EaseOutBounce( t )

	if( t < ( 1 / 2.75 ) ) then
	
		return 7.5625 * t * t;
		
	elseif( t < ( 2 / 2.75 ) ) then
	
		t = t - ( 1.5 / 2.75 );
		return ( 7.5625 * t ) * t + 0.75;
		
	elseif( t < ( 2.5 / 2.75 ) ) then
	
		t = t - ( 2.25 / 2.75 );
		return ( 7.5625 * t ) * t + 0.9375;
		
	else
	
		t = t - ( 2.625 / 2.75 );
		return ( 7.5625 * t ) * t + 0.984375;
		
	end

end


/*------------------------------------
	math.EaseInBounce()
------------------------------------*/
function math.EaseInBounce( t )

	return 1 - math.EaseOutBounce( 1 - t );

end


/*------------------------------------
	math.EaseInOutBounce()
------------------------------------*/
function math.EaseInOutBounce( t )

	if( t < 0.5 ) then
	
		return 0.5 * math.EaseInBounce( 2 * t );
		
	end
	
	return 0.5 * ( 1 + math.EaseOutBounce( 2 * t - 1 ) );

end


/*------------------------------------
	math.EaseOutBack()
------------------------------------*/
function math.EaseOutBack( t, s )

	s = s or 1.70158;

	t = 1 - t;
	
	return 1 - t * t * ( ( s + 1 ) * t - s );

end


/*------------------------------------
	math.LerpNoClamp()
------------------------------------*/
function math.LerpNoClamp( t, a, b )

	return a + t * ( b - a );

end


/*------------------------------------
	KNOT()
------------------------------------*/
local function KNOT( i, tinc )

	return ( i - 3 ) * tinc;
	
end


/*------------------------------------
	math.calcBSplineN()
------------------------------------*/
function math.calcBSplineN( i, k, t, tinc )

	if ( k == 1 ) then
	
		if ( ( KNOT( i, tinc ) <= t ) && ( t < KNOT( i + 1, tinc ) ) ) then
		
			return 1;
			
		else
		
			return 0;
			
		end
		
	else
		local ft = ( t - KNOT( i, tinc ) ) * math.calcBSplineN( i, k - 1, t, tinc );
		local fb = KNOT( i + k - 1, tinc ) - KNOT( i, tinc );

		local st = ( KNOT( i + k, tinc ) - t ) * math.calcBSplineN( i + 1, k - 1, t, tinc );
		local sb = KNOT( i + k, tinc ) - KNOT( i + 1, tinc );
		
		local first = 0;
		local second = 0;

		if ( fb > 0 ) then
		
			first = ft / fb;
			
		end
		if ( sb > 0 ) then
		
			second = st / sb;
			
		end

		return first + second;
		
	end
	
end


/*------------------------------------
	math.BSplinePoint()
------------------------------------*/
function math.BSplinePoint( tDiff, tPoints, tMax )
	
	local Q = Vector( 0, 0, 0 );
	local tinc = tMax / ( table.getn( tPoints ) - 3 );
	
	tDiff = tDiff + tinc;
	
	for idx, pt in pairs( tPoints ) do
	
		local n = math.calcBSplineN( idx, 4, tDiff, tinc );
		Q = Q + (n * pt);
		
	end
	
	return Q;
	
end


/*------------------------------------
	RayIntersectSphere()
------------------------------------*/
function math.RayIntersectSphere( startPos, rayDir, spherePos, sphereRadius )

	local dst = startPos - spherePos;
	local b = dst:Dot( rayDir );
	local c = dst:Dot( dst ) - ( sphereRadius * sphereRadius );
	local d = b * b - c;
	
	if( d > 0 ) then
	
		return true, ( -b - math.sqrt( d ) );
		
	end
	
	return false;

end
