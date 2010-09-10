
ITEM.Name		= "Shotgun";
ITEM.Description	= "Pelt your enemies with a load of buckshot";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration		= 0.5;
ITEM.ViewModel		= "models/zinger/v_shotgun.mdl";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE to aim";
	ITEM.Image		= Material( "zinger/hud/items/shotgun" );
	
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

