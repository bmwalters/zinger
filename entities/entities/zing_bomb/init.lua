
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
	//self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:NextThink( -1 );
	
	// wake and disable drag
	// we calculate the throw vector as if we have none
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:EnableDrag( false );
		phys:Wake();
	
	end
	
	// fuse sound
	self.Sound = CreateSound( self.Entity, Sound( "ambient/fire/fire_small_loop1.wav" ) );
	
	self.Damage = 700;
	self.FuseTime = 1;
		
end


/*------------------------------------
	OnRemove()
------------------------------------*/
function ENT:OnRemove()

	self.Sound:Stop();

end


/*------------------------------------
	OnIgnite()
------------------------------------*/
function ENT:OnIgnite()

	self.dt.Active = true;
	
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:EnableDrag( true );
		phys:SetDamping( 0.1, 0.5 );
	
	end

	// start timer
	self:NextThink( CurTime() + self.FuseTime );
	
	// effect and sound
	local effect = EffectData();
	effect:SetOrigin( self.Entity:GetPos() );
	effect:SetAttachment( self:LookupAttachment( "Fuse" ) );
	effect:SetEntity( self.Entity );
	util.Effect( "Zinger.Fuse", effect );
		
	self.Sound:Play();
	self.Sound:ChangePitch( 150 );

end


/*------------------------------------
	PhysicsCollide()
------------------------------------*/
function ENT:PhysicsCollide( data, physobj )

	if ( IsValid( data.HitEntity ) && data.HitEntity.IsBomb ) then
	
		return;
		
	end

	if( !self.dt.Active ) then

		self.dt.Active = true;
		
		// do it on a delay
		timer.Simple( 0, function() self:OnIgnite(); end );
		
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	local owner = self:GetOwner();
	if( !IsValid( owner ) ) then
	
		SafeRemoveEntityDelayed( self, 0 );
		return;
		
	end
	
	local pos = self:GetPos();
	local team = owner:Team();
	
	// remove thyself
	SafeRemoveEntityDelayed( self, 0 );
	self:SetNotSolid( true );
	
	// blow up
	util.Explosion( pos, self.Damage, team );

end
