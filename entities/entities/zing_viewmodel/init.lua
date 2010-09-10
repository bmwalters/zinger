
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

/*------------------------------------
	UpdateTransmitState()
------------------------------------*/
function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS;

end


/*------------------------------------
	SetPitchLocked()
------------------------------------*/
function ENT:SetPitchLocked( value )

	self.dt.PitchLocked = value;

end
