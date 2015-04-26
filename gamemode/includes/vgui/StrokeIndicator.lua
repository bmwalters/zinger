local PANEL = {}

local Background = Material("zinger/hud/elements/strokeindicator")

function PANEL:Init()
	self.BaseClass.Init(self)

	self:SetSize(128, 256)

	self.DefaultX = 0
	self.DefaultY = ScrH() - 256
	self.ElementTitle = "Stroke Indicator"
	self.Flag = ELEM_FLAG_HASBALL

	self.WasReady = false
	self.TeeTime = 0

	self:InitDone()
end

function PANEL:SetTeeTime(state)
	if state == 0 then
		self.TeeTime = 0
	elseif state == 1 then
		self.TeeTime = CurTime() + TEE_TIME
	end
end

function PANEL:Think()
end

function PANEL:DrawTeeTime()
	-- blink
	if math.sin(CurTime() * 12) < 0 then return end

	DisableClipping(true)

	-- draw in center of screen
	local x, y = self:ScreenToLocal(ScrW() * 0.5, ScrH() * 0.5)
	draw.SimpleTextOutlined("HIT YOUR BALL!", "Zing52", x, y, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)

	DisableClipping(false)
end

function PANEL:DrawNotification(text, color)
	draw.SimpleTextOutlined(text, "Zing30", self.MidWidth, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
end

function PANEL:Paint()
	if not self:ShouldPaint() then
		self.WasReady = false
		self:SetTeeTime(0)
		return
	end

	if self.TeeTime ~= 0 then
		if self.TeeTime - CurTime() < TEE_TIME * 0.4 then
			self:DrawTeeTime()
		end
	end

	local ply = LocalPlayer()

	if controls.GetPower() > 0 then
		local frac = controls.GetPower() / 100

		-- pulsating red
		local r = 225 + (math.sin(CurTime() * 10) * 30)
		surface.SetDrawColor(r, color_red.g, color_red.b, 200)

		surface.DrawRect(17, 27 + (204 - (204 * frac)), 90, 204 * frac)
	end

	-- draw material
	surface.SetMaterial(Background)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, self.Width, self.Height)

	-- hit indicator
	if HasBall(LocalPlayer()) and ply:CanHit() then
		if controls.GetPower() > 0 then
			self:DrawNotification(controls.GetPower() .. "%", color_red)
		else
			if math.sin(CurTime() * 8) > 0 then
				self:DrawNotification("GO!", color_green)
			end
		end

		-- sound!
		if not self.WasReady then
			surface.PlaySound(Sound("zinger/readyturn.mp3"))
			self.WasReady = true
		end
	else
		-- waiting notification
		self:DrawNotification("WAIT", color_yellow)
		self.WasReady = false
		self:SetTeeTime(0)
	end

	-- must call
	self.BaseClass.Paint(self)
end

derma.DefineControl("StrokeIndicator", "", PANEL, "BaseElement")
