local PANEL = {}

local Background = Material("zinger/hud/help")
local ButtonLeft = Material("zinger/hud/buttonleft")
local ButtonRight = Material("zinger/hud/buttonright")
local BlackModelSimple = Material("black_outline")

function PANEL:Init()
	self:SetSize(512, 512)
	self:Center()

	-- create 3D help icon
	self.HelpIcon = vgui.Create("3DIcon", self)
	self.HelpIcon:SetSize(200, 200)
	self.HelpIcon:SetPos(7, -45)
	self.HelpIcon:SetModel(Model("models/zinger/help.mdl"))
	self.HelpIcon:SetAngles(Angle(0, 0, 20))
	self.HelpIcon:SetViewDistance(60)
	self.HelpIcon:SetOutline(1.08)
	self.HelpIcon.Run = function(icon)
		icon.Entity:SetAngles(icon.Entity:GetAngles() + Angle(0, FrameTime() * 20, 0))
	end

	self.Left = vgui.Create("DImageButton", self)
	self.Left:SetMaterial("zinger/hud/buttonleft")
	self.Left:SizeToContents()
	self.Left:SetPos(0, 256)
	self.Left.DoClick = function(btn)
		self:PreviousCategory()

		-- play sound
		ButtonSoundDefault()
	end

	self.Right = vgui.Create("DImageButton", self)
	self.Right:SetMaterial("zinger/hud/buttonright")
	self.Right:SizeToContents()
	self.Right:SetPos(512 - 64, 256)
	self.Right.DoClick = function(btn)
		self:NextCategory()

		-- play sound
		ButtonSoundDefault()
	end

	self.Close = vgui.Create("Button", self)
	self.Close:SetText("close")
	self.Close:SetPos((self:GetWide() * 0.5) - 128, 512 - 64)
	self.Close.DoClick = function(btn)
		-- play sound
		ButtonSoundOkay()
		self:SetVisible(false)
	end

	self.Categories = {}
	self.CurrentCategory = nil

	-- load help
	for _, f in pairs(file.Find("zinger/gamemode/includes/help/*", "LUA")) do
		self:LoadHelpFile(f)
	end
end

function PANEL:PerformLayout()
end

function PANEL:ApplySchemeSettings()
end

function PANEL:OnCursorMoved(x, y)
end

function PANEL:OnCursorExited()
end

function PANEL:ShowTopic(key)
	local category, topic = unpack(string.Explode(":", key))

	if self.CurrentCategory then
		self.CurrentCategory.Panel:SetVisible(false)
	end

	if self.Categories[category] then
		self.Categories[category].Panel:SetVisible(true)
	end

	self.CurrentCategory = self.Categories[category]

	if topic then
		for _, t in pairs(self.Categories[category].Topics) do
			if t.Panel.Topic == topic then
				timer.Simple(FrameTime() + 0.001, function()
					t.Panel:SetClosed(false)
				end)

				return
			end
		end
	end
end

function PANEL:PreviousCategory()
	local found = false

	for key, category in pairs(self.Categories) do
		if found then
			self:ShowTopic(key)
			break
		end

		if category == self.CurrentCategory then
			found = true
		end
	end
end

function PANEL:NextCategory()
	local last = nil

	for key, category in pairs(self.Categories) do
		if category == self.CurrentCategory then
			if last then
				self:ShowTopic(last)
				break
			end
		end

		last = key
	end
end

