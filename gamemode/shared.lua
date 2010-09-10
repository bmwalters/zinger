
// setup gamemode information
GM.Name								= "Zinger!";
GM.Author							= "Arcadium Software";
GM.Email							= "team@the-arcadium.com";
GM.Website 							= "http://the-arcadium.com";

// setup fretta
GM.Help								= "Zinger! is a team based gamemode that combines action, adventure and strategy wrapped around a game of mini golf";
GM.TeamBased						= true;
GM.RoundBased 				 		= false;
GM.AllowAutoTeam					= true;
GM.AllowSpectating					= true;
GM.SecondsBetweenTeamSwitches		= 60;
GM.SelectModel						= false;
GM.SelectColor						= false;
GM.GameLength						= GAME_LENGTH;

// modules
require( "rules" );

// variables
local LastMouseX = 0;
local LastMouseY = 0;


/*------------------------------------
	CreateTeams()
------------------------------------*/
function GM:CreateTeams()

	// create spectators
	team.SetUp( TEAM_UNASSIGNED, "Cloud Watchers", Color( 230, 230, 230 ), false );
	team.SetUp( TEAM_SPECTATOR, "Cloud Watchers", Color( 230, 230, 230 ), true );
	team.SetSpawnPoint( TEAM_UNASSIGNED, "info_player_start" );
	
	// create red team
	team.SetUp( TEAM_ORANGE, "Sandbaggers", color_team_orange, true );
	team.SetSpawnPoint( TEAM_ORANGE, "info_player_start" );
	
	// create blue team
	team.SetUp( TEAM_PURPLE, "Bandits", color_team_purple, true );
	team.SetSpawnPoint( TEAM_PURPLE, "info_player_start" );
	
end


/*------------------------------------
	ClipVelocity()
------------------------------------*/
local function ClipVelocity( velocity, normal, overbounce )

	// Determine how far along plane to slide based on incoming direction.
	local backoff = velocity:Dot( normal ) * overbounce;
	local out = velocity - ( normal * backoff );

	// iterate once to make sure we aren't still moving through the plane
	local adjust = out:Dot( normal );
	if( adjust < 0 ) then
		
		out = out - ( normal * adjust );
		
	end
	
	return out;

end


/*------------------------------------
	TryMove()
------------------------------------*/
local function TryMove( pos, velocity, delta )

	local endPos = pos + velocity * delta;
	
	local tr = util.TraceHull( {
		start = pos,
		endpos = endPos,
		mins = OBSERVER_HULL_MIN,
		maxs = OBSERVER_HULL_MAX,
		mask = MASK_NPCWORLDSTATIC,
	} );
	
	return tr;
	
end


/*------------------------------------
	ObserverMove()
------------------------------------*/
local planes = {};
local function ObserverMove( pl, mv )
	
	local forwardSpd = math.sign( mv:GetForwardSpeed() ) * OBSERVER_SPEED;
	local sideSpd = math.sign( mv:GetSideSpeed() ) * OBSERVER_SPEED;
	local upSpd = math.sign( mv:GetUpSpeed() ) * OBSERVER_SPEED;
		
	local velocity = mv:GetVelocity();
	local origin = mv:GetOrigin();
	
	// if we're moving calculate a new velocity, otherwise just decay the old one
	if( forwardSpd != 0 || sideSpd != 0 || upSpd != 0 ) then
	
		local angles = mv:GetMoveAngles();
		local forward = angles:Forward();
		local right = angles:Right();
		
		forward:Normalize();
		right:Normalize();
		
		local v = ( forward * forwardSpd ) + ( right * sideSpd );
		v.z = v.z + upSpd;
		
		velocity = velocity + v * FrameTime();
		
	end
	
	// apply friction
	velocity = velocity * 0.95;

	local primal_velocity = velocity;
		
	// use up to 4 iterations, because we can hit multiple planes
	local num_planes = 0;
	local time = FrameTime();
	for i = 1, 4 do
	
		local tr = TryMove( origin, velocity, time );
		
		origin = tr.HitPos;
		time = time - time * tr.Fraction;
		
		// no reason to perform further checks or clipping if we
		// made it the whole distance without hitting anything.
		if( tr.Fraction == 1 ) then
		
			break;
			
		end
		
		num_planes = num_planes + 1;
		planes[ num_planes ] = tr.HitNormal;
		
		// clip to all current planes
		for i = 1, num_planes do
		
			velocity = ClipVelocity( velocity, planes[ i ], 1 );
		
		end
		
		if( num_planes > 2 ) then
		
			local dir = planes[ 1 ]:Cross( planes[ 2 ] );
			dir:Normalize();
			
			local d = dir:Dot( velocity );
			
			velocity = dir * d;
		
		end
		
		// stop dead to prevent twitching in corners
		if( velocity:Dot( primal_velocity ) <= 0 ) then
		
			velocity = vector_origin;
			
		end
				
	end
	
	mv:SetVelocity( velocity );
	mv:SetOrigin( origin );
	
