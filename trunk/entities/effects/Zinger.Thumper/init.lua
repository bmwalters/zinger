
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local ball = data:GetEntity();
	local origin = data:GetOrigin();
	
	if( !IsValid( ball ) ) then
	
		return;
		
	end
	
	// particle effect
	ParticleEffect( "Zinger.Thumper", origin, angle_zero, ball );
	//ParticleEffectAttach( "Zinger.JumpTrail", PATTACH_ABSORIGIN_FOLLOW, ball, -1 );

	// sound
	ball:EmitSound( "coast.thumper_hit" );
			
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