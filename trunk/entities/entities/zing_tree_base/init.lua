
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()
	
	// setup
	self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetMoveType( MOVETYPE_NONE );
	
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:EnableMotion( false );
	
	end
	
end