end


/*------------------------------------
	Move()
------------------------------------*/
function GM:Move( pl, mv )
	
	// validate camera
	local camera = pl:GetCamera();
	if ( !IsValid( camera ) ) then
	
		// add friction to spectators
		if ( pl:GetMoveType() == MOVETYPE_NOCLIP ) then
		
			ObserverMove( pl, mv );
		
		end
		
		return true;

	end
	
	local pos = camera:GetPos();
	local viewdir = pl:GetAimVector();
	local cmd = pl:GetCurrentCommand();
	pos = pos - viewdir * cmd:GetMouseX();
	
	// position camera
	mv:SetOrigin( pos );
	
	// update aim vector
	pl:UpdateAimVector();
	
	return true;
	
end


/*------------------------------------
	KeyPress()
------------------------------------*/
function GM:KeyPress( pl, key )
	
	if( CLIENT ) then
	
		// check for use key
		if( key == IN_USE ) then
		
			// validate equipped item
			local item = inventory.Equipped();
			if ( item ) then
			
				// use if instant
				if ( item.Cursor == nil ) then
			
					RunConsoleCommand( "item", "use" );
					
				else
				
					// activate cursor
					self:SetCursor( item.Cursor );
				
				end
				
			end
		
		end
	
	end

end


/*------------------------------------
	KeyRelease()
------------------------------------*/
function GM:KeyRelease( pl, key )

	if( CLIENT ) then
	
		if( key == IN_USE ) then
		
			// clear cursor
			self:SetCursor( nil );
		
		end
	
	end
	
end


/*------------------------------------
	PlayerFootstep()
------------------------------------*/
function GM:PlayerFootstep( pl, pos, foot, sound, volume, rf ) 

	return true;
	
end


/*------------------------------------
	PlayerNoClip()
------------------------------------*/
function GM:PlayerNoClip( pl, on )
	
	return false;
	
end


/*------------------------------------
	OnPlayerCreated()
------------------------------------*/
function GM:OnPlayerCreated( pl )

	// setup datatable vars
	pl:InstallDT();
	
	if( CLIENT ) then
	
		// check for local player
		if ( pl == LocalPlayer() ) then
		
			// local player creation hook
			self:OnLocalPlayerCreated( entity );
			
		end
		
	end
	
	items.Install( pl );
	inventory.Install( pl );
	
	if( SERVER ) then
	
		pl.NextSprayTime = CurTime();

	end
		
end


/*------------------------------------
	Think()
------------------------------------*/
function GM:Think()

	// nature
	self:NatureThink();

	if( SERVER ) then
	
		if ( CurTime() > ( self.NextUpdate or 0 ) ) then
		
			self.NextUpdate = CurTime() + 0.5;
			
			// gameplay
			self:UpdateGameplay();
			
			// supply crates
			rules.Call( "UpdateCrates" );
			
		end
	
	end
	
	if( CLIENT ) then
	
		// get player
		local pl = LocalPlayer();
		
		// update mouse gestures
		controls.Update( pl );
		
		// ensure the aim vector is set on the client
		if( SinglePlayer() ) then
		
			pl:UpdateAimVector();
		
		end
		
		// update music
		music.Update();
		
	end
	
	// run think for all players
	for _, pl in pairs( player.GetAll() ) do
	
		pl:Think();

	end
	
	return self.BaseClass.Think( self );
	
end


/*------------------------------------
	Tick()
------------------------------------*/
function GM:Tick()
	
	// the clouds create a bunch of garbage- lets clean some of it up
	// TODO: fix the garbage? not even sure if its possible with all
	// the calculations involved!!!!
	collectgarbage( "step", 90 );
	
end
