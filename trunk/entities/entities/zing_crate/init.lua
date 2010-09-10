
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.Item = items.Random();
	
	self.Activated = false;
	
	// setup
	self:DrawShadow( true );
	self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetCollisionGroup( COLLISION_GROUP_NONE );
	self:SetTrigger( true );
	
	// spawn sound
	self:EmitSound( "physics/wood/wood_box_impact_bullet4.wav" );
	
	// violently jolt the crate once it has emerged
	// from the ground.
	timer.Simple( 0.15, function()
	
		if( IsValid( self.Entity ) ) then
		
			local phys = self:GetPhysicsObject();
			if( IsValid( phys ) ) then
			
				phys:Wake();
				phys:ApplyForceOffset( vector_up * phys:GetMass() * 75, self:GetPos() + VectorRand() * 40 );
				phys:SetMass( 5 );
				self:SetGravity( 2 );
				
			end
	
		end
		
	end );
	
	rules.Call( "CrateSpawned", self );
		
end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think( pl, ball )

	// gibs
	local effect = EffectData();
	effect:SetOrigin( self:GetPos() );
	effect:SetAngle( self:GetAngles() );
	util.Effect( "Zinger.CrateBreak", effect );
	
	SafeRemoveEntity( self );
	
end


/*------------------------------------
	DoPickup()
------------------------------------*/
function ENT:DoPickup( pl, ball )

	if( self.Activated ) then
	
		return;
		
	end
	self.Activated = true;

	inventory.Give( pl, self.Item );
	rules.Call( "SupplyCratePicked", self, ball );

	// gibs
	local effect = EffectData();
	effect:SetOrigin( self:GetPos() );
	effect:SetAngle( self:GetAngles() );
	util.Effect( "Zinger.CrateBreak", effect );

	// sound
	WorldSound( Sound( "physics/wood/wood_box_impact_bullet1.wav" ), self:GetPos(), 100, 100 );
	
	// particle effect
	ParticleEffect( "Zinger.CratePickup", self:GetPos(), angle_zero, ent );
	
	self:Remove();

end


/*------------------------------------
	StartTouch()
------------------------------------*/
function ENT:StartTouch( ent )

	if( IsBall( ent ) ) then
	
		local owner = ent:GetOwner();
		if( !IsValid( owner ) ) then
		
			return;
		
		end
		
		self:DoPickup( owner, ent );
		
	end
	
end


/*------------------------------------
	PhysicsCollide()
------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
	
	// check for world
	local hitWorld = data.HitEntity:IsWorld();
	if ( hitWorld ) then
	
		// run trace of collision
		local trace = {};
		trace.start = self:GetPos();
		trace.endpos = data.HitPos - ( vector_up * 32 );
		trace.filter = self;
		local tr = util.TraceLine( trace );
		
		// check if we're out of bounds
		if ( IsOOB( tr ) ) then
		
			// gibs
			local effect = EffectData();
			effect:SetOrigin( self:GetPos() );
			effect:SetAngle( self:GetAngles() );
			util.Effect( "Zinger.CrateBreak", effect );
			
			SafeRemoveEntityDelayed( self, 0 );
		
		end
	
	end
	
end
