
// object
local PANEL = {};

// textures
local BubbleSide = surface.GetTextureID( "zinger/hud/bubbleside" );
local BubbleTail = surface.GetTextureID( "zinger/hud/bubbletail" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// default size
	self:SetSize( 200, 90 );
	
	// disable mouse
	self:SetMouseInputEnabled( false );
	
	// create avatar
	self.Avatar = vgui.Create( "AvatarImage", self );
	self.Avatar:SetVisible( false );
	self.Avatar:SetPos( 32, 13 );
	self.Avatar:SetSize( 32, 32 );
	
	// defaults
	self.LastShow = 0;
	self.Alpha = 255;
	self.LastText = "";
	self.LastImg = nil;
	
end


/*------------------------------------
	ApplySchemeSettings()
------------------------------------*/
function PANEL:ApplySchemeSettings()

end


/*------------------------------------
	Show()
------------------------------------*/
function PANEL:Show( text, img )

	// update time
	self.LastShow = CurTime();
	
	// check for image
	if ( img != nil ) then
	
		// check for player
		if ( type( img ) == "Player" ) then
		
			// use avatar image
			self.Avatar:SetPlayer( img );
			self.Avatar:SetVisible( true );
		
		end
		
	else
	
		// hide avatar
		self.Avatar:SetVisible( false );
	
	end
	
	// check for new text
	if ( #text != #self.LastText || img != self.LastImg ) then
	
		// measure
		surface.SetFont( "Zing22" );
		local w, h = surface.GetTextSize( text );
		
		// update size
		self:SetSize( math.max( w + 60, 110 ), 90 );
		
		// check for avatar
		if ( self.Avatar:IsVisible() ) then
		
			// increase size
			self:SetSize( self:GetWide() + self.Avatar:GetWide() + 8, 90 );
			
		end
		
	end
	
	// store
	self.LastText = text;
	self.LastImg = img;

end


/*------------------------------------
	Update()
------------------------------------*/
function PANEL:Update()

	// get size
	local w, h = self:GetSize();
	
	// get mouse positions
	local mx, my = gui.MousePos();
	self:SetPos( mx - ( w * 0.5 ), my - h + 14 );
	
	// update alpha
	self.Alpha = math.Approach( self.Alpha, ( CurTime() - self.LastShow < 0.1 ) && 255 || 0, FrameTime() * 700 );

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()

	self:Update();
	
end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()
	
	// get size
	local w, h = self:GetSize();
	
	// update
	self:Update();
	
	// shrink height because we're going to add a tail
	h = h - 30;
	
	// draw left side
	surface.SetDrawColor( 0, 0, 0, self.Alpha );
	surface.SetTexture( BubbleSide );
	surface.DrawTexturedRectRotated( 15, h * 0.5, 30, h, 0 );
	surface.DrawTexturedRectRotated( w - 15, h * 0.5, 30, h, 180 );
	surface.DrawRect( 30, 0, w - 60, h );
	
	// draw center
	surface.SetTexture( BubbleTail );
	surface.DrawTexturedRect( ( w * 0.5 ) - 15, h, 30, 30 );
	
	// draw right side
	surface.SetDrawColor( 255, 255, 255, self.Alpha );
	surface.SetTexture( BubbleSide );
	surface.DrawTexturedRectRotated( 17, h * 0.5, 28, h - 6, 0 );
	surface.DrawTexturedRectRotated( w - 17, h * 0.5, 28, h - 6, 180 );
	surface.DrawRect( 31, 3, w - 62, h - 6 );
	
	// draw tail
	surface.SetTexture( BubbleTail );
	surface.DrawTexturedRect( ( w * 0.5 ) - 13, h - 3, 26, 28 );
	
	// get center position
	local x = w * 0.5;
	
	// check for avatar
	if ( self.Avatar:IsVisible() ) then
	
		// move center over
		x = x + ( self.Avatar:GetWide() * 0.5 ) + 6;
		draw.RoundedBox( 4, self.Avatar.X - 2, self.Avatar.Y - 2, self.Avatar:GetWide() + 4, self.Avatar:GetTall() + 4, Color( 0, 0, 0, self.Alpha ) );
	
	end
	
	// update avatar transparency
	self.Avatar:SetAlpha( self.Alpha );
	
	// draw text
	draw.SimpleText( self.LastText, "Zing22", x, h * 0.5, Color( 0, 0, 0, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
	
end

// register
derma.DefineControl( "ZingBubble", "", PANEL, "DPanel" );
