function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local angle = data:GetAngle()
	local normal = data:GetNormal()
	local ball = data:GetEntity()

	if not IsValid(ball) then return end

	-- muzzle effect
	ParticleEffect("Zinger.BlowgunAir", pos + normal * 10, angle, ball)

	-- sound
	ball:EmitSound("zinger/items/blowgun.mp3")
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end