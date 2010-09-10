
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	UpdateTransmitState()
------------------------------------*/
function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS;

end


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	// setup
	self:DrawShadow( false );
	self:SetNoDraw( true );
	
	// sounds
	self.EngineSound = CreateSound( self.Entity, Sound( "zinger/items/airplane.wav" ) );
	self.EngineSound:SetSoundLevel( 0.5 );
	self.EngineSound:PlayEx( 0, 100 );
	self.WeaponSound = CreateSound( self.Entity, Sound( "zinger/items/ac130cannon.mp3" ) );
	self.WeaponSound:SetSoundLevel( 0.48 );
	
	// defaults
	self.NextShot = CurTime() + 3;
	self.Volume = 0;
	self.Leaving = false;
		
end


/*------------------------------------
	OnRemove()
------------------------------------*/
function ENT:OnRemove()

	// clean up sounds
	self.EngineSound:Stop();
	self.WeaponSound:Stop();

end


/*------------------------------------
	FireWeapon()
------------------------------------*/
function ENT:FireWeapon()

	// list of targets
	local targets = {};
	
	// iterate all players
	for _, pl in pairs( player.GetAll() ) do
		
		// validate ball
		local ball = pl:GetBall();
		if ( IsBall( ball ) && ball:Team() == self.Hunt && !ball:GetNinja() ) then

			// add as target
			table.insert( targets, { ball, ball:GetPos() } );
		
		end
		
	end
	
	// do we have targets?
	if ( #targets > 0 ) then
	
		// select a random target
		local target = table.Random( targets );
		local ball = target[ 1 ];
		local pos = target[ 2 ];
		
		// play the weapon sound
		self.WeaponSound:Stop();
		self.WeaponSound:PlayEx( 1.2, math.random( 96, 104 ) );
		
		// delay the shot
		timer.Simple( 0.2, function()
		
			// validate ball
			if ( IsBall( ball ) ) then
			
				// trace position for tracer (paradox?)
				local tr = util.TraceLine( {
					start = pos,
					endpos = pos + Vector( 0, 0, 4096 ),
					filter = ball,
				} );
				
				// tracer
				util.ParticleTracerEx( "Zinger.AC130Tracer", tr.HitPos - Vector( 0, 0, 16 ), pos, true, 0, -1 );
			
				// explosion
				timer.Simple( 0.2, function()
				
					util.Explosion( pos, 200, util.OtherTeam( self.Hunt ), ball );
					
				end );
				
			end
			
		end );
	
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// check if volume has reach max
	if ( self.Volume < 1 ) then

		// slowly raise engine volume
		self.Volume = math.Approach( self.Volume, 1, 0.025 );
		self.EngineSound:ChangeVolume( self.Volume );
		
	else
	
		// time to leave?
		if ( !self.Leaving && self.DieTime - CurTime() < 2 ) then
		
			// fade out engine
			self.Leaving = true;
			self.EngineSound:FadeOut( 2.0 );
		
		end
		
	end
	
	// fire a shot if its time
	local ct = CurTime();
	if ( ct > self.NextShot && !self.Leaving ) then
	
		self.NextShot = ct + 1;
		self:FireWeapon();
	
	end

end
