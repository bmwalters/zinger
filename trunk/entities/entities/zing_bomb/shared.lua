
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName					= "Bomb";
ENT.Model					= Model( "models/zinger/bomb.mdl" );
ENT.IsBomb					= true;

/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Bool", 0, "Active" );
	self.dt.Active = false;

end
