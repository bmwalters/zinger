
include( 'shared.lua' );

ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self:SetRenderBounds( Vector( -28, -28, 0 ), Vector( 28, 28, 4 ) );
	
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
	width = 1.6 + ( ( width / 600 ) * 0.075 );
	
	self:DrawModelOutlined( Vector( width, width, 1.05 ) );
	
end


/*------------------------------------
	DrawOnRadar()
------------------------------------*/
function ENT:DrawOnRadar( x, y, ang )

	local r, g, b, a = self:GetColor();

	self:RadarDrawCircle( x, y, 6, Color( r, g, b, a ), ang );

end
