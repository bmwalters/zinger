
ITEM.Name		= "Stop n' Go";
ITEM.Description	= "Stops you in place and enables your turn instantly";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/stopngo" );
	
end

/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		local phys = self.Ball:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			// halt their motion
			phys:EnableMotion( false );
			phys:EnableMotion( true );

			// enable their next hit
			timer.Simple( 0.1, function()
			
				if( IsValid( self.Player ) && IsValid( self.Ball ) ) then
				
					rules.Call( "EnableHit", self.Player, self.Ball );
					
				end
		
			end );
			
		end
	
	end
	
end
