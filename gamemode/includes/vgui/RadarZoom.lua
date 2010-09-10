
// object
local PANEL = {};

// textures
local Background = Material( "zinger/hud/elements/radarzoom" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self.BaseClass.Init( self );

	self:SetSize( 56, 56 );
	
	self.DefaultX = 10;
	self.DefaultY = 10;
	self.ElementTitle = "Radar Zoom";
	self.Flag = ELEM_FLAG_PLAYERS;
	
	self:InitDone();
	
	self:SetMouseInputEnabled( true );

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	OnMouseReleased()
------------------------------------*/
function PANEL:OnMouseReleased( mc )

	ButtonSoundDefault();
	GAMEMODE.Radar:ToggleZoom();
	
end


/*------------------------------------
	EditChanged()
------------------------------------*/
function PANEL:EditChanged( bool )

	self:SetMouseInputEnabled( true );

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	if ( !self:ShouldPaint() ) then
	
		return;
		
	end
	
	// get ball
	local valid, ball = LPHasBall();
	if( !valid ) then
	
		return;
		
	end
	
	// draw material
	surface.SetMaterial( Background );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, 64, 64 );
	
	draw.SimpleTextOutlined( ( GAMEMODE.Radar.ZoomScale == 1 ) && "-" || "+", "Zing42", 25, 23, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black );
	
	// must call
	self.BaseClass.Paint( self );

end

// register
derma.DefineControl( "RadarZoom", "", PANEL, "BaseElement" );
