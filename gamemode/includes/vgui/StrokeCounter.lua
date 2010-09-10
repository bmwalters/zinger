
// object
local PANEL = {};

// textures
local Background = Material( "zinger/hud/elements/strokecounter" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self.BaseClass.Init( self );

	self:SetSize( 80, 80 );
	
	self.DefaultX = 100;
	self.DefaultY = ScrH() - 100;
	self.ElementTitle = "Stroke Counter";
	self.Flag = ELEM_FLAG_HASBALL;
	
	self:InitDone();

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	if ( !self:ShouldPaint() ) then
	
		return;
		
	end
	
	// get player
	local pl = LocalPlayer();
	
	// draw material
	surface.SetMaterial( Background );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, 128, 128 );
	
	draw.SimpleTextOutlined( pl:GetStrokes(), "Zing42", self.MidWidth, self.MidHeight - 6, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black );
	DisableClipping( false );
	
	// must call
	self.BaseClass.Paint( self );

end

// register
derma.DefineControl( "StrokeCounter", "", PANEL, "BaseElement" );
