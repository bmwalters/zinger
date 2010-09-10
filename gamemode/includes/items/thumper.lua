
ITEM.Name				= "Thumper";
ITEM.Description		= "A throwable bomb used to blow your enemies to bits";
ITEM.ActionText			= "threw a";

ITEM.ViewModel			= "models/zinger/v_mallet.mdl";
ITEM.ViewModelPitchLock	= true;

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/v_mallet.mdl";
	ITEM.InventoryRow		= 4;
	ITEM.InventoryColumn	= 1;
	ITEM.InventoryDistance	= 40;
	ITEM.InventoryAngles	= Angle( 0, -90, 0 );
	ITEM.InventoryPosition	= Vector( 0, -6, -20 );
		
	ITEM.Tip		= "Press USE to swing";

end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	local swingDuration = self:SetViewModelAnimation( "swing" );
	
	self.Ball:EmitSound( "weapons/iceaxe/iceaxe_swing1.wav", 100, 50 );
	
	self.Swung = true;
	self.Hit = false;
	self.SwingTime = CurTime() + swingDuration + 0.35;

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	// did the mallet finish the swing anim?
	if( !self.Hit && ( self.SwingTime - 0.25 ) <= CurTime() ) then
	
		self.Hit = true;
		
		local pos, ang = self:GetWeaponPosition();

		// shake the earth!
		util.ScreenShake( pos, 8, 15, 2, 3072 );

		// emit particles
		local effect = EffectData();
		effect:SetEntity( self.Ball );
		effect:SetOrigin( pos );
		util.Effect( "Zinger.Thumper", effect );
	
	end

	return self.SwingTime >= CurTime();

end
