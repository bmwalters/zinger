local function GetCursorTrace(ply)
	local pos = ply:GetShootPos()
	local dir = ply:GetCursorVector()

	return util.TraceLine({
		start = pos,
		endpos = pos + (dir * 2048)
	})
end

local function SpawnEntity(ply, class, model) -- pretty much ripped from sandbox
	-- get position and trace
	local pos = ply:GetShootPos()
	local trace = GetCursorTrace(ply)

	-- attempt to create
	local ent = ents.Create(class)
	if not IsValid(ent) then
		return
	end

	-- setup entity
	ent:SetModel(model)
	ent:SetAngles(vector_origin)
	ent:SetPos(trace.HitPos)
	ent:Spawn()
	ent:Activate()

	-- find flush position
	local flush = trace.HitPos - (trace.HitNormal * 512)
	flush = ent:NearestPoint(flush)
	flush = ent:GetPos() - flush
	flush = trace.HitPos + flush

	-- set position
	ent:SetPos(flush)

	return ent
end

local debugcmds = {
	testparticle = function(ply, args) -- particle tests
		local trace = GetCursorTrace(ply)
		ParticleEffect(args[2] or "", trace.HitPos + (trace.HitNormal * 24), vector_origin, ply)
	end,
	testeffect = function(ply, args) -- effect tests
		local trace = GetCursorTrace(ply)

		local effect = EffectData()
		effect:SetOrigin(trace.HitPos + trace.HitNormal * 24)
		effect:SetNormal(trace.HitNormal)
		util.Effect(args[2] or "", effect)
	end,
	spawnent = function(ply, args)
		local trace = GetCursorTrace(ply)

		local ent = ents.Create(args[2])
		ent:Spawn()
		ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)
	end,
	fish = function(ply, args)
		local trace = GetCursorTrace(ply)

		local ent = ents.Create("func_fish_pool")
		ent:SetKeyValue("max_range", "200")
		ent:SetKeyValue("fish_count", "10")
		ent:SetKeyValue("model", "models/zinger/butterfly.mdl")
		ent:SetPos(trace.HitPos - trace.HitNormal * 32)
		ent:Spawn()
		ent:Activate()
	end,
	forcestart = function(ply, args) -- match start
		rules.Call("StartHole")
	end,
	forcenext = function(ply, args) -- next hole
		GAMEMODE:PrepareNextHole()
		rules.Call("StartHole")
	end,
	giveall = function(ply, args) -- give all items
		for _, item in pairs(items.GetAll()) do
			inventory.Give(ply, item, tonumber(args[2]))
		end
	end,
	give = function(ply, args)
		local item = items.Get(args[2]) -- give item
		if not item then
			return
		end

		inventory.Give(ply, item, tonumber(args[3]))
	end,
	spawnmodel = function(ply, args)
		local model = args[2]
		if not util.IsValidModel(model) then
			return
		end

		SpawnEntity(ply, "prop_physics", model)
	end,
	dumpitems = function(ply, args) -- used for updating the websites (we're lazy)
		-- bbcode or html
		local bbcode = (args[2] == "bbcode")

		-- opening element
		local itemdata = (not bbcode) and "<ul>\n" or "[list]\n"

		-- iterate through all the items
		for _, item in pairs(GAMEMODE:GetItems()) do
			-- add to list
			itemdata = itemdata .. (not bbcode) and "<li>" or "[*]"
			itemdata = itemdata .. item.Name .. " - " .. item.Description
			itemdata = itemdata .. (not bbcode) and "</li>\n" or "\n"
		end

		-- closing element
		itemdata = itemdata .. (not bbcode) and "</ul>\n" or "[/list]\n"

		file.Write("zingeritems.txt", itemdata)
	end,
	rings = function(ply, args) -- activate all rings
		local rings = GAMEMODE:GetHoleRings()
		for _, ring in pairs(rings) do
			rules.Call("RingPassed", ring, ply:GetBall())
		end
	end,
	sky = function(ply, args)
		local time = args[2]
		if time == "dawn" then
			GAMEMODE:SetSky(SKY_DAWN)
		elseif time == "day" then
			GAMEMODE:SetSky(SKY_DAY)
		elseif time == "dusk" then
			GAMEMODE:SetSky(SKY_DUSK)
		elseif time == "night" then
			GAMEMODE:SetSky(SKY_NIGHT)
		end
	end,
	suicide = function(ply, args)
		rules.Call("OutOfBounds", ply:GetBall())
	end,
}

local function ZingerDebug(ply, cmd, args) -- just some basic debug utils
	-- super admins only
	if (IsValid(ply) and not ply:IsSuperAdmin()) or not args[1] then return end

	-- grab action
	local action = string.lower(args[1] or "")

	if debugcmds[action] then
		debugcmds[action](ply, args)
	end
end
concommand.Add("zinger_debug", ZingerDebug, nil, "Zinger debug admin utils")

local function HitCommand(ply, cmd, args)
	if GAMEMODE:GetRoundState() ~= ROUND_ACTIVE then return end

	local ball = ply:GetBall()
	if not IsBall(ball) or not ply:CanHit() then return end

	-- get the direction
	local dir = Vector(tonumber(args[1]), tonumber(args[2]), 0)

	-- get power
	local power = math.Clamp(tonumber(args[3]) or 0, 0, 100)

	-- when the player is on the tee, make sure they've hit it
	-- hard enough to get the ball off
	if ball.OnTee then
		power = math.max(power, 5)
	end

	ply:HitBall(dir, power)
end
concommand.Add("hit", HitCommand)

local decalfrequency = GetConVar("decalfrequency")
local function SprayCommand(ply, cmd, args)
	local ball = ply:GetBall()
	if not IsBall(ball) then return end

	local pos = ball:GetPos()

	local tr = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0, 0, 48),
		mask = MASK_SOLID_BRUSHONLY,
		filter = ball,
	})
	if tr.Hit then
		if ply.NextSprayTime <= CurTime() then
			ply.NextSprayTime = CurTime() + decalfrequency:GetInt()

			-- sound
			sound.Play(Sound("SprayCan.Paint"), ball:GetPos(), 100, 100)

			-- decal
			ply:SprayDecal(tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		end
	end
end
concommand.Add("spray", SprayCommand)

local function ItemCommand(pl, cmd, args)
	if GAMEMODE:GetRoundState() ~= ROUND_ACTIVE then return end

	local ball = ply:GetBall()
	if not IsBall(ball) then
		return
	end

	-- grab action
	local action = string.lower(args[1] or "")

	-- equipping
	if action == "equip" then
		local item = items.Get(args[2])
		if item then
			inventory.Equip(ply, item)
		end
	-- unequipping
	elseif action == "unequip" then
		inventory.Unequip(ply)
	-- using
	elseif action == "use" then
		if ball.OnTee then return end

		inventory.Activate(ply)
	end
end
concommand.Add("item", ItemCommand)
