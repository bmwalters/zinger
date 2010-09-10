
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
	Initialize()
------------------------------------*/
function ENT:Initialize()

	// setup
	self:DrawShadow( false );
	self:SetNoDraw( true );
	
	// sounds
	self.FlyBySound = CreateSound( self.Entity, Sound( "zinger/items/airstrikeflyby.mp3" ) );
	self.FlyBySound:SetSoundLevel( 0.5 );
	self.FlyBySound:Play();
	
	// defaults
	self.NextShot = CurTime() + 3;
	self.ShotCount = 0;
	
	timer.Simple( 3, function()
	
		util.ScreenShake( self:GetPos(), 2, 15, 3, 3072 );
		
	end );
	
	SafeRemoveEntityDelayed( self, 8.1 );
		
end


/*------------------------------------
	OnRemove()
------------------------------------*/
function ENT:OnRemove()

	// clean up sounds
	self.FlyBySound:Stop();

end


/*------------------------------------
	FireWeapon()
------------------------------------*/
function ENT:FireWeapon()

	local dir = self:GetAngles():Forward();
	
	local pos = self:GetPos() - ( dir * ( 500 - ( self.ShotCount * 100 ) ) ) + ( VectorRand() * 40 );
	
	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + Vector( 0, 0, 1048 ),
	} );
	pos = tr.HitPos - Vector( 0, 0, 16 );
	
	if ( !self.AimDir ) then
	
		self.AimDir = ( self.TargetPos - pos );
		
	end
	
	// create bomb and drop it
	local bomb = ents.Create( "zing_bomb" );
	bomb:SetModel( Model( "models/zinger/rocket.mdl" ) );
	bomb:SetOwner( self:GetOwner() );
	bomb:SetPos( pos );
	bomb:SetAngles( self.AimDir:Angle() );
	bomb:Spawn();
	bomb.Damage = 500;
	bomb.FuseTime = 0;
	
	local phys = bomb:GetPhysicsObject();
	if ( IsValid( phys ) ) then
		
		phys:Wake();
		phys:EnableDrag( false );
		phys:SetMass( 80 );
		phys:SetDamping( 0, 0 );
		phys:ApplyForceCenter( self.AimDir * ( phys:GetMass() ) );
	
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()
	
	// fire a shot if its time
	if ( self.NextShot > 0 && CurTime() > self.NextShot ) then
	
		self.ShotCount = self.ShotCount + 1;
		if ( self.ShotCount < 5 ) then
		
			self.NextShot = CurTime() + 0.15;
		
		else
		
			self.NextShot = -1;
			
		end
		
		self:FireWeapon();
	
	end

end
