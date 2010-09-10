
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	KeyValue()
------------------------------------*/
function ENT:KeyValue( key, value )

	self.KeyValues = self.KeyValues || {};
	
	// save hole
	if( key == "hole" ) then
	
		self.dt.Hole = value;
		
	else
	
		self.KeyValues[ key ] = value;
		
	end

end
