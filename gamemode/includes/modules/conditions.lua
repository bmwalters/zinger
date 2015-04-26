local Conditions = {}

-- load up the base item because things need it
local path = "zinger/gamemode/includes/conditions/"
include(path .. "base.lua")

-- load up the remaining conditions
for k, v in pairs(file.Find(path .. "*", "LUA")) do
	if v == "base.lua" then
		if SERVER then
			AddCSLuaFile(path .. v)
		end
		return
	end

	local _, _, key = string.find(v, "([%w_]*)%.lua") -- was \.lua

	CONDITION = CreateCondition(key)

	if SERVER then
		AddCSLuaFile(path .. v)
	end
	include(path .. v)

	Conditions[key] = CONDITION

	CONDITION = nil
end


module("conditions", package.seeall)

function Call(ply, condition, func, ...)
	if not (condition and condition[func]) then return end

	local ball = ply:GetBall()
	if not IsBall(ball) then return end

	rawset(condition, "Ball", ball)
	rawset(condition, "Player", ply)

	-- call the function
	local status, ret = pcall(condition[func], condition, ...)

	-- cleanup for the next call
	rawset(condition, "Player", nil)

	if status == true and ret then
		return ret
	elseif status == false then
		Error(ret)
	end
end

function Get(key)
	return Conditions[key]
end

function GetAll()
	return Conditions
end

function Install(ply)
	if SERVER then
		ply.ConditionData = {}
		ply.ActiveConditions = {}
	end
end

if SERVER then
	function GetTable(ply, condition)
		ply.ConditionData[condition] = ply.ConditionData[condition] or {}

		return ply.ConditionData[condition]
	end

	function ResetTable(ply, condition)
		ply.ConditionData[condition] = {}
	end
end
