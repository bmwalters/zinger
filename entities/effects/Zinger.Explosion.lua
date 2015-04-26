function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER

	-- particles
	ParticleEffect(water and "Zinger.WaterExplosion" or "Zinger.Explosion", pos, angle_zero, Entity(0))

	-- dynamic light
	local light = DynamicLight(0)
	light.Pos = pos
	light.Size = 256
	light.Decay = 512
	light.R = 255
	light.G = 230
	light.B = 0
	light.Brightness = 8
	light.DieTime = CurTime() + 3

	-- sound.Play("BaseExplosionEffect.Sound", pos, 100, 100)
	sound.Play(Sound(water and "WaterExplosionEffect.Sound" or "zinger/kablamos.mp3"), pos, 100, 100)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end