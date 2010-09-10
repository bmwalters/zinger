
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	if( self.dt.Active ) then
	
		// if we're active, create a dynamic light at the Fuse attachment
		local attachment = self:GetAttachment( self:LookupAttachment( "Fuse" ) );
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

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	self:DrawModel();
	
end
