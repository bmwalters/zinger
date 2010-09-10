
ITEM.Name			= "Uzi";
ITEM.Description	= "'Yo boss, can I hold my gun like this?'";

ITEM.ViewModel		= "models/zinger/v_uzi.mdl";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/v_uzi.mdl";
	ITEM.InventoryRow		= 2;
	ITEM.InventoryColumn	= 3;
	ITEM.InventoryDistance	= 26;
	ITEM.InventoryAngles	= Angle( -22.5, 90, 0 );
	ITEM.InventoryPosition	= Vector( 0, 0, -4 );
	
	ITEM.Cursor				= Material( "zinger/hud/reticule" );
	ITEM.Tip				= "Hold USE to aim";

end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.NextFireTime = CurTime() + 0.05;
	self.HoldTime = CurTime() + 2;

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	if( self.NextFireTime <= CurTime() ) then
	
		self.NextFireTime = CurTime() + 0.1;

		local pos, ang = self:GetWeaponPosition();
		local dir = self:GetAimVector();
	
		// fire bullets
		util.FireBullets( {
			Count = 1,
			Position = pos,
			Dir = dir,
			Spread = 0.03,
			Entity = self.Ball,
		} );
		
		// muzzle flash
		local effect = EffectData();
		effect:SetNormal( dir );
		effect:SetOrigin( pos );
		effect:SetAngle( dir:Angle() );
		effect:SetEntity( self.Ball );
		util.Effect( "Zinger.MuzzleUzi", effect );
		
	end

	return self.HoldTime > CurTime();

end

