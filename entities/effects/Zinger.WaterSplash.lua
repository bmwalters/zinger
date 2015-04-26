local SplashSounds = {
	Sound("zinger/watersplash1.wav"),
	Sound("zinger/watersplash2.wav"),
	Sound("zinger/watersplash3.wav"),
	Sound("zinger/watersplash4.wav"),
	Sound("zinger/watersplash5.wav")
}

function EFFECT:Init(data)
	local pos = data:GetOrigin()

	-- particles
	ParticleEffect("Zinger.WaterSplash", pos, angle_zero, Entity(0))

	-- sound
	sound.Play(SplashSounds[math.random(1, #SplashSounds)], pos, 100, 100)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
