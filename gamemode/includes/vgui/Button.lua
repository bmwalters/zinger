local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()
	self.BaseClass.Init(self)

	-- background
	self:SetMaterial("zinger/hud/button")

	-- automatic size
	self:SizeToContents()

	-- default text
	self:SetText("button")
end

function PANEL:PaintOver(w, h)
	-- draw shadow
	draw.SimpleText(self:GetText(), "Zing30", (w * 0.5) + 1, (h * 0.5) - 3, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	-- draw text
	draw.SimpleText(self:GetText(), "Zing30", w * 0.5, (h * 0.5) - 4, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

derma.DefineControl("Button", "", PANEL, "DImageButton")
