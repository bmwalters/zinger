
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
	self:DrawShadow( true );
	self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER );
	
	// raise mass
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then

		phys:EnableMotion( false );
		
	end

end


/*------------------------------------
	TeeOff()
------------------------------------*/
function ENT:TeeOff( dir, power )
	
	// create a fake tee
	local ent = ents.Create( "prop_physics_multiplayer" );
		ent:SetPos( self:GetPos() );
		ent:SetAngles( self:GetAngles() );
		ent:SetModel( self:GetModel() );
		ent:SetColor( self:GetColor() );
		ent:SetSolid( SOLID_VPHYSICS );
		ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS );
		ent:SetOwner( self );
		ent:Spawn();
	
	// give it a forward motion and a spin
	local phys = ent:GetPhysicsObject();
	if ( IsValid( phys ) ) then
	
		// apply force
		phys:Wake();
		phys:ApplyForceCenter( ( dir * ( 50 + power ) ) + Vector( 0, 0, 100 + power ) );
		
		// this gives it a spin
		phys:ApplyForceOffset( ( dir * -power ), self:GetPos() - Vector( 0, 0, 10 ) );
	
	end
	
	// remove entities
	SafeRemoveEntityDelayed( ent, 3 );
	SafeRemoveEntityDelayed( self, 0 );
	
end
