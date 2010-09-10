
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local angle = data:GetAngle();
	
	local up = angle:Up();
	local forward = angle:Forward();
	local right = angle:Right();
	
	// top
	local lpos, lang = LocalToWorld( Vector( 0, 0, 16 ), Angle( 0, 0, 0 ), pos, angle );
	local effect = EffectData();
	effect:SetOrigin( lpos );
	effect:SetAngle( lang );
	effect:SetNormal( up );
	util.Effect( "Zinger.CrateGib", effect );
	
	// bottom
	local lpos, lang = LocalToWorld( Vector( 0, 0, -16 ), Angle( 180, 0, 0 ), pos, angle );
	local effect = EffectData();
	effect:SetOrigin( lpos );
	effect:SetAngle( lang );
	effect:SetNormal( up * -1 );
	util.Effect( "Zinger.CrateGib", effect );
	
	// front
	local lpos, lang = LocalToWorld( Vector( 0, -16, 0 ), Angle( 90, -90, 0 ), pos, angle );
	local effect = EffectData();
	effect:SetOrigin( lpos );
	effect:SetAngle( lang );
	effect:SetNormal( right );
	util.Effect( "Zinger.CrateGib", effect );
	
	// back
	local lpos, lang = LocalToWorld( Vector( 0, 16, 0 ), Angle( 90, 90, 0 ), pos, angle );
	local effect = EffectData();
	effect:SetOrigin( lpos );
	effect:SetAngle( lang );
	effect:SetNormal( right * -1 );
	util.Effect( "Zinger.CrateGib", effect );
	
	// left
	local lpos, lang = LocalToWorld( Vector( -16, 0, 0 ), Angle( -90, 0, 0 ), pos, angle );
	local effect = EffectData();
	effect:SetOrigin( lpos );
	effect:SetAngle( lang );
	effect:SetNormal( forward * -1 );
	util.Effect( "Zinger.CrateGib", effect );
	
	// right
	local lpos, lang = LocalToWorld( Vector( 16, 0, 0 ), Angle( 90, 0, 0 ), pos, angle );
	local effect = EffectData();
	effect:SetOrigin( lpos );
	effect:SetAngle( lang );
	effect:SetNormal( forward );
	util.Effect( "Zinger.CrateGib", effect );
	
end


/*------------------------------------
	Think()
------------------------------------*/
function EFFECT:Think()

	return false;

end


/*------------------------------------
	Render()
------------------------------------*/
function EFFECT:Render()
end
