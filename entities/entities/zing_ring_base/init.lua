
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
	self:DrawShadow( false );
	self:SetModel( self.Model );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER );
	self:SetColor( 255, 255, 20, 255 );
	
	// if we're parented use a physics shadow to keep us solid
	if( IsValid( self:GetParent() ) ) then
	
		self.IsParented = true;
		self:MakePhysicsObjectAShadow( false, false );
		
	end
	
	// freeze
	local phys = self:GetPhysicsObject();
	if( IsValid( phys ) ) then

		phys:EnableMotion( false );
		
	end
	
	// create trigger
	local trigger = ents.Create( "zing_ring_trigger" );
	trigger:SetPos( self:GetPos() );
	trigger:SetAngles( self:GetAngles() );
	trigger:Spawn();
	trigger:SetParent( self );
	trigger:SetRing( self );
	self:DeleteOnRemove( trigger );
	
end


/*------------------------------------
	SetTeamDone()
------------------------------------*/
function ENT:SetTeamDone( t, bool )

	if ( t == TEAM_ORANGE ) then
	
		self.dt.RedDone = bool;
		
	elseif ( t == TEAM_PURPLE ) then
	
		self.dt.BlueDone = bool;
		
	end

end


/*------------------------------------
	IsInGround()
------------------------------------*/
function ENT:IsInGround()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector( 0, 0, 32 ),
		filter = self,
	} );
	
	return tr.Hit;

end


/*------------------------------------
	AlwaysSpawn()
------------------------------------*/
function ENT:AlwaysSpawn()

	return ( self.KeyValues[ 'spawnflags' ] == "1" );

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	if( self.IsParented ) then

		// update the physics object shadow to allow parenting
		local phys = self:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:UpdateShadow( self:GetPos(), self:GetAngles(), FrameTime() );
		
		end

		self:NextThink( CurTime() );
		return true;
		
	end

end
