
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
		
	// wake and disable drag
	// we calculate the throw vector as if we have none
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:EnableGravity( false );
		phys:EnableDrag( false );
		phys:Wake();
	
	end
	
	// fuse sound
	//self.Sound = CreateSound( self.Entity, Sound( "ambient/fire/fire_small_loop1.wav" ) );	
	
	// trail
	local effect = EffectData();
	effect:SetOrigin( self.Entity:GetPos() );
	effect:SetAttachment( self:LookupAttachment( "Exhaust" ) );
	effect:SetEntity( self.Entity );
	util.Effect( "Zinger.RocketTrail", effect );
	
end


/*------------------------------------
	OnRemove()
------------------------------------*/
function ENT:OnRemove()

	//self.Sound:Stop();

end


/*------------------------------------
	Explode()
------------------------------------*/
function ENT:Explode()

	if( self.Exploded ) then
	
		return;
		
	end
	self.Exploded = true;

	local owner = self:GetOwner();
	if( !IsValid( owner ) ) then
	
		SafeRemoveEntityDelayed( self, 0 );
		return;
		
	end
	
	local pos = self:GetPos();
	local team = owner:Team();
	
	// remove thyself
	SafeRemoveEntityDelayed( self, 0 );
	
	// blow up
	util.Explosion( pos, 700, team );

end


/*------------------------------------
	PhysicsCollide()
------------------------------------*/
function ENT:PhysicsCollide()

	self:Explode();
	
end