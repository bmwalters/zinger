
ITEM.Name		= "Jump";
ITEM.Description	= "Launch your ball into the air and over obstacles";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/jump" );
	
end

/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		local phys = self.Ball:GetPhysicsObject();
		if( IsValid( phys ) ) then
			
			// leap into the air
			self.Ball:SetGroundEntity( NULL );
			phys:SetVelocity( phys:GetVelocity() + Vector( 0, 0, 500 ) );
			
			local effect = EffectData();
			effect:SetEntity( self.Ball );
			effect:SetOrigin( self.Ball:GetPos() );
			util.Effect( "Zinger.Jump", effect );
						
		end
		
	end
	
end

