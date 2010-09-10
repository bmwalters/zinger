
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
	self:SetMoveType( MOVETYPE_NONE );
	self:SetNotSolid( true );
	self:SetTrigger( true );
	self:SetAngles( Angle( 0, math.random( 0, 360 ), 0 ) );
	
end


/*------------------------------------
	StartTouch()
------------------------------------*/
function ENT:StartTouch( ent )

	self:EmitSound( "zinger/bush.wav", 100, math.random( 100, 110 ) );
	ParticleEffect( "Zinger.BushLeaves", ent:GetPos(), ( ent:GetPos() - self:GetPos() ):GetNormal():Angle(), -1 );

end


/*------------------------------------
	EndTouch()
------------------------------------*/
function ENT:EndTouch( ent )

	self:EmitSound( "zinger/bush.wav", 100, math.random( 100, 110 ) );
	ParticleEffect( "Zinger.BushLeaves", ent:GetPos(), ( ent:GetPos() - self:GetPos() ):GetNormal():Angle(), -1 );

end

