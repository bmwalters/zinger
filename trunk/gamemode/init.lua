
// manifest
include( 'manifest.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function GM:Initialize()
end


/*------------------------------------
	InitPostEntity()
------------------------------------*/
function GM:InitPostEntity()

	// create round controller
	local rc = ents.Create( "zing_round_controller" );
	rc:Spawn();
	
	// wait for players
	self:SetRoundState( ROUND_WAITING );
	self:UpdateGameplay();
	
	// build the course
	self:GenerateCourse();

end


/*------------------------------------
	FinishMove()
------------------------------------*/
function GM:FinishMove( pl, mv )
end


/*------------------------------------
	ShowHelp()
------------------------------------*/
function GM:ShowHelp( pl )

	// pass back to client
	pl:ConCommand( "zingerhelp" );
	
end


/*------------------------------------
	PlaySound()
------------------------------------*/
function GM:PlaySound( sound, filter )
	
	// start match music
	umsg.Start( "PlaySound", filter );
		umsg.String( sound );
	umsg.End();

end
