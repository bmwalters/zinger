local PANEL = {}

local background_color = Color(0, 0, 0, 80)

local function rebuild(self) -- todo: not this
	local Offset = 0
	if ( self.Horizontal ) then
		local x, y = self.Padding, self.Padding;
		for k, panel in pairs( self.Items ) do
			if ( panel:IsVisible() ) then
				local w = panel:GetWide()
				local h = panel:GetTall()
				if ( x + w  > self:GetWide() ) then
					x = self.Padding
					y = y + h + self.Spacing
				end
				panel:SetPos( x, y )
				x = x + w + self.Spacing
				Offset = y + h + self.Spacing
			end
		end
	else
		for k, panel in pairs( self.Items ) do
			if ( panel:IsVisible() ) then
				if ( self.m_bNoSizing ) then
					panel:SizeToContents()
					panel:SetPos( (self:GetCanvas():GetWide() - panel:GetWide()) * 0.5, self.Padding + Offset )
				else
					panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
					panel:SetPos( self.Padding, self.Padding + Offset )
				end
				panel:InvalidateLayout( true )
				Offset = Offset + panel:GetTall() + self.Spacing
			end
		end
		Offset = Offset + self.Padding
	end
	self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing )
	self:GetCanvas():AlignBottom( self.Spacing )
	if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then
		self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )
	end
end

function PANEL:Init()
	-- should always be first
	self.BaseClass.Init(self)

	-- position and size
	self:SetSize(500, 160)
	self.ElementTitle = "Chat Area"
	self.DefaultX = (ScrW() * 0.5) - (self:GetWide() * 0.5)
	self.DefaultY = ScrH() - self:GetTall() - 30

	-- chat prompt
	self.Prompt = vgui.Create("DLabel", self)
	self.Prompt:SetSize(50, 20)
	self.Prompt:AlignBottom()
	self.Prompt:AlignLeft()
	self.Prompt:SetVisible(false)
	self.Prompt:SetFont("ZingChat")
	self.Prompt:SetTextColor(color_white)
	self.Prompt:SetContentAlignment(1)
	self.Prompt:SetExpensiveShadow(1, color_black)

	-- chat input
	self.TextInput = vgui.Create("DLabel", self)
	self.TextInput:SetSize(500, 20)
	self.TextInput:AlignBottom()
	self.TextInput:AlignLeft()
	self.TextInput:SetVisible(false)
	self.TextInput:SetFont("ZingChat")
	self.TextInput:SetTextColor(color_white)
	self.TextInput:SetText(" ")
	self.TextInput:SetWrap(true)
	self.TextInput:SetAutoStretchVertical(true)
	self.TextInput:SetContentAlignment(1)
	self.TextInput:SetExpensiveShadow(1, color_black)

	-- chat history
	self.History = vgui.Create("DPanelList", self)
	self.History:SetSize(500, 120)
	self.History.Rebuild = rebuild
	self.History:SetDrawBackground(false)

	-- defaults
	self.LastUpdate = 0
	self:SetAlpha(255)
	self.CurrentAlpha = 255

	self:InitDone()

	self:InvalidateLayout()
end

function PANEL:Think()
	self.BaseClass.Think(self)
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)
end

function PANEL:Paint(w, h)
	-- draw overlay
	if self.Prompt:IsVisible() then
		-- full alpha
		self.CurrentAlpha = 255
		self:SetAlpha(255)

		self.TextInput:AlignBottom()
		local x, y = self.TextInput:GetPos()
		self.Prompt:SetPos(0, y)

		-- draw background
		surface.SetDrawColor(background_color)
		surface.DrawRect(0, 0, self.Width, self.Height)
		surface.DrawRect(0, y, self.Width, self.TextInput:GetTall())
	-- fade out after delay
	elseif CurTime() - self.LastUpdate > 7 and not hud.EditMode() then
		self.CurrentAlpha = math.Approach(self.CurrentAlpha, 1, FrameTime() * 200)
		self:SetAlpha(self.CurrentAlpha)
	else
		self.CurrentAlpha = 255
		self:SetAlpha(255)
	end

	-- must call
	self.BaseClass.Paint(self, w, h)
