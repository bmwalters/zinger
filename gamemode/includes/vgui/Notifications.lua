local PANEL = {}

function PANEL:Init()
	-- should always be first
	self.BaseClass.Init(self)

	self:SetSize(800, 256)
	self.ElementTitle = "Notification Area"
	self.DefaultX = (ScrW() * 0.5) - (self:GetWide() * 0.5)
	self.DefaultY = 10

	self.Flag = ELEM_FLAG_PLAYERS

	self.Notifications = {}

	self:InitDone()
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)
end

function PANEL:ApplySchemeSettings()
end

function PANEL:Think()
	self.BaseClass.Think(self)

	for i = #self.Notifications, 1, -1 do
		-- check if dead
		if not self.Notifications[i]:Alive() then
			-- kill and remove
			self.Notifications[i]:Remove()
			table.remove(self.Notifications, i)
		end
	end

	-- starting Y position
	local y = 0

	-- cycle through monitors
	for i = 1, #self.Notifications do
		-- update target Y position
		self.Notifications[i].TargetY = y
		y = y + 32
	end
end

function PANEL:AddNotification(...)
	-- create note
	local note = vgui.Create("NotificationLine", self)

	-- add each text
	for _, text in pairs({...}) do
		note:AddText(text)
	end

	self.Notifications[#self.Notifications + 1] = note
end

function PANEL:Paint(w, h)
	if not self:ShouldPaint() then return end

	-- must call
	self.BaseClass.Paint(self, w, h)
end

derma.DefineControl("Notifications", "", PANEL, "BaseElement")


PANEL = {}

function PANEL:Init()
	self:SetSize(512, 32)
	self:AlignTop(-31)
	self:CenterHorizontal()

	self:SetMouseInputEnabled(false)

	self.TargetY = 0
	self.Die = CurTime() + 8
	self.Items = {}
end

function PANEL:PerformLayout()
	local last

	for _, v in pairs(self.Items) do
		if last then
			-- move right of last item
			v:MoveRightOf(last, 8)
		else
			-- starting spot
			v:AlignLeft(0)
		end

		last = v
	end

	self:SetWide(last.X + last:GetWide() + 4)
	self:CenterHorizontal()
end

function PANEL:ApplySchemeSettings()
end

function PANEL:Think()
end

function PANEL:AddText(item)
	local label = vgui.Create("DLabel", self)
	label:SetFont("Zing22")

	label.Paint = function(p)
		-- outlined text
		draw.SimpleTextOutlined(p:GetValue(), "Zing22", 2, 2, p:GetTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		return true
	end

	local t = type(item)

	-- players
	if t == "Player" then
		-- use player name and team color
		label:SetText(item:Name())
		label:SetTextColor(team.GetColor(item:Team()))
	-- entities
	elseif t == "Entity" and item.PrintName then
		-- use print name and notify color
		label:SetText(item.PrintName)
		label:SetTextColor(item.NotifyColor or color_white)
	-- items
	elseif t == "table" and item.IsItem then
		-- item name and brown
		label:SetText(item.Name)
		label:SetTextColor(color_brown)
	else
		-- just turn it into a string and white
		label:SetText(tostring(item))
		label:SetTextColor(color_white)
	end

	label:SizeToContents()
	label:SetWide(label:GetWide() + 4)
	label:SetTall(32)

	self.Items[#self.Items + 1] =  label

	-- dirty
	self:InvalidateLayout()
end

function PANEL:Alive()
	if not self.Die then return true end

	return CurTime() < self.Die
end

function PANEL:Paint(w, h)
	local x, y = self:GetPos()

	-- animate position
	self:AlignTop(math.Approach(y, self.TargetY, FrameTime() * 450))
end

derma.DefineControl("NotificationLine", "", PANEL, "DPanel")
