
// fonts
surface.CreateFont( "ComickBook", 14, 1, true, false, "Zing14" );
surface.CreateFont( "ComickBook", 18, 1, true, false, "Zing18" );
surface.CreateFont( "ComickBook", 20, 1, true, false, "Zing20" );
surface.CreateFont( "ComickBook", 22, 1, true, false, "Zing22" );
surface.CreateFont( "ComickBook", 30, 1, true, false, "Zing30" );
surface.CreateFont( "ComickBook", 42, 1, true, false, "Zing42" );
surface.CreateFont( "ComickBook", 52, 1, true, false, "Zing52" );
surface.CreateFont( "ComickBook", 18, 100, true, false, "ZingChat" );

// variables
local LastMouseMove = CurTime();
local CustomCursor;
local Scoreboard = nil;
local HelpPanel = nil;
local FirstHelp = false;
local HelpTopics = {};


/*------------------------------------
	InitializeHUD()
------------------------------------*/
function GM:InitializeHUD()
	
	// create effects monitor
	self.EffectsMonitor = vgui.Create( "ZingEffectsMonitor" );
	self.EffectsMonitor:ParentToHUD();
	
	// create popup bubble
	self.Bubble = vgui.Create( "ZingBubble" );
	self.Bubble:ParentToHUD();
	
	// create all the hud elements
	self.ChatArea = hud.CreateElement( "ChatArea" );
	self.Notifications = hud.CreateElement( "Notifications" );
	self.PointCard = hud.CreateElement( "PointCard" );
	self.StrokeIndicator = hud.CreateElement( "StrokeIndicator" );
	hud.CreateElement( "StrokeCounter" );
	self.SelectedItem = hud.CreateElement( "SelectedItem" );
	hud.CreateElement( "RadarZoom" );
	self.Radar = hud.CreateElement( "Radar" );
	
	// create help panel
	HelpPanel = vgui.Create( "Help" );
	HelpPanel:SetVisible( false );
	
	// add any queued topics
	for _, topic in pairs( HelpTopics ) do
	
		HelpPanel:CreateHelpTopic( topic[ 1 ], topic[ 2 ], topic[ 3 ], topic[ 4 ] );
	
	end
	HelpPanel:LoadComplete();
	
end


/*------------------------------------
	CreateHelpTopic()
------------------------------------*/
function GM:CreateHelpTopic( category, title, text, index )
	
	// queue
	table.insert( HelpTopics, { category, title, text, index } );
	
end


/*------------------------------------
	StartChat()
------------------------------------*/
function GM:StartChat( t )

	// pass to chat panel
	self.ChatArea:StartChat( t );
	return true;

end


/*------------------------------------
	ChatTextChanged()
------------------------------------*/
function GM:ChatTextChanged( text )

	// pass to chat panel
	self.ChatArea:ChatTextChanged( text );

end


/*------------------------------------
	FinishChat()
------------------------------------*/
function GM:FinishChat()

	// pass to chat panel
	self.ChatArea:FinishChat();

end


/*------------------------------------
	OnPlayerChat()
------------------------------------*/
function GM:OnPlayerChat( pl, text, t, dead )
	
	// pass to chat panel
	self.ChatArea:OnPlayerChat( pl, text, t, dead );
	
end


/*------------------------------------
	ChatText()
------------------------------------*/
function GM:ChatText( pid, name, text, msgtype )
	
	// ignore chat
	if ( msgtype == "chat" ) then
	
		return;
		
	end
	
	// pass to chat panel
	self.ChatArea:ChatText( pid, name, text, msgtype );
	
end


/*------------------------------------
	AddNotification()
------------------------------------*/
function GM:AddNotification( ... )

	self.Notifications:AddNotification( ... );

end


/*------------------------------------
	ItemAlert
------------------------------------*/
function GM:ItemAlert( text )

	self.SelectedItem:SetAlert( text );

end


