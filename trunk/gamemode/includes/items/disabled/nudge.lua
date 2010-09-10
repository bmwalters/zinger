
ITEM.Name		= "Nudge";
ITEM.Description	= "Gives you a boost in the direction your cursor is aiming";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/nudge" );
	
end

/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
		
		local phys = self.Ball:GetPhysicsObject();
		if( IsValid( phys ) ) then
			
			local velocity = phys:GetVelocity();
			local speed = velocity:Length();
			local dir = self:GetAimVector();
			
			// particle effect on drive
			ParticleEffect( "Zinger.BallDrive", phys:GetPos(), dir:Angle(), self.Ball );
			
			// nudge them in their aim direction
			phys:SetVelocity( velocity + ( dir * math.max( speed * 3.5, 350 ) ) );
			
			// sound
			self.Ball:EmitSound( "zinger/putt1.mp3" );
		
		end
		
	end
		
end

