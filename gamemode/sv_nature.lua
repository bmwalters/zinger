local NextInsect = 0

-- clean up insects each hole
AddCleanupClass("zing_butterfly")
AddCleanupClass("zing_firefly")

function GM:SpawnInsect()
	-- count insects, check if we're at our target
	local numInsects = 0
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == "zing_insect_firefly" or v:GetClass() == "zing_insect_butterfly" then
			numInsects = numInsects + 1
		end
	end

	if numInsects >= INSECT_COUNT then
		return
	end

	local target = self:GetRandomHoleEntity()
	if IsValid(target) then
		local pos = VectorRand() * target:BoundingRadius() * math.Rand(1.1, 2.1)
		pos.z = math.abs(pos.z) + 8
		pos = target:GetPos() + pos

		local insect = ents.Create((self:GetSky() == SKY_NIGHT) and "zing_insect_firefly" or "zing_insect_butterfly")
		insect:SetPos(pos)
		insect:Spawn()
	end
end

function GM:NatureThink()
	-- check spawn time
	if NextInsect <= CurTime() then
		NextInsect = CurTime() + math.random(5, 15)

		self:SpawnInsect()
	end
end

function GM:SetSky(sky)
	local rc = RoundController()
	if IsValid(rc) then
		rc:SetNWInt("Sky", sky)
	else
		timer.Simple(0, function()
			self:SetSky(sky)
		end)
	end
end

function GM:NextSky()
	-- TODO: this should actually increment the sky
	self:SetSky(SKY_NIGHT)
end
