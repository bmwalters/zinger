
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// engine glow
	local attachment = self:GetAttachment( self:LookupAttachment( "Exhaust" ) );
	if( attachment ) then

		local light = DynamicLight( self:EntIndex() );
		light.Pos = attachment.Pos;
		light.Size = 128;
		light.Decay = 512;
		light.R = 255;
		light.G = 230;
		light.B = 0;
		light.Brightness = 2;
		light.DieTime = CurTime() + 1;
	
	end
		
end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	self:DrawModel();
	
end
