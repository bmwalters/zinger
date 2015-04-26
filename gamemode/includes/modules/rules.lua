module("rules", package.seeall)

local Rules = {}
local CurrentRule

function Clear()
	-- clear table
	CurrentRule = nil
end

function Call(name, ...)
	local args = {...}
	-- make sure we've got our table
	if not CurrentRule then
		-- grab a unique copy
		CurrentRule = table.Copy(Rules[GAMEMODE:GetCurrentRules()])
	end

	if CurrentRule[name] then
		if SERVER then
			-- pass every event to stats
			stats.Call(name, unpack(args))
		end

		return CurrentRule[name](CurrentRule, unpack(args))
	end

	-- TODO: add a debug message?
end

if SERVER then
	function Pick()
		GAMEMODE:SetCurrentRules(1)
	end
end

-- load base rule
local path = "zinger/gamemode/includes/rules/"
if SERVER then AddCSLuaFile(path .. "base.lua") end
include(path .. "base.lua")

-- load rules
for _, f in pairs(file.Find(path .. "*", "LUA")) do
	if f == "base.lua" then continue end
	-- extract name
	local _, _, key = string.find(f, "([%w_]*)%.lua") -- was \.lua

	-- create base
	RULE = CreateRule()
	RULE.Key = key

	if SERVER then
		AddCSLuaFile(path .. f)
	end
	include(path .. f)

	-- add to list
	Rules[#Rules + 1] = RULE
	RULE.Index = #Rules

	RULE = nil
end

Rules[#Rules + 1] = CreateRule()
