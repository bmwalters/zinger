
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local angle = data:GetAngle();
	local normal = data:GetNormal();
	local ball = data:GetEntity();

	// dynamic light
	local light = DynamicLight( ball:EntIndex() );
	light.Pos = pos;
	light.Size = 256;
	light.Decay = 512;
	light.R = 255;
	light.G = 230;
	light.B = 0;
	light.Brightness = 5;
	light.DieTime = CurTime() + 0.5;
	
	// muzzle effect
	ParticleEffect( "Zinger.RocketMuzzleFlash", pos + normal * 10, angle, ball );

	// sound
	ball:EmitSound( "Weapon_RPG.Single" );
	
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