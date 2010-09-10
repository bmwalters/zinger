
ITEM.Name		= "Magnet";
ITEM.Description	= "";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;
ITEM.ViewModel		= "models/zinger/v_magnet.mdl";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip			= "Hold USE to aim";
	ITEM.Image		= Material( "zinger/hud/items/magnet" );
	
end


/*------------------------------------
	Equip()
------------------------------------*/
function ITEM:Equip()

	self.ViewModelSkin = ( self.Player:Team() == TEAM_ORANGE ) and 1 or 0;

	self:ActivateViewModel();
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		// hide the view model, we want it to appear as if its being thrown
		self:DeactivateViewModel();

		local pos, ang = self:GetWeaponPosition();
		local target = self:GetTargetPosition();
	
		// clamp for distance
		local diff = ( target - pos );
		local dist = diff:Length();
		local dir = diff:GetNormal();
		
		target = pos + dir * math.min( 550, dist );
		
		// find the mid point
		local midPoint = ( pos + target ) * 0.5;	
		midPoint.z = midPoint.z + 128;
		
		// debug
		debugoverlay.Line( pos, midPoint, 2, color_white );
		debugoverlay.Line( midPoint, target, 2, color_white );
		debugoverlay.Cross( midPoint, 8, 2, color_black );
		debugoverlay.Cross( pos, 8, 2, color_black );
		debugoverlay.Cross( target, 8, 2, color_black );
		debugoverlay.Sphere( pos, 550, 2, Color( 255, 128, 0, 0 ) );
		
		// how high do we travel to reac the apex?
		local dist1 = midPoint.z - pos.z;
		local dist2 = midPoint.z - target.z;
		
		// how long will it take to travel the distance
		local time1 = math.sqrt( dist1 / ( 0.5 * 600 ) );
		local time2 = math.sqrt( dist2 / ( 0.5 * 600 ) );
		if( time1 < 0.1 ) then
		
			return;
			
		end
		
		// calculate the launch force required
		local force = ( target - pos ) / ( time1 + time2 );
		force.z = 600 * time1;
		
		// I can't figure out the proper angles for the attachment
		// so just rotate it here.
		ang:RotateAroundAxis( ang:Forward(), -25 );
		
		// create magnet and throw it
		local magnet = ents.Create( "zing_magnet" );
		magnet:SetOwner( self.Ball );
		magnet:SetPos( pos );
		magnet:SetSkin( ( self.Player:Team() == TEAM_ORANGE ) and 1 or 0 );
		magnet:SetAngles( ang );
		magnet:Spawn();
		magnet.Team = self.Ball:Team();

		local phys = magnet:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			phys:SetVelocity( force );
		
		end
		
	end
	
end

