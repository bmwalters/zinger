
// materials
local MaterialHorizon = Material( "zinger/sky/sky" );
local MaterialPuff = Material( "zinger/particles/puff" );
local MaterialSun = Material( "zinger/sky/sun" );
local MaterialSunBurst = Material( "zinger/sky/sunburst" );
local MaterialMoon = Material( "zinger/sky/moon" );
local MaterialStar = Material( "zinger/sky/star" );
local MaterialComet = Material( "zinger/sky/comet" );

// model we use to render the sky horizon
local HorizonModel = ClientsideModel( "models/zinger/ball.mdl" );
HorizonModel:SetNoDraw( true );
HorizonModel:SetModelScale( Vector( -2500, -2500, -2500 ) );
HorizonModel:SetupBones();

// convars
local SkyConVar = CreateClientConVar( "cl_zing_skydetail", "4", true, false );
local NatureSoundConVar = CreateClientConVar( "cl_zing_naturesounds", "1", true, false );
local NaturePPConVar = CreateClientConVar( "cl_zing_nature_pp", "1", true, false );
CreateConVar( "cl_zing_show_foliage", "1", { FCVAR_CHEAT } );

// different sky types
local Skies = {
	[ SKY_DAWN ] = {
		SkyColor = Color( 102, 156, 190, 255 ),
		HorizonColor = Color( 226, 161, 95, 255 ),
		SunColor = Color( 253, 252, 150, 255 ),
		Elevation = 0,
		CloudColor = Color( 180, 180, 180, 255 ),
		ColorModify = {
			addr = 0.08, addg = 0.04, addb = 0,
			mulr = 0, mulg = 0, mulb = 0,
			color = 1.2,
			contrast = 1,
			brightness = -0.01,
		}
	},
	[ SKY_DAY ] = {
		SkyColor = Color( 132, 186, 220, 255 ),
		HorizonColor = Color( 255, 255, 255, 255 ),
		SunColor = Color( 253, 252, 191, 255 ),
		CloudColor = Color( 255, 255, 255, 255 ),
		Elevation = 20,
		ColorModify = {
			addr = 0, addg = 0, addb = 0,
			mulr = 0, mulg = 0, mulb = 0,
			color = 1.1,
			contrast = 1,
			brightness = 0,
		}
	},
	[ SKY_DUSK ] = {
		SkyColor = Color( 91, 54, 201, 255 ),
		HorizonColor = Color( 255, 133, 88, 255 ),
		SunColor = Color( 253, 225, 139, 255 ),
		CloudColor = Color( 180, 180, 180, 255 ),
		Elevation = 180,
		StarOpacity = 0.25,
		ColorModify = {
			addr = 0.0, addg = 0.035, addb = 0.1,
			mulr = 0, mulg = 0, mulb = 0,
			color = 1.1,
			contrast = 1,
			brightness = -0.025,
		}
	},
	[ SKY_NIGHT ] = {
		SkyColor = Color( 22, 52, 128, 255 ),
		HorizonColor = Color( 42, 5, 109, 255 ),
		SunColor = Color( 253, 252, 191, 255 ),
		CloudColor = Color( 140, 140, 140, 255 ),
		Elevation = 195,
		StarOpacity = 1,
		ColorModify = {
			addr = 0.0, addg = 0.05, addb = 0.15,
			mulr = 0, mulg = 0, mulb = 0,
			color = 1.1,
			contrast = 1,
			brightness = -0.05,
		}
	},
};

// day sounds
local DaySounds = {
	Sound( "zinger/nature/bird1.mp3" ),
	Sound( "zinger/nature/bird2.mp3" ),
	Sound( "zinger/nature/bird3.mp3" ),
	Sound( "zinger/nature/crow1.mp3" ),
	Sound( "zinger/nature/magpie1.mp3" ),
	Sound( "zinger/nature/magpie2.mp3" ),
	Sound( "zinger/nature/sparrow1.mp3" )
};

// night sounds
local NightSounds = {
	Sound( "zinger/nature/frog1.mp3" ),
	Sound( "zinger/nature/frog2.mp3" ),
	Sound( "zinger/nature/frog3.mp3" ),
	Sound( "zinger/nature/cricket1.mp3" ),
	Sound( "zinger/nature/cricket2.mp3" ),
	Sound( "zinger/nature/cricket3.mp3" ),
	Sound( "zinger/nature/cricket4.mp3" )
};

// configure sounds for times of day
local NatureSounds = {
	[ SKY_DAWN ] = {
		Samples = DaySounds
	},
	[ SKY_DAY ] = {
		Transition = Sound( "zinger/nature/rooster1.mp3" ),
		Samples = DaySounds
	},
	[ SKY_DUSK ] = {
		Samples = NightSounds
	},
	[ SKY_NIGHT ] = {
		Transition = Sound( "zinger/nature/owl1.mp3" ),
		Samples = NightSounds
	},
};


