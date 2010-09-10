
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

	// hide
	self:SetNoDraw( true );
	self:DrawShadow( false );

end


/*------------------------------------
	SetRoundEndTime()
------------------------------------*/
function ENT:SetRoundEndTime( time )

	self.dt.RoundEndTime = time;

end


/*------------------------------------
	SetRoundDuration()
------------------------------------*/
function ENT:SetRoundDuration( time )

	self.dt.RoundDuration = time;

end


/*------------------------------------
	SetRoundState()
------------------------------------*/
function ENT:SetRoundState( state )

	self.dt.RoundState = state;

end


/*------------------------------------
	SetCurrentHole()
------------------------------------*/
function ENT:SetCurrentHole( num )

	self.dt.CurrentHole = num;

end


/*------------------------------------
	SetCurrentRules()
------------------------------------*/
function ENT:SetCurrentRules( num )

	self.dt.CurrentRules = num;

end


/*------------------------------------
	SetProgress()
------------------------------------*/
function ENT:SetProgress( t, float )

	if ( t == TEAM_ORANGE ) then
	
		self.dt.RedProgress = float;
		
	elseif ( t == TEAM_PURPLE ) then
	
		self.dt.BlueProgress = float;
		
	end

end
