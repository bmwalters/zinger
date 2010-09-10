
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName					= "Proximity Bomb";
ENT.Model					= Model( "models/zinger/proxbomb.mdl" );
ENT.IsBomb					= true;


/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Bool", 0, "Active" );
	self.dt.Active = false;

end
