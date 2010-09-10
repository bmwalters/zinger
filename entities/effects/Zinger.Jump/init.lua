
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local ball = data:GetEntity();
	
	if( !IsValid( ball ) ) then
	
		return;
		
	end
	
	// particle effect
	ParticleEffect( "Zinger.Jump", ball:GetPos(), angle_zero, ball );
	ParticleEffectAttach( "Zinger.JumpTrail", PATTACH_ABSORIGIN_FOLLOW, ball, -1 );
	
	// sound
	ball:EmitSound( "zinger/boing.wav" );
			
end


/*------------------------------------
	Think()
------------------------------------*/
function EFFECT:Think()

	return false;

end


/*------------------------------------
	Render()
------------------------------------*/
function EFFECT:Render()
end