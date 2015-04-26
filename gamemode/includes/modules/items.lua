local Items = {}
local NumItems = 0
local MaxRow = 0


-- load up the base item because things need it
local path = "zinger/gamemode/includes/items/"
if SERVER then AddCSLuaFile(path .. "base.lua") end
include(path .. "base.lua")

-- load up the remaining items
for k, v in pairs(file.Find(path .. "*", "LUA")) do
	if v == "base.lua" then continue end

	local _, _, key = string.find(v, "([%w_]*)%.lua") -- was \.lua

	ITEM = CreateItem(key)

	if SERVER then
		AddCSLuaFile(path .. v)
	end
	include(path .. v)

	-- precache
	if ITEM.InventoryModel then
		ITEM.InventoryModel = Model(ITEM.InventoryModel)
	end
	if ITEM.ViewModel then
		ITEM.ViewModel = Model(ITEM.ViewModel)
	end

	if CLIENT then
		if ITEM.InventoryRow then
			MaxRow = math.max(MaxRow, ITEM.InventoryRow)
		end

		if ITEM.Help then
			GM:CreateHelpTopic("Items", ITEM.Name, ITEM.Help .. "\n")
		end
	end

	Items[key] = ITEM

	ITEM = nil

	NumItems = NumItems + 1
end


module("items", package.seeall)

function Call(ply, item, func, ...)
	if not item or not item[func] then return end

	local ball = ply:GetBall()
	if not IsBall(ball) then return end

	rawset(item, "Ball", ball)
	rawset(item, "Player", ply)

	-- call the function
	local status, ret = pcall(item[func], item, ...)

	-- cleanup for the next call
	rawset(item, "Player", nil)

	if status == true and ret ~= nil then
		return ret
	elseif status == false then
		Error(ret)
	end
end

function Get(key)
	return Items[key]
end

function GetCount()
	return NumItems
end

function GetMaxRow()
	return MaxRow
end

function Random()
	if table.Count(Items) == 0 then return end

	return table.Random(Items)
end

function GetAll()
	return Items
end

function Install(ply)
	if SERVER then
		ply.ItemData = {}
		ply.ActiveItems = {}
	end
end

if SERVER then
	function GetTable(ply, item)
		ply.ItemData[item] = ply.ItemData[item] or {}

		return ply.ItemData[item]
	end

	function ResetTable(ply, item)
		ply.ItemData[item] = {}
	end

	function SpawnCrate()
		-- get node and radius
		local node = GAMEMODE:GetRandomSupplyNode()
		if not IsValid(node) then
			Error("tryed to spawn items on a map with no supply nodes")
			return
		end

		local radius = node:SpawnRadius()

		-- find a random point that is not out of bounds and spawn an item there
		-- (in case the mapper fucked up, only give it 50 tries - Brandon)
		for i = 1, 50 do
			local angle = math.rad(math.random(0, 360))
			local dir = Vector(math.cos(angle), math.sin(angle), 0)

			local pos = node:GetPos() + dir * math.random(radius * 0.25, radius)

			-- trace down to see if its inbounds
			local tr = util.TraceHull({
				start = pos + Vector(0, 0, radius),
				endpos = pos - Vector(0, 0, radius),
				mins = Vector(-16, -16, -16),
				maxs = Vector(16, 16, 16),
			})

			if (tr.HitWorld and not IsOOB(tr) and not IsSpaceOccupied(tr.HitPos, Vector(-16, -16, -16), Vector(16, 16, 16))) then
				local ent = ents.Create("zing_crate")
				ent:Spawn()
				ent:SetPos(tr.HitPos)

				break
			end
		end
	end
end
