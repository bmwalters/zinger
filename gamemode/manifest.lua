
// derive from fretta
DeriveGamemode( 'fretta' );

// include loader (which loads a bunch of stuff too)
include( 'includes/sh_loader.lua' );

// server
if ( SERVER ) then

	// send client files
	AddCSLuaFile( 'cl_hud.lua' );
	AddCSLuaFile( 'cl_init.lua' );
	AddCSLuaFile( 'cl_nature.lua' );
	AddCSLuaFile( 'cl_player_events.lua' );
	AddCSLuaFile( 'manifest.lua' );
	AddCSLuaFile( 'sh_constants.lua' );
	AddCSLuaFile( 'shared.lua' );
	AddCSLuaFile( 'sh_debugoverlay_extension.lua' );
	AddCSLuaFile( 'sh_entity_extension.lua' );
	AddCSLuaFile( 'sh_math_extension.lua' );
	AddCSLuaFile( 'sh_player_extension.lua' );
	AddCSLuaFile( 'sh_roundinfo.lua' );
	AddCSLuaFile( 'sh_util_extension.lua' );
	
	// load files
	include( 'sv_battlestats.lua' );
	include( 'sv_bot.lua' );
	include( 'sv_commands.lua' );
	include( 'sv_gameplay.lua' );
	include( 'sv_nature.lua' );
	include( 'sv_player_events.lua' );
	include( 'sv_player_extension.lua' );
	include( 'sv_util_extension.lua' );
	
end

// client
if ( CLIENT ) then

	// load files
	include( 'cl_hud.lua' );
	include( 'cl_nature.lua' );
	include( 'cl_player_events.lua' );

end

// shared
include( 'sh_debugoverlay_extension.lua' );
include( 'sh_entity_extension.lua' );
include( 'sh_math_extension.lua' );
include( 'sh_player_extension.lua' );
include( 'sh_roundinfo.lua' );
include( 'sh_util_extension.lua' );
include( 'shared.lua' );

// load modules
LL( PATH_MODULES, nil, nil, function( f, p )
	
	// include
	sh_include( ("%s%s"):format( p, f ) );

end );

// particle effects
PrecacheParticleSystem( "Zinger.Explosion" );
PrecacheParticleSystem( "Zinger.BallImpact" );
PrecacheParticleSystem( "Zinger.BallDrive" );
PrecacheParticleSystem( "Zinger.RingExplode" );
PrecacheParticleSystem( "Zinger.CratePickup" );
PrecacheParticleSystem( "Zinger.Ninja" );
PrecacheParticleSystem( "Zinger.ShellBrass" );
PrecacheParticleSystem( "Zinger.ShellShotgun" );
PrecacheParticleSystem( "Zinger.MuzzleFlash" );
PrecacheParticleSystem( "Zinger.BulletImpact" );
PrecacheParticleSystem( "Zinger.Fuse" );
PrecacheParticleSystem( "Zinger.Stone" );
PrecacheParticleSystem( "Zinger.TeleportRed" );
PrecacheParticleSystem( "Zinger.TeleportBlue" );
PrecacheParticleSystem( "Zinger.RocketMuzzleFlash" );
PrecacheParticleSystem( "Zinger.AC130Tracer" );
PrecacheParticleSystem( "Zinger.BlowgunAir" );
PrecacheParticleSystem( "Zinger.BlowDart" );
PrecacheParticleSystem( "Zinger.ShroomGrow" );
PrecacheParticleSystem( "Zinger.RocketTrail" );
PrecacheParticleSystem( "Zinger.Jump" );
PrecacheParticleSystem( "Zinger.WaterExplosion" );
PrecacheParticleSystem( "Zinger.WaterSplash" );
PrecacheParticleSystem( "Zinger.JumpTrail" );
PrecacheParticleSystem( "Zinger.ButterflyDeath" );
PrecacheParticleSystem( "Zinger.Thumper" );
PrecacheParticleSystem( "Zinger.Dazed" );
PrecacheParticleSystem( "Zinger.Waterfall" );
PrecacheParticleSystem( "Zinger.Help" );
PrecacheParticleSystem( "Zinger.HelpExplode" );

// load vgui files
LL( PATH_VGUI, nil, nil, function( f )

	// server only
	if ( SERVER ) then
	
		// download for clients
		AddCSLuaFile( ("%s%s"):format( PATH_VGUI, f ) );
		
	else
	
		// include
		include( ("%s%s"):format( PATH_VGUI, f ) );
		
	end

end );
