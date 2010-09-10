
// manifest
include( 'manifest.lua' );

// modules
require( 'controls' );
require( 'music' );
require( 'hud' );

// convars
CreateClientConVar( "cl_zing_simpleoutline", "0", true, false );
local fpstest = CreateConVar( "cl_zing_fpstest", "0", { FCVAR_CHEAT } );


/*------------------------------------
	Initialize()
------------------------------------*/
function GM:Initialize()

	// base class
	self.BaseClass:Initialize();
	
	// music precache
	music.Precache();
	
end


/*------------------------------------
	InitPostEntity()
------------------------------------*/
function GM:InitPostEntity()
	
	// devs dont need to see the splash screen
	if ( !Dev() ) then
	
		// show vgui
		self:ShowSplash();
		
	end
	
end


/*------------------------------------
	OnEntityCreated()
------------------------------------*/
function GM:OnEntityCreated( entity )

	// validate
	if( !IsValid( entity ) ) then
	
		return;
		
	end
	
	// check for player
	if ( entity:IsPlayer() ) then
	
		// generic player creation hook
		self:OnPlayerCreated( entity );
		
	end

end


/*------------------------------------
	OnLocalPlayerCreated()
------------------------------------*/
function GM:OnLocalPlayerCreated( pl )

	// make our own mouse wheel event
	vgui.GetWorldPanel().OnMouseWheeled = function( p, delta )
	
		self:GUIMouseWheeled( delta );
	
	end
	
	// make our own mouse move event
	vgui.GetWorldPanel().OnCursorMoved = function( p, x, y )
	
		self:GUIMouseMoved( x, y );
	
	end
	
	// create the hud
	self:InitializeHUD();
	
	// devs dont need to hear the theme song
	// (this shit got annoying after months of developing)
	if ( !Dev() ) then
	
		timer.Simple( 1, function()
		
			// this is our theme song <3
			music.PlayTheme();
			
		end );
		
	end
	
end


/*------------------------------------
	RenderScene()
------------------------------------*/
function GM:RenderScene( origin, angles )

	// save render information
	self.LastSceneOrigin = origin;
	self.LastSceneAngles = angles;

	// base class
	return self.BaseClass.RenderScene( self, origin, angles );
	
end


/*------------------------------------
	PreDrawOpaqueRenderables()
------------------------------------*/
function GM:PreDrawOpaqueRenderables()

	if( fpstest:GetBool() ) then
		
		return true;
		
	end

end


/*------------------------------------
	PreDrawTranslucentRenderables()
------------------------------------*/
function GM:PreDrawTranslucentRenderables()

	if( fpstest:GetBool() ) then
		
		return true;
		
	end
	
end


// hack to allow that panorama mod to work with our sky
local oldRenderView = render.RenderView;
render.RenderView = function( view )

	// save render information
	GAMEMODE.LastSceneOrigin = view.origin;
	GAMEMODE.LastSceneAngles = view.angles;
	
	return oldRenderView( view );

end


/*------------------------------------
	RenderScreenspaceEffects()
------------------------------------*/
function GM:RenderScreenspaceEffects()

	if( fpstest:GetBool() ) then
		
		return true;
		
	end

	// render sky
	self:RenderSkyScreenspaceEffects();
	
	// base class
	return self.BaseClass.RenderScreenspaceEffects( self );

end


/*------------------------------------
	PostDrawTranslucentRenderables()
------------------------------------*/
function GM:PostDrawTranslucentRenderables()

	// render aim assist
	controls.DrawAimAssist();
	
	// base class
	return self.BaseClass.PostDrawTranslucentRenderables( self );
	
end


/*------------------------------------
	PostDrawOpaqueRenderables()
------------------------------------*/
function GM:PostDrawOpaqueRenderables()

	// show hint areas
	hud.DrawHints();
	
	// base class
	return self.BaseClass.PostDrawOpaqueRenderables( self );
	
