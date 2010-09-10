
ITEM.Name		= "Insta-Shroom";
ITEM.Description	= "Grow your own temporary (non edible) shroom to create a new obstacle";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;
ITEM.ActionText		= "grew an";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE and pick a location";
	ITEM.Image		= Material( "zinger/hud/items/instashroom" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		local tr = self:GetTargetTrace();
	
		// make sure its in a playable area
		if ( !IsWorldTrace( tr ) || IsOOB( tr ) ) then
			
			self:ItemAlert( "Invalid Position" );
			
			return true;
		
		end
		
		
		local pos = self.Ball:GetPos();
		
		// too far away
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
		
		// effect
		ParticleEffect( "Zinger.ShroomGrow", shroom:GetPos(), vector_origin, -1 );
		
		// sound
		shroom:EmitSound( "zinger/items/grass.wav" );
		
		SafeRemoveEntityDelayed( shroom, 30 );
		
		umsg.Start( "AddNotfication", util.TeamOnlyFilter( self.Player:Team() ) );
			umsg.Char( NOTIFY_ITEMACTION );
			umsg.Entity( self.Player );
			umsg.Char( self.Index );
		umsg.End();

	end
	
end
