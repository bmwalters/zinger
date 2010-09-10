
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName				= "Shroom";
ENT.Model					= Model( "models/zinger/mushroom.mdl" );
ENT.Size					= 48;

/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Bool", 0, "Impact" );
	self.dt.Impact = false;

end
