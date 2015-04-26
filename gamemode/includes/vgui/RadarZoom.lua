local PANEL = {}

local Background = Material("zinger/hud/elements/radarzoom")

function PANEL:Init()
	self.BaseClass.Init(self)

	self:SetSize(56, 56)

	self.DefaultX = 10
	self.DefaultY = 10
	self.ElementTitle = "Radar Zoom"
	self.Flag = ELEM_FLAG_PLAYERS

	self:InitDone()

	self:SetMouseInputEnabled(true)
end

function PANEL:Think()
end

function PANEL:OnMouseReleased(mc)
	ButtonSoundDefault()
	GAMEMODE.Radar:ToggleZoom()
end

function PANEL:EditChanged(bool)
	self:SetMouseInputEnabled(true)
end

function PANEL:Paint(w, h)
	if not self:ShouldPaint() then return end

	-- get ball
	local valid, ball = HasBall(LocalPlayer())
	if not valid then return end

	-- draw material
	surface.SetMaterial(Background)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, 64, 64)

	draw.SimpleTextOutlined((GAMEMODE.Radar.ZoomScale == 1) and "-" or "+", "Zing42", 25, 23, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)

	-- must call
	self.BaseClass.Paint(self, w, h)
end

derma.DefineControl("RadarZoom", "", PANEL, "BaseElement")
