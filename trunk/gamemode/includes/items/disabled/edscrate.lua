
ITEM.Name		= "E.D.S. Crate";
ITEM.Description	= "Evil Demolition Supply Crate tricks the enemy into picking it up then... BOOM!";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;
ITEM.ActionText		= "placed an";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE and pick a location";
	ITEM.Image		= Material( "zinger/hud/items/edscrate" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		local tr = self:GetTargetTrace();
	
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
		
		umsg.Start( "AddNotfication", util.TeamOnlyFilter( t ) );
			umsg.Char( NOTIFY_ITEMACTION );
			umsg.Entity( self.Player );
			umsg.Char( self.Index );
		umsg.End();
		
	end
	
end
