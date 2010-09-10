
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

// accessors
AccessorFunc( ENT, "Target", "Target" );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.CurrentDir = self:GetAngles():Forward();

	self:SetTarget( NULL );

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
	
	// trail
	local effect = EffectData();
	effect:SetOrigin( self.Entity:GetPos() );
	effect:SetAttachment( self:LookupAttachment( "Exhaust" ) );
	effect:SetEntity( self.Entity );
	util.Effect( "Zinger.RocketTrail", effect );
	
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


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	local target = self:GetTarget();
	
	// our target disappeared
	if( !IsValid( target ) ) then
	
		return;
	
	end
	
	// figure out direction
	local dir = ( target:GetPos() - self:GetPos() );
	dir:Normalize();
	
	// is there an obstacle in my way?
	local tr = util.TraceEntity( {
		start = self:GetPos(),
		endpos = target:GetPos(),
		filter = self,
	}, self );
	if( tr.Entity != target ) then
		
		// force the rocket to go upward in a hope of
		// being able to avoid the obstacle
		dir.z = 1;
		dir:Normalize();
		
	end
	
	self.CurrentDir = LerpVector( FrameTime() * 3, self.CurrentDir, dir );
		
	// point toward them
	self:SetAngles( self.CurrentDir:Angle() );
	
	// track them
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:SetVelocity( self.CurrentDir * HOMING_ROCKET_SPEED );
	
	end

	self:NextThink( CurTime() );
	return true;

end
