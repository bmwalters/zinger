
ITEM.Name			= "Air Strike";
ITEM.Description	= "";
ITEM.ActionText		= "radioed in an";

ITEM.ViewModel		= "models/zinger/v_radio.mdl";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/v_radio.mdl";
	ITEM.InventoryRow		= 3;
	ITEM.InventoryColumn	= 7;
	ITEM.InventoryDistance	= 3;
	ITEM.InventoryAngles	= Angle( 0, 130, 0 );
	ITEM.InventoryPosition	= Vector( 0, 2, -6 );
	
	ITEM.Cursor		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE and pick a location";
	
end



/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	// find if any ac130's are active
	if ( #ents.FindByClass( "zing_airstrike" ) > 0 ) then
	
		self:ItemAlert( "Air Strike already inbound" );
		return true;
	
	end
	

	local tr = self:GetTrace();

	// make sure its in a playable area
	if ( IsOOB( tr ) ) then
		
		self:ItemAlert( "Invalid Position" );
		return true;
	
	end
	
	local pos = tr.HitPos;
		
	// validate ball
	local ball = self.Player:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
		
	end
	
	// create entity
	local ent = ents.Create( "zing_airstrike" );
	ent:SetPos( pos );
	ent:SetAngles( ( pos - self.Player:GetPos() ):Angle():Right():Angle() );
	ent:SetOwner( ball );
	ent:Spawn();
	ent.TargetPos = pos;
	
	// play global sound
	GAMEMODE:PlaySound( "zinger/items/airstrikeradio.mp3" );
	
end

