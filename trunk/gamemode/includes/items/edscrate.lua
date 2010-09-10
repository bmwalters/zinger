
ITEM.Name			= "E.D.S. Crate";
ITEM.Description	= "Evil Demolition Supply Crate tricks the enemy into picking it up then... BOOM!";
ITEM.ActionText		= "placed an";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/crate.mdl";
	ITEM.InventoryRow		= 4;
	ITEM.InventoryColumn	= 6;
	ITEM.InventoryDistance	= 54;
	ITEM.InventoryAngles	= Angle( 0, 45, 20 );
	ITEM.InventoryPosition	= Vector( 0, 0, 4 );
	
	ITEM.Cursor		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE and pick a location";

end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	local tr = self:GetTrace();

	// make sure its in a playable area
	if ( !IsWorldTrace( tr ) || IsOOB( tr ) ) then
		
		self:ItemAlert( "Invalid position" );
		return true;
	
	end

	
	local pos = self.Ball:GetPos();
	
	// too far away
	if ( ( tr.HitPos - pos ):Length() > 400 ) then

		self:ItemAlert( "Too far away" );
		return true;
	
	end
	
	
	local t = self.Player:Team();
	
	// cycle enemy balls
	for _, enemy in pairs( team.GetPlayers( util.OtherTeam( t ) ) ) do
	
		local ball = enemy:GetBall();
		if ( IsBall( ball ) && ( tr.HitPos - ball:GetPos() ):Length() < 180 ) then
		
			self:ItemAlert( "Too close to enemy" );
			return true;
		
		end
	
	end
	
	
	// create crate
	local crate = ents.Create( "zing_crate" );
	crate:SetPos( tr.HitPos + ( tr.HitNormal * 20 ) );
	crate.Ignore = t;
	crate.DoPickup = function( me, pl, ball )
	
		if ( pl:Team() != me.Ignore ) then
	
			util.Explosion( me:GetPos(), 900, self.Player:Team(), me );
			me:Remove();
			
		end
	
	end;
	crate:Spawn();
	
	// give them a tip its not real
	crate:DrawShadow( false );
	
	// notify
	self:Notify( util.TeamOnlyFilter( t ) );
		
end
