
local surface = surface
local draw = draw
local Color = Color

local SKIN = {}

SKIN.PrintName 		= ""
SKIN.Author 		= ""
SKIN.DermaVersion	= 1

/*---------------------------------------------------------
	ScrollBar
---------------------------------------------------------*/
function SKIN:PaintVScrollBar( panel )

	draw.RoundedBox( 2, 0, 0, panel:GetWide(), panel:GetTall(), color_black );
	draw.RoundedBox( 2, 2, 2, panel:GetWide() - 4, panel:GetTall() - 4, color_yellow_dark );

end

function SKIN:LayoutVScrollBar( panel )

	local Wide = panel:GetWide()
	local Scroll = panel:GetScroll() / panel.CanvasSize
	local BarSize = math.max( panel:BarScale() * (panel:GetTall() - (Wide * 2)), 10 )
	local Track = panel:GetTall() - (Wide * 2) - BarSize
	Track = Track + 1
	
	Scroll = Scroll * Track
	
	panel.btnGrip:SetPos( 0, Wide + Scroll )
	panel.btnGrip:SetSize( Wide, BarSize )
	
	panel.btnUp:SetPos( 0, 0, Wide, Wide )
	panel.btnUp:SetSize( Wide, Wide )
	panel.btnUp:SetVisible( false );
	
	panel.btnDown:SetPos( 0, panel:GetTall() - Wide, Wide, Wide )
	panel.btnDown:SetSize( Wide, Wide )
	panel.btnDown:SetVisible( false );

end

/*---------------------------------------------------------
	ScrollBarGrip
---------------------------------------------------------*/
function SKIN:PaintScrollBarGrip( panel )

	draw.RoundedBox( 2, 0, 0, panel:GetWide(), panel:GetTall(), color_black );
	draw.RoundedBox( 2, 2, 2, panel:GetWide() - 4, panel:GetTall() - 4, color_yellow );

end

derma.DefineSkin( "zinger", "", SKIN );
