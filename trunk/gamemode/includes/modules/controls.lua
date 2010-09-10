
// client only 
if ( SERVER ) then return; end

// start module
module( 'controls', package.seeall );


// variables
local CurrentView;
local LastCamera;
local ViewGestureX;
local ViewGestureY;
local ViewAngle = Angle( 0, 0, 0 );
local ViewDistance;
local HitStarted;
local HitDirection;
local HitPower = -1;
local PowerSound;
local BallMins = Vector( -BALL_SIZE, -BALL_SIZE, -1 );
local BallMaxs = Vector( BALL_SIZE, BALL_SIZE, 1 );
local GroundTraceSize = Vector( 0, 0, BALL_SIZE * BALL_SIZE );

// materials
local WhiteMaterial = CreateMaterial( "White", "UnlitGeneric", {
	[ "$basetexture" ] = "color/white",
	[ "$vertexcolor" ] = "1",
	[ "$vertexalpha" ] = "1",
	[ "$nocull" ] = "1",
} );


/*------------------------------------
	ClearHitGesture()
------------------------------------*/
local function ClearHitGesture( pl )
	
	// clear values
	HitStarted = nil;
	HitDirection = nil;
	HitPower = -1;
	
	// validate sound
	if ( PowerSound ) then

		// stop it
		PowerSound:Stop();
		
	end
	
end



/*------------------------------------
	Update()
------------------------------------*/
function Update( pl )
	
	// validate camera
	local camera = pl:GetCamera();
	if ( !IsValid( camera ) ) then
	
		return;
		
	end
	
	// changing view angle
	if ( InViewGesture() ) then
		
		// get mouse position
		local x, y = gui.MousePos();
		
		// modify view based on mouse movement
		ViewAngle.Pitch = ViewAngle.Pitch - ( ( y - ViewGestureY ) * ( GetConVarNumber( "m_pitch" ) * 8 ) );
		ViewAngle.Yaw = ViewAngle.Yaw - ( ( x - ViewGestureX ) * ( GetConVarNumber( "m_yaw" ) * 6 ) );
		
		// update mouse position
		ViewGestureX, ViewGestureY = gui.MousePos();
	
	end
	
	// balls only (lol)
	if ( !IsBall( camera ) ) then
	
		return;
		
	end
	
	// update hit
	if ( InHitGesture() ) then
		
		local normal = Vector( 0, 0, 1 );
		local distance = normal:Dot( camera:GetPos() );
		local pickingPos = CurrentView.origin;
		pl:SetFOV( CurrentView.fov );
		local pickingRay = pl:GetCursorAimVector();
		
		// intersect picking ray with the ball hit plane
		local denom = normal:Dot( pickingRay );
		if ( denom == 0 ) then
		
			return;
			
		end
		local rayDistance = -( normal:Dot( pickingPos ) - distance ) / denom;
		local hitPos = pickingPos + pickingRay * rayDistance;
		
		// calculate direction
		local diff = ( camera:GetPos() - hitPos );
		local dist = diff:Length();
		local dir = diff:GetNormal();
		
		// save direction
		HitDirection = dir;
		
		// calculate power
		local center = camera:GetPos():ToScreen();
		center = Vector( center.x, center.y, 0 );
		local mouse = Vector( gui.MouseX(), gui.MouseY(), 0 );
		diff = ( center - mouse );
		dist = diff:Length();
		
		local _, size = camera:GetPos2D();
		
		// save power
		HitPower = math.floor( math.Clamp( ( dist - size ) / ( ScrH() * 0.3 ), 0.01, 1 ) * 100 );
		
		// power clicks every even number
		if ( HitPower % 2 == 1 ) then
		
			PowerSound:ChangePitch( 100 + ( ( HitPower * 0.01 ) * 50 ) );
			
		end
		
	end
	
end


/*------------------------------------
	GetPower()
------------------------------------*/
function GetPower()

	return HitPower or -1;

end


/*------------------------------------
	GetDistance()
------------------------------------*/
function GetDistance()

	return ViewDistance or 0;

