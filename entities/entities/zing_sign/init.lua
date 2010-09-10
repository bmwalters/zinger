
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

include( 'shared.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()
	
	self:DrawShadow( true );
	self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER );
	
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then

		phys:EnableMotion( false );
		
	end

end


/*------------------------------------
	KeyValue()
------------------------------------*/
function ENT:KeyValue( key, value )

	key = string.lower( key );
	
	if( key == "line1" || key == "line2" || key == "line3" ) then
	
		//print( key, value );
		self:SetNetworkedString( key, value );
		
	end
	
	if( key == "line1color" || key == "line2color" || key == "line3color" ) then
	
		local color = string.Explode( " ", value );
		self:SetNetworkedVector( key, Vector( tonumber( color[1] ), tonumber( color[2] ), tonumber( color[3] ) ) );
		//print( key, Vector( tonumber( color[1] ), tonumber( color[2] ), tonumber( color[3] ) ) );
		
	end

end