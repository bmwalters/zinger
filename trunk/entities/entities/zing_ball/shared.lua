
// basic setup
ENT.Type 					= "anim";
ENT.Base					= "zing_base";
ENT.PrintName					= "Zinger Ball";
ENT.Model					= Model( "models/zinger/ball.mdl" );
ENT.Size					= BALL_SIZE;
ENT.IsBall					= true;

// accessors
AccessorFunc( ENT, "IsNinja", "Ninja" );
AccessorFunc( ENT, "IsStone", "Stone" );
AccessorFunc( ENT, "IsDisguise", "Disguise" );
AccessorFunc( ENT, "IsSpy", "Spy" );


/*------------------------------------
	SetupDataTables()
------------------------------------*/
function ENT:SetupDataTables()

	self:DTVar( "Entity", 0, "ViewModel" );
	self.dt.ViewModel = NULL;

end


/*------------------------------------
	Team()
------------------------------------*/
function ENT:Team()

	local pl = self:GetOwner();
	if ( !IsValid( pl ) ) then
	
		return TEAM_SPECTATOR;
		
	end
	
	return pl:Team();

end


/*------------------------------------
	GetWeaponPosition()
------------------------------------*/
function ENT:GetWeaponPosition( item )

	// does this ball have a view model?
	// if not return the ball position and angles
	local viewmodel = self.dt.ViewModel;
	if( !IsValid( viewmodel ) ) then
	
		return self:GetPos(), self.AimVec:Angle();
		
	end
	
	// get the muzzle attachment on the view model
	// if it doesn't exist just return the view models position and angles
	local attachment = viewmodel:GetAttachment( viewmodel:LookupAttachment( "Muzzle" ) );
	if( !attachment ) then
	
		return viewmodel:GetPos(), viewmodel:GetAngles();
	
	end
	
	return attachment.Pos, attachment.Ang;

end