function PANEL:CreateHelpTopic(category, title, text, index)
	if not self.Categories[category] then
		self.Categories[category] = {}
		self.Categories[category].Title = category
		self.Categories[category].Topics = {}
		self.Categories[category].Panel = vgui.Create("DPanelList", self)
		self.Categories[category].Panel:StretchToParent(60, 145, 60, 60)
		self.Categories[category].Panel:SetDrawBackground(false)
		self.Categories[category].Panel:SetVisible(false)
		self.Categories[category].Panel:SetZPos(-99)
		self.Categories[category].Panel:SetSpacing(2)
		self.Categories[category].Panel:EnableVerticalScrollbar()
		self.Categories[category].Panel.VBar:SetSkin("zinger")
	end

	local tab = self.Categories[category].Topics
	tab[#tab + 1] = {index or (#tab + 1), title, text}
end

function PANEL:LoadHelpFile(f)
	HELP = {}

	include("zinger/gamemode/includes/help/" .. f)
	self:CreateHelpTopic(HELP.category, HELP.title, HELP.text, HELP.index)

	HELP = nil
end

function PANEL:LoadComplete()
	for _, category in pairs(self.Categories) do
		table.sort(category.Topics, function(a, b) return a[1] < b[1] end)

		for _, topic in pairs(category.Topics) do
			local v = vgui.Create("HelpTopic", category.Panel)
			v:Create(topic[2], topic[3])
			v.Category = category
			topic.Panel = v
			category.Panel:AddItem(v)
		end
	end
end

function PANEL:Paint(w, h)
	-- draw background
	surface.SetMaterial(Background)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, w, h)

	if self.CurrentCategory then
		draw.SimpleText(self.CurrentCategory.Title, "Zing30", w * 0.5, 115, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

derma.DefineControl("Help", "", PANEL, "DPanel")


PANEL = {}

function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 22)

	self:SetPaintBackground(false)

	self.Closed = true

	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("Zing18")
	self.NameLabel:AlignTop()
	self.NameLabel:SetContentAlignment(5)
	self.NameLabel:SetSize(self:GetWide(), 22)
	self.NameLabel:SetExpensiveShadow(1, color_black)
	self.NameLabel:SetMouseInputEnabled(true)
	self.NameLabel:SetCursor("hand")
	self.NameLabel.OnMousePressed = function(lbl, mc)
		self:Toggle()

		-- play sound
		ButtonSoundDefault()
	end

	self.TextLabel = vgui.Create("DLabel", self)
	self.TextLabel:SetContentAlignment(7)
	self.TextLabel:SetFont("Zing18")
	self.TextLabel:MoveBelow(self.NameLabel)
	self.TextLabel:AlignLeft(10)
	self.TextLabel:SetWide(self:GetWide() - 20)
	self.TextLabel:SetWrap(true)
	self.TextLabel:SetAutoStretchVertical(true)
	self.TextLabel:SetExpensiveShadow(1, color_black)
end

function PANEL:ApplySchemeSettings()
	self.NameLabel:SetFont("Zing18")
	self.NameLabel:SetTextColor(color_yellow)

	self.TextLabel:SetFont("Zing18")
	self.TextLabel:SetTextColor(color_white)
end

function PANEL:PerformLayout(w, h)
	-- self:SetTall(self.TextLabel:GetTall())
	if h ~= self.LastTall then
		self:GetParent():InvalidateLayout()
	end

	self.LastTall = h
end

function PANEL:Toggle()
	self:SizeTo(self:GetWide(), self.NameLabel:GetTall() + ((self.Closed) and self.TextLabel:GetTall() or 0), 0.2, 0, 2)
	self.Closed = not self.Closed

	if not self.Closed then
		if self.Category.CurrentTopic and self.Category.CurrentTopic:IsValid() and self.Category.CurrentTopic ~= self then
			self.Category.CurrentTopic:SetClosed(true)
		end
	end

	self.Category.CurrentTopic = self
end

function PANEL:SetClosed(bool)
	if self.Closed ~= bool then
		self:Toggle()
	end
end

function PANEL:Create(title, text)
	self.Topic = title

	self:SetWide(self:GetParent():GetWide())

	self.NameLabel:SetText(title)

	self.TextLabel:SetText(text)

	self:InvalidateLayout()
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(0, 0, w, h)
end

derma.DefineControl("HelpTopic", "", PANEL, "DPanel")
