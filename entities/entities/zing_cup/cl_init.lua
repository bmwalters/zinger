
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT;

local MIN_HEIGHT = 50;
local MAX_HEIGHT = 130;

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	// this cup is locked so show that.
	self.Forcefield = ClientsideModel( "models/zinger/cup_forcefield.mdl", RENDERGROUP_TRANSLUCENT );
	self.Forcefield:SetNoDraw( true );
	self.Forcefield:SetPos( self:GetPos() );
	self.Forcefield:SetParent( self );
	
	// the two flags
	local color = team.GetColor( TEAM_ORANGE );
	self.RedFlag = ClientsideModel( "models/zinger/cup_flag.mdl", RENDERGROUP_OPAQUE );
	self.RedFlag:SetNoDraw( true );
	self.RedFlag:SetPos( self:GetPos() );
	self.RedFlag:SetColor( color.r, color.g, color.b, 255 );
	self.RedFlag.Speed = math.Rand( 3, 5 );
	self.RedFlag.CurrentHeight = MIN_HEIGHT;
	self.RedFlag.BuildBonePositions = function( ent, numBones, numPhysBones )
			
		local height = MIN_HEIGHT + ( MAX_HEIGHT / 1 ) * RoundController():GetProgress( TEAM_ORANGE );
		
		ent.TargetHeight = height;
		ent.CurrentHeight = Lerp( FrameTime(), ent.CurrentHeight, ent.TargetHeight );
			
		for i = 0, numBones - 1 do
		
			local wave = 0;
			if( i > 0 ) then
			
				wave = math.sin( ( CurTime() + 17 ) * ent.Speed + i ) * 8;
			
			end
			
			local matrix = ent:GetBoneMatrix( i );
			matrix:Translate( Vector( ent.CurrentHeight, 0, wave ) );
			ent:SetBoneMatrix( i, matrix );
		
		end
	
	end
	
	local color = team.GetColor( TEAM_PURPLE );
	self.BlueFlag = ClientsideModel( "models/zinger/cup_flag.mdl", RENDERGROUP_OPAQUE );
	self.BlueFlag:SetNoDraw( true );
	self.BlueFlag:SetPos( self:GetPos() );
	self.BlueFlag:SetColor( color.r, color.g, color.b, 255 );
	self.BlueFlag.Speed = math.Rand( 3, 5 );
	self.BlueFlag.CurrentHeight = MIN_HEIGHT;
	self.BlueFlag.BuildBonePositions = function( ent, numBones, numPhysBones )
			
		local height = MIN_HEIGHT + ( MAX_HEIGHT / 1 ) * RoundController():GetProgress( TEAM_PURPLE );
		
		ent.TargetHeight = height;
		ent.CurrentHeight = Lerp( FrameTime(), ent.CurrentHeight, ent.TargetHeight );
			
		for i = 0, numBones - 1 do
		
			local wave = 0;
			if( i > 0 ) then
			
				wave = math.cos( CurTime() * ent.Speed + i ) * 8;
			
			end
			
			local matrix = ent:GetBoneMatrix( i );
			matrix:Translate( Vector( ent.CurrentHeight, 0, wave ) );
			ent:SetBoneMatrix( i, matrix );
		
		end
	
	end

	self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() );
	
	// base class
	self.BaseClass.Initialize( self );
	
end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	 self.BaseClass.Think( self );

	local pl = LocalPlayer();
	if( !IsValid( pl ) ) then
	
		return;
		
	end
	
	local angle = ( self:GetPos() - EyePos() ):Angle();
	angle.p = 0;
	
	if ( pl:Team() == TEAM_ORANGE ) then
	
		angle.y = angle.y - 150;
		self.RedFlag:SetAngles( angle );
	
		angle.y = angle.y - 60;
		self.BlueFlag:SetAngles( angle );
		
	else
	
		angle.y = angle.y - 150;
		self.BlueFlag:SetAngles( angle );
	
		angle.y = angle.y - 60;
		self.RedFlag:SetAngles( angle );
	
	end
		
end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	// hide when not needed
	if ( self.CurrentHole != self.dt.Hole ) then
	
		return;
		
	end
	
	// calculate outline width
	local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
	width = 1.05 + ( ( width / MAX_VIEW_DISTANCE ) * 0.15 );
	
	self:DrawModelOutlined( Vector( width, width, 1 ) );
	
	render.SuppressEngineLighting( true );
	local r, g, b = self.RedFlag:GetColor();
	render.SetColorModulation( r / 255, g / 255, b / 255 );
	self.RedFlag:DrawModel();
	local r, g, b = self.BlueFlag:GetColor();
	render.SetColorModulation( r / 255, g / 255, b / 255 );
	self.BlueFlag:DrawModel();
	render.SuppressEngineLighting( false );
	

		
	local pl = LocalPlayer();
	if( !IsValid( pl ) ) then
	
		return;
		
	end
	
	// hide when not needed
	if ( !rules.Call( "CanTeamSink", pl:Team() ) ) then
	
		local color = team.GetColor( pl:Team() );
	
		render.SuppressEngineLighting( true );
		render.SetColorModulation( color.r / 255, color.g / 255, color.b / 255 );
		render.SetBlend( 0.25 );
		//self.Forcefield:DrawModel();
		render.SuppressEngineLighting( false );
		render.SetColorModulation( 1, 1, 1 );
		
	end

end

/*------------------------------------
	DrawOnRadar()
------------------------------------*/
function ENT:DrawOnRadar( x, y, ang )

	self:RadarDrawCircle( x, y, 8, color_white );

end
