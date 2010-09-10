
// basic setup
ENT.Type 					= "anim";
ENT.PrintName				= "";
ENT.Author					= "";
ENT.Contact					= "";
ENT.Purpose					= "";
ENT.Instructions			= "";
ENT.Spawnable				= false;
ENT.AdminSpawnable			= false;


/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "RoundEndTime" );
	self:DTVar( "Float", 1, "RedProgress" );
	self:DTVar( "Float", 2, "BlueProgress" );
	self:DTVar( "Float", 3, "RoundDuration" );
	self:DTVar( "Int", 0, "RoundState" );
	self:DTVar( "Int", 1, "CurrentHole" );
	self:DTVar( "Int", 2, "Sky" );
	self:DTVar( "Int", 3, "CurrentRules" );
	
	//self.dt.Sky = SKY_DAY;
	
end


/*------------------------------------
	GetRoundEndTime()
------------------------------------*/
function ENT:GetRoundEndTime()

	return self.dt.RoundEndTime;

end


/*------------------------------------
	GetRoundDuration()
------------------------------------*/
function ENT:GetRoundDuration()

	return self.dt.RoundDuration;

end


/*------------------------------------
	GetRoundState()
------------------------------------*/
function ENT:GetRoundState()

	return self.dt.RoundState;

end


/*------------------------------------
	GetCurrentHole()
------------------------------------*/
function ENT:GetCurrentHole()

	return self.dt.CurrentHole;

end


/*------------------------------------
	GetCurrentRules()
------------------------------------*/
function ENT:GetCurrentRules()

	return self.dt.CurrentRules;

end


/*------------------------------------
	GetProgress()
------------------------------------*/
function ENT:GetProgress( t )

	if ( t == TEAM_ORANGE ) then
	
		return self.dt.RedProgress;
		
	elseif ( t == TEAM_PURPLE ) then
	
		return self.dt.BlueProgress;
		
	end
	
	return 0;

end
