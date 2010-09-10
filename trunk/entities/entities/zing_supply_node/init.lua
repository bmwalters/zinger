
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	UpdateTransmitState()
------------------------------------*/
function ENT:UpdateTransmitState()

	return TRANSMIT_NEVER;

end

/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	debugoverlay.Sphere( self:GetPos(), self:SpawnRadius(), 1.05, Color( 40, 40, 40, 0 ) );

	self:NextThink( CurTime() + 1 );
	return true;

end

/*------------------------------------
	SpawnRadius()
------------------------------------*/
function ENT:SpawnRadius()

	return ( self.KeyValues[ 'SpawnRadius' ] or 1 );

end
