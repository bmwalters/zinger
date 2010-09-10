
ITEM.Name			= "Shotgun";
ITEM.Description	= "Pelt your enemies with a load of buckshot";

ITEM.ViewModel		= "models/zinger/v_shotgun.mdl";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/v_shotgun.mdl";
	ITEM.InventoryRow		= 1;
	ITEM.InventoryColumn	= 3;
	ITEM.InventoryDistance	= 45;
	ITEM.InventoryAngles	= Angle( -22.5, 90, 0 );
	ITEM.InventoryPosition	= Vector( 0, -8, -8 );
	
	ITEM.Cursor				= Material( "zinger/hud/reticule" );
	ITEM.Tip				= "Hold USE to aim";

end



/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.HoldTime = CurTime() + 0.75;

	local pos, ang = self:GetWeaponPosition();
	local dir = self:GetAimVector();
	
	// fire bullets
	util.FireBullets( {
		Count = 8,
		Position = pos,
		Dir = dir,
		Spread = 0.05,
		Entity = self.Ball,
	} );
	
	// muzzle flash
	local effect = EffectData();
	effect:SetNormal( dir );
	effect:SetOrigin( pos );
	effect:SetAngle( dir:Angle() );
	effect:SetEntity( self.Ball );
	util.Effect( "Zinger.MuzzleShotgun", effect );
	
end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.HoldTime > CurTime();

end

