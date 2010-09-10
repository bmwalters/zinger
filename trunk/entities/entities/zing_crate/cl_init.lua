
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


ENT.HintTopic = "Gameplay:Supply Crates";
ENT.HintOffset = Vector( 0, 0, 50 );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.PopTime = CurTime() + 0.15;
	self.AnimTime = CurTime() + 0.5;
	self.RebuildShadow = true; 

	// keep track of bone velocities
	self.BoneVelocities = {};
	self.BoneScales = {};
	for i = 0, 4 do
	
		self.BoneVelocities[ i ] = math.random( 0, 2 );
		self.BoneScales[ i ] = 0.1;
	
	end

	self.BaseClass.Initialize( self );
	
	// bloat out render bounds because we pop the box out of the ground beyond its boundaries
	self:SetRenderBounds( self:OBBMins() * 1.1, self:OBBMaxs() * 1.1 );
	
end

/*------------------------------------
	BuildBonePositions()
------------------------------------*/
function ENT:BuildBonePositions( numbones )

	local percent = math.Clamp( ( self.PopTime - CurTime() ) / 0.15, 0, 1 );
	
	for i = 0, numbones - 1 do
	
		local bone = self:GetBoneMatrix( i );
		if( bone ) then
			
			// animate out of the ground
			bone:Translate( Vector( 0, math.LerpNoClamp( percent, 0, -40 ), 0 ) );
			
			// animate the scale of the bone, for the explosion effect
			bone:Scale( Vector() * self.BoneScales[ i ] );
			
			// explode outward
			if( self.PopTime <= CurTime() ) then
			
				local speed = FrameTime() * 8;
				local dist = ( 1 - self.BoneScales[ i ] );
				
				// update bone scales and scale velocities
				self.BoneVelocities[ i ] = self.BoneVelocities[ i ] + speed * dist;
				self.BoneScales[ i ] = self.BoneScales[ i ] + self.BoneVelocities[ i ] * speed;
				self.BoneVelocities[ i ] = self.BoneVelocities[ i ] * ( 0.95 - FrameTime() * 8 );
			
			end
			
			self:SetBoneMatrix( i, bone );
		
		end
	
	end
	
	self.RebuildShadow = true;
		
	// don't need to animate forever...
	if( self.AnimTime <= CurTime() ) then
	
		self.BuildBonePositions = nil;
	
	end

end

/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	if( self.RebuildShadow ) then
	
		// make sure the shadow updates
		self:MarkShadowAsDirty( true );
		self.RebuildShadow = false;
	
	end

	// calculate outline width
	local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
	width = 1.05 + ( ( width / MAX_VIEW_DISTANCE ) * 0.1 );

	self:DrawModelOutlined( Vector() * width );
	
end


/*------------------------------------
	DrawOnRadar()
------------------------------------*/
function ENT:DrawOnRadar( x, y, a )

	self:RadarDrawRect( x, y, 6, 6, color_brown, a );

end

