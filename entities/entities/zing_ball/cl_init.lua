
// shared file
include( 'shared.lua' );

// materials
local CircleMaterial = Material( "sgm/playercircle" );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.BaseClass.Initialize( self );
	
	local inflatedSize = self.Size * 1.15;
	self:SetRenderBounds( Vector() * -inflatedSize, Vector() * inflatedSize );
	
	self.MicModel = ClientsideModel( Model( "models/extras/info_speech.mdl" ), RENDERGROUP_OPAQUE );
	self.MicModel:SetMaterial( "zinger/models/mic/mic" );
	self.MicModel:SetNoDraw( true );
	
end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	local owner = self:GetOwner();
	if( !IsValid( owner ) ) then
	
		return;
	
	end

	// pre draw, would really like some better way to do this, oh well.
	/*
	self.CanSee = true;
	for k, v in pairs( owner.ActiveItems ) do
	
		local ret = GAMEMODE:ItemCall( owner, v, "PreDrawBall" );
		if( ret != nil && ret != true ) then
		
			self.CanSee = false;
			
		end
		
	end
	if( !self.CanSee ) then
	
		return;
		
	end
	*/
	
	local pos = self:GetPos();
	/*
	if ( owner == LocalPlayer() ) then
	
		self:DrawShadow( true );
		
	end
	
	*/
	local tr = util.TraceLine( {
		start = pos,
		endpos = pos - Vector( 0, 0, 64 ),
		filter = self,
		mask = MASK_NPCWORLDSTATIC,
	} );
	if( tr.Hit ) then
	
		// disguise
		local t = owner:Team();
		if( self:GetDisguise() ) then
		
			t = util.OtherTeam( t );
		
		end
	
		local color = team.GetColor( t );
	
		// draw team circle
		render.SetMaterial( CircleMaterial );
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal * 0.2, tr.HitNormal, 64, 64, Color( color.r, color.g, color.b, ( 1 - tr.Fraction ) * 255 ) );
		
	end

	// calculate outline width
	local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
	width = 1.1 + ( ( width / MAX_VIEW_DISTANCE ) * 0.2 );

	self:DrawModelOutlined( Vector() * width );
	
	if ( owner:IsSpeaking() ) then

		if ( IsValid( self.MicModel ) ) then
		
			local ea = EyeAngles();
			self.MicModel:SetPos( pos + Vector( 0, 0, self.Size * 2.5 ) + ( ea:Right() * self.Size * 0.5 ) );
			self.MicModel:SetAngles( Angle( 0, ea.Yaw + 180, 0 ) );
			
			render.SuppressEngineLighting( true );
			self.MicModel:DrawModel();
			
			render.SuppressEngineLighting( false );
			
		end
		
	end
	
	
	// post draw
	/*
	for k, v in pairs( owner.ActiveItems ) do
	
		GAMEMODE:ItemCall( owner, v, "PostDrawBall" );
		
	end
	*/

end


/*------------------------------------
	GetPos2D()
------------------------------------*/
function ENT:GetPos2D()

	return GetEntityPos2D( self, self.Size );

end



