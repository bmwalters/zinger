function util.Explosion(pos, strength, team, entity)
	local offset = pos + Vector(0, 0, 16)

	-- try to find the ground
	local tr = util.TraceLine({
		start = offset,
		endpos = offset + Vector(0, 0, -48),
		mask = MASK_SOLID_BRUSHONLY,
	})

	debugoverlay.Line(tr.StartPos, tr.HitPos, 1, color_white)

	-- prevent us from decaling the entity if they passed it
	if IsValid(entity) then
		entity:SetNotSolid(true)
	end

	-- decal
	util.Decal("Zinger.Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	-- prevent us from decaling the entity if they passed it
	if IsValid(entity) then
		entity:SetNotSolid(false)
	end

	-- explosion effect
	local effect = EffectData()
	effect:SetOrigin(tr.HitPos + tr.HitNormal * 24)
	effect:SetNormal(tr.HitNormal)
	util.Effect("Zinger.Explosion", effect)

	-- kill butterflies in range
	debugoverlay.Sphere(pos, 96, 1, Color(0, 128, 255, 0))
	for _, butterfly in pairs(ents.GetAll()) do
		if butterfly:GetClass() ~= "zing_butterfly" then continue end

		local butterflyPos = butterfly:GetPos()
		local dist = (pos - butterflyPos):Length()

		if dist <= 128 then
			ParticleEffect("Zinger.ButterflyDeath", butterflyPos, vector_origin, -1)
			butterfly:Remove()
		end
	end

	-- no need to calculate force if the strength is zero
	if (not strength) or strength == 0 then
		return
	end

	debugoverlay.Sphere(pos, EXPLOSION_DISTANCE, 1, Color(255, 128, 0, 0))

	-- find all entities in range
	for k, v in pairs(ents.FindInSphere(pos, EXPLOSION_DISTANCE)) do
		-- don't affect non-balls or balls that are on the tee
		if (not IsBall(v)) or v.OnTee then continue end

		-- ignore own team
		if (v:Team() == team) then continue end

		local diff = (v:GetPos() - pos)
		local dist = diff:Length()

		-- explosion falloff
		local falloff = math.Clamp(1 - (dist / EXPLOSION_DISTANCE), 0, 1)

		-- always blow up with an upwards force
		local dir = diff:GetNormal()
		dir.z = 1
		dir:Normalize()

		-- punt their ball
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(dir * phys:GetMass() * (strength or 750) * falloff * DAMAGE_MULTIPLIER)
		end
	end

	util.ScreenShake(pos, 5, 5, 0.25, EXPLOSION_DISTANCE + (MAX_VIEW_DISTANCE * 1.5))
end

function util.FireBullets(bullet)
	for i = 1, (bullet.Count or 1) do
		-- apply spread to bullet
		local dir = bullet.Dir + (VectorRand() * bullet.Spread)
		dir:Normalize()

		local tr = util.TraceLine({
			start = bullet.Position,
			endpos = bullet.Position + dir * 16384,
			filter = bullet.Entity,
		})

		if IsValid(tr.Entity) and IsBall(tr.Entity) then
			local phys = tr.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceCenter(dir * phys:GetMass() * (bullet.Force or 240) * DAMAGE_MULTIPLIER)
			end
		end

		util.ParticleTracerEx("Zinger.Tracer", tr.StartPos, tr.HitPos, true, bullet.Entity:EntIndex(), -1)

		debugoverlay.Line(tr.StartPos, tr.HitPos, 1, color_white)

		ParticleEffect("Zinger.BulletImpact", tr.HitPos, angle_zero, ball)
	end
end
