function EFFECT:Init(data)
	local ball = data:GetEntity()
	local origin = data:GetOrigin()

	if not IsValid(ball) then return end

	-- particle effect
	ParticleEffect("Zinger.Thumper", origin, angle_zero, ball)
	-- ParticleEffectAttach("Zinger.JumpTrail", PATTACH_ABSORIGIN_FOLLOW, ball, -1)

	ball:EmitSound("coast.thumper_hit")
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
