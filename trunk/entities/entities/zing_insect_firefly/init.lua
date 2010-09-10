
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.BaseClass.Initialize( self );

end


/*------------------------------------
	MoveToTarget()
------------------------------------*/
function ENT:MoveToTarget( target )

	// just slowly move toward target
	local dir = ( ( target:GetPos() + self.Offset ) - self:GetPos() );
	dir:Normalize();
	local velocity = ( dir * 20 );
	
	self:SetLocalVelocity( velocity );

end
