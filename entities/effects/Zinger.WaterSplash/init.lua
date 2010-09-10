
local SplashSounds = {
	Sound( "zinger/watersplash1.wav" ),
	Sound( "zinger/watersplash2.wav" ),
	Sound( "zinger/watersplash3.wav" ),
	Sound( "zinger/watersplash4.wav" ),
	Sound( "zinger/watersplash5.wav" )
}

/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();

	// particles
	ParticleEffect( "Zinger.WaterSplash", pos, angle_zero, Entity( 0 ) );
	
	// sound
	WorldSound( SplashSounds[ math.random( 1, #SplashSounds ) ], pos, 100, 100 );

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