local NextSound = CurTime() + 3;
local NextComet = CurTime() + math.Rand( 3, 30 );

local StarColor = Color( 255, 255, 255,255 );
local ShadeColor = Color( 200, 200, 200, 255 );

local ColorMod = {};
local Clouds = {};
local Stars = {};


/*------------------------------------
	GenerateCloudShape()
------------------------------------*/
local function GenerateCloudShape( size )

	local cloud = { { Offset = Vector( 0, 0, 0 ), Frame = 1, Speed = 0.1 } };
	
	// generate 6 sprites for the cloud, ensure they're spaced at least 48 units apart
	for i = 1, 6 do

		while( true ) do
		
			local valid = false;
		
			// build a random offset
			local offset = Vector( math.Rand( -( size / 1.5 ), ( size / 1.5 ) ), math.Rand( -( size / 2 ), ( size / 2 ) ), 0 );
			for k, v in pairs( cloud ) do
			
				if( ( v.Offset - offset ):Length() >= ( size / 2 ) ) then
				
					valid = true;
					break;
					
				end
						
			end
			
			// valid?
			if( valid ) then
			
				// add to the cloud
				table.insert( cloud, {
					Offset = offset,
					Frame = math.random( 1, 3 ),
					Speed = math.Rand( 0.1, 0.6 ),
					Delta = 0,
				} );
				
				break;
				
			end
		
		end
		
	end
	
	return cloud;
	
end


/*------------------------------------
	GenerateClouds()
------------------------------------*/
local function GenerateClouds()

	// ensure we get a random distribution EVERY time
	math.randomseed( SysTime() );

	// generate clouds
	for i = 1, SKY_NUM_CLOUDS do
	
		local size = math.random( 1500, 1800 );
	
		// generate a random cloud shape
		local shape = GenerateCloudShape( size );
		
		// calculate cloud elevation and speed
		local elevation = math.random( 0, 15 );
		local speed = math.Rand( -2, 2 );
		speed = speed * ( 1 - ( ( 1 / 35 ) * ( elevation - 10 ) ) );
		
		// cloud bearing angle
		local bearing = ( 360 / SKY_NUM_CLOUDS ) * ( i - 1 );
		
		// add cloud to list
		table.insert( Clouds, {
			Size = size,
			Shape = shape,
			Speed = speed,
			Angle = Angle( -elevation, bearing, 0 ),
		} );
		
	end

end


/*------------------------------------
	GenerateStars()
------------------------------------*/
local function GenerateStars()

	// generate 120 stars
	for i = 1, 120 do
	
		local size = math.random( 100, 150 );
		
		// calculate star elevation
		local elevation = math.random( -10, 80 );
		
		// star bearing angle
		local bearing = math.random( 0, 360 );
		
		local angle = Angle( -elevation, bearing, 0 );
		local normal = angle:Forward();
		local position = normal * 14000;
		normal = ( vector_origin - position ):GetNormal();
		
		// add star to list
		table.insert( Stars, {
			Size = size,
			Normal = normal,
			Position = position,
			TwinkleRate = math.Rand( 1, 2 ),
		} );
		
	end

end


local Comet;


