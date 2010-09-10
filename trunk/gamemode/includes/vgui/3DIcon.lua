
// object
local PANEL = {};

// materials
local BlackModelSimple = Material( "black_outline" );

// accessors
AccessorFunc( PANEL, "Distance", "Distance", FORCE_NUMBER );
AccessorFunc( PANEL, "Outline", "Outline", FORCE_NUMBER );
AccessorFunc( PANEL, "AnimationSpeed", "AnimationSpeed", FORCE_NUMBER );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()
	
	// default
	self:SetViewDistance( 45 );
	self:SetOutline( 0 );
	
	// entity storage
	self.Entity = nil;
	self:SetAnimationSpeed( 0 );
	self.LastPaint = 0;

end


/*------------------------------------
	SetModel()
------------------------------------*/
function PANEL:SetModel( model )

	// create
	self.Entity = ClientsideModel( Model( model ), RENDER_GROUP_OPAQUE_ENTITY );
	self.Entity:SetNoDraw( true );
	self.Entity:SetPos( vector_origin );
	self.Entity:SetAngles( Angle( 0, 0, 0 ) );
	
end


/*------------------------------------
	SetViewDistance()
------------------------------------*/
function PANEL:SetViewDistance( dist )

	// setup render view position
	self.ViewPos = Vector( dist, 0, 0 );
	self.ViewAng = ( vector_origin - self.ViewPos ):Angle();
	
end


/*------------------------------------
	SetOffset()
------------------------------------*/
function PANEL:SetOffset( pos )

	self.Entity:SetPos( pos );
	
end


/*------------------------------------
	SetAngles()
------------------------------------*/
function PANEL:SetAngles( ang )

	self.Entity.Angles = ang;
	self.Entity:SetAngles( ang );

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()

	if ( self:GetAnimationSpeed() > 0 ) then
	
		self.Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self:GetAnimationSpeed() );
	
	end
	
	self:Run();

end


/*------------------------------------
	Run()
------------------------------------*/
function PANEL:Run()
end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	local p = self:GetParent();
	if ( p.ShouldPaint && !p:ShouldPaint() ) then
	
		return;
		
	end
	
	self.LastPaint = RealTime();

	// validate
	if ( !IsValid( self.Entity ) ) then
	
		return;
		
	end

	// get size
	local w, h = self:GetSize();
	
	// setup renderer
	render.SuppressEngineLighting( true );
	render.SetLightingOrigin( Vector( 256, 0, 0 ) );
	render.ResetModelLighting( 0, 0, 0 );
	render.SetModelLighting( BOX_FRONT, 1, 1, 1 );
	render.SetModelLighting( BOX_TOP, 1, 1, 1 );
	render.SetColorModulation( 1, 1, 1 );
	
	// get position
	local x, y = self:LocalToScreen( 0, 0 );
	
	// start camera
	cam.Start3D( self.ViewPos, self.ViewAng, 80, x, y, w, h );
	
		if ( self:GetOutline() > 0 ) then
		
			SetMaterialOverride( BlackModelSimple );
			
			self.Entity:SetModelScale( Vector() * self:GetOutline() );
			self.Entity:SetupBones();
			self.Entity:DrawModel();
			
			// reset everything
			SetMaterialOverride();
			self.Entity:SetModelScale( Vector() * 1 );
			self.Entity:SetupBones();
			
		end
		
		local r, g, b = self.Entity:GetColor();
		render.SetColorModulation( r / 255, g / 255, b / 255 );
	
		self.Entity:DrawModel();
		
		render.SetColorModulation( 1, 1, 1 );
	
	// end camera
	cam.End3D();
	
	// reset view
	cam.Start3D( GAMEMODE.LastSceneOrigin, GAMEMODE.LastSceneAngles );
	cam.End3D();
	
	// reset lighting
	render.SuppressEngineLighting( false );
	
end

// register
derma.DefineControl( "3DIcon", "", PANEL, "DPanel" );
