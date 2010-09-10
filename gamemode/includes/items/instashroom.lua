
ITEM.Name			= "Insta-Shroom";
ITEM.Description	= "Grow your own temporary (non edible) shroom to create a new obstacle";
ITEM.ActionText		= "grew an";

if( CLIENT ) then

	ITEM.InventoryModel		= "models/zinger/mushroom.mdl";
	ITEM.InventoryRow		= 4;
	ITEM.InventoryColumn	= 7;
	ITEM.InventoryDistance	= 48;
	ITEM.InventoryAngles	= Angle( 0, 45, 20 );
	ITEM.InventoryPosition	= Vector( 0, 0, -16 );
	
	ITEM.Cursor		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE and pick a location";

end

if( SERVER ) then

	AddCleanupClass( "zing_shroom" );

end

/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	local tr = self:GetTrace();
	
	// make sure its in a playable area
	if ( !IsWorldTrace( tr ) || IsOOB( tr ) ) then
		
		self:ItemAlert( "Invalid Position" );
		return true;
	
	end
	
	
	// too far away
	local pos = self.Ball:GetPos();
	if ( ( tr.HitPos - pos ):Length() > 400 ) then

		self:ItemAlert( "Too far away" );
		return true;
	
	end
	
	
	// cycle rings
	for _, ent in pairs( ents.FindByClass( "zing_ring" ) ) do
	
		if ( ( tr.HitPos - ent:GetPos() ):Length() < 128 ) then
		
			self:ItemAlert( "Too close to ring" );
			return true;
		
		end
	
	end
	
	// cycle cups
	for _, ent in pairs( ents.FindByClass( "zing_cup" ) ) do
	
		if ( ( tr.HitPos - ent:GetPos() ):Length() < 128 ) then
		
			self:ItemAlert( "Too close to cup" );
			return true;
		
		end
	
	end
		
		
	// create crate
	local shroom = ents.Create( "zing_shroom" );
	shroom:SetPos( tr.HitPos );
	shroom:SetAngles( Angle( 0, math.random( 0, 360 ), 0 ) );
	shroom:Spawn();
	if( tr.HitNonWorld ) then
	
		shroom:SetParent( tr.Entity );
	
	end
	SafeRemoveEntityDelayed( shroom, 30 );
	
	
	// effect
	ParticleEffect( "Zinger.ShroomGrow", shroom:GetPos(), angle_zero, -1 );
	
	// sound
	shroom:EmitSound( "zinger/items/grass.wav" );
	
	// notify
	self:Notify( util.TeamOnlyFilter( self.Player:Team() ) );

end


