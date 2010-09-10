
// variables
local NextInsect = CurTime();

// clean up insects each hole
AddCleanupClass( "zing_butterfly" );
AddCleanupClass( "zing_firefly" );


/*------------------------------------
	SpawnInsect()
------------------------------------*/
function GM:SpawnInsect()

	// count insects, check if we're at our target
	local numInsects = #ents.FindByClass( "zing_insect_firefly" ) + #ents.FindByClass( "zing_insect_butterfly" );
	if( numInsects >= INSECT_COUNT ) then
	
		return;
	
	end
	
	local target = self:GetRandomHoleEntity();
	if( IsValid( target ) ) then
	
		local pos = VectorRand() * target:BoundingRadius() * math.Rand( 1.1, 2.1 );
		pos.z = math.abs( pos.z ) + 8;
		pos = target:GetPos() + pos;
		
		local insect = ents.Create( ( self:GetSky() == SKY_NIGHT ) && "zing_insect_firefly" || "zing_insect_butterfly" );
		insect:SetPos( pos );
		insect:Spawn();
		
	end

end


/*------------------------------------
	NatureThink()
------------------------------------*/
function GM:NatureThink()

	// check spawn time
	if ( NextInsect <= CurTime() ) then
	
		NextInsect = CurTime() + math.random( 5, 15 );

		self:SpawnInsect();
		
	end
	
end


/*------------------------------------
	SetSky()
------------------------------------*/
function GM:SetSky( sky )

	local rc = RoundController();
	if( IsValid( rc ) ) then
	
		rc.dt.Sky = sky;
		
	else
	
		timer.Simple( 0, function() self:SetSky( sky ) end );
	
	end

end


/*------------------------------------
	NextSky()
------------------------------------*/
function GM:NextSky()

	// TODO: this should actually increment the sky
	self:SetSky( SKY_NIGHT );

end

