
// object
local PANEL = {};

// colors
local background_color = Color( 0, 0, 0, 80 );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// should always be first
	self.BaseClass.Init( self );
	
	// position and size
	self:SetSize( 500, 160 );
	self.ElementTitle = "Chat Area";
	self.DefaultX = ( ScrW() * 0.5 ) - ( self:GetWide() * 0.5 );
	self.DefaultY = ScrH() - self:GetTall() - 30;
	
	// chat prompt
	self.Prompt = vgui.Create( "DLabel", self );
	self.Prompt:SetSize( 50, 20 );
	self.Prompt:AlignBottom();
	self.Prompt:AlignLeft();
	self.Prompt:SetVisible( false );
	self.Prompt:SetFont( "ZingChat" );
	self.Prompt:SetTextColor( color_white );
	self.Prompt:SetContentAlignment( 1 );
	self.Prompt:SetExpensiveShadow( 1, color_black );
	
	// chat input
	self.TextInput = vgui.Create( "DLabel", self );
	self.TextInput:SetSize( 500, 20 );
	self.TextInput:AlignBottom();
	self.TextInput:AlignLeft();
	self.TextInput:SetVisible( false );
	self.TextInput:SetFont( "ZingChat" );
	self.TextInput:SetTextColor( color_white );
	self.TextInput:SetText( " " );
	self.TextInput:SetWrap( true );
	self.TextInput:SetAutoStretchVertical( true );
	self.TextInput:SetContentAlignment( 1 );
	self.TextInput:SetExpensiveShadow( 1, color_black );
	
	// chat history
	self.History = vgui.Create( "DPanelList", self );
	self.History:SetSize( 500, 120 );
	self.History:SetBottomUp( true );
	self.History:SetDrawBackground( false );
	
	// defaults
	self.LastUpdate = 0;
	self:SetAlpha( 255 );
	self.CurrentAlpha = 255;
	
	self:InitDone();
	
	self:InvalidateLayout();

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()

	self.BaseClass.Think( self );

end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()
	
	self.BaseClass.PerformLayout( self );

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()
	
	// draw overlay
	if ( self.Prompt:IsVisible() ) then
	
		// full alpha
		self.CurrentAlpha = 255;
		self:SetAlpha( 255 );
		
		self.TextInput:AlignBottom();
		local x, y = self.TextInput:GetPos();
		self.Prompt:SetPos( 0, y );
	
		// draw background
		surface.SetDrawColor( background_color );
		surface.DrawRect( 0, 0, self.Width, self.Height )
		surface.DrawRect( 0, y, self.Width, self.TextInput:GetTall() );
		
	// fade out after delay
	elseif ( CurTime() - self.LastUpdate > 7 && !hud.EditMode() ) then
	
		self.CurrentAlpha = math.Approach( self.CurrentAlpha, 1, FrameTime() * 200 );
		self:SetAlpha( self.CurrentAlpha );
		
	else
	
		self.CurrentAlpha = 255;
		self:SetAlpha( 255 );
		
	end
	
	// must call
	self.BaseClass.Paint( self );

end


/*------------------------------------
	StartChat()
------------------------------------*/
function PANEL:StartChat( t )

	// change prompt text
	self.Prompt:SetText( ( t ) && "(TEAM) : " || "(ALL) : " );
	self.Prompt:SizeToContents();
	
	// clear and position input
	self.TextInput:SetText( "" );
	self.TextInput:SizeToContents();
	self.TextInput:MoveRightOf( self.Prompt );
	self.TextInput:SetWide( self:GetWide() - self.Prompt:GetWide() );
	
	// make visible
	self.Prompt:SetVisible( true );
	self.TextInput:SetVisible( true );
	
	self:InvalidateLayout();
	
end


/*------------------------------------
	ChatTextChanged()
------------------------------------*/
function PANEL:ChatTextChanged( text )

	// update input
	self.TextInput:SetText( text );
	self:InvalidateLayout();
	
end


/*------------------------------------
	FinishChat()
------------------------------------*/
function PANEL:FinishChat()

	// hide everything
	self.TextInput:SetText( " " );
	self.Prompt:SetVisible( false );
	self.TextInput:SetVisible( false );
	self:InvalidateLayout();
	
end


/*------------------------------------
	OnPlayerChat()
------------------------------------*/
function PANEL:OnPlayerChat( pl, text, t, dead )

	// update time
	self.LastUpdate = CurTime();
	
	// create entry
	local v = vgui.Create( "ChatAreaPlayerLine", self.History );
	v:SetPos( 0, -100 );
	v:Create( pl, text );
	
	// add after 1 frame
	timer.Simple( FrameTime() + 0.001, function()
		self.History:AddItem( v );
	end );
	
end


/*------------------------------------
	ChatText()
------------------------------------*/
function PANEL:ChatText( pid, name, text, msgtype )

	// update time
	self.LastUpdate = CurTime();
	
	// create entry
	local l = vgui.Create( "DLabel", self );
	l:SetSize( 500, 20 );
	l:SetFont( "ZingChat" );
	l:SetTextColor( color_yellow );
	l:SetText( text );
	l:SetWrap( true );
	l:SetAutoStretchVertical( true );
	l:SetContentAlignment( 1 );
	l:SetExpensiveShadow( 1, color_black );
	l:SetPos( 0, -100 );
	
	// add after 1 frame
	timer.Simple( FrameTime() + 0.001, function()
		self.History:AddItem( l );
	end );
	
end


// register
derma.DefineControl( "ChatArea", "", PANEL, "BaseElement" );


PANEL = {};


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// setup
	self:SetWide( self:GetParent():GetWide() );
	self:SetPaintBackground( false );
	
	// player name
	self.NameLabel = vgui.Create( "DLabel", self );
	self.NameLabel:SetFont( "ZingChat" );
	self.NameLabel:AlignTop();
	self.NameLabel:SetContentAlignment( 7 );
	self.NameLabel:SetExpensiveShadow( 1, color_black );
	
	// chat
	self.TextLabel = vgui.Create( "DLabel", self );
	self.TextLabel:SetContentAlignment( 7 );
	self.TextLabel:SetFont( "ZingChat" );
	self.TextLabel:AlignTop();
	self.TextLabel:SetWrap( true );
	self.TextLabel:SetAutoStretchVertical( true );
	self.TextLabel:SetExpensiveShadow( 1, color_black );
	
end


/*------------------------------------
	ApplySchemeSettings()
------------------------------------*/
function PANEL:ApplySchemeSettings()

	// change fonts
	self.NameLabel:SetFont( "ZingChat" );
	self.TextLabel:SetFont( "ZingChat" );
	self.TextLabel:SetTextColor( color_white );
	
end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()

	self:SetTall( self.TextLabel:GetTall() );

end


/*------------------------------------
	Create()
------------------------------------*/
function PANEL:Create( pl, text )
	
	self:SetWide( self:GetParent():GetWide() );

	self.NameLabel:SetText( pl:Name() .. ": " );
	self.NameLabel:SetTextColor( team.GetColor( pl:Team() ) );
	self.NameLabel:SizeToContents();
	
	self.TextLabel:SetText( text );
	self.TextLabel:SetSize( self:GetWide() - self.NameLabel:GetWide(), 20 );
	self.TextLabel:MoveRightOf( self.NameLabel );
	
	self:InvalidateLayout();
	
end

// register
derma.DefineControl( "ChatAreaPlayerLine", "", PANEL, "DPanel" );