end


/*------------------------------------
	PlayerBindPress()
------------------------------------*/
function GM:PlayerBindPress( pl, bind, down )
	
	// stop the inventory binds
	if ( bind:find( "invprev" ) || bind:find( "invnext" ) ) then
	
		return true;
		
	end
	
	return false;
	
end


/*------------------------------------
	ShouldDrawLocalPlayer()
------------------------------------*/
function GM:ShouldDrawLocalPlayer( pl )
	
	return false;
	
end


/*------------------------------------
	GetMotionBlurValues()
------------------------------------*/
function GM:GetMotionBlurValues( x, y, fwd, spin )

	// validate player
	local pl = LocalPlayer();
	if( IsValid( pl ) ) then
	
		// validate ball
		local ball = pl:GetBall();
		if( IsBall( ball ) ) then
			
			// calculate forward motion blur
			local fwd = ( ball:GetVelocity():Dot( EyeVector() ) - 100 ) / 30000;
			fwd = math.Clamp( fwd, 0, 1 );

			return x, y, fwd, spin;
		
		end
	
	end

	return x, y, fwd, spin;

end


/*------------------------------------
	CreateMove()
------------------------------------*/
function GM:CreateMove( cmd )

	// get player
	local pl = LocalPlayer();
	
	// validate camera
	local camera = pl:GetCamera()
	if ( !IsValid( camera ) ) then
	
		// allow spectators to fly up/down using jump/duck
		if ( cmd:KeyDown( IN_JUMP ) ) then
		
			cmd:SetUpMove( 1 );
			
		elseif ( cmd:KeyDown( IN_DUCK ) ) then
		
			cmd:SetUpMove( -1 );
			
		end
		
		// clear buttons
		cmd:SetButtons( 0 );
		return;
		
	end
	
	// clear all but the use button
	local buttons = 0;
	if( cmd:KeyDown( IN_USE ) ) then
	
		buttons = buttons | IN_USE;
		
	end
	if ( controls.InHitGesture() || controls.InViewGesture() ) then
	
		buttons = buttons | IN_CANCEL;
	
	end
	cmd:SetButtons( buttons );

	// :( PlayerSpray isn't called
	if( cmd:GetImpulse() == 201 ) then
	
		RunConsoleCommand( "spray" );
	
	end
	
	// validate
	if ( controls.IsValid() ) then
	
		// update view angle and distance on server
		cmd:SetViewAngles( controls.GetViewAngles() );
		cmd:SetMouseX( controls.GetDistance() );
		
		// pass the cursor aim vector to the server
		// hidden inside the movement speeds
		local dir = pl:GetCursorAimVector();
		cmd:SetForwardMove( dir.x );
		cmd:SetSideMove( dir.y );
		cmd:SetUpMove( dir.z );
		
	end
	
end


/*------------------------------------
	CalcView()
------------------------------------*/
function GM:CalcView( pl, origin, angles, fov )

	// validate camera
	local camera = pl:GetCamera()
	if ( IsValid( camera ) ) then
	
		return controls.UpdateView( pl, camera, origin, angles, fov );
		
	end

end


/*------------------------------------
	AdjustMouseSensitivity()
------------------------------------*/
function GM:AdjustMouseSensitivity( num )
end


/*------------------------------------
	GUIMousePressed()
------------------------------------*/
function GM:GUIMousePressed( mc, aimvec )
	
	// get player
	local pl = LocalPlayer();
	
	// left click
	if ( mc == MOUSE_LEFT ) then
		
		if ( !IsValid( pl:GetBall() ) ) then
		
			RunConsoleCommand( "hit" );
			return;
			
		end
		
		hud.ClickHints();
	
		// check for use key
		if ( pl:KeyDown( IN_USE ) ) then
		
			// validate item
			local item = inventory.Equipped();
			if ( item && item.Cursor ) then
			
				// use item
				RunConsoleCommand( "item", "use" );
				
			end
		
		else
	
			controls.OnHitGesture( pl, true );
			
		end
	
	// right click
	elseif ( mc == MOUSE_RIGHT ) then
		
		controls.OnViewGesture( pl, true );
	
	end
	
