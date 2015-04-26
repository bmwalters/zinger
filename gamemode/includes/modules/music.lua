if not CLIENT then return end

module("music", package.seeall)

local MusicSound
local Fade = 1.0
local NextTrack
local InBattle = false

-- battle music
local BattleMusicTracks = {
	-- file name			length
	{"evilmarch.mp3",		71 },
	{"graveblow.mp3",		102},
	{"interloper.mp3",		262},
	-- {"Nerves.mp3",		172},
	{"powerrestored.mp3",	48 },
	{"westernstreets.mp3",	108},
}

local MusicVolume = CreateConVar("cl_zing_musicvolume", "1", true, false)

function Precache()
	-- precache theme
	util.PrecacheSound("zinger/music/hamstermarch.mp3")

	-- precache music
	for _, song in pairs(BattleMusicTracks) do
		util.PrecacheSound("zinger/music/" .. song[1])
	end
end

local function GetVolume()
	return math.Clamp(MusicVolume:GetFloat(), 0, 1)
end

local function StopTrack()
	if not MusicSound then return end

	-- stop sound
	MusicSound:Stop()
	MusicSound = nil
end

local function Play(filename)
	-- stop if already playing
	StopTrack()

	-- create sound object
	MusicSound = CreateSound(LocalPlayer(), "zinger/music/" .. filename)
	MusicSound:PlayEx(GetVolume(), 100)
end

local function ChangeVolume(cvar, oldvalue, newvalue)
	if not MusicSound then return end

	MusicSound:ChangeVolume(newvalue * Fade)
end
cvars.AddChangeCallback("cl_zing_musicvolume", ChangeVolume)

local function TrackDone()
	StopTrack()

	-- play next battle track if needed
	if InBattle then
		local song = BattleMusicTracks[math.random(1, #BattleMusicTracks)]
		PlayTrack(song[1], song[2])
	end
end

function PlayTrack(song, duration)
	if not duration then
		-- we don't want to depend on this because it sucks, but at least fall back to it if needed
		duration = SoundDuration(song)
	end

	-- queue the song if we already have a song playing
	if MusicSound then
		NextTrack = {song, duration}
		return
	end

	-- reset fade fraction
	Fade = 1

	-- create sound object
	MusicSound = CreateSound(LocalPlayer(), "zinger/music/" .. song)
	MusicSound:Play()
	MusicSound:ChangeVolume(GetVolume())

	timer.Adjust("ZingerMusic", duration, 0, TrackDone)
	timer.Start("ZingerMusic")
end

function Update()
	if not NextTrack then return end

	-- slowly fade out
	Fade = math.Approach(Fade, 0, FrameTime() * 0.5)

	-- change the volume on the sound
	MusicSound:ChangeVolume(GetVolume() * Fade)

	-- if fading is done
	if Fade == 0 then
		-- start next track
		StopTrack()
		PlayTrack(NextTrack [1], NextTrack[2])
		NextTrack = nil
	end
end

function PlayTheme()
	-- clear flag
	InBattle = false

	-- start theme song
	PlayTrack("hamstermarch.mp3", 38)
end

function PlayBattle()
	-- set flag
	InBattle = true

	-- random track
	local song = BattleMusicTracks[math.random(1, #BattleMusicTracks)]
	PlayTrack(song[1], song[2])
end

local function BeginBattleMusic()
	PlayBattle()
end
net.Receive("Zing_BeginBattleMusic", BeginBattleMusic)