/*------------------------------------
	GUIMouseMoved()
------------------------------------*/
function GM:GUIMouseMoved( x, y )

	// update mouse movement time
	LastMouseMove = CurTime();

end


/*------------------------------------
	AddScoreboardKills()
------------------------------------*/
function GM:AddScoreboardKills( scoreboard )

	local func = function( pl )
		
		return pl:Frags();
		
	end
	scoreboard:AddColumn( "Score", 72, func, 0.5, nil, 6, 6 );

end


/*------------------------------------
	AddScoreboardDeaths()
------------------------------------*/
function GM:AddScoreboardDeaths( scoreboard )

	local func = function( pl )
		
		return pl:Deaths();
		
	end
	scoreboard:AddColumn( "Strokes", 72, func, 0.5, nil, 6, 6 );

end


/*------------------------------------
	HUDShouldDraw()
------------------------------------*/
function GM:HUDShouldDraw( name )

	// allow them to disable the hud
	if ( GetConVarNumber( "cl_drawhud" ) < 1 ) then
	
		return false;
		
	end

	return true;

end


/*------------------------------------
	HUDPaint()
------------------------------------*/
function GM:HUDPaint()

	// get screen size
	local sw = ScrW();
	local sh = ScrH();

	// get player
	local pl = LocalPlayer();
	
	// round info
	self:HUDPaintRoundInfo( sw, sh );
	
	// update popup bubble
	self:UpdateBubble( pl );
	
	// details
	self:HUDPaintPlayerDetails();
	
	// draw custom cursor
	if ( CustomCursor ) then
	
		// check for custom cursor
		local item = inventory.Equipped();
		if ( item ) then
		
			// get mouse position
			local mx, my = gui.MousePos();
			
			// draw cursor
			surface.SetMaterial( CustomCursor );
			surface.SetDrawColor( 255, 255, 255, 255 );
			surface.DrawTexturedRectRotated( mx, my, 64, 64, 0 );
			
		else
		
			// reset it
			self:SetCursor( nil );
		
		end
		
	end
	
end


/*------------------------------------
	SetCursor()
------------------------------------*/
function GM:SetCursor( cursor )

	if ( !cursor ) then
	
		vgui.GetWorldPanel():SetCursor( "arrow" );
		CustomCursor = nil;
		
	else
	
		CustomCursor = cursor;
		vgui.GetWorldPanel():SetCursor( "blank" );
	
	end

end


/*------------------------------------
	DrawTopTip()
------------------------------------*/
local function DrawTopTip( sw, sh, text, text_color )

	// draw text
	draw.SimpleTextOutlined( text, "Zing18", sw * 0.5, 62, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black );
	
end


/*------------------------------------
	DrawTopTip()
------------------------------------*/
local function DrawTopBar( sw, sh, text, text_color )

	// draw background
	surface.SetDrawColor( 0, 0, 0, 180 );
	surface.DrawRect( 0, 0, sw, 60 );
	
	// draw text
	draw.SimpleTextOutlined( text, "Zing42", sw * 0.5, 30, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black );
	
end


/*------------------------------------
	DrawBottomBar()
------------------------------------*/
local function DrawBottomBar( sw, sh, text, text_color )

	// draw background
	surface.SetDrawColor( 0, 0, 0, 180 );
	surface.DrawRect( 0, sh - 20, sw, 20 );
	
	// draw text
	draw.SimpleTextOutlined( text, "Zing18", sw * 0.5, sh - 10, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black );
	
end


/*------------------------------------
	DrawRoundTip()
------------------------------------*/
local function DrawRoundTip( sw, sh, text, text_color )

	// measure text
	surface.SetFont( "Zing22" );
	local w, h = surface.GetTextSize( text );
	
	draw.RoundedBox( 6, ( sw * 0.5 ) - ( w * 0.5 ) - 6, 122, w + 12, h + 6, Color( 0, 0, 0, 180 ) );
	// draw text
	draw.SimpleTextOutlined( text, "Zing22", sw * 0.5, 125, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black );
	
end


