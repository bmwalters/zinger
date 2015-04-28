DeriveGamemode("fretta13")

GM.Name		= "Zinger!"
GM.Author	= "Arcadium Software"
GM.Email	= "team@the-arcadium.com"
GM.Website	= "http://the-arcadium.com"

-- setup fretta
GM.Help							= "Zinger! is a team based gamemode that combines action, adventure and strategy wrapped around a game of mini golf."
GM.TeamBased					= true
GM.RoundBased					= false
GM.AllowAutoTeam				= true
GM.AllowSpectating				= true
GM.SecondsBetweenTeamSwitches	= 60
GM.SelectModel					= false
GM.SelectColor					= false
GM.GameLength					= GAME_LENGTH

include("sh_enums.lua")

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("sh_enums.lua")
	AddCSLuaFile("cl_hud.lua")
	AddCSLuaFile("cl_init.lua")
	AddCSLuaFile("cl_nature.lua")
	AddCSLuaFile("cl_player_events.lua")
	AddCSLuaFile("sh_entity_extension.lua")
	AddCSLuaFile("sh_math_extension.lua")
	AddCSLuaFile("sh_player_extension.lua")
	AddCSLuaFile("sh_roundinfo.lua")
	AddCSLuaFile("sh_util_extension.lua")

	for _, f in pairs(file.Find("zinger/gamemode/includes/help/*", "LUA")) do
		AddCSLuaFile("zinger/gamemode/includes/help/"..f)
	end

	include("sv_resources.lua")
	include("sv_battlestats.lua")
	include("sv_bot.lua")
	include("sv_commands.lua")
	include("sv_gameplay.lua")
	include("sv_nature.lua")
	include("sv_player_events.lua")
	include("sv_player_extension.lua")
	include("sv_util_extension.lua")

	util.AddNetworkString("Zing_TeeTime")
	util.AddNetworkString("Zing_ItemAlert")
	util.AddNetworkString("Zing_ResetView")
	util.AddNetworkString("Zing_AddNotfication")
	util.AddNetworkString("Zing_EmitSoundTeam")
	util.AddNetworkString("Zing_GiveItem")
	util.AddNetworkString("Zing_TakeItem")
	util.AddNetworkString("Zing_EquipItem")
	util.AddNetworkString("Zing_UnequipItem")
	util.AddNetworkString("Zing_BeginBattleMusic")
	util.AddNetworkString("Zing_PlaySound")
	util.AddNetworkString("Zing_Cleanup")
	-- Fretta things
	util.AddNetworkString("PlayableGamemodes")
	util.AddNetworkString("RoundAddedTime")
	util.AddNetworkString("PlayableGamemodes")
	util.AddNetworkString("fretta_teamchange")
end

if CLIENT then
	include("cl_hud.lua")
	include("cl_nature.lua")
	include("cl_player_events.lua")
end

include("sh_entity_extension.lua")
include("sh_math_extension.lua")
include("sh_player_extension.lua")
include("sh_roundinfo.lua")
include("sh_util_extension.lua")

-- load modules
local path = "zinger/gamemode/includes/modules/"
for _, f in pairs(file.Find(path .. "*", "LUA")) do
	if SERVER then
		AddCSLuaFile(path .. f)
	end
	include(path .. f)
end