end


/*------------------------------------
	SetDistance()
------------------------------------*/
function SetDistance( val )
	
	ViewDistance = val;

end


/*------------------------------------
	MoveDistance()
------------------------------------*/
function MoveDistance( diff )
	
	// modify distance
	ViewDistance = ViewDistance + ( -diff * 40 );

end


/*------------------------------------
	OnViewGesture()
------------------------------------*/
function OnViewGesture( pl, down )

	// validate camera
	local camera = pl:GetCamera();
	if ( !IsValid( camera ) ) then
	
		return;
		
	end
	
	// cancelling hit
	if ( HitDirection != nil ) then
	
		// clear
		ClearHitGesture( pl );
		surface.PlaySound( Sound( "ui/buttonclickrelease.wav" ) );
	
	end
	
	// starting
	if ( down ) then
	
		// store mouse position
		ViewGestureX, ViewGestureY = gui.MousePos();
		
	// stopping
	else
	
		// clear
		ViewGestureX = nil;
		ViewGestureY = nil;
	
	end

end



/*------------------------------------
	OnHitGesture()
------------------------------------*/
function OnHitGesture( pl, down )

	// ignore
	if ( !down || !pl.dt.CanHit ) then
	
		return;
		
	end
	
	// validate ball
	local ball = pl:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
		
	end
	
	// starting
	if ( !InHitGesture() ) then
		
		local center, size = ball:GetPos2D();
		
		// get the mouse position
		local mx, my = gui.MousePos();
		
		// check if they clicked the ball
		if ( math.abs( mx - center.x ) > size || math.abs( my - center.y ) > size ) then
		
			return;
			
		end
		
		// check for sound
		if ( !PowerSound ) then
		
			// create it
			PowerSound = CreateSound( pl, Sound( "buttons/lightswitch2.wav" ) );
		
		end
		
		// play
		PowerSound:PlayEx( 0.2, 100 );
		PowerSound:ChangeVolume( 0.2 );
		
		// start hit
		HitStarted = CurTime();
		
	// stopping
	else
	
		// slow down quick clicks (most are mistakes)
		if ( CurTime() - HitStarted < 0.15 ) then
		
			return;
			
		end
		
		// hit their ball
		RunConsoleCommand( "hit", HitDirection.x, HitDirection.y, HitPower );
		
		// clear
		ClearHitGesture( pl );
	
	end

end


/*------------------------------------
	InHitGesture()
------------------------------------*/
function InHitGesture()

	// check
	return ( HitStarted != nil );

end


/*------------------------------------
	InViewGesture()
------------------------------------*/
function InViewGesture()

	// check
	return ( ViewGestureX != nil && ViewGestureY != nil );

end


/*------------------------------------
	IsValid()
------------------------------------*/
function IsValid()

	// check
	return ( CurrentView != nil );

end


/*------------------------------------
	GetViewAngles()
------------------------------------*/
function GetViewAngles()

	return CurrentView.angles;

end


/*------------------------------------
	GetViewFOV()
------------------------------------*/
function GetViewFOV()

	return CurrentView.fov;

end


/*------------------------------------
	GetViewPos()
------------------------------------*/
function GetViewPos()

	return CurrentView.origin;

end



/*------------------------------------
	GetCursorDirection()
------------------------------------*/
function GetCursorDirection()

	local pl = LocalPlayer();
	if( IsValid( pl ) ) then
	
		// hack to make sure that the trace is accurate.
		pl:SetFOV( CurrentView.fov );
		return pl:GetCursorAimVector();
		
	end
	
	return vector_up;

end


