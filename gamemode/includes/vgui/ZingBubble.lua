local PANEL = {}

local BubbleSide = surface.GetTextureID("zinger/hud/bubbleside")
local BubbleTail = surface.GetTextureID("zinger/hud/bubbletail")

function PANEL:Init()
	self:SetSize(200, 90)

	self:SetMouseInputEnabled(false)

	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:SetVisible(false)
	self.Avatar:SetPos(32, 13)
	self.Avatar:SetSize(32, 32)

	self.LastShow = 0
	self.Alpha = 255
	self.LastText = ""
	self.LastImg = nil
end

function PANEL:ApplySchemeSettings()
end

function PANEL:Show(text, img)
	-- update time
	self.LastShow = CurTime()

	if img then
		if type(img) == "Player" then
			-- use avatar image
			self.Avatar:SetPlayer(img)
			self.Avatar:SetVisible(true)
		end
	else
		-- hide avatar
		self.Avatar:SetVisible(false)
	end

	-- check for new text
	if #text ~= #self.LastText or img ~= self.LastImg then
		-- measure
		surface.SetFont("Zing22")
		local w, h = surface.GetTextSize(text)

		-- update size
		self:SetSize(math.max(w + 60, 110), 90)

		-- check for avatar
		if self.Avatar:IsVisible() then
			-- increase size
			self:SetSize(self:GetWide() + self.Avatar:GetWide() + 8, 90)
		end
	end

	-- store
	self.LastText = text
	self.LastImg = img
end

function PANEL:Update(w, h)
	if not (w and h) then w, h = self:GetSize() end
	local mx, my = gui.MousePos()
	self:SetPos(mx - (w * 0.5), my - h + 14)

	-- update alpha
	self.Alpha = math.Approach(self.Alpha, (CurTime() - self.LastShow < 0.1) and 255 or 0, FrameTime() * 700)
end

function PANEL:Think()
	self:Update()
end

function PANEL:Paint(w, h)
	self:Update(w, h)

	-- shrink height because we're going to add a tail
	h = h - 30

	-- draw left side
	surface.SetDrawColor(0, 0, 0, self.Alpha)
	surface.SetTexture(BubbleSide)
	surface.DrawTexturedRectRotated(15, h * 0.5, 30, h, 0)
	surface.DrawTexturedRectRotated(w - 15, h * 0.5, 30, h, 180)
	surface.DrawRect(30, 0, w - 60, h)

	-- draw center
	surface.SetTexture(BubbleTail)
	surface.DrawTexturedRect((w * 0.5) - 15, h, 30, 30)

	-- draw right side
	surface.SetDrawColor(255, 255, 255, self.Alpha)
	surface.SetTexture(BubbleSide)
	surface.DrawTexturedRectRotated(17, h * 0.5, 28, h - 6, 0)
	surface.DrawTexturedRectRotated(w - 17, h * 0.5, 28, h - 6, 180)
	surface.DrawRect(31, 3, w - 62, h - 6)

	-- draw tail
	surface.SetTexture(BubbleTail)
	surface.DrawTexturedRect((w * 0.5) - 13, h - 3, 26, 28)

	-- get center position
	local x = w * 0.5

	if self.Avatar:IsVisible() then
		-- move center over
		x = x + (self.Avatar:GetWide() * 0.5) + 6
		draw.RoundedBox(4, self.Avatar.X - 2, self.Avatar.Y - 2, self.Avatar:GetWide() + 4, self.Avatar:GetTall() + 4, Color(0, 0, 0, self.Alpha))
	end

	self.Avatar:SetAlpha(self.Alpha)

	-- draw text
	draw.SimpleText(self.LastText, "Zing22", x, h * 0.5, Color(0, 0, 0, self.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

derma.DefineControl("ZingBubble", "", PANEL, "DPanel")