/*------------------------------------
	HUDPaintRoundInfo()
------------------------------------*/
function GM:HUDPaintRoundInfo( sw, sh )
	
	// get info
	local pl = LocalPlayer();
	local t = pl:Team();
	local state = self:GetRoundState();
	
	if ( t == TEAM_SPECTATOR ) then
	
		// spectator
		DrawTopBar( sw, sh, "Spectator Mode", color_white );
		
		// helpful tip :D
		DrawBottomBar( sw, sh, "use the scorecard to select a team", color_white );
		
	end
	
	// waiting
	if ( state == ROUND_WAITING ) then
		
		if ( team.NumPlayers( TEAM_ORANGE ) == 0 || team.NumPlayers( TEAM_PURPLE ) == 0 ) then
		
			// waiting for players
			DrawRoundTip( sw, sh, "Waiting for more players", color_yellow );
		
		else
		
			// ready to being
			local waiting = math.floor( self:GetGameTimeLeft() - ( self.GameLength * 60 ) );
			DrawRoundTip( sw, sh, "Ready to begin in " .. waiting, color_yellow );
			
		end
		
		// show what team theyre on
		if ( t != TEAM_SPECTATOR ) then
		
			// show current team name
			DrawTopBar( sw, sh, team.GetName( t ), team.GetColor( t ) );
		
		end
		
	// active game
	elseif ( state == ROUND_ACTIVE ) then
	
		if ( t == TEAM_SPECTATOR ) then
		
			DrawRoundTip( sw, sh, "Game in progress", color_yellow );
			DrawTopTip( sw, sh, "select a team to join the game", color_white );
		
		end
		
	// intermission
	elseif ( state == ROUND_INTERMISSION ) then
	
		// waiting for players
		DrawRoundTip( sw, sh, "Intermission", color_yellow );
	
	end

end


/*------------------------------------
	HUDPaintPlayerDetails()
------------------------------------*/
function GM:HUDPaintPlayerDetails()
	
	// iterate all players
	for _, pl in pairs( player.GetAll() ) do
		
		// validate ball
		local ball = pl:GetBall();
		if ( IsBall( ball ) && !ball:GetNinja() ) then
		
			// get 2D information
			local center, size = ball:GetPos2D();
			
			// show names
			if ( input.IsKeyDown( KEY_LALT ) ) then
			
				draw.SimpleTextOutlined( pl:Name(), "Zing18", center.x, center.y - size, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black );
			
			end
		
		end
	
	end

end


/*------------------------------------
	HUDPaintTips()
------------------------------------*/
function GM:HUDPaintTips( sw, sh )
end


/*------------------------------------
	UpdateBubble()
------------------------------------*/
function GM:UpdateBubble( pl )

	// run bubble
	self.Bubble:Think();
	
	// disable in vgui
	if ( !vgui.IsHoveringWorld() ) then
	
		return;
	
	// disable when in gestures
	elseif ( controls.InHitGesture() || controls.InViewGesture() ) then
	
		return;
		
	end
	
	// run trace
	pl:SetFOV( 80 );
	local tr = util.TraceLine( {
		start = EyePos(),
		endpos = EyePos() + pl:GetCursorAimVector() * ( 1024 * 3 ),
		
	} );
	
	// moved too recently
	// (this prevents bubble spam)
	if ( CurTime() - LastMouseMove < 0.3 ) then
	
		return;
	
	end
	
	// measuring
	if ( tr.HitWorld && input.IsKeyDown( KEY_LALT ) ) then
	
		// validate ball
		local ball = pl:GetCamera();
		if ( IsBall( ball ) ) then
		
			// check for out of bounds
			if ( IsOOB( tr ) ) then
				
				// nope!
				self.Bubble:Show( "Out of Bounds!" );
			
			else
			
				// get ball position
				local pos = ball:GetPos() - Vector( 0, 0, ball.Size );
				
				// measure to trace
				local distance = ( tr.HitPos - pos ):Length() * DISTANCE_SCALE;
				
				// calculate height and make it human readable
				local height = math.floor( ( tr.HitPos.z - pos.z ) * DISTANCE_SCALE );
				if ( height > 0 ) then
				
					height = "up";
					
				elseif ( height == 0 ) then
				
					height = "level";
					
				else
				
					height = "down";
				
				end
				
				// use measure information
				self.Bubble:Show( util.InchesToFeet( math.floor( distance ) ) .. " [" .. height .. "]" );
				
			end
			
		end
	
	// entity target
	elseif ( ValidEntity( tr.Entity ) ) then
	
		// get entity
		local ent = tr.Entity;
		
		// handle balls (lol)
		if ( IsBall( ent ) ) then
		
			// use owner
			ent = ent:GetOwner();
			
			// validate player
			if ( IsValid( ent ) && ent:IsPlayer() ) then
				
				// use player information
				self.Bubble:Show( ( ent == pl ) && "YOU!" || ent:Name(), ent );
				
			end
			
		elseif ( ent.PrintName != nil && ent.PrintName != "" ) then
		
			// let the entity decide
			self.Bubble:Show( ent:GetTipText() );
		
		end
		
	end
	