end

function PANEL:StartChat(t)
	-- change prompt text
	self.Prompt:SetText((t) and "(TEAM) : " or "(ALL) : ")
	self.Prompt:SizeToContents()

	-- clear and position input
	self.TextInput:SetText("")
	self.TextInput:SizeToContents()
	self.TextInput:MoveRightOf(self.Prompt)
	self.TextInput:SetWide(self:GetWide() - self.Prompt:GetWide())

	-- make visible
	self.Prompt:SetVisible(true)
	self.TextInput:SetVisible(true)

	self:InvalidateLayout()
end

function PANEL:ChatTextChanged(text)
	-- update input
	self.TextInput:SetText(text)
	self:InvalidateLayout()
end

function PANEL:FinishChat()
	-- hide everything
	self.TextInput:SetText(" ")
	self.Prompt:SetVisible(false)
	self.TextInput:SetVisible(false)
	self:InvalidateLayout()
end

function PANEL:OnPlayerChat(pl, text, t, dead)
	-- update time
	self.LastUpdate = CurTime()

	-- create entry
	local v = vgui.Create("ChatAreaPlayerLine", self.History)
	v:SetPos(0, -100)
	v:Create(pl, text)

	-- add after 1 frame
	timer.Simple(FrameTime() + 0.001, function()
		self.History:AddItem(v)
	end)
end

function PANEL:ChatText(pid, name, text, msgtype)
	-- update time
	self.LastUpdate = CurTime()

	-- create entry
	local l = vgui.Create("DLabel", self)
	l:SetSize(500, 20)
	l:SetFont("ZingChat")
	l:SetTextColor(color_yellow)
	l:SetText(text)
	l:SetWrap(true)
	l:SetAutoStretchVertical(true)
	l:SetContentAlignment(1)
	l:SetExpensiveShadow(1, color_black)
	l:SetPos(0, -100)

	-- add after 1 frame
	timer.Simple(FrameTime() + 0.001, function()
		self.History:AddItem(l)
	end)
end

derma.DefineControl("ChatArea", "", PANEL, "BaseElement")


PANEL = {}

function PANEL:Init()
	self:SetWide(self:GetParent():GetWide())
	self:SetPaintBackground(false)

	-- player name
	self.NameLabel = vgui.Create("DLabel", self)
	self.NameLabel:SetFont("ZingChat")
	self.NameLabel:AlignTop()
	self.NameLabel:SetContentAlignment(7)
	self.NameLabel:SetExpensiveShadow(1, color_black)

	-- chat
	self.TextLabel = vgui.Create("DLabel", self)
	self.TextLabel:SetContentAlignment(7)
	self.TextLabel:SetFont("ZingChat")
	self.TextLabel:AlignTop()
	self.TextLabel:SetWrap(true)
	self.TextLabel:SetAutoStretchVertical(true)
	self.TextLabel:SetExpensiveShadow(1, color_black)
end

function PANEL:ApplySchemeSettings()
	-- change fonts
	self.NameLabel:SetFont("ZingChat")
	self.TextLabel:SetFont("ZingChat")
	self.TextLabel:SetTextColor(color_white)
end

function PANEL:PerformLayout()
	self:SetTall(self.TextLabel:GetTall())
end

function PANEL:Create(pl, text)
	self:SetWide(self:GetParent():GetWide())

	self.NameLabel:SetText(pl:Name() .. ": ")
	self.NameLabel:SetTextColor(team.GetColor(pl:Team()))
	self.NameLabel:SizeToContents()

	self.TextLabel:SetText(text)
	self.TextLabel:SetSize(self:GetWide() - self.NameLabel:GetWide(), 20)
	self.TextLabel:MoveRightOf(self.NameLabel)

	self:InvalidateLayout()
end

derma.DefineControl("ChatAreaPlayerLine", "", PANEL, "DPanel")
