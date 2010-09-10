
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

// ball sounds
local BounceSounds = {
	Sound( "zinger/ballbounce1.mp3" ),
	Sound( "zinger/ballbounce2.mp3" ),
	Sound( "zinger/ballbounce3.mp3" ),
	Sound( "zinger/ballbounce4.mp3" )
}
local DriveSounds = {
	Sound( "zinger/drive1.mp3" ),
	Sound( "zinger/drive2.mp3" )
}
local PuttSounds = {
	Sound( "zinger/putt1.mp3" )
}
local CollideSounds = {
	Sound( "zinger/ballcollide.mp3" )
}

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()
	
	// setup
	self:DrawShadow( false );
	self:SetModel( self.Model );
	self:PhysicsInitSphere( self.Size, "grass" );
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER );
	self:SetCollisionBounds( Vector( -self.Size, -self.Size, -self.Size ), Vector( self.Size, self.Size, self.Size ) );
	
	// set mass and damping
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then

		phys:SetMass( 30 );
		phys:SetDamping( 0.8, 0.8 );
		phys:Wake();
		
	end
	
	// store last movement
	self.LastMove = CurTime();
	
	// spawn the view model
	local viewmodel = ents.Create( "zing_viewmodel" );
	viewmodel:SetPos( self:GetPos() );
	viewmodel:Spawn();
	viewmodel:SetOwner( self.Entity );
	self.dt.ViewModel = viewmodel;
	
	self:DeleteOnRemove( viewmodel );
	
end


/*------------------------------------
	OutOfBounds()
------------------------------------*/
function ENT:OutOfBounds()

	if( self:WaterLevel() >= 3 || self.MakeWaterSplash ) then
	
		self.MakeWaterSplash = false;
	
		local effect = EffectData();
		effect:SetOrigin( self:GetPos() );
		util.Effect( "Zinger.WaterSplash", effect );
		
	else

		util.Explosion( self:GetPos(), 0 );
		
	end
	
	// we went oob we should no longer be welded to anything
	constraint.RemoveConstraints( self, "Weld" );
	
	// get owner then destroy
	local pl = self:GetOwner();
	SafeRemoveEntityDelayed( self, 0 );
	
	// let them look at what they did wrong for 2 seconds
	timer.Simple( 2, function()
	
		if ( !IsValid( pl ) ) then
		
			return;
			
		end
	
		// add back to queue
		GAMEMODE:AddToQueue( pl, true );
		
	end );
	
end


/*------------------------------------
	PhysicsCollide()
------------------------------------*/
function ENT:PhysicsCollide( data, physobj )

	// not bouncing by default
	local bounce = false;
	
	// enable damping and drag again
	if( self.HasJumped ) then
	
		self.HasJumped = false;
	
		physobj:EnableDrag( true );
		physobj:SetDamping( self.LinearDamping or 0.8, self.LinearDamping or 0.8 );
	
	end
	
	// check for world
	local hitWorld = data.HitEntity:IsWorld() || data.HitEntity:GetMoveType() == MOVETYPE_PUSH;
	if ( hitWorld ) then
		
		// run trace of collision
		local trace = {};
		trace.start = self:GetPos();
		trace.endpos = data.HitPos + ( data.HitNormal * ( self.Size * 2 ) );
		trace.filter = self;
		local tr = util.TraceLine( trace );
		
		// check if we're out of bounds
		if ( IsOOB( tr ) ) then
		
			rules.Call( "OutOfBounds", self );
			
		elseif ( self.OnTee ) then
		
			self.OnTee = false;
			
			rules.Call( "TeePlayer", self:Team() );
			
		end
	
	end
	
	// bounce off world surfaces if they are within our normal threshold
	if ( hitWorld && Vector( 0, 0, 1 ):Dot( data.HitNormal ) >= -0.35 ) then
	
		bounce = true;
		
		// particle effect on impact with world
		ParticleEffect( "Zinger.BallImpact", data.HitPos, angle_zero, self.Entity );
		
		// play the sound where the collision happened, not just on the ball!
		WorldSound( table.Random( BounceSounds ), data.HitPos, 75, 100 );
		
	elseif ( !hitWorld ) then
	
		// bounce of other balls
		if ( IsBall( data.HitEntity ) ) then
		
			bounce = true;
			
			// collision sound
			WorldSound( table.Random( CollideSounds ), data.HitPos, 75, 100 );
			
			// call event
			GAMEMODE:BallHitBall( self, data.HitEntity );
			
		elseif ( !IsCup( data.HitEntity ) && !IsCrate( data.HitEntity ) && !IsMagnet( data.HitEntity ) ) then
		
			// particle effect on impact with world
			ParticleEffect( "Zinger.BallImpact", data.HitPos, angle_zero, self.Entity );
			
			// play the sound where the collision happened, not just on the ball!
			WorldSound( table.Random( BounceSounds ), data.HitPos, 75, 100 );
		
		end
	
	end
	
	// bouncing?
	if ( bounce ) then
	
		// calculate bounce normal
		local normal = data.OurOldVelocity:GetNormal();
		if( !hitWorld ) then
		
			normal = ( data.HitObject:GetPos() - physobj:GetPos() ):GetNormal();
		
		end
		local dot = data.HitNormal:Dot( normal * -1 );
		local reflect = ( 2 * data.HitNormal * dot ) + normal;

		local speed = math.max( data.OurOldVelocity:Length(), data.Speed );

		// bounce me
		local scale = 1;
		if( self:GetStone() ) then
		
			scale = 0.2;
			
		end
		physobj:SetVelocity( reflect * speed * 0.8 * scale );
		
		// bounce other
		local scale = 1;
		if( IsBall( data.HitEntity ) && data.HitEntity:GetStone() ) then
		
			scale = 0.2;
			
		end
		data.HitObject:SetVelocity( reflect * -speed * 0.8 * scale );
		
	end
	
