
// get player metatable
local meta = FindMetaTable( "Player" );
assert( meta );

/*------------------------------------
	InstallDT()
------------------------------------*/
function meta:InstallDT()

	// create datatable
	self:InstallDataTable();
	
	// ball entity
	self:DTVar( "Entity", 0, "Ball" );
	self.dt.Ball = NULL;
	
	// camera entity
	self:DTVar( "Entity", 1, "Camera" );
	self.dt.Camera = NULL;
	
	// enable hit flag
	self:DTVar( "Bool", 0, "CanHit" );
	self.dt.CanHit = false;
	
	// number of strokes we have
	self:DTVar( "Float", 0, "Strokes" );
	
end


/*------------------------------------
	GetBall()
------------------------------------*/
function meta:GetBall()

	// validate datatable vars
	if ( !self.dt ) then
	
		return NULL;
		
	end
	
	return self.dt.Ball;

end


/*------------------------------------
	GetCamera()
------------------------------------*/
function meta:GetCamera()

	// validate datatable vars
	if ( !self.dt ) then
	
		return NULL;
		
	end
	
	return self.dt.Camera;

end


/*------------------------------------
	GetStrokes()
------------------------------------*/
function meta:GetStrokes()

	// validate datatable vars
	if ( !self.dt ) then
	
		return 0;
		
	end
	
	return self.dt.Strokes;
	
end


/*------------------------------------
	CanHit()
------------------------------------*/
function meta:CanHit()

	// validate datatable vars
	if ( !self.dt ) then
	
		return false;
		
	end
	
	return self.dt.CanHit;

end


/*------------------------------------
	Alive()
------------------------------------*/
function meta:Alive()

	return true;

end


/*------------------------------------
	GetCursorVector()
------------------------------------*/
function meta:GetCursorVector()

	return ( self.CursorAim or self:GetAimVector() );

end


/*------------------------------------
	UpdateAimVector()
------------------------------------*/
function meta:UpdateAimVector()

	// validate camera
	local camera = self:GetCamera();
	if ( !IsValid( camera ) ) then
	
		return;
		
	end
	
	// update players position
	local pos = camera:GetPos();
	local viewdir = self:GetAimVector();
	local cmd = self:GetCurrentCommand();
	pos = pos - viewdir * cmd:GetMouseX();
	
	// calculate the cursor aim vector
	self.CursorAim = Vector( cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove() );
	if ( !cmd:KeyDown( IN_CANCEL ) && IsBall( camera ) ) then
		
		// trace players view
		self:SetFOV( 80 );
		local trace = {};
		trace.start = pos;
		trace.endpos = pos + ( self:GetCursorVector() * 4096 );
		trace.filter = { camera, self };
		trace.mask = MASK_NPCWORLDSTATIC;
		local tr = util.TraceLine( trace );
		
		// calculate direction
		local dir = ( ( tr.HitPos + Vector( 0, 0, camera.Size ) ) - camera:GetPos() );
		dir:Normalize();
		
		// update aim
		camera:SetAimVector( dir );
		
	end

end


/*------------------------------------
	AllowImmediateDecalPainting()
------------------------------------*/
function meta:AllowImmediateDecalPainting()

	self.NextSprayTime = CurTime();
	
end


/*------------------------------------
	Think()
------------------------------------*/
function meta:Think()

	if( SERVER ) then
	
		inventory.Think( self );
		
		local ball = self:GetBall();
		if ( IsBall( ball ) && ball.OnTee ) then
		
			if ( CurTime() > ( ball.TeedAt + TEE_TIME ) ) then
			
				if ( #GAMEMODE:GetQueue( self:Team() ) > 0 ) then
				
					rules.Call( "FailedToTee", self, ball );
					
				end
			
			end
		
		end
		
	end

end

