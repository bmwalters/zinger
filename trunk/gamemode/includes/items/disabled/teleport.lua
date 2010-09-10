
ITEM.Name		= "Teleport";
ITEM.Description	= "Travel through another dimension!";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip			= "Hold USE and pick a location";
	ITEM.Image		= Material( "zinger/hud/items/teleport" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then

		if ( self.Player:GetStrokes() == 0 ) then
			
			self:ItemAlert( "Cannot teleport from tee" );
			
			return true;
		
		end

		local tr = self:GetTargetTrace();
		
		// make sure its in a playable area
		if ( !IsWorldTrace( tr ) || IsOOB( tr ) ) then
			
			self:ItemAlert( "Invalid position" );
		
			return true;
		
		end
		
		local pos = self.Ball:GetPos();
		
		// too far away
		if ( ( tr.HitPos - pos ):Length() > 800 ) then
		
			self:ItemAlert( "Too far away" );
			
			return true;
		
		end
		
		// cycle through rings
		for _, ent in pairs( ents.FindByClass( "zing_ring" ) ) do
		
			if ( ( ent:GetPos() - tr.HitPos ):Length() < 100 ) then
				
				self:ItemAlert( "Too close to ring" );
				
				return true;
			
			end
		
		end
		
		// unweld
		constraint.RemoveConstraints( self.Ball, "Weld" );
		self.Player:ClearEffect( "magnet" );
		
		self.Ball:SetPos( tr.HitPos + ( tr.HitNormal * self.Ball.Size ) );
		
		// effect
		local effect = EffectData();
		effect:SetOrigin( self.Ball:GetPos() );
		effect:SetEntity( self.Ball );
		effect:SetScale( 1.5 );
		util.Effect( "Zinger.Teleport", effect );
		
	end
	
end
