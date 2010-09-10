
// variables
local RoundControllerEnt;

/*------------------------------------
	RoundController()
------------------------------------*/
function RoundController()

	// find it if needed
	if ( !IsValid( RoundControllerEnt ) ) then
	
		// find and save it
		local entlist = ents.FindByClass( "zing_round_controller" );
		RoundControllerEnt = entlist[ 1 ];
	
	end
	
	return RoundControllerEnt;
	
end


/*------------------------------------
	GetRoundState()
------------------------------------*/
function GM:GetRoundState()

	// get round controller
	local rc = RoundController();
	if ( !rc.GetRoundState ) then
	
		return 0;
		
	end
	
	return rc:GetRoundState();
	
end


/*------------------------------------
	GetRoundEndTime()
------------------------------------*/
function GM:GetRoundEndTime()

	// get round controller
	local rc = RoundController();
	if ( !rc.GetRoundEndTime ) then
	
		return 0;
		
	end
	
	return rc:GetRoundEndTime();
	
end


/*------------------------------------
	GetGameTimeLeft()
------------------------------------*/
function GM:GetGameTimeLeft()
	
	return math.max( self:GetRoundEndTime() - CurTime(), 0 );

end


/*------------------------------------
	GetRoundDuration()
------------------------------------*/
function GM:GetRoundDuration()

	// get round controller
	local rc = RoundController();
	if ( !rc.GetRoundDuration ) then
	
		return 0;
		
	end
	
	return rc:GetRoundDuration();
	
end


/*------------------------------------
	GetTeamProgress()
------------------------------------*/
function GM:GetTeamProgress( t )

	// get round controller
	local rc = RoundController();
	if ( !rc.GetProgress ) then
	
		return 0;
		
	end
	
	return rc:GetProgress( t );
	
end


/*------------------------------------
	GetCurrentHole()
------------------------------------*/
function GM:GetCurrentHole()

	// get round controller
	return RoundController():GetCurrentHole();
	
end


/*------------------------------------
	GetCurrentRules()
------------------------------------*/
function GM:GetCurrentRules()

	// get round controller
	return RoundController():GetCurrentRules();
	
end


/*------------------------------------
	GetSky()
------------------------------------*/
function GM:GetSky()

	local rc = RoundController();
	if( IsValid( rc ) ) then
	
		if ( rc.dt.Sky == 0 ) then
		
			return 1;
			
		end
		
		return rc.dt.Sky;
		
	end
	
	return SKY_DAY;

end


if ( SERVER ) then

	/*------------------------------------
		SetRoundEndTime()
	------------------------------------*/
	function GM:SetRoundEndTime( time )

		local rc = RoundController();
		rc:SetRoundDuration( time - CurTime() );
		rc:SetRoundEndTime( time );
		
	end


	/*------------------------------------
		SetRoundState()
	------------------------------------*/
	function GM:SetRoundState( state )
	
		RoundController():SetRoundState( state );
		
	end
	
	
	/*------------------------------------
		SetCurrentHole()
	------------------------------------*/
	function GM:SetCurrentHole( hole )
	
		RoundController():SetCurrentHole( hole );
	
	end
	
	
	/*------------------------------------
		SetCurrentRules()
	------------------------------------*/
	function GM:SetCurrentRules( rules )
	
		RoundController():SetCurrentRules( rules );
	
	end
	
	
	/*------------------------------------
		SetTeamProgress()
	------------------------------------*/
	function GM:SetTeamProgress( t, percent )
	
		RoundController():SetProgress( t, percent );
	
	end

end
