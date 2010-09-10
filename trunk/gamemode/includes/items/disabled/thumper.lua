
ITEM.Name		= "Thumper";
ITEM.Description	= "";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/thumper" );
	
end

/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		util.ScreenShake( self.Ball:GetPos(), 8, 15, 2, 3072 );
	
		local effect = EffectData();
		effect:SetEntity( self.Ball );
		effect:SetOrigin( self.Ball:GetPos() );
		util.Effect( "Zinger.Thumper", effect );
		
		for _, enemy in pairs( team.GetPlayers( util.OtherTeam( self.Ball:Team() ) ) ) do
		
			local ball = enemy:GetBall();
			if( IsValid( ball ) && !( ball:GetDisguise() || ball:GetNinja() ) ) then
			
				local phys = ball:GetPhysicsObject();
				if( IsValid( phys ) ) then
			
					// leap into the air
					ball:SetGroundEntity( NULL );
					phys:SetVelocity( phys:GetVelocity() + Vector( 0, 0, math.random( 500, 700 ) ) );
					
					// sound
					ball:EmitSound( "zinger/boing.wav", 75, 100 );
					
					local effect = EffectData();
					effect:SetEntity( ball );
					effect:SetOrigin( ball:GetPos() );
					util.Effect( "Zinger.Dazed", effect );
					
				end
				
			end
		
		end
		
	end
	
end