PrecacheParticleSystem("Zinger.Explosion")
PrecacheParticleSystem("Zinger.BallImpact")
PrecacheParticleSystem("Zinger.BallDrive")
PrecacheParticleSystem("Zinger.RingExplode")
PrecacheParticleSystem("Zinger.CratePickup")
PrecacheParticleSystem("Zinger.Ninja")
PrecacheParticleSystem("Zinger.ShellBrass")
PrecacheParticleSystem("Zinger.ShellShotgun")
PrecacheParticleSystem("Zinger.MuzzleFlash")
PrecacheParticleSystem("Zinger.BulletImpact")
PrecacheParticleSystem("Zinger.Fuse")
PrecacheParticleSystem("Zinger.Stone")
PrecacheParticleSystem("Zinger.TeleportRed")
PrecacheParticleSystem("Zinger.TeleportBlue")
PrecacheParticleSystem("Zinger.RocketMuzzleFlash")
PrecacheParticleSystem("Zinger.AC130Tracer")
PrecacheParticleSystem("Zinger.BlowgunAir")
PrecacheParticleSystem("Zinger.BlowDart")
PrecacheParticleSystem("Zinger.ShroomGrow")
PrecacheParticleSystem("Zinger.RocketTrail")
PrecacheParticleSystem("Zinger.Jump")
PrecacheParticleSystem("Zinger.WaterExplosion")
PrecacheParticleSystem("Zinger.WaterSplash")
PrecacheParticleSystem("Zinger.JumpTrail")
PrecacheParticleSystem("Zinger.ButterflyDeath")
PrecacheParticleSystem("Zinger.Thumper")
PrecacheParticleSystem("Zinger.Dazed")
PrecacheParticleSystem("Zinger.Waterfall")
PrecacheParticleSystem("Zinger.Help")
PrecacheParticleSystem("Zinger.HelpExplode")

game.AddDecal("Zinger.Scorch", {
	"zinger/decals/scorch1",
	"zinger/decals/scorch2",
	"zinger/decals/scorch3",
	"zinger/decals/scorch4",
	"zinger/decals/scorch5",
	"zinger/decals/scorch6",
	"zinger/decals/scorch7",
	"zinger/decals/scorch8",
	"zinger/decals/scorch9",
	"zinger/decals/scorch10",
	"zinger/decals/scorch11",
	"zinger/decals/scorch12",
})

-- load vgui files
local path = "zinger/gamemode/includes/vgui/"
for k, v in pairs(file.Find(path .. "*", "LUA")) do
	if SERVER then
		AddCSLuaFile(path .. v)
	else
		include(path .. v)
	end
end

require("rules")

local LastMouseX = 0
local LastMouseY = 0


function GM:CreateTeams()
	-- create spectators
	team.SetUp(TEAM_UNASSIGNED, "Cloud Watchers", Color(230, 230, 230), false)
	team.SetUp(TEAM_SPECTATOR, "Cloud Watchers", Color(230, 230, 230), true)
	team.SetSpawnPoint(TEAM_UNASSIGNED, "info_player_start")

	-- create red team
	team.SetUp(TEAM_ORANGE, "Sandbaggers", color_team_orange, true)
	team.SetSpawnPoint(TEAM_ORANGE, "info_player_start")

	-- create blue team
	team.SetUp(TEAM_PURPLE, "Bandits", color_team_purple, true)
	team.SetSpawnPoint(TEAM_PURPLE, "info_player_start")
end


local function ClipVelocity(velocity, normal, overbounce)
	-- Determine how far along plane to slide based on incoming direction.
	local backoff = velocity:Dot(normal) * overbounce
	local out = velocity - (normal * backoff)

	-- iterate once to make sure we aren't still moving through the plane
	local adjust = out:Dot(normal)
	if adjust < 0 then
		out = out - (normal * adjust)
	end

	return out
end


local function TryMove(pos, velocity, delta)
	local endPos = pos + velocity * delta

	local tr = util.TraceHull({
		start = pos,
		endpos = endPos,
		mins = OBSERVER_HULL_MIN,
		maxs = OBSERVER_HULL_MAX,
		mask = MASK_NPCWORLDSTATIC,
	})

	return tr
end


