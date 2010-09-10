
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.BoingEndTime = CurTime();
	self.BoingActive = false;
	self.RebuildShadow = true;

	// inflate the render bounds a little because we bloat out when something hits me
	self:SetRenderBounds( self:OBBMins() * 1.5, self:OBBMaxs() * 1.5 );
	
	self.BaseClass.Initialize( self );

end


/*------------------------------------
	BuildBonePositions()
------------------------------------*/
function ENT:BuildBonePositions( numBones )
	
	local percent = math.Clamp( ( self.BoingEndTime - CurTime() ), 0, 1 );
	
	// scale the bones
	if( self.BoingActive ) then
	
		local scale = 1 + ( math.sin( CurTime() * 50 ) * percent * 0.25 );

		for i = 0, numBones - 1 do
		
			local matrix = self:GetBoneMatrix( i );
		
			matrix:Scale( Vector( 1, scale, scale ) );
					
			self:SetBoneMatrix( i, matrix );
			
		end
		
		// we're animating our bones
		// update the shadow to reflect them
		self.RebuildShadow = true;
				
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	if( !self.BoingActive && self.dt.Impact ) then
	
		self.BoingActive = true;
		self.BoingEndTime = CurTime() + 1;
	
	end
	
	if( self.BoingActive && self.BoingEndTime <= CurTime() ) then
	
		self.BoingActive = false;
	
	end
	
	self.ModelScale = math.Approach( self.ModelScale or 0, 1, FrameTime() * 5 );
	if( self.ModelScale < 1 ) then
	
		self.RebuildShadow = true;
		
	end

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	if( self.RebuildShadow ) then
	
		// redraw the shadow
		self:MarkShadowAsDirty( true );
		self.RebuildShadow = false;
		
	end
	
	if ( self.ModelScale < 1 ) then
			
		// render model
		self:SetModelScale( Vector() * self.ModelScale );
		self:SetupBones();
		self:DrawModel();
		
	else

		// calculate outline width
		local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
		width = 1.1 + ( ( width / MAX_VIEW_DISTANCE ) * 0.1 );

		self:DrawModelOutlined( Vector( width, width, 1.05 ) );
		
	end

end
