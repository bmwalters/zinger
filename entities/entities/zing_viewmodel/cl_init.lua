
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	local owner = self:GetOwner();
	if( !IsValid( owner ) ) then
	
		return;
		
	end
	
	local pl = owner:GetOwner();
	if( !IsValid( pl ) ) then
	
		return;
		
	end
	
	// pre draw, would really like some better way to do this, oh well.
	/*
	local canSee = true;
	for k, v in pairs( pl.ActiveItems ) do
	
		local ret = GAMEMODE:ItemCall( pl, v, "PreDrawViewModel" );
		if( ret != nil && ret != true ) then
		
			canSee = false;
			
		end
		
	end
	if( !canSee ) then
	
		self:DrawShadow( false );
		return;

	else
	
		self:DrawShadow( true );
	
	end
	*/
	
	
	self.ModelScale = math.Approach( self.ModelScale or 0, 1, FrameTime() * 5 );
	
	if ( self.ModelScale < 1 ) then
		
		// render model
		self:SetModelScale( Vector() * self.ModelScale );
		self:SetupBones();
		self:DrawModel();
		
	else
			
		// calculate outline width
		local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
		width = 1.025 + ( ( width / MAX_VIEW_DISTANCE ) * 0.05 );

		self:DrawModelOutlined( Vector() * width );
	
	end
	
	
	// post draw
	/*
	for k, v in pairs( pl.ActiveItems ) do
	
		GAMEMODE:ItemCall( pl, v, "PostDrawViewModel" );
		
	end
	*/
	
end
