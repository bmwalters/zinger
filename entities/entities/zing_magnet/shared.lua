
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName					= "Magnet";
ENT.Model					= Model( "models/zinger/magnet.mdl" );
ENT.IsMagnet					= true;

/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Bool", 0, "Active" );
	self.dt.Active = false;

end
