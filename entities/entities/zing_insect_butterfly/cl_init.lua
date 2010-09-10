
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	self:DrawModel();

end