local planes = {}
local function ObserverMove(pl, mv)
	local forwardSpd = math.sign(mv:GetForwardSpeed()) * OBSERVER_SPEED
	local sideSpd = math.sign(mv:GetSideSpeed()) * OBSERVER_SPEED
	local upSpd = math.sign(mv:GetUpSpeed()) * OBSERVER_SPEED

	local velocity = mv:GetVelocity()
	local origin = mv:GetOrigin()

	-- if we're moving calculate a new velocity, otherwise just decay the old one
	if forwardSpd ~= 0 or sideSpd ~= 0 or upSpd ~= 0 then
		local angles = mv:GetMoveAngles()
		local forward = angles:Forward()
		local right = angles:Right()

		forward:Normalize()
		right:Normalize()

		local v = (forward * forwardSpd) + (right * sideSpd)
		v.z = v.z + upSpd

		velocity = velocity + v * FrameTime()
	end

	-- apply friction
	velocity = velocity * 0.95

	local primal_velocity = velocity

	-- use up to 4 iterations, because we can hit multiple planes
	local num_planes = 0
	local time = FrameTime()
	for i = 1, 4 do
		local tr = TryMove(origin, velocity, time)

		origin = tr.HitPos
		time = time - time * tr.Fraction

		-- no reason to perform further checks or clipping if we
		-- made it the whole distance without hitting anything.
		if tr.Fraction == 1 then
			break
		end

		num_planes = num_planes + 1
		planes[num_planes] = tr.HitNormal

		-- clip to all current planes
		for i = 1, num_planes do
			velocity = ClipVelocity(velocity, planes[i], 1)
		end

		if num_planes > 2 then
			local dir = planes[1]:Cross(planes[2])
			dir:Normalize()

			local d = dir:Dot(velocity)

			velocity = dir * d
		end

		-- stop dead to prevent twitching in corners
		if velocity:Dot(primal_velocity) <= 0 then
			velocity = vector_origin
		end
	end

	mv:SetVelocity(velocity)
	mv:SetOrigin(origin)
end


function GM:Move(ply, mv)
	local camera = ply:GetCamera()
	if not IsValid(camera) then
		-- add friction to spectators
		if ply:GetMoveType() == MOVETYPE_NOCLIP then
			ObserverMove(ply, mv)
		end

		return true
	end

	local pos = camera:GetPos()
	local viewdir = ply:GetAimVector()
	local cmd = ply:GetCurrentCommand()
	pos = pos - viewdir * cmd:GetMouseX()

	-- position camera
	mv:SetOrigin(pos)

	ply:UpdateAimVector()

	return true
end


function GM:KeyPress(pl, key)
	if CLIENT then
		if key == IN_USE then
			local item = inventory.Equipped()
			if item then
				-- use if instant
				if item.Cursor == nil then
					RunConsoleCommand("item", "use")
				else
					-- activate cursor
					self:SetCursor(item.Cursor)
				end
			end
		end
	end
end

function GM:KeyRelease(ply, key)
	if CLIENT then
		if key == IN_USE then
			-- clear cursor
			self:SetCursor(nil)
		end
	end
end


function GM:PlayerFootstep(ply, pos, foot, sound, volume, rf)
	return true
end


function GM:PlayerNoClip(ply, on)
	return false
end


function GM:OnPlayerCreated(ply)
	-- ball entity
	ply:SetNWEntity("Ball", NULL)

	-- camera entity
	ply:SetNWEntity("Camera", NULL)

	-- enable hit flag
	ply:SetNWBool("CanHit", false)

	-- number of strokes we have
	ply:SetNWFloat("Strokes", 0)

	if CLIENT then
		if ply == LocalPlayer() then
			-- local player creation hook
			self:OnLocalPlayerCreated(ply)
		end
	end

	items.Install(ply)
	inventory.Install(ply)

	if SERVER then
		ply.NextSprayTime = CurTime()
	end
end


function GM:Think()
	-- nature
	self:NatureThink()

	if SERVER then
		if (CurTime() > (self.NextUpdate or 0)) then
			self.NextUpdate = CurTime() + 0.5

			-- gameplay
			self:UpdateGameplay()

			-- supply crates
			rules.Call("UpdateCrates")
		end
	end

	if CLIENT then
		-- get player
		local ply = LocalPlayer()

		-- update mouse gestures
		controls.Update(ply)

		-- ensure the aim vector is set on the client
		if game.SinglePlayer() then
			ply:UpdateAimVector()
		end

		-- update music
		music.Update()
	end

	-- run think for all players
	for _, ply in pairs(player.GetAll()) do
		ply:Think()
	end

	return self.BaseClass.Think(self)
end


function GM:Tick()
	-- the clouds create a bunch of garbage- lets clean some of it up
	-- TODO: fix the garbage? not even sure if its possible with all
	-- the calculations involved!!!!
	collectgarbage("step", 90)
end
