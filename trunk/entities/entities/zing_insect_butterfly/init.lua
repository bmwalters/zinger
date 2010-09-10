
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.BaseClass.Initialize( self );
	
	self:SetModel( "models/zinger/butterfly.mdl" );
	self:ResetSequence( self:LookupSequence( "idle" ) );
	self:SetPlaybackRate( 1.0 );
	self:SetMoveType( MOVETYPE_NOCLIP );
	
	self:SetColor( math.random( 100, 255 ), math.random( 100, 255 ), math.random( 100, 255 ), 255 );

end


/*------------------------------------
	MoveToTarget()
------------------------------------*/
function ENT:MoveToTarget( target )

	// ensure our target position is still visible
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = ( target:GetPos() + self.Offset ),
		filter = { self, target },
	} );
	if( tr.Fraction < 1 ) then
	
		self.NextTargetTime = CurTime();
		self.NextPositionTime = CurTime();
		
	end

	local dir = ( ( target:GetPos() + self.Offset ) - self:GetPos() );
	local dist = dir:Length();
	dir:Normalize();
	
	// approach velocity
	local velocity = ( dir + VectorRand() * 0.05 ):GetNormal() * dist;
	//velocity.z = velocity.z + math.Rand( -100, 100 );
	
	local dir = ( self:GetPos() - target:GetPos() );
	local dist = dir:Length();
	dir:Normalize();
	local radius = target:BoundingRadius() + self:BoundingRadius();
	if( dist < radius ) then

		velocity = velocity + dir * ( radius - dist ) * 2;
	
	end
	
	// apply to existing velocity
	velocity = self:GetVelocity() + velocity;
	
	// friction
	velocity = velocity * ( 0.95 - FrameTime() * 4 );
	
	// clamp
	local speed = velocity:Length();
	velocity:Normalize();
	velocity = velocity * math.min( speed, 100 );
	
	// angles
	local angles = self:GetAngles();
	angles = LerpAngle( FrameTime() * 4, angles, velocity:Angle() );
	angles.p = math.Clamp( angles.p, -15, 15 );
	angles.r = math.Clamp( angles.r, -20, 20 );
	self:SetAngles( angles );
	
	if ( math.AngleDifference( angles.y, velocity:Angle().y ) > 2 ) then
	
		self:SetPlaybackRate( 2.0 );
		velocity.x = 0;
		velocity.y = 0;
	
	elseif ( velocity.z > 1 ) then
	
		self:SetPlaybackRate( 3.0 );
		
	elseif ( velocity.z < 1 ) then
	
		self:SetPlaybackRate( 0.8 );
		
	else
	
		if ( math.random( 1, 20 ) == 20 ) then
		
			velocity.z = velocity.z + math.Rand( 100, 300 );
			self:SetPlaybackRate( 3.0 );
			
		else
		
			self:SetPlaybackRate( 1.0 );
			
		end
	
	end
	
	self:SetLocalVelocity( velocity );

end
