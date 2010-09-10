
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	ParticleEffectAttach( "Zinger.RocketTrail", PATTACH_POINT_FOLLOW, data:GetEntity(), data:GetAttachment() );
	
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
