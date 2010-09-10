
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local angle = data:GetAngle();
	local normal = data:GetNormal();
	local ball = data:GetEntity();
	
	if( !IsValid( ball ) ) then
	
		return;
		
	end
	
	// muzzle effect
	ParticleEffect( "Zinger.BlowgunAir", pos + normal * 10, angle, ball );

	// sound
	ball:EmitSound( "zinger/items/blowgun.mp3" );
	
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