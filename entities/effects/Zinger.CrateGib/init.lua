
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local angle = data:GetAngle();
	local normal = data:GetNormal();
	
	self.Entity:SetModel( "models/zinger/crategib.mdl" );
	self.Entity:SetAngles( angle );
	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS );
	self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) );
	self.Entity:DrawShadow( true );
	self.Entity:CreateShadow();
	
	local phys = self.Entity:GetPhysicsObject();
	if( IsValid( phys ) ) then
	
		phys:Wake();
		phys:SetAngle( angle );
		phys:SetDamping( 0.8, 0.8 );
		phys:AddAngleVelocity( VectorRand() * 200 );
		phys:SetVelocity( normal * 50 );
	
	end
	
	self.DieTime = CurTime() + 3;

end


/*------------------------------------
	Think()
------------------------------------*/
function EFFECT:Think()

	local frac = math.Clamp( ( self.DieTime - CurTime() ) / 3, 0, 1 );

	self:SetColor( 255, 255, 255, 255 * frac );

	return ( self.DieTime > CurTime() );

end


/*------------------------------------
	Render()
------------------------------------*/
function EFFECT:Render()

	self.Entity:DrawModel();

end
