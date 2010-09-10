
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName				= "Ring";
ENT.Model					= Model( "models/zinger/arch.mdl" );
ENT.Size					= 48;
ENT.NotifyColor				= Color( 255, 240, 0, 255 );


/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Int", 0, "Hole" );
	self:DTVar( "Bool", 0, "RedDone" );
	self:DTVar( "Bool", 1, "BlueDone" );
	
end


/*------------------------------------
	IsTeamDone()
------------------------------------*/
function ENT:IsTeamDone( t )

	if ( t == TEAM_ORANGE ) then
	
		return self.dt.RedDone;
		
	elseif ( t == TEAM_PURPLE ) then
	
		return self.dt.BlueDone;
		
	end
	
	return false;

end
