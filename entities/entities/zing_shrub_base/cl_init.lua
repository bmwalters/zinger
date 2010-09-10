
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.SwayOffset = math.random() * 4;
	self.SwayAngle = Angle( math.random( 2, 8 ), 0, math.random( 2, 8 ) );
	
	// render bounds
	self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() );
	
end


/*------------------------------------
	BuildBonePositions()
------------------------------------*/
function ENT:BuildBonePositions( numBones )

	local sway = math.sin( CurTime() + self.SwayOffset );
		
	for i = 0, numBones - 1 do
	
		local amt = sway * ( i / numBones );
		
		local bone = self:GetBoneMatrix( i );
		bone:Rotate( Angle( self.SwayAngle.p * amt, 0, self.SwayAngle.r * amt ) );
		self:SetBoneMatrix( i, bone );
	
	end
	
	// dirty the shadow
	self:MarkShadowAsDirty( true );
	
end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	if ( GetConVarNumber( "cl_zing_show_foliage" ) <= 0 ) then
	
		return;
		
	end

	self:DrawModel();

end
