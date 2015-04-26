function EFFECT:Init(data)
	ParticleEffectAttach("Zinger.RocketTrail", PATTACH_POINT_FOLLOW, data:GetEntity(), data:GetAttachment())
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