end


/*------------------------------------
	GUIMouseReleased()
------------------------------------*/
function GM:GUIMouseReleased( mc )

	// get player
	local pl = LocalPlayer();
	
	// left click
	if ( mc == MOUSE_LEFT ) then
	
		controls.OnHitGesture( pl, false );
	
	// right click
	elseif ( mc == MOUSE_RIGHT ) then
	
		controls.OnViewGesture( pl, false );
	
	end
	
end


/*------------------------------------
	GUIMouseWheeled()
------------------------------------*/
function GM:GUIMouseWheeled( delta )

	// validate camera
	local camera = LocalPlayer():GetCamera();
	if ( !IsValid( camera ) ) then
	
		return;
		
	end
	
	// modify distance
	controls.MoveDistance( delta );

end


local BlackModel = Material( "zinger/models/black" );
local BlackModelSimple = Material( "black_outline" );


/*------------------------------------
	DrawModelOutlinedSimple()
------------------------------------*/
local function DrawModelOutlinedSimple( ent, width, width2 )

	// render black model
	render.SuppressEngineLighting( true );
	SetMaterialOverride( BlackModelSimple );

	// render model
	ent:SetModelScale( width );
	ent:SetupBones();
	ent:DrawModel();
	
	// render second if needed
	if ( width2 ) then
	
		ent:SetModelScale( width2 );
		ent:SetupBones();
		ent:DrawModel();
	
	end
	
	// clear
	SetMaterialOverride();
	render.SuppressEngineLighting( false );
	
	// render model
	ent:SetModelScale( Vector() * 1 );
	ent:SetupBones();
	ent:DrawModel();

end


/*------------------------------------
	DrawModelOutlined()
------------------------------------*/
function DrawModelOutlined( ent, width, width2 )

	if ( GetConVarNumber( "cl_zing_simpleoutline" ) > 0 ) then
	
		DrawModelOutlinedSimple( ent, width, width2 );
		return;
	
	end

	// start stencil
	render.SetStencilEnable( true );
	
	// render the model normally, and into the stencil buffer
	render.ClearStencil();
	render.SetStencilFailOperation( STENCILOPERATION_KEEP );
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE );
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS );
	render.SetStencilWriteMask( 1 );
	render.SetStencilReferenceValue( 1 );
	
		// render model
		ent:SetModelScale( Vector() * 1 );
		ent:SetupBones();
		ent:DrawModel();
	
	// render the outline everywhere the model isn't
	render.SetStencilReferenceValue( 0 );
	render.SetStencilTestMask( 1 );
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL );
	render.SetStencilPassOperation( STENCILOPERATION_ZERO );
	
	// render black model
	render.SuppressEngineLighting( true );
	SetMaterialOverride( BlackModel );
	
		// render model
		ent:SetModelScale( width );
		ent:SetupBones();
		ent:DrawModel();
		
		// render second if needed
		if ( width2 ) then
		
			ent:SetModelScale( width2 );
			ent:SetupBones();
			ent:DrawModel();
		
		end
		
	// clear
	SetMaterialOverride();
	render.SuppressEngineLighting( false );
	
	// end stencil buffer
	render.SetStencilEnable( false );

end


/*------------------------------------
	GetEntityPos2D()
------------------------------------*/
function GetEntityPos2D( ent, size )

	// get right based off player view
	local right = LocalPlayer():GetAimVector():Angle():Right();
	
	// calculate the 2D area of the ball location
	local pos = ent:GetPos();
	local center = pos:ToScreen();
	local bounds = pos + ( right * ( size * 2 ) );
	bounds = bounds:ToScreen();
	
	return center, math.abs( center.x - bounds.x );

end
