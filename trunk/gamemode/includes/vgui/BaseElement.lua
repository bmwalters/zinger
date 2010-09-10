
// object
local PANEL = {};

// colors
local overlay_color = Color( 255, 255, 255, 30 );
local overlay_color_selected = Color( 255, 255, 100, 30 );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()
	
	// visibility flags
	//   ELEM_FLAG_ALWAYS		- always visible
	//   ELEM_FLAG_SPECTATORS	- spectators only
	//   ELEM_FLAG_PLAYERS		- players only
	//   ELEM_FLAG_HASBALL		- players with a ball
	self.Flag = ELEM_FLAG_ALWAYS;
	
	// defaults
	self.XOffset = 0;
	self.YOffset = 0;
	self.ElementTitle = "Element";
	
end


/*------------------------------------
	InitDone()
------------------------------------*/
function PANEL:InitDone()

	// move to default position
	self:SetPos( self.DefaultX, self.DefaultY );
	
	// always disable mouse so it doesn't block other interactions
	self:SetMouseInputEnabled( false );

end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()
	
	self.Width, self.Height = self:GetSize();
	self.MidWidth = self.Width * 0.5;
	self.MidHeight = self.Height * 0.5;

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	OnMousePressed()
------------------------------------*/
function PANEL:OnMousePressed( mc )

	if ( mc == MOUSE_RIGHT ) then
	
		return;
		
	end

	if ( !hud.EditMode() ) then
	
		return;
		
	end
	
	local mx, my = gui.MousePos();
	self.XOffset = mx - self.X;
	self.YOffset = my - self.Y;
	
	hud.Select( self );

end


/*------------------------------------
	OnMouseReleased()
------------------------------------*/
function PANEL:OnMouseReleased( mc )

	if ( mc == MOUSE_RIGHT ) then
	
		return;
		
	end
	
	if ( !hud.EditMode() ) then
	
		return;
		
	end
	
	hud.Select( nil );

end


/*------------------------------------
	ShouldPaint()
------------------------------------*/
function PANEL:ShouldPaint()

	if ( hud.EditMode() ) then
	
		return true;
		
	elseif ( self.Flag == ELEM_FLAG_ALWAYS ) then
	
		return true;
		
	elseif ( self.Flag == ELEM_FLAG_SPECTATORS ) then
	
		return ( LocalPlayer():Team() == TEAM_SPECTATOR );
		
	elseif ( self.Flag == ELEM_FLAG_PLAYERS ) then
		
		return ( LocalPlayer():Team() != TEAM_SPECTATOR );
		
	elseif ( self.Flag == ELEM_FLAG_HASBALL ) then
	
		return ( LPHasBall() );
		
	elseif ( self.Flag == ELEM_FLAG_ITEMEQUIPPED ) then
	
		return ( GAMEMODE:GetRoundState() == ROUND_ACTIVE && LPHasBall() && inventory.Equipped() != nil );
		
	end
	
	return false;

end


/*------------------------------------
	EditChanged()
------------------------------------*/
function PANEL:EditChanged( bool )
end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	if ( !hud.EditMode() ) then
	
		return;
		
	end
	
	// drag
	if ( hud.GetSelected() == self ) then
	
		// update position
		local mx, my = gui.MousePos();
		self:SetPos( math.Clamp( mx - self.XOffset, 0, ScrW() - self.Width ), math.Clamp( my - self.YOffset, 0, ScrH() - self.Height ) );
	
	end
	
	// draw overlay
	surface.SetDrawColor( ( hud.GetSelected() == self ) && overlay_color_selected || overlay_color );
	surface.DrawRect( 0, 0, self.Width, self.Height );
	
	// tips
	draw.SimpleText( self.ElementTitle, "Zing14", self.MidWidth + 1, 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP );
	draw.SimpleText( self.ElementTitle, "Zing14", self.MidWidth, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP );
	draw.SimpleText( self.X .. "," .. self.Y, "Zing14", self.MidWidth + 1, self.MidHeight + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
	draw.SimpleText( self.X .. "," .. self.Y, "Zing14", self.MidWidth, self.MidHeight, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
	
end

// register
derma.DefineControl( "BaseElement", "", PANEL, "DPanel" );
