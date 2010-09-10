
// shared file
include( 'shared.lua' );

// materials
local BlackModel = Material( "zinger/models/black" );
local BlackModelSimple = Material( "black_outline" );
local White = Material( "vgui/white" );
local Circle = Material( "zinger/hud/circle" );
local RadarPing = Material( "zinger/hud/elements/radarping" );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

end


/*------------------------------------
	DrawModelOutlined()
------------------------------------*/
function ENT:DrawModelOutlined( width, width2 )

	DrawModelOutlined( self, width, width2 );

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()
end


/*------------------------------------
	RadarDrawSquare()
------------------------------------*/
function ENT:RadarDrawSquare( x, y, size, color, a )

	surface.SetDrawColor( color.r, color.g, color.b, color.a );
	surface.DrawRect( x - ( size * 0.5 ), y - ( size * 0.5 ), size, size );
	
	if( a ) then
	
		a = math.rad( a );

		local ax = x + math.cos( a ) * size;
		local ay = y + math.sin( a ) * size;
		
		surface.DrawLine( x, y, ax, ay );
		
	end

end


/*------------------------------------
	RadarDrawCircle()
------------------------------------*/
function ENT:RadarDrawCircle( x, y, size, color, a, material )

	surface.SetDrawColor( color.r, color.g, color.b, color.a );

	if( a ) then
	
		local ar = math.rad( a );

		local ax = x + math.cos( ar ) * size;
		local ay = y + math.sin( ar ) * size;
		
		surface.DrawLine( x, y, ax, ay );
		
		a = ( 360 - a ) + 90;
		
	end

	surface.SetMaterial( material or Circle );
	surface.DrawTexturedRectRotated( x, y, size, size, a or 0 );

end


/*------------------------------------
	RadarDrawTexturedCircle()
------------------------------------*/
function ENT:RadarDrawTexturedCircle( x, y, size, color, a, material )

	if( a ) then
	
		a = ( 360 - a ) + 90;
		
	end

	surface.SetDrawColor( color.r, color.g, color.b, color.a );
	surface.SetMaterial( material or Circle );
	surface.DrawTexturedRectRotated( x, y, size, size, a or 0 );

end


/*------------------------------------
	RadarDrawRadius()
------------------------------------*/
function ENT:RadarDrawRadius( x, y, radius, color, color2 )

	self.RadarGrowTime = self.RadarGrowTime or ( CurTime() + 0.25 );
	self.RadarPingOffset = self.RadarPingOffset or math.random( 1, 360 );
	
	// grow
	local scale = 1 - math.Clamp( ( self.RadarGrowTime - CurTime() ) / 0.25, 0, 1 );
	radius = GAMEMODE.Radar.ScaleRadius * radius * 2 * scale;

	// draw the radius circle
	self:RadarDrawTexturedCircle( x, y, radius, color );
	
	// draw the ping line
	self:RadarDrawTexturedCircle( x, y, radius, color2, CurTime() * 100 + self.RadarPingOffset, RadarPing );
	
end


/*------------------------------------
	RadarDrawRect()
------------------------------------*/
function ENT:RadarDrawRect( x, y, w, h, color, a )

	if( a ) then
	
		a = ( 360 - a ) + 90;
		
	end

	surface.SetMaterial( White );
	surface.SetDrawColor( color.r, color.g, color.b, color.a );
	surface.DrawTexturedRectRotated( x, y, w, h, a or 0 );

end


/*------------------------------------
	ShowHint()
------------------------------------*/
function ENT:ShowHint()

	// no help topic
	if ( !self.HintTopic ) then
	
		self.DontHint = true;
		return;
		
	elseif ( hud.IsHintSurpressed( self.HintTopic ) ) then
	
		self.DontHint = true;
		return;
	
	elseif ( !hud.ShouldHint( self.HintTopic ) ) then
	
		return;
		
	end
	
	if ( hud.AddHint( self:GetPos() + ( self.HintOffset or vector_origin ), self.HintTopic ) ) then
	
		self.DontHint = true;
		
	end
	
end


/*------------------------------------
	HintThink()
------------------------------------*/
function ENT:HintThink()

	local check, ball = LPHasBall();
	if ( !check ) then
	
		hud.DelayHints();
		return;
		
	end
	
	if ( ball:GetVelocity():Length() > 40 ) then
	
		return;
		
	end
	
	// throw a hint if possible
	if ( !self.DontHint && ( ball:GetPos() - self:GetPos() ):Length() <= HINT_DISTANCE ) then
	
		print( self, "showing" );
		self:ShowHint();
	
	end
	
end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// set next think
	self:NextThink( CurTime() + 0.5 );
	
	// update hole
	self.CurrentHole = RoundController():GetCurrentHole();
	
	self:HintThink();
	
	return true;
	
end


/*------------------------------------
	GetTipText()
------------------------------------*/
function ENT:GetTipText()

	return self.PrintName;

end

