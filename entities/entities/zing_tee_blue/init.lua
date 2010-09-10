
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

include( 'shared.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()
	
	self.BaseClass.Initialize( self );
	
	local color = team.GetColor( TEAM_PURPLE );
	self:SetColor( color.r, color.g, color.b, 255 );
		
end
