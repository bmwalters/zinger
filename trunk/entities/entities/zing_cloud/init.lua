
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
	GetPathTarget()
------------------------------------*/
function ENT:GetPathTarget( path )

	return ents.FindByName( path:GetKeyValues()['target'] )[1];

end


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self:DrawShadow( false );

	local pathEnt = ents.FindByName( self.Path )[1];
	local path = {};
	
	
	table.insert( path, pathEnt:GetPos() );
	SafeRemoveEntityDelayed( pathEnt, 0 );
	
	// walk the path and find all the waypoints for us
	local nextEnt = self:GetPathTarget( pathEnt );
	while( IsValid( nextEnt ) && nextEnt != pathEnt ) do
	
		table.insert( path, nextEnt:GetPos() );
		SafeRemoveEntityDelayed( nextEnt, 0 );

		nextEnt = self:GetPathTarget( nextEnt );
	
	end
	
	// end where they started?
	if( nextEnt == pathEnt ) then
	
		table.insert( path, pathEnt:GetPos() );
	
	end
	
	// set the position to the exact center of our path
	local pos = Vector(0,0,0);
	for i = 1, #path do
	
		pos = pos + path[i];
	
	end
	pos = pos * ( 1 / #path );
	self:SetPos( pos );
	
	// inflate the path a bit to take into account mapper error
	for i = 1, #path do
	
		path[i] = ( ( path[i] - pos ) * 1.04 ) + pos; // + Vector( 0, 0, 32 );
	
	end
	
	// send off to the client
	self:SetNetworkedInt( "NumWaypoints", #path );
	for i = 1, #path do
	
		self:SetNetworkedVector( i, path[i] );
	
	end
	
	
	
	self.BaseClass.Initialize( self );

end


/*------------------------------------
	KeyValue()
------------------------------------*/
function ENT:KeyValue( key, value )

	if( key == "destination" ) then
	
		self.Path = value;
	
	end
	
	return self.BaseClass.KeyValue( self, key, value );

end
