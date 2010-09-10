
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local ball = data:GetEntity();
	local volume = data:GetScale() * 100;
	
	self.Team = team;
	self.Ball = ball;
	self.EndTime = CurTime() + 0.5;
	
	if( !IsValid( self.Ball ) ) then
	
		return;
	
	end
	
	// particle effect
	if( ball:Team() == TEAM_PURPLE ) then

		ParticleEffectAttach( "Zinger.TeleportBlue", PATTACH_POINT_FOLLOW, ball, 1 );
	
	else
		ParticleEffectAttach( "Zinger.TeleportRed", PATTACH_POINT_FOLLOW, ball, 1 );
	
	end
	
	// sound
	ball:EmitSound( "zinger/items/teleport.mp3", volume, 130 );
			
end


/*------------------------------------
	Think()
------------------------------------*/
function EFFECT:Think()

	if( !IsValid( self.Ball ) ) then
	
		return false;
	
	end

	// dynamic light
	local light = DynamicLight( self.Ball:EntIndex() );
	light.Pos = self.Ball:GetPos();
	light.Size = 64 + math.random( 16, 32 );
	light.Decay = 128;
	
	if( self.Ball:Team() == TEAM_PURPLE ) then
	
		light.R = 64;
		light.G = 64;
		light.B = 255;
		
	else
	
		light.R = 255;
		light.G = 64;
		light.B = 64;
	
	end
	
	light.Brightness = math.random( 1, 8 );
	light.DieTime = CurTime() + 0.1;

	return ( self.EndTime >= CurTime() );

end


/*------------------------------------
	Render()
------------------------------------*/
function EFFECT:Render()
end