/*------------------------------------
	RenderStars()
------------------------------------*/
function GM:RenderStars( opacity )

	render.SetMaterial( MaterialStar );
	
	// render the stars
	mesh.Begin( MATERIAL_QUADS, #Stars );
	for i = 1, #Stars do
	
		local star = Stars[ i ];

		StarColor.a = ( 155 + math.sin( CurTime() * star.TwinkleRate ) * 100 ) * opacity;
		mesh.QuadEasy( star.Position, star.Normal, star.Size, star.Size, StarColor );
		
	end
	mesh.End();
	
	if ( Comet == nil ) then
	
		if( NextComet <= CurTime() ) then
		
			NextComet = CurTime() + math.Rand( 3, 30 );
	
			local angle = Angle( math.random( 20, 40 ) * -1, math.random( 0, 360 ), 0 );
			local normal = angle:Forward();
			local position = normal * 13000;
			normal = ( vector_origin - position ):GetNormal();
			
			Comet = {
				Angle = Angle( math.random( 20, 40 ) * -1, math.random( 0, 360 ), 0 ),
				Alpha = 1,
			};
			
			if ( math.random( 1, 2 ) == 1 ) then
			
				Comet.Direction = -1
				
			else
			
				Comet.Direction = 1
			
			end
			
		end
		
	else
	
		Comet.Alpha = math.Approach( Comet.Alpha, 255, FrameTime() * 100 );
		Comet.Angle = Comet.Angle + Angle( ( FrameTime() * 45 ), ( ( FrameTime() * 45 ) * 2 ) * Comet.Direction, 0 )
		Comet.Normal = Comet.Angle:Forward();
		Comet.Position = Comet.Normal * 13000;
		Comet.Normal = ( vector_origin - Comet.Position ):GetNormal();
		
		render.SetMaterial( MaterialComet );
		
		mesh.Begin( MATERIAL_QUADS, 1 );
		
		mesh.QuadEasy( Comet.Position, Comet.Normal, 1500, 150, Color( 255, 255, 255, Comet.Alpha * opacity ), ( Comet.Direction == 1 ) && 217.5 || 337.5 );
		
		mesh.End();
		
		if ( Comet.Angle.p > 10 ) then
		
			Comet = nil;
		
		end
		
	end
	
end


/*------------------------------------
	RenderCelestialBodies()
------------------------------------*/
function GM:RenderCelestialBodies( percent, origin )

	local elevation = Skies[ self:GetSky() ].Elevation;
			
	// should render the sun?
	if( self:GetSky() != SKY_NIGHT ) then
	
		local time = CurTime();
		
		local normal = Angle( -elevation, 0, 0 ):Forward();
		local position = normal * 14000;
		normal = ( origin - position ):GetNormal();
		
		// sun color
		local SunColor = Skies[ self:GetSky() ].SunColor;
		
		// render the sun rays
		render.SetMaterial( MaterialSunBurst );
		render.DrawQuadEasy( position, normal, 6000, 6000, Color( SunColor.r, SunColor.g, SunColor.b, 200 ), time * 2 );
		render.DrawQuadEasy( position, normal, 6000, 6000, Color( SunColor.r, SunColor.g, SunColor.b, 200 ), time * -2 );
		render.DrawQuadEasy( position, normal, 12000, 12000, Color( SunColor.r, SunColor.g, SunColor.b, 128 ), time * -4 );
		
		// render the sun body
		render.SetMaterial( MaterialSun );
		render.DrawQuadEasy( position, normal, 4000, 4000, Color( SunColor.r, SunColor.g, SunColor.b, 255 ) );
	
	// should render the moon?
	else
	
		local normal = Angle( -( elevation - 180 ), 0, 0 ):Forward();
		local position = normal * 14000;
		normal = ( origin - position ):GetNormal();
		
		// render the moon glow
		render.SetMaterial( MaterialSun );
		render.DrawQuadEasy( position, normal, 4000, 4000, color_white );
		
		// render the moon
		render.SetMaterial( MaterialMoon );
		render.DrawQuadEasy( position, normal, 3000, 3000, color_white );
		
	end
	
end


/*------------------------------------
	RenderClouds()
------------------------------------*/
function GM:RenderClouds( percent, origin )
	
	// cloud color
	local CloudColor = Skies[ self:GetSky() ].CloudColor;
	
	render.SetMaterial( MaterialPuff );

	// render the outline pass
	mesh.Begin( MATERIAL_QUADS, SKY_NUM_CLOUDS * 6 * 3 );
	for i = 1, SKY_NUM_CLOUDS do
	
		local cloud = Clouds[ i ];
				
		local normal = cloud.Angle:Forward();
		local position = normal * 14000;
		normal = ( origin - position ):GetNormal();
		local right = normal:Angle():Right();
		local up = normal:Angle():Up();
		
		// animate the cloud
		cloud.Angle.y = cloud.Angle.y + FrameTime() * cloud.Speed + FrameTime() * ( cloud.Speed < 0 && -0.5 || 0.5 );
				
		//
		// do the caching of the normal and stuff in this pass.	
		//
		
		cloud.Normal = normal;
		cloud.Position = position;
		
		// render background
		for j = 1, 6 do
		
			local sprite = cloud.Shape[ j ];
		
			sprite.Position = position + right * sprite.Offset.x + up * sprite.Offset.y;
			sprite.Delta = math.sin( CurTime() * sprite.Speed ) * 128;
				
			mesh.QuadEasy(
				sprite.Position,
				normal,
				cloud.Size + sprite.Delta + 128, cloud.Size + sprite.Delta + 128,
				color_black
			);
		
		end
				
		// render shade
		for j = 1, 6 do
		
			local sprite = cloud.Shape[ j ];
		
			mesh.QuadEasy(
				sprite.Position,
				normal,
				cloud.Size + sprite.Delta, cloud.Size + sprite.Delta,
				ShadeColor
			);
		
		end
		
		// render color
		for j = 1, 6 do
		
			local sprite = cloud.Shape[ j ];
	
			mesh.QuadEasy(
				position + right * sprite.Offset.x + up * ( sprite.Offset.y + ( cloud.Size * 0.075 ) ),
				normal,
				( cloud.Size + sprite.Delta ) * 0.9, ( cloud.Size + sprite.Delta ) * 0.8,
				CloudColor
			);
		
		end
	
	end
	mesh.End();	

end


/*------------------------------------
	RenderSkyScreenspaceEffects()
------------------------------------*/
function GM:RenderSkyScreenspaceEffects()

	if ( NaturePPConVar:GetInt() <= 0 ) then
	
		return;
		
	end

	local currentSky = Skies[ self:GetSky() ].ColorModify;
	
	// draw color modification
	ColorMod[ "$pp_colour_addr" ] = currentSky.addr;
	ColorMod[ "$pp_colour_addg" ] = currentSky.addg;
	ColorMod[ "$pp_colour_addb" ] = currentSky.addb;
	ColorMod[ "$pp_colour_brightness" ] = currentSky.brightness
	ColorMod[ "$pp_colour_contrast" ] = currentSky.contrast;
	ColorMod[ "$pp_colour_colour" ] = currentSky.color;
	ColorMod[ "$pp_colour_mulr" ] = currentSky.mulr;
	ColorMod[ "$pp_colour_mulg" ] = currentSky.mulg;
	ColorMod[ "$pp_colour_mulb" ] = currentSky.mulb;
	DrawColorModify( ColorMod );

end


/*------------------------------------
	PreDrawSkyBox()
------------------------------------*/
function GM:PreDrawSkyBox()

	if ( SkyConVar:GetInt() < 0 ) then
	
		return;
		
	end

	//local pre = gcinfo();

	local angles = self.LastSceneAngles;

	local SkyColor = Skies[ self:GetSky() ].SkyColor;
	local HorizonColor = Skies[ self:GetSky() ].HorizonColor;
	local StarOpacity = Skies[ self:GetSky() ].StarOpacity;
		
	// clear to the sky color
	render.Clear( SkyColor.r, SkyColor.g, SkyColor.b, 255 );
	cam.Start3D( vector_origin, angles )

		// render the horizon
		render.SuppressEngineLighting( true );
		render.SetColorModulation( HorizonColor.r / 255, HorizonColor.g / 255, HorizonColor.b / 255 );
		SetMaterialOverride( MaterialHorizon );
				
			HorizonModel:DrawModel();
			
		SetMaterialOverride();
		render.SetColorModulation( 1, 1, 1 );
		render.SuppressEngineLighting( false );
				
		// adhere to sky level of detail
		if( SkyConVar:GetInt() > 2 && StarOpacity && StarOpacity > 0 ) then
		
			// draw stars
			self:RenderStars( StarOpacity );
			
		end
		
		// adhere to sky level of detail
		if( SkyConVar:GetInt() > 0 ) then
		
			// draw sun and moon
			self:RenderCelestialBodies( percent, vector_origin );
			
		end
		
		// adhere to sky level of detail
		if( SkyConVar:GetInt() > 1 ) then
		
			// draw clouds
			self:RenderClouds( percent, vector_origin );
			
			// the clouds create a bunch of garbage- lets clean some of it up
			// TODO: fix the garbage? not even sure if its possible with all
			// the calculations involved!!!!
			//collectgarbage( "step", 90 );
			
		end
	
	cam.End3D();
	
	//local post = gcinfo();
	//print( post - pre );
	
	return true;

end


/*------------------------------------
	NatureThink()
------------------------------------*/
function GM:NatureThink()

	// check sound time
	if ( CurTime() > NextSound ) then
	
		// make sure we have sounds to use
		if ( NatureSounds[ self:GetSky() ] && NatureSounds[ self:GetSky() ].Samples ) then
		
			// play a random sound
			self:PlayNatureSound( table.Random( NatureSounds[ self:GetSky() ].Samples ) );
			
		end
	
	end
	
end


/*------------------------------------
	PlayNatureSound()
------------------------------------*/
function GM:PlayNatureSound( sound )

	// set the delay
	NextSound = CurTime() + SoundDuration( sound ) + math.random( 2, 8 );
	
	// allow them to disable
	if( NatureSoundConVar:GetInt() < 1 ) then
	
		return;
		
	end
	
	// randomize where its coming from
	local pos = LocalPlayer():GetPos() + Vector( math.random( -20, 20 ), math.random( -20, 20 ), 0 );
	
	// play the sound
	WorldSound( sound, pos, 75, math.random( 95, 105 ) );
	
end


/*------------------------------------
	GetCloudShadeColor()
------------------------------------*/
function GM:GetCloudShadeColor()

	return ShadeColor;

end


/*------------------------------------
	GetCloudColor()
------------------------------------*/
function GM:GetCloudColor()

	return Skies[ self:GetSky() ].CloudColor;

end


// generate the clouds
GenerateClouds();
GenerateStars();
