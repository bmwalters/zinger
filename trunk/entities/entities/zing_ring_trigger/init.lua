
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );

// accessor functions
AccessorFunc( ENT, "Ring", "Ring" );

/*------------------------------------
	UpdateTransmitState()
------------------------------------*/
function ENT:UpdateTransmitState()

	// this is merely a serverisde trigger that has to be an anim :(
	// the client never needs to know we exist
	return TRANSMIT_NEVER;

end

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.Entities = {};
	self:SetRing( NULL );
	
	// setup
	self:SetSolid( SOLID_BBOX );
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );
	self:SetTrigger( true );
	self:SetNotSolid( true );
	self:DrawShadow( false );
	self:SetNoDraw( true );
	
	// rather large box, but we'll do an additioanl plane check to see if they
	// passed through the ring or not
	self:SetCollisionBounds( Vector( -64, -64, -64 ), Vector( 64, 64, 64 ) );
		
end

/*------------------------------------
	GetPlaneSide()
------------------------------------*/
function ENT:GetPlaneSide( point )

	local normal = self:GetUp();
	local distance = normal:Dot( self:GetPos() );
	local pointDistance = normal:Dot( point ) - distance;
	
	// based on the distance to the plane determine what side we're on
	if( pointDistance < 0 ) then return 1; end
	
	return 0;
	
end

/*------------------------------------
	StartEntity()
------------------------------------*/
function ENT:StartEntity( ent )

	self.Entities[ ent ] = self:GetPlaneSide( ent:GetPos() );

end

/*------------------------------------
	EndEntity()
------------------------------------*/
function ENT:EndEntity( ent )

	self.Entities[ ent ] = nil;

end

/*------------------------------------
	CheckEntities()
------------------------------------*/
function ENT:CheckEntities()

	local ring = self:GetRing();
	if( !IsValid( ring ) ) then
	
		return;
		
	end

	// check all the entities touching the ring
	// if their side swaps from a/b we know they passed through the ring
	// also, check distance to ensure they didn't skim past the outside of the ring
	for ent, side in pairs( self.Entities ) do
	
		if( IsValid( ent ) && !ring:IsTeamDone( ent:Team() ) && self:GetPlaneSide( ent:GetPos() ) != side && ( ent:GetPos() - self:GetPos() ):Length () <= 48 ) then
		
			ring:SetTeamDone( ent:Team(), true );
			rules.Call( "RingPassed", ring, ent );
		
			self.Entities[ ent ] = nil;
			
		end
	
	end
	
end

/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	self:CheckEntities();
	
	self:NextThink( CurTime() );
	return true;

end

/*------------------------------------
	StartTouch()
------------------------------------*/
function ENT:StartTouch( ent )

	if( ent:GetClass() == "zing_ball" ) then
	
		self:StartEntity( ent );
	
	end

end

/*------------------------------------
	EndTouch()
------------------------------------*/
function ENT:EndTouch( ent )

	if( ent:GetClass() == "zing_ball" ) then
	
		self:EndEntity( ent );

	end
	
end
