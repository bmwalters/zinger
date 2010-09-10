
ITEM.Name		= "Stone";
ITEM.Description	= "Get heavy like a rock and you won't be knocked around";
ITEM.IsEffect		= true;
ITEM.IsTimed		= true;
ITEM.Duration		= 20;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/stone" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration;
	
	self.Ball:SetStone( true );
	
	if( SERVER ) then
	
		// increase damping to make us feel heavy
		local phys = self.Ball:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:SetDamping( 2.5, 2.5 );
		
		end
		
		// material
		self.Ball:SetMaterial( "zinger/rock" );
		
		// particle effect
		local effect = EffectData();
		effect:SetOrigin( self.Ball:GetPos() );
		effect:SetAttachment( 1 );
		effect:SetEntity( self.Ball );
		util.Effect( "Zinger.Stone", effect );
		
		// sound
		self.Ball:EmitSound( Sound( "physics/concrete/boulder_impact_hard4.wav" ) );
	
	end
	
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function ITEM:Deactivate()

	self.Ball:SetStone( false );

	if( SERVER ) then
			
		// restore damping
		local phys = self.Ball:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:SetDamping( 0.8, 0.8 );
		
		end
		
		// restore material
		self.Ball:SetMaterial( "" );
	
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.Data.EndTime && self.Data.EndTime > CurTime();

end
