
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local ball = data:GetEntity();
		
	// particle effect
	ParticleEffectAttach( "Zinger.Dazed", PATTACH_ABSORIGIN_FOLLOW, ball, -1 );

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
