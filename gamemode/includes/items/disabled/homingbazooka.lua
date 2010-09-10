
ITEM.Name		= "Homing Bazooka";
ITEM.Description	= "A persistent rocket that hunts down your targeted opponent";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration		= 1.5;
ITEM.ViewModel		= "models/zinger/v_bazooka.mdl";
ITEM.ViewModelSkin	= 1;

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE to aim";
	ITEM.Image		= Material( "zinger/hud/items/homingbazooka" );
	
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
		local tr = self:GetTargetTrace();
		
		// fire direction
		local dir = ( tr.HitPos - pos );
		dir:Normalize();
		
		// create the rocket
		local rocket = ents.Create( "zing_homing_rocket" );
		rocket:SetPos( pos - dir * 16 );
		rocket:SetAngles( dir:Angle() );
		rocket:Spawn();
		rocket:SetOwner( self.Ball );
		
		// try and find an enemy ball at our target location
		local balls = ents.FindByClass( "zing_ball" );
		local closestBall = NULL;
		local closestDist = HOMING_TARGET_RADIUS;
		for k, v in pairs( balls ) do
		
			local dist = ( v:GetPos() - tr.HitPos ):Length();
			if( v:Team() != self.Player:Team() && dist <= closestDist ) then
			
				closestDist = dist;
				closestBall = v;
			
			end
		
		end
		rocket:SetTarget( closestBall );
		
		// debug overlay
		debugoverlay.Sphere( tr.HitPos, HOMING_TARGET_RADIUS, 1, Color( 0, 255, 0, 0 ) );
		
		// kick start it
		local phys = rocket:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:SetVelocity( dir * HOMING_ROCKET_SPEED );
		
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
