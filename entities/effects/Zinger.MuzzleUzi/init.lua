
/*------------------------------------
	Init()
------------------------------------*/
function EFFECT:Init( data )

	local pos = data:GetOrigin();
	local angle = data:GetAngle();
	local normal = data:GetNormal();
	local ball = data:GetEntity();
	
	if( !IsValid( ball ) ) then
	
		return;
		
	end

	// dynamic light
	local light = DynamicLight( ball:EntIndex() );
	light.Pos = pos;
	light.Size = 128;
	light.Decay = 512;
	light.R = 255;
	light.G = 230;
	light.B = 0;
	light.Brightness = 2;
	light.DieTime = CurTime() + 0.25;
	
	// muzzle effect
	ParticleEffect( "Zinger.MuzzleFlash", pos + normal * 10, angle, ball );
	ParticleEffect( "Zinger.ShellBrass", pos + normal * 10, angle_zero, ball );

	// sound
	//ball:EmitSound( "zinger/items/uzi" .. math.random( 1, 5 ) .. ".mp3" );
	ball:EmitSound( "zinger/items/uzi.mp3" );
	
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