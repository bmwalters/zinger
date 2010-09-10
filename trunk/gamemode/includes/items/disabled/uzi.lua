
ITEM.Name		= "Uzi";
ITEM.Description	= "'Yo boss, can I hold my gun like this?'";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration		= 2;
ITEM.ViewModel		= "models/zinger/v_uzi.mdl";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE to aim";
	ITEM.Image		= Material( "zinger/hud/items/uzi" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.Data.NextFireTime = CurTime() + 0.05;
	self.Data.EndTime = CurTime() + self.Duration;

end


/*------------------------------------
	Equip()
------------------------------------*/
function ITEM:Equip()

	self:ActivateViewModel();

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

	if( SERVER ) then
	
		if( self.Data.NextFireTime <= CurTime() ) then
		
			self.Data.NextFireTime = CurTime() + 0.1;

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
	
	end

	return self.Data.EndTime > CurTime();

end

