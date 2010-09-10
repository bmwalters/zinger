
// client only 
if ( SERVER ) then return; end

// start module
module( 'music', package.seeall );


// variables
local MusicSound;
local Fade = 1.0;
local NextTrack;
local InBattle = false;

// battle music
local BattleMusicTracks = {
	// file name				length
	{ "Evil March.mp3",			71  },
	{ "Grave Blow.mp3",			102 },
	{ "Interloper.mp3",			262 },
//	{ "Nerves.mp3",				172 },
	{ "Power Restored.mp3",		48  },
	{ "Western Streets.mp3",	108 }
};

// convars
local MusicVolume = CreateConVar( "cl_zing_musicvolume", "1", true, false );


/*------------------------------------
	Precache
------------------------------------*/
function Precache()

	// precache theme
	Sound( "zinger/music/Hamster March.mp3" );
	
	// precache music
	for _, song in pairs( BattleMusicTracks ) do
	
		Sound( "zinger/music/" .. song[ 1 ] );
	
	end

end


/*------------------------------------
	GetVolume()
------------------------------------*/
local function GetVolume()

	return math.Clamp( MusicVolume:GetFloat(), 0, 1 );

end

/*------------------------------------
	StopTrack()
------------------------------------*/
local function StopTrack()

	// validate
	if ( !MusicSound ) then
	
		return;
		
	end
	
	// stop sound
	MusicSound:Stop();
	MusicSound = nil;

end


/*------------------------------------
	Play()
------------------------------------*/
local function Play( filename )

	// stop if already playing
	StopTrack();
	
	// create sound entity
	MusicSound = CreateSound( LocalPlayer(), Sound( "zinger/music/" .. filename ) );
	MusicSound:PlayEx( GetVolume(), 100 );
	
end


/*------------------------------------
	ChangeVolume()
------------------------------------*/
local function ChangeVolume( cvar, oldvalue, newvalue )

	// validate
	if ( !MusicSound ) then
	
		return;
		
	end
	
	// change the volume on the sound
	MusicSound:ChangeVolume( newvalue * Fade );

end
cvars.AddChangeCallback( "cl_zing_musicvolume", ChangeVolume );


/*------------------------------------
	TrackDone()
------------------------------------*/
local function TrackDone()

	// destroy
	StopTrack();
	
	// play next battle track if needed
	if ( InBattle ) then
	
		local song = table.Random( BattleMusicTracks );
		PlayTrack( song[ 1 ], song[ 2 ] );
	
	end

end


/*------------------------------------
	PlayTrack()
------------------------------------*/
function PlayTrack( song, duration )
	
	// validate the duration
	if ( !duration ) then
	
		// we don't want to depend on this because it sucks with mp3
		// but at least fall back to it if needed
		duration = SoundDuration( song );
		
	end
	
	// queue the song if we already have a song playing
	if ( MusicSound ) then
	
		NextTrack = { song, duration };
		return;
		
	end
	
	// reset fade fraction
	Fade = 1;
	
	// create sound entity
	MusicSound = CreateSound( LocalPlayer(), Sound( "zinger/music/" .. song ) );
	MusicSound:Play();
	MusicSound:ChangeVolume( GetVolume() );
	
	timer.Adjust( "ZingerMusic", duration, 0, TrackDone );
	timer.Start( "ZingerMusic" );

end


/*------------------------------------
	Update()
------------------------------------*/
function Update()

	// only fade when needed
	if ( NextTrack ) then
	
		// slowly fade out
		Fade = math.Approach( Fade, 0, FrameTime() * 0.5 );
		
		// change the volume on the sound
		MusicSound:ChangeVolume( GetVolume() * Fade );
		
		// are we done fading?
		if ( Fade == 0 ) then
		
			// start next track
			StopTrack();
			PlayTrack( NextTrack [ 1 ], NextTrack[ 2 ] );
			NextTrack = nil;
		
		end
		
	end

end


/*------------------------------------
	PlayTheme()
------------------------------------*/
function PlayTheme()

	// clear flag
	InBattle = false;
	
	// start theme song
	PlayTrack( "Hamster March.mp3", 38 );
	
end


/*------------------------------------
	PlayBattle()
------------------------------------*/
function PlayBattle()

	// set flag
	InBattle = true;
	
	// random track
	local song = table.Random( BattleMusicTracks );
	PlayTrack( song[ 1 ], song[ 2 ] );
	
end


/*------------------------------------
	BeginBattleMusic()
------------------------------------*/
local function BeginBattleMusic( msg )

	PlayBattle();
	
end
usermessage.Hook( "BeginBattleMusic", BeginBattleMusic );
