
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
	self:NextThink( -1 );
	
	self.Team = TEAM_SPECTATOR;
	
	// wake and disable drag
	// we calculate the throw vector as if we have none
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:EnableDrag( false );
		phys:Wake();
	
	end
	
end


/*------------------------------------
	PhysicsCollide()
------------------------------------*/
function ENT:PhysicsCollide()

	if( !self.dt.Active ) then

		self.dt.Active = true;
		
		local phys = self:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:EnableDrag( true );
			phys:SetDamping( 0.1, 0.5 );
		
		end

		// start timer
		self:NextThink( CurTime() );
		
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	debugoverlay.Sphere( self:GetPos(), 96, 0.05, Color( 255, 255, 255, 0 ) );
	
	local owner = self:GetOwner();

	// blow up?
	local entities = ents.FindInSphere( self:GetPos(), 96 );
	for k, v in pairs( entities ) do
	
		// only attack the opposing team
		if( IsBall( v ) && v:Team() != self.Team && !( v:GetNinja() || v:GetDisguise() ) ) then

			// blow up
			util.Explosion( self:GetPos(), 950, self.Team, self );
			self:Remove();
			
			return;
		
		end
	
	end
	
	self:NextThink( CurTime() );
	return true;

end
