
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	ParticleEffectAttach( "Zinger.Fuse", PATTACH_POINT_FOLLOW, data:GetEntity(), data:GetAttachment()  );
	
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
