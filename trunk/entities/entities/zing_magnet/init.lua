
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.DieTime = CurTime() + MAGNET_DURATION;
	self.Team = TEAM_SPECTATOR;

	// setup
	self:DrawShadow( true );
	self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
		
	// wake and disable drag
	// we calculate the throw vector as if we have none
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:EnableDrag( false );
		phys:Wake();
		phys:SetMass( 10 );
	
	end
	
	// magnet sound
	self.Sound = CreateSound( self.Entity, Sound( "ambient/machines/combine_shield_loop3.wav" ) );	
		
end


/*------------------------------------
	OnRemove()
------------------------------------*/
function ENT:OnRemove()

	self.Sound:Stop();

end

/*------------------------------------
	GetSuctionPosition()
------------------------------------*/
function ENT:GetSuctionPosition()

	return ( self:GetAttachment( 1 ).Pos + self:GetAttachment( 2 ).Pos ) * 0.5;

end

/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// remove magnet
	if( self.DieTime <= CurTime() ) then
	
		self:Remove();
		return;
		
	end

	if( self.dt.Active ) then
	
		debugoverlay.Sphere( self:GetPos(), MAGNET_ATTRACT_RADIUS, 0.05, Color( 255, 255, 255, 0 ) );

		local owner = self:GetOwner();
		local balls = ents.FindByClass( "zing_ball" );
		local suctionPoint = self:GetSuctionPosition();
		
		if( !IsValid( owner ) ) then
		
			return;
			
		end

		// attract balls
		for k, v in pairs( balls ) do
		
			if( !v:IsConstrained() && v:Team() != owner:Team() ) then
				
				local phys = v:GetPhysicsObject();
				if( IsValid( phys ) ) then
				
					local dir = ( suctionPoint - phys:GetPos() );
					local dist = dir:Length();
					
					if( dist <= MAGNET_ATTRACT_RADIUS ) then
					
						// no need to use any nasty sqrts unless this is in range
						dir:Normalize();
						
						local force = dir * phys:GetMass() * ( MAGNET_ATTRACT_RADIUS - dist ) * MAGNET_ATTRACT_STRENGTH;
						if( force:LengthSqr() != 0 ) then
					
							phys:ApplyForceCenter( force );
							
						end
						
					end
				
				end
				
			end
		
		end
	
	end

	self:NextThink( CurTime() );
	return true;
	
end


/*------------------------------------
	GetPlaneSide()
------------------------------------*/
function ENT:GetPlaneSide( point )

	local normal = self:GetUp();
	local distance = normal:Dot( self:GetSuctionPosition() - normal * 16 );
	local pointDistance = normal:Dot( point ) - distance;
	
	// based on the distance to the plane determine what side we're on
	if( pointDistance < 0 ) then return 1; end
	
	return 0;
	
end


/*------------------------------------
	PhysicsCollide()
------------------------------------*/
function ENT:PhysicsCollide( data, physobj )

	if( !self.dt.Active ) then

		self.dt.Active = true;
		
		local phys = self:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:EnableDrag( true );
			phys:SetDamping( 0.1, 0.5 );
		
		end
		
		self.Sound:Play();
		self.Sound:ChangePitch( 150 );
		self.Sound:ChangeVolume( 0.1 );
		
	else
	
		if( IsBall( data.HitEntity ) && data.HitEntity:Team() != self.Team && !( data.HitEntity:GetNinja() || data.HitEntity:GetDisguise() ) ) then
	
			// ensure its near the tip of the magnet
			if( self:GetPlaneSide( data.HitPos ) == 0 ) then
			
				timer.Simple( 0, function()
				
					// add a monitor to them with the time remaining
					umsg.Start( "AddMonitorTimer", data.HitEntity:GetOwner() );
					umsg.Char( GAMEMODE:GetItemByKey( "magnet" ).Index );
					umsg.Float( self.DieTime - CurTime() );
					umsg.End();
				
					// weld
					data.HitEntity:EmitSound( "Metal.SawbladeStick" );
					constraint.Weld( data.HitEntity, self, 0, 0, 0, 0, false );
					
				end );
				
			end
		
		end
		
	end

end

