
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName				= "Viewmodel";

ENT.AutomaticFrameAdvance	= true;

/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Bool", 0, "PitchLocked" );

end


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.BaseClass.Initialize( self );

	if( SERVER ) then
	
		self:DrawShadow( true );
		self:SetNoDraw( true );
	
	end
		
	self.ViewAngle = Angle( 0, 0, 0 );

end



/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	local ball = self:GetOwner();
	if( !IsValid( ball ) ) then
	
		return;
		
	end
	
	if ( CLIENT ) then
	
		local m = self:GetModel();

		if ( self:IsEffectActive( EF_NODRAW ) || m != self.LastModel ) then
		
			self.ModelScale = 0;
			
		end
		
		self.LastModel = m;
		
	end
	
	// we predict on the local player, but allow the server to calculate it for others
	if( CLIENT && ball:GetOwner() != LocalPlayer() ) then
	
		return;
		
	end
	
	// lerp viewing angle
	self.ViewAngle = LerpAngle( FrameTime() * 6, self.ViewAngle, ( ball.AimVec or vector_up ):Angle() );
	
	if( self.dt.PitchLocked ) then
	
		self.ViewAngle.p = 0;
		
	end
	
	local angle = self.ViewAngle;
	local right = angle:Right();
	
	// calculate the position of the model
	local pos = ball:GetPos();
	pos = pos + right * ball.Size * 1.1;
	//pos = pos + Vector( 0, 0, 6 );
	
	self:SetPos( pos );
	self:SetAngles( angle );
	
	self:NextThink( CurTime() );
	return true;

end
