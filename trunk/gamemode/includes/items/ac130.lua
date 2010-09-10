
ITEM.Name			= "AC-130";
ITEM.Description	= "A plane loaded full of modernized warfare rains death from above";
ITEM.ActionText		= "called in an";

ITEM.ViewModel		= "models/zinger/v_radio.mdl";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/v_radio.mdl";
	ITEM.InventoryRow		= 3;
	ITEM.InventoryColumn	= 6;
	ITEM.InventoryDistance	= 3;
	ITEM.InventoryAngles	= Angle( 0, 130, 0 );
	ITEM.InventoryPosition	= Vector( 0, 2, -6 );
	
	ITEM.Tip		= "Press USE to activate";
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	// find if any ac130's are active
	if ( #ents.FindByClass( "zing_ac130" ) > 0 ) then
	
		self:ItemAlert( "AC-130 already active" );
		return true;
	
	end
	
	// validate ball
	local ball = self.Player:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
		
	end
	
	// create entity
	local ent = ents.Create( "zing_ac130" );
	ent:SetPos( self.Player:GetPos() );
	ent:Spawn();
	
	// setup information
	ent.DieTime = CurTime() + 20;
	ent.Hunt = util.OtherTeam( self.Player:Team() );
	
	// delay removal
	SafeRemoveEntityDelayed( ent, 20 );
	
	// send notification
	self:Notify();

	// play global sound
	GAMEMODE:PlaySound( "zinger/items/ac130radio.mp3" );
	
end
