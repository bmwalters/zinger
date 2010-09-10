
ITEM.Name			= "Bazooka";
ITEM.Description	= "Launch a rocket at your inferior opponents";
ITEM.ActionText		= "launched a";

ITEM.ViewModel		= "models/zinger/v_bazooka.mdl";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/v_bazooka.mdl";
	ITEM.InventoryRow		= 3;
	ITEM.InventoryColumn	= 1;
	ITEM.InventoryDistance	= 60;
	ITEM.InventoryAngles	= Angle( -10, 45, 20 );
	ITEM.InventoryPosition	= Vector( 0, -8, -8 );
	
	ITEM.Cursor		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE to aim";
	ITEM.Help		= "Blah blah test test";

end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.HoldTime = CurTime() + 0.75;

	local pos, ang = self:GetWeaponPosition();
	local targetPos = self:GetTrace().HitPos;
	
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


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.HoldTime > CurTime();

end
