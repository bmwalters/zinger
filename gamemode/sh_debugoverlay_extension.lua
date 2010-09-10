
/*------------------------------------
	Trace()
------------------------------------*/
function debugoverlay.Trace( trace, tr, time )

	// main line
	debugoverlay.Line( tr.StartPos, tr.HitPos, time, Color( 0, 255, 0, 255 ) );
	debugoverlay.Line( tr.HitPos, trace.endpos, time, Color( 255, 0, 0, 255 ) );
	
	// start/hit/end
	debugoverlay.Cross( tr.StartPos, 8, time, Color( 40, 40, 40, 255 ) );
	debugoverlay.Cross( tr.HitPos, 8, time, Color( 40, 40, 40, 255 ) );
	debugoverlay.Cross( trace.endpos, 8, time, Color( 40, 40, 40, 255 ) );
	
	// normal
	debugoverlay.Line( tr.HitPos, tr.HitPos + tr.HitNormal * 32, time, Color( 0, 0, 255, 255 ) );
	
	// bounding boxes
	if( trace.mins && trace.maxs ) then
	
		debugoverlay.Box( tr.HitPos, trace.mins, trace.maxs, time, Color( 255, 255, 255, 64 ) );
		debugoverlay.Box( tr.StartPos, trace.mins, trace.maxs, time, Color( 255, 255, 255, 64 ) );
	
	end

end
