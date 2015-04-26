function LerpColor(percent, colorA, colorB)
	return Color(
		Lerp(percent, colorA.r, colorB.r),
		Lerp(percent, colorA.g, colorB.g),
		Lerp(percent, colorA.b, colorB.b),
		Lerp(percent, colorA.a, colorB.a)
	)
end


function IsBall(ent)
	return IsValid(ent) and ent.IsBall
end

function IsCrate(ent)
	return IsValid(ent) and ent.IsCrate
end

function IsMagnet(ent)
	return IsValid(ent) and ent.IsMagnet
end

function IsCup(ent)
	return IsValid(ent) and ent.IsCup
end

function IsTee(ent)
	return IsValid(ent) and ent.IsTee
end

function IsJumpPad(ent)
	return IsValid(ent) and ent.IsJumpPad
end

function IsTelePad(ent)
	return IsValid(ent) and ent.IsTelePad
end


function IsOOB(tr)
	return (tr.MatType == MAT_SLOSH or bit.band(util.PointContents(tr.HitPos), CONTENTS_WATER) == CONTENTS_WATER or tr.HitSky)
end


function IsWorldTrace(tr)
	-- assume movetype_push is a brush
	return (tr.HitWorld or (IsValid(tr.Entity) and tr.Entity:GetMoveType() == MOVETYPE_PUSH))
end


local developer = CreateConVar("zinger_developer", 0, FCVAR_ARCHIVE, "Enables developer features of Zinger!") -- GetConVar("developer")
function Dev()
	return developer:GetBool()
end

function dprint(...)
	if not Dev() then return end

	local s = "~ " .. table.concat({...}, "\t")
	MsgN(s)
end


function util.InchesToFeet(inches)
	local feet = math.floor(inches / 12)
	inches = inches % 12

	local text = (feet > 0) and (feet .. "'-") or ""
	text = text .. inches .. "\""

	return text
end


function util.OtherTeam(t)
	return (t == TEAM_ORANGE) and TEAM_PURPLE or TEAM_ORANGE
end

local color_red = Color(255, 0, 0)
local color_green = Color(0, 255, 0)
local color_blue = Color(0, 0, 255)
local color_gray40 = Color(40, 40, 40)
local color_white_a = Color(255, 255, 255, 64)

function debugoverlay.Trace(trace, tr, time)
	-- main line
	debugoverlay.Line(tr.StartPos, tr.HitPos, time, color_green)
	debugoverlay.Line(tr.HitPos, trace.endpos, time, color_red)

	-- start/hit/end
	debugoverlay.Cross(tr.StartPos, 8, time, color_gray40)
	debugoverlay.Cross(tr.HitPos, 8, time, color_gray40)
	debugoverlay.Cross(trace.endpos, 8, time, color_gray40)

	-- normal
	debugoverlay.Line(tr.HitPos, tr.HitPos + tr.HitNormal * 32, time, color_blue)

	-- bounding boxes
	if trace.mins and trace.maxs then
		debugoverlay.Box(tr.HitPos, trace.mins, trace.maxs, time, color_white_a)
		debugoverlay.Box(tr.StartPos, trace.mins, trace.maxs, time, color_white_a)
	end
end

--[[
local TraceLine = util.TraceLine
function util.TraceLine(trace)
	local tr = TraceLine(trace)

	if trace.debug then
		debugoverlay.Trace(trace, tr, trace.duration or 1)
	end

	return tr
end

local TraceHull = util.TraceHull
function util.TraceHull(trace)
	local tr = TraceHull(trace)

	if trace.debug then
		debugoverlay.Trace(trace, tr, trace.duration or 1)
	end

	return tr
end

local TraceEntity = util.TraceEntity
function util.TraceEntity(trace, entity)
	local tr = TraceEntity(trace, entity)

	if trace.debug then
		tr.mins = entity:OBBMins()
		tr.maxs = entity:OBBMaxs()

		debugoverlay.Trace(trace, tr, trace.duration or 1)
	end

	return tr
end
--]]

function IsSpaceOccupied(pos, mins, maxs, entity)
	-- ensure the area is empty
	local tr = util.TraceHull({
		start = pos,
		endpos = pos,
		mins = mins,
		maxs = maxs,
		filter = entity,
	})

	return tr.StartSolid
end

function table.RemoveValue(t, value)
	for i = #t, 1, -1 do
		if t[i] and t[i] == value then
			table.remove(i)
			return i
		end
	end
end

function HasBall(ply)
	local ent = ply:GetBall()
	if IsBall(ent) then
		return true, ent
	end

	return false
end