end


/*------------------------------------
	Hit
------------------------------------*/
function ENT:Hit( dir, power )
	
	// get physics object
	local phys = self:GetPhysicsObject();
	
	// validate
	if ( !IsValid( phys ) ) then
	
		return;
	
	end
	
	// which sound bank to use
	local sounds = ( power > 40 ) && DriveSounds || PuttSounds;
	
	// play sound
	WorldSound( table.Random( sounds ), phys:GetPos(), 75, 100 );
	
	// particle effect on drive
	ParticleEffect( "Zinger.BallDrive", self:GetPos(), dir:Angle(), self.Entity );
	
	// hit the ball
	phys:Wake();
	phys:ApplyForceCenter( dir * power * phys:GetMass() * 35 );
	
	// delay
	self.LastMove = CurTime() + 2;
	
	// validate owner
	local pl = self:GetOwner();
	if ( IsValid( pl ) ) then
	
		pl:AddStroke();
		
	end
	
end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// validate owner
	local pl = self:GetOwner();
	if ( !IsValid( pl ) ) then
	
		return;
		
	end
	
	// measure speed
	local speed = self:GetVelocity():Length();
	
	// check if we'ved stopped (or at least slowed down enough)
	if ( speed < 15 ) then
	
		// make sure we've stopped for the minimal amount of time
		if ( CurTime() - self.LastMove > rules.Call( "GetStopTime" ) ) then
		
			if ( !pl:CanHit() ) then
		
				// call event
				rules.Call( "EnableHit", pl, self );
				
			end
			
		end
		
	else
	
		// only update if we aren't already delayed
		if ( CurTime() > self.LastMove ) then
	
			// delay
			self.LastMove = CurTime();
			
		end
		
		pl:SetCanHit( false );
	
	end
	
	// hit the water?
	if( self:WaterLevel() >= 3 ) then
	
		rules.Call( "OutOfBounds", self );
		
	end
	
	self:NextThink( CurTime() );
	return true;
	
end


/*------------------------------------
	SafePosition
------------------------------------*/
function ENT:SafePosition( pos, stop )

	// don't go inside other balls
	local mins, maxs = Vector( -self.Size, -self.Size, -self.Size ), Vector( self.Size, self.Size, self.Size );
	local adjustedPos = pos;
	for i = 1, 8 do
	
		if( IsSpaceOccupied( adjustedPos, mins, maxs, self ) ) then
		
			adjustedPos.z = adjustedPos.z + ( maxs.z - mins.z );
		
		end
	
	end

	self:SetPos( adjustedPos );
	
	if ( stop ) then
	
		// stop in place
		local phys = self:GetPhysicsObject();
		if ( IsValid( phys ) ) then
		
			// disable then enable motion to kill any velocity
			phys:EnableMotion( false );
			phys:SetVelocity( vector_origin );
			phys:SetVelocityInstantaneous( vector_origin );
			timer.Simple( 0, function()
				if ( IsValid( phys ) ) then
				
					phys:EnableMotion( true );
					
				end
			end );
			
		end
		
	end

end
