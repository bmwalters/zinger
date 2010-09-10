
/*------------------------------------
	TeamChangeNotification()
------------------------------------*/
function GM:TeamChangeNotification( pl, oldteam, newteam )

	self:ChatText( pl:UserID(), pl:Name(), pl:Name() .. " changed team to " .. team.GetName( newteam ), "team" );
	
end


/*------------------------------------
	CleanUp()
------------------------------------*/
local function CleanUp( msg )

	RunConsoleCommand( "r_cleardecals" );
	hud.RemoveHints();
	
end
usermessage.Hook( "CleanUp", CleanUp );


/*------------------------------------
	PlaySound()
------------------------------------*/
local function PlaySound( msg )

	SND( msg:ReadString() );
	
end
usermessage.Hook( "PlaySound", PlaySound );


/*------------------------------------
	TeeTime()
------------------------------------*/
local function TeeTime( msg )

	GAMEMODE.StrokeIndicator:SetTeeTime( msg:ReadChar() );

end
usermessage.Hook( "TeeTime", TeeTime );


/*------------------------------------
	AddNotfication()
------------------------------------*/
local function AddNotfication( msg )

	local t = msg:ReadChar();
	if ( t == NOTIFY_RING ) then
	
		GAMEMODE:AddNotification( msg:ReadEntity(), "activated", msg:ReadEntity() );
		return;
		
	elseif ( t == NOTIFY_CRATE ) then
	
		GAMEMODE:AddNotification( msg:ReadEntity(), "picked up", items.Get( msg:ReadString() ) );
		return;
		
	elseif ( t == NOTIFY_ITEMACTION ) then
	
		local pl = msg:ReadEntity();
		local item = items.Get( msg:ReadString() );
	
		GAMEMODE:AddNotification( pl, item.ActionText, item );
		return;
		
	elseif ( t == NOTIFY_ITEMPLAYER ) then
	
		local pl = msg:ReadEntity();
		local item = items.Get( msg:ReadString() );
	
		GAMEMODE:AddNotification( pl, item.ActionText, msg:ReadEntity(), "with", item );
		return;
		
	elseif ( t == NOTIFY_SINKCUP ) then
	
		GAMEMODE:AddNotification( msg:ReadEntity(), "reached the", msg:ReadEntity() );
		return;
	
	end
	
end
usermessage.Hook( "AddNotfication", AddNotfication );


/*------------------------------------
	ItemAlert()
------------------------------------*/
local function ItemAlert( msg )

	GAMEMODE:ItemAlert( msg:ReadString() );
	
end
usermessage.Hook( "ItemAlert", ItemAlert );


/*------------------------------------
	ShowTeam()
------------------------------------*/
function GM:ShowTeam()
end
