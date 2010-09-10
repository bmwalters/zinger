
// setup
ITEM.Name			= "Air Strike";
ITEM.Description	= "";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration 		= 20;
ITEM.ViewModel		= "models/zinger/v_radio.mdl";
ITEM.ActionText		= "radioed in an";

// client setup
if ( CLIENT ) then

	ITEM.Cursor 	= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE and pick a location";
	ITEM.Image		= Material( "zinger/hud/items/airstrike" );
	
end


/*------------------------------------
	Equip()
------------------------------------*/
function ITEM:Equip()

	self:ActivateViewModel();

end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	// find if any ac130's are active
	if ( #ents.FindByClass( "zing_airstrike" ) > 0 ) then
	
		if ( SERVER ) then
			
			self:ItemAlert( "Air Strike already inbound" );
			
		end
		
		// deny
		return true;
	
	end
	
	local pos;
	
	if( SERVER ) then
	
		local tr = self:GetTargetTrace();
	
		// make sure its in a playable area
		if ( IsOOB( tr ) ) then
			
			self:ItemAlert( "Invalid Position" );
			
			return true;
		
		end
		
		pos = tr.HitPos;
		
	end

	self:DeactivateViewModel();
	
	if ( CLIENT ) then
	
		return;
		
	end
	
	// validate ball
	local ball = self.Player:GetBall();
	if ( !IsBall( ball ) ) then
	
		return;
		
	end
	
	// create entity
	local ent = ents.Create( "zing_airstrike" );
	ent:SetPos( pos );
	ent:SetAngles( ( pos - self.Player:GetPos() ):Angle():Right():Angle() );
	ent:SetOwner( ball );
	ent:Spawn();
	ent.TargetPos = pos;
	
	// play global sound
	GAMEMODE:PlaySound( "zinger/items/airstrikeradio.mp3" );
	
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function ITEM:Deactivate()
end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()
end
