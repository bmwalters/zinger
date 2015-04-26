function EFFECT:Init(data)
	ParticleEffectAttach("Zinger.Ninja", PATTACH_ABSORIGIN_FOLLOW, data:GetEntity(), data:GetAttachment())
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
