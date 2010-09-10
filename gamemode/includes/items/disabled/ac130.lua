
// setup
ITEM.Name			= "AC-130";
ITEM.Description	= "A plane loaded full of modernized warfare rains death from above";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration 		= 20;
ITEM.ViewModel		= "models/zinger/v_radio.mdl";
ITEM.ActionText		= "called in an";

// client setup
if ( CLIENT ) then

	ITEM.Image			= Material( "zinger/hud/items/ac130" );
	
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
	if ( #ents.FindByClass( "zing_ac130" ) > 0 ) then
	
		if ( SERVER ) then
			
			self:ItemAlert( "AC-130 already active" );
			
		end
		
		// deny
		return true;
	
	end
	
	// set end time
	self.Data.EndTime = CurTime() + self.Duration;
	
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
	local ent = ents.Create( "zing_ac130" );
	ent:SetPos( self.Player:GetPos() );
	ent:Spawn();
	
	// setup information
	ent.DieTime = CurTime() + self.Duration;
	ent.Hunt = util.OtherTeam( self.Player:Team() );
	
	// delay removal
	SafeRemoveEntityDelayed( ent, self.Duration );
	
	// send notification
	umsg.Start( "AddNotfication" );
		umsg.Char( NOTIFY_ITEMACTION );
		umsg.Entity( self.Player );
		umsg.Char( self.Index );
	umsg.End();
	
	// play global sound
	GAMEMODE:PlaySound( "zinger/items/ac130radio.mp3" );
	
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
