local PANEL = {}

local Background = Material("zinger/hud/elements/strokecounter")

function PANEL:Init()
	self.BaseClass.Init(self)

	self:SetSize(80, 80)

	self.DefaultX = 100
	self.DefaultY = ScrH() - 100
	self.ElementTitle = "Stroke Counter"
	self.Flag = ELEM_FLAG_HASBALL

	self:InitDone()
end

function PANEL:Think()
end

function PANEL:Paint()
	if not self:ShouldPaint() then return end

	local ply = LocalPlayer()

	-- draw material
	surface.SetMaterial(Background)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, 128, 128)

	draw.SimpleTextOutlined(ply:GetStrokes(), "Zing42", self.MidWidth, self.MidHeight - 6, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
	DisableClipping(false)

	-- must call
	self.BaseClass.Paint(self)
end

derma.DefineControl("StrokeCounter", "", PANEL, "BaseElement")
