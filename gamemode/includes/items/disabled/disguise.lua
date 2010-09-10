
ITEM.Name		= "Disguise";
ITEM.Description	= "Confuse the enemy team by changing to their ball color";
ITEM.IsEffect		= true;
ITEM.IsTimed		= true;
ITEM.Duration		= 60;
ITEM.ActionText		= "is using a";

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/disguise" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration;
	
	self.Ball:SetDisguise( true );
	
	if ( SERVER ) then
	
		umsg.Start( "AddNotfication", util.TeamOnlyFilter( self.Player:Team() ) );
			umsg.Char( NOTIFY_ITEMACTION );
			umsg.Entity( self.Player );
			umsg.Char( self.Index );
		umsg.End();
	
	end
		
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function ITEM:Deactivate()

	self.Ball:SetDisguise( false );

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.Data.EndTime && self.Data.EndTime > CurTime();

end
