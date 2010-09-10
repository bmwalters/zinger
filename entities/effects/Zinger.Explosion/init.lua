
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local water = ( util.PointContents( pos ) & CONTENTS_WATER ) == CONTENTS_WATER;

	// particles
	ParticleEffect( water && "Zinger.WaterExplosion" || "Zinger.Explosion", pos, angle_zero, Entity( 0 ) );
	
	// dynamic light
	local light = DynamicLight( 0 );
	light.Pos = pos;
	light.Size = 256;
	light.Decay = 512;
	light.R = 255;
	light.G = 230;
	light.B = 0;
	light.Brightness = 8;
	light.DieTime = CurTime() + 3;
	
	// sound
	//WorldSound( "BaseExplosionEffect.Sound", pos, 100, 100 );
	WorldSound( Sound( water && "WaterExplosionEffect.Sound" || "zinger/kablamos.mp3" ), pos, 100, 100 );

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