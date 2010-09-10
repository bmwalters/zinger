
// object
local PANEL = {};

// textures
local Background = Material( "zinger/hud/elements/radar" );
local Glass = Material( "zinger/hud/elements/radarglass" );
local North = Material( "zinger/hud/elements/radarnorth" );
local Lines = Material( "zinger/hud/elements/radarlines" );

/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self.BaseClass.Init( self );

	self:SetSize( 210, 210 );
	
	self.DefaultX = 10;
	self.DefaultY = 10;
	self.ElementTitle = "Radar";
	self.Flag = ELEM_FLAG_PLAYERS;
	self.CenterX = 102;
	self.CenterY = 103;
	
	self.Rad = 73;
	self.ZoomScale = 1;
	self:SetRadius( 768 );
	
	self:InitDone();

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	SetRadius()
------------------------------------*/
function PANEL:SetRadius( rad )

	self.WorldRadius = rad;
	self.ScaleRadius = self.Rad / rad;

end


/*------------------------------------
	ToggleZoom()
------------------------------------*/
function PANEL:ToggleZoom()

	self.ZoomScale = ( self.ZoomScale == 1 ) && 2 || 1;
	self:SetRadius( 768 * self.ZoomScale );

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	if ( !self:ShouldPaint() ) then
	
		return;
		
	end
	
	// get ball
	local valid, ball = LPHasBall();
	if( !valid ) then
	
		return;
		
	end
	
	// draw material
	surface.SetMaterial( Glass );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, 256, 256 );
	
	local pos = ball:GetPos();
	local viewangle = controls.GetViewAngles();
	
	// draw radar north
	local yaw_deg = viewangle.y + 180;
	local yaw_rad = math.rad( yaw_deg );
	local target = ( 360 - yaw_deg ) + 90;

	// find all entities in range of the ball that have radar drawing functions
	local entities = ents.FindInSphere( pos, self.WorldRadius );
	for _, entity in pairs( entities ) do
	
		if( entity.DrawOnRadar ) then
		
			local targetpos = entity:GetPos();
			local targetangle = entity:GetAngles();
		
			// ensure we're within the radius
			local dist = self.ScaleRadius * ( targetpos - pos ):Length2D();
			if( dist <= self.Rad ) then
				
				local angle = math.rad( math.deg( math.atan2( targetpos.y - pos.y, targetpos.x - pos.x ) ) - 180 - viewangle.y );

				local x = self.CenterX + math.sin( angle ) * dist;
				local y = self.CenterY + math.cos( angle ) * dist;
				
				local forward = targetangle.y + viewangle.y + 90;
				local right = forward + 90;
				
				entity:DrawOnRadar( x, y, forward, right );
				
			end

		end
	
	end
	
	// draw material
	surface.SetMaterial( Background );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, 256, 256 );
	
	// this gives the rotation a sloppy feel
	self.RadarAngle = self.RadarAngle or target;
	self.RadarAngle = math.ApproachAngle( self.RadarAngle, target, ( self.RadarAngle - target ) * ( FrameTime() * 8.6 ) );
	
	// draw north
	surface.SetMaterial( North );
	surface.DrawTexturedRectRotated( self.CenterX + math.cos( yaw_rad ) * self.Rad, self.CenterY + math.sin( yaw_rad ) * self.Rad, 32, 32, target );
	
	// even sloppier
	self.LineAngle = self.LineAngle or target;
	self.LineAngle = math.ApproachAngle( self.LineAngle, target, ( self.LineAngle - target ) * ( FrameTime() * 8 ) );
	
	// draw lines
	surface.SetMaterial( Lines );
	surface.DrawTexturedRectRotated( self.CenterX, self.CenterY, 256, 256, self.LineAngle );
	
	// must call
	self.BaseClass.Paint( self );

end

// register
derma.DefineControl( "Radar", "", PANEL, "BaseElement" );
