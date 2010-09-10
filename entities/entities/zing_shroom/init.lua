
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()
	
	self:DrawShadow( true );
	self:SetModel( self.Model );
	self:SetSolid( SOLID_BBOX );
	self:SetCollisionGroup( COLLISION_GROUP_NONE );
	self:SetMoveType( MOVETYPE_NONE );
	self:SetCollisionBounds( self:OBBMins(), self:OBBMaxs() );
	self:SetTrigger( true );

	self:NextThink( -1 );

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think( ent )

	self.dt.Impact = false;

end


/*------------------------------------
	StartTouch()
------------------------------------*/
function ENT:StartTouch( ent )

	if( IsBall( ent ) ) then
	
		local phys = ent:GetPhysicsObject();
		if( IsValid( phys ) ) then
	
			local normal = phys:GetVelocity();
			local speed = 200 + normal:Length();
			normal:Normalize();
		
			local hitNormal = ( ent:GetPos() - self:GetPos() );
			hitNormal.z = 0;
			hitNormal:Normalize();
		
			local dot = hitNormal:Dot( normal * -1 );
			local reflect = ( 2 * hitNormal * dot ) + normal;
			
			local plane = hitNormal:Cross( vector_up );
			plane:Normalize();
						
			debugoverlay.Cross( ent:GetPos(), 8, 5, color_black );
			debugoverlay.Line( ent:GetPos(), ent:GetPos() - normal * 128, 5, Color( 0, 255, 0, 255 ) );
			debugoverlay.Line( ent:GetPos(), ent:GetPos() + reflect * 128, 5, Color( 255, 0, 0, 255 ) );
			debugoverlay.Line( ent:GetPos() - plane * 64, ent:GetPos() + plane * 64, 5, Color( 255, 255, 255, 255 ) );
			
			phys:SetVelocity( reflect * speed * 2 );
			
			self.dt.Impact = true;
			self:NextThink( CurTime() + 1 );
			
			self:EmitSound( "zinger/boing.wav" );
	
		end
		
	end

end
