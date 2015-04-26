local PANEL = {}

-- local Default = Material("zinger/hud/items/default")

function PANEL:Init()
	self:SetSize(256, 256)
	self:AlignTop(190)
	self:AlignLeft(-255)

	self:SetMouseInputEnabled(false)

	self.Monitors = {}
end

function PANEL:PerformLayout()
end

function PANEL:ApplySchemeSettings()
end

function PANEL:ClearAllEffects()
	if self.Monitors then
		for i = #self.Monitors, 1, -1 do
			self.Monitors[i]:Remove()
		end
		self.Monitors = {}
	end
end

function PANEL:ClearAllEffects()
	if self.Monitors then
		for i = #self.Monitors, 1, -1 do
			self.Monitors[i]:Remove()
		end
		self.Monitors = {}
	end
end

function PANEL:ClearEffect(key)
	if self.Monitors then
		for i = #self.Monitors, 1, -1 do
			if self.Monitors[i].Item.Key == key then

				self.Monitors[i]:Remove()
				table.remove(self.Monitors, i)
			end
		end
	end
end

function PANEL:Think()
	for i = #self.Monitors, 1, -1 do
		-- check if dead
		if not self.Monitors[i]:Alive() then
			-- kill and remove
			self.Monitors[i]:Remove()
			table.remove(self.Monitors, i)
		end
	end

	-- starting Y position
	local y = 20

	for i = 1, #self.Monitors do
		-- update target Y position
		self.Monitors[i].TargetY = y
		y = y + 32
	end
end

function PANEL:AddMonitor(item, duration)
	local monitor = vgui.Create("ZingEffectsMonitorLine", self)
	monitor:SetItem(item, duration)

	self.Monitors[#self.Monitors + 1] = monitor
end

function PANEL:Paint()
	local ply = LocalPlayer()
	if not ply.Team or ply:Team() == TEAM_SPECTATOR then
		return
	elseif not IsBall(ply:GetBall()) then
		return
	end

	-- calculate target X position
	self.TargetX = (#self.Monitors > 0) and 20 or -255

	-- get current X position and animate
	local x = self:GetPos()
	self:AlignLeft(math.Approach(x, self.TargetX, FrameTime() * 1000))

	-- draw title
	draw.SimpleTextOutlined("Effects Monitor", "Zing18", 3, 3, color_green, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
end

derma.DefineControl("ZingEffectsMonitor", "", PANEL, "DPanel")


PANEL = {}

function PANEL:Init()
	self:SetSize(256, 32)
	self:AlignTop(32)
	self:AlignLeft(-255)

	self:SetMouseInputEnabled(false)

	self.TargetY = 0
	self.Text = ""
end

function PANEL:PerformLayout()
end

function PANEL:ApplySchemeSettings()
end

function PANEL:Think()
end

function PANEL:SetItem(item, duration)
	-- calculate when to die
	self.Die = CurTime() + (duration or item.Duration)

	-- use name as text
	self.Item = item
	self.Text = item.Name
	self.Image = item.Image
end

function PANEL:Alive()
	-- assume alive if this doesnt exist
	if not self.Die then return true end

	return CurTime() < self.Die
end

function PANEL:Paint(w, h)
	local x, y = self:GetPos()

	-- animate position
	self:AlignLeft(math.Approach(x, 0, FrameTime() * 1000))
	self:AlignTop(math.Approach(y, self.TargetY, FrameTime() * 300))

	-- draw image
	surface.SetMaterial(self.Image or Default)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, 32, 32)

	-- draw text
	local remaining = math.ceil(self.Die - CurTime())
	draw.SimpleTextOutlined(self.Text .. " " .. remaining, "Zing18", 40, 16, (remaining > 3) and color_yellow or color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
end

derma.DefineControl("ZingEffectsMonitorLine", "", PANEL, "DPanel")