/*------------------------------------
	UpdateView()
------------------------------------*/
function UpdateView( pl, camera, origin, angles, fov )
	
	if ( !vgui.CursorVisible() ) then
	
		gui.EnableScreenClicker( true );
		
	end
	
	// check for view reset
	if ( LastCamera == nil ) then

		ViewAngle.Pitch = 45;
		ViewDistance = 400;
		ViewAngle.Yaw = camera:GetAngles().Yaw;
			
	end
	
	// clamp
	ViewAngle.Pitch = math.Clamp( ViewAngle.Pitch, 0, 90 );
	ViewDistance = math.Clamp( ViewDistance, MIN_VIEW_DISTANCE, MAX_VIEW_DISTANCE );
	
	local cameraPos = camera:GetPos();
	local camPos = cameraPos + ( ViewAngle:Forward() * -ViewDistance );
	
	// create default view
	local view = {
	
		origin = camPos,
		angles = ViewAngle,
		fov = 80
		
	};
	
	// if new camera or no previous view, reset current
	if ( !CurrentView || camera != LastCamera ) then
	
		CurrentView = view;
	
	end
	
	// do interpolation on position
	view.origin = LerpVector( FrameTime() * 5, CurrentView.origin, view.origin );
	
	// always face camera
	view.angles = ( cameraPos - view.origin ):Angle();

	// save current view
	CurrentView = view;
	LastCamera = camera;
	
	/*
	for k, v in pairs( pl.ActiveItems or {} ) do
	
		GAMEMODE:ItemCall( pl, v, "CalcView", view );
		
	end
	*/
	
	view.origin, view.angles = cam.ApplyShake( view.origin, view.angles, 1 );
	
	// override
	return view;

end


/*------------------------------------
	DrawAimAssist()
------------------------------------*/
function DrawAimAssist()

	// validate player
	local pl = LocalPlayer();
	if( !IsValid( pl ) ) then
	
		return;
		
	end
	
	// don't call unless we have a direction (UpdateGestures makes this)
	if( !HitDirection ) then
	
		return;
		
	end

	// validate ball
	local ball = pl:GetCamera();
	if ( !IsBall( ball ) ) then
	
		return;
		
	end
	
	if ( InHitGesture() ) then
	
		local points = {};
	
		local lastDirection = HitDirection;
		local lastPosition = ball:GetPos();
		local len = ball.Size * 2;
		
		render.SetMaterial( WhiteMaterial );
		mesh.Begin( MATERIAL_LINE_STRIP, 16 );
		
		for i = 1, 16 do
			
			local position = lastPosition + lastDirection * ( i * len );
						
			// hit a wall or slope?
			local tr = util.TraceHull( {
				start = lastPosition,
				endpos = position,
				filter = ball,
				mins = BallMins,
				maxs = BallMaxs,
				mask = MASK_NPCSOLID_BRUSHONLY
			} );
			if( tr.HitWorld ) then
			
				position = tr.HitPos;
			
				// enough to reflect?
				if( tr.HitNormal:Dot( vector_up ) < 0.5 ) then
					
					lastDirection = ( 2 * tr.HitNormal * tr.HitNormal:Dot( tr.Normal * -1 ) ) + tr.Normal;

				end
			
			end
			
			local tr = util.TraceHull( {
				start = position + GroundTraceSize,
				endpos = position - GroundTraceSize,
				filter = ball,
				mins = BallMins,
				maxs = BallMaxs,
				mask = MASK_NPCSOLID_BRUSHONLY
			} );
			if( tr.Hit ) then
			
				local newPos = tr.HitPos + Vector( 0, 0, ball.Size );
				if( newPos.z > position.z ) then
				
					position = newPos;
					
				end
				
			end
			
			local frac = 1 - ( i / 16 );

			// add vertex
			mesh.Position( position );
			mesh.Color( 255, 255, 255, 255 * frac );
			mesh.AdvanceVertex();
			
			lastPosition = position;
			len = math.Clamp( ( HitPower * 0.02 ) * 3, 0.3, 3 );

		end
		
		mesh.End();
		
	end

end

if( CLIENT ) then

	/*------------------------------------
		ResetViewMessage()
	------------------------------------*/
	function ResetViewMessage( msg )
	
		LastCamera = nil;
	
	end
	usermessage.Hook( "ResetView", ResetViewMessage );
	
end