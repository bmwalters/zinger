function EFFECT:Init(data)
	local ball = data:GetEntity()

	-- particle effect
	ParticleEffectAttach("Zinger.Dazed", PATTACH_ABSORIGIN_FOLLOW, ball, -1)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