end


/*------------------------------------
	ScoreboardShow()
------------------------------------*/
function GM:ScoreboardShow()

	// make sure clicker is visible
	gui.EnableScreenClicker( true );

	// create scorecard
	if ( !Scoreboard ) then
	
		Scoreboard = vgui.Create( "Scorecard" );
		
	end
	
	// make visible
	Scoreboard.CurrentTeam = LocalPlayer():Team();
	Scoreboard:SetVisible( true );
	
end


/*------------------------------------
	ScoreboardHide()
------------------------------------*/
function GM:ScoreboardHide()

	// hide clicker
	gui.EnableScreenClicker( false );
	
	// hide scorecard
	Scoreboard:SetVisible( false );
	
end


/*------------------------------------
	IsScoreboardOpen
------------------------------------*/
function GM:IsScoreboardOpen()

	// validate
	if ( Scoreboard ) then
	
		// use visible flag
		return Scoreboard:IsVisible();
		
	end
	
	return false;

end


/*------------------------------------
	OnSpawnMenuOpen()
------------------------------------*/
function GM:OnSpawnMenuOpen()

	inventory.Show();

end


/*------------------------------------
	OnSpawnMenuClose()
------------------------------------*/
function GM:OnSpawnMenuClose()

	inventory.Hide();

end


/*------------------------------------
	ShowHelpPanel()
------------------------------------*/
local function ShowHelpPanel()

	// show panel if its not already up
	if ( !HelpPanel:IsVisible() ) then
	
		HelpPanel:SetVisible( true );
		HelpPanel:MakePopup();
		
	end

end


/*------------------------------------
	ShowHelp()
------------------------------------*/
local function ShowHelp( pl, cmd, args )
	
	ShowHelpPanel();
	
	// check if this is the first time they've opened the help
	if ( !FirstHelp ) then
	
		// show introduction topic
		HelpPanel:ShowTopic( "Basics:Introduction" );
		FirstHelp = true;
		
	end

end
concommand.Add( "zingerhelp", ShowHelp );


/*------------------------------------
	ShowTopic
------------------------------------*/
function GM:ShowTopic( key )
		
	ShowHelpPanel();
	
	// show topic
	HelpPanel:ShowTopic( key );

end


/*------------------------------------
	ButtonSoundDefault()
------------------------------------*/
function ButtonSoundDefault()

	SND( ("zinger/ballbounce%d.mp3"):format( math.random( 1, 4 ) ) );

end


/*------------------------------------
	ButtonSoundCancel()
------------------------------------*/
function ButtonSoundCancel()

	SND( "zinger/ballcollide.mp3" );

end


/*------------------------------------
	ButtonSoundOkay()
------------------------------------*/
function ButtonSoundOkay()

	SND( "zinger/putt1.mp3" );

end
