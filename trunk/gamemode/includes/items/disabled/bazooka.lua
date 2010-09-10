
ITEM.Name		= "Bazooka";
ITEM.Description	= "Launch a rocket at your inferior opponents";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration		= 1.5;
ITEM.ViewModel		= "models/zinger/v_bazooka.mdl";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE to aim";
	ITEM.Image		= Material( "zinger/hud/items/bazooka" );
	
end


/*------------------------------------
	Equip()
------------------------------------*/
function ITEM:Equip()

	self:ActivateViewModel();
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration;

	if( SERVER ) then
	
		local pos, ang = self:GetWeaponPosition();
		local targetPos = self:GetTargetPosition();
		
		// fire direction
		local dir = ( targetPos - pos );
		dir:Normalize();
		
		// create the rocket
		local rocket = ents.Create( "zing_rocket" );
		rocket:SetPos( pos - dir * 16 );
		rocket:SetAngles( dir:Angle() );
		rocket:Spawn();
		rocket:SetOwner( self.Ball );
		
		local phys = rocket:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:SetVelocity( dir * ROCKET_SPEED );
		
		end
		
		// muzzle flash
		local effect = EffectData();
		effect:SetNormal( dir );
		effect:SetOrigin( pos );
		effect:SetAngle( ang );
		effect:SetEntity( self.Ball );
		util.Effect( "Zinger.MuzzleBazooka", effect );
	
	end
			
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function ITEM:Deactivate()

	self:DeactivateViewModel();

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.Data.EndTime > CurTime();

end
