
// get player metatable
local meta = FindMetaTable( "Player" );
assert( meta );

// accessors
AccessorFunc( meta, "Ball", "Ball" );
AccessorFunc( meta, "LoadoutState", "LoadoutState" );


/*------------------------------------
	SpawnBall()
------------------------------------*/
function meta:SpawnBall()

	// get team color
	local color = team.GetColor( self:Team() );
	
	// create ball
	local ball = ents.Create( "zing_ball" );
	ball:Spawn();
	
	// save
	self:SetBall( ball );
	ball:SetOwner( self );
	
	self:SetMoveType( MOVETYPE_NONE );
	
	return ball;

end


/*------------------------------------
	HitBall()
------------------------------------*/
function meta:HitBall( dir, power )

	// validate ball
	local ball = self:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
	
	end
	
	power = rules.Call( "BallHit", self, power );
	
	// hit the ball
	ball:Hit( dir, power );
	self:SetCanHit( false );
	
	// clear notification
	umsg.Start( "TeeTime", self );
		umsg.Char( 0 );
	umsg.End();
	
end


/*------------------------------------
	SetBall()
------------------------------------*/
function meta:SetBall( ent )

	// neuter them first!
	SafeRemoveEntity( self.dt.Ball );
	
	self.dt.Ball = ent;

end


/*------------------------------------
	SetCamera()
------------------------------------*/
function meta:SetCamera( ent )
	
	self.dt.Camera = ent;

end


/*------------------------------------
	SetStrokes()
------------------------------------*/
function meta:SetStrokes( num )
	
	self.dt.Strokes = num;
	
	self:SetDeaths( math.max( 0, num ) );

end


/*------------------------------------
	AddStroke()
------------------------------------*/
function meta:AddStroke()

	self:SetStrokes( self.dt.Strokes + 1 );
	
end


/*------------------------------------
	RemoveStroke()
------------------------------------*/
function meta:RemoveStroke()

	self:SetStrokes( self.dt.Strokes - 1 );
	
end


/*------------------------------------
	SetCanHit()
------------------------------------*/
function meta:SetCanHit( bool )

	self.dt.CanHit = bool;

end


/*------------------------------------
	AddPoints()
------------------------------------*/
function meta:AddPoints( amt )

	GAMEMODE:AddPoints( self, amt );

end


/*------------------------------------
	ActivateViewModel()
------------------------------------*/
function meta:ActivateViewModel( model, skin, locked )

	// validate ball
	local ball = self:GetBall();
	if( !IsBall( ball ) ) then
	
		return;
	
	end
	
	// validate model
	local viewmodel = ball.dt.ViewModel;
	if( !IsValid( viewmodel ) ) then
	
		return;
	
	end
	
	viewmodel:SetModel( model );
	viewmodel:SetNoDraw( false );
	viewmodel:DrawShadow( true );
	viewmodel:SetSkin( skin or 0 );
	viewmodel:SetPitchLocked( locked or false );
	viewmodel:ResetSequence( 0 );

end



/*------------------------------------
	SetViewModelAnimation()
------------------------------------*/
function meta:SetViewModelAnimation( anim, speed )

	// validate ball
	local ball = self:GetBall();
	if( !IsBall( ball ) ) then
	
		return 0;
	
	end
	
	// validate model
	local viewmodel = ball.dt.ViewModel;
	if( !IsValid( viewmodel ) ) then
	
		return 0;
	
	end
	
	viewmodel:ResetSequence( viewmodel:LookupSequence( anim ) );
	viewmodel:SetPlaybackRate( speed or 1 );
	
	return viewmodel:SequenceDuration();

end


/*------------------------------------
	DeactivateViewModel()
------------------------------------*/
function meta:DeactivateViewModel()

	// validate ball
	local ball = self:GetBall();
	if( !IsBall( ball ) ) then
	
		return;
	
	end
	
	// validate model
	local viewmodel = ball.dt.ViewModel;
	if( !IsValid( viewmodel ) ) then
	
		return;
	
	end
	
	viewmodel:SetNoDraw( true );
	viewmodel:DrawShadow( false );

end


/*------------------------------------
	ItemAlert()
------------------------------------*/
function meta:ItemAlert( text )

	umsg.Start( "ItemAlert", self );
		umsg.String( text );
	umsg.End();

end
