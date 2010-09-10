
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;

local ColorYellow = Color( color_yellow.r, color_yellow.g, color_yellow.b, 255 );
local ColorGold = Color( color_yellow_dark.r, color_yellow_dark.g, color_yellow_dark.b, 255 );

ENT.HintTopic = "Gameplay:Rings";


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.Particles = false;

	// render bounds
	self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() );
	
end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()
	
	// update hole
	self.CurrentHole = RoundController():GetCurrentHole();
	
	local pl = LocalPlayer();
	if ( !IsValid( pl ) ) then
	
		return;
		
	end
	
	// check if team is activated this ring
	local t = pl:Team();
	if ( self:IsTeamDone( pl:Team() ) ) then
		
		// gray
		self:SetColor( 64, 64, 64, 255 );
		
		// this hole is done, yet we haven't played the particle effect
		// so do so now.
		if ( !self.Particles ) then
		
			self.Particles = true;
			
			// particles
			ParticleEffectAttach( "Zinger.RingExplode", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0 );
			
			// dynamic light
			local light = DynamicLight( self:EntIndex() );
			light.Pos = self:GetPos();
			light.R = 255;
			light.G = 240;
			light.B = 0;
			light.Brightness = 5;
			light.Size = 512;
			light.Decay = 2048;
			light.DieTime = CurTime() + 1;
		
		end
	
	else
		
		local percent = math.abs( math.sin( CurTime() ) );
		
		// animate the color
		self:SetColor( Lerp( percent, ColorGold.r, ColorYellow.r ), Lerp( percent, ColorGold.g, ColorYellow.g ), Lerp( percent, ColorGold.b, ColorYellow.b ), 255 );
			
	end
	
	self:HintThink();
	
	self:NextThink( CurTime() + 0.5 );
	return true;

end

/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	// hide when not needed
	if ( self.CurrentHole != self.dt.Hole ) then
	
		return;
		
	end
	
	// calculate outline width
	local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
	local width2 = 0.95 - ( ( width / MAX_VIEW_DISTANCE ) * 0.05 );
	width = 1.05 + ( ( width / MAX_VIEW_DISTANCE ) * 0.05 );
	
	render.SuppressEngineLighting( true );
	self:DrawModelOutlined( Vector() * width, Vector() * width2 );
	render.SuppressEngineLighting( false );

end



/*------------------------------------
	DrawOnRadar()
------------------------------------*/
function ENT:DrawOnRadar( x, y, a )

	local r, g, b, ap = self:GetColor();

	self:RadarDrawRect( x, y, 10, 4, Color( r, g, b, ap ), a - 90 );

end
