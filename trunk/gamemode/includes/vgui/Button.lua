
// object
local PANEL = {};

// accessors
AccessorFunc( PANEL, "Text", "Text", FORCE_STRING );

/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// base class
	self.BaseClass.Init( self );
	
	// background
	self:SetMaterial( "zinger/hud/button" );
	
	// automatic size
	self:SizeToContents();
	
	// default text
	self:SetText( "button" );
	
end


/*------------------------------------
	PaintOver()
------------------------------------*/
function PANEL:PaintOver()

	// draw shadow
	draw.SimpleText( self:GetText(), "Zing30", ( self:GetWide() * 0.5 ) + 1, ( self:GetTall() * 0.5 ) - 3, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
	
	// draw text
	draw.SimpleText( self:GetText(), "Zing30", self:GetWide() * 0.5, ( self:GetTall() * 0.5 ) - 4, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
	
end

// register
derma.DefineControl( "Button", "", PANEL, "DImageButton" );
