
// basic setup
ENT.Type 					= "anim";
ENT.PrintName				= nil;
ENT.Author					= "";
ENT.Contact					= "";
ENT.Purpose					= "";
ENT.Instructions			= "";
ENT.Spawnable				= false;
ENT.AdminSpawnable			= false;
ENT.Model					= Model( "models/error.mdl" );
ENT.Size					= 0;


/*------------------------------------
	SetAimVector
------------------------------------*/
function ENT:SetAimVector( vec )

	self.AimVec = vec;

end


/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Int", 0, "Hole" );
	
end


/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:GetHole()

	return self.dt.Hole;

end
