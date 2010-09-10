
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.GrowEndTime = CurTime() + 0.25;
	
	self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() );

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	local scale = 0.5 + ( 1 - math.Clamp( ( self.GrowEndTime - CurTime() ) / 0.25, 0, 1 ) ) * 0.5;
	
	if ( scale < 1 ) then
		
		// render model
		self:SetModelScale( Vector() * scale );
		self:SetupBones();
		self:DrawModel();
		
	else

		// calculate outline width
		local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
		width = 1.05 + ( ( width / MAX_VIEW_DISTANCE ) * 0.05 );
		
		self:DrawModelOutlined( Vector() * width );
	
	end
	
end


/*------------------------------------
	DrawOnRadar()
------------------------------------*/
function ENT:DrawOnRadar( x, y, a )

	self:RadarDrawRadius( x, y, MAGNET_ATTRACT_RADIUS, color_white_translucent, color_white_translucent2 );
	self:RadarDrawCircle( x, y, 5, color_red );
	
end
