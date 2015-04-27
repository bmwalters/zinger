local PANEL = {}

local Background = Material("zinger/hud/scorecard")
local ButtonLeft = Material("zinger/hud/buttonleft")
local ButtonRight = Material("zinger/hud/buttonright")
local BlackModelSimple = Material("black_outline")

function PANEL:Init()
	-- always show this players team first
	self.CurrentTeam = LocalPlayer():Team()

	self:SetSize(512, 512)
	self:Center()

	-- create 3D ball
	self.Ball = vgui.Create("3DIcon", self)
	self.Ball:SetSize(200, 200)
	self.Ball:SetPos(0, -45)
	self.Ball:SetModel(Model("models/zinger/ball.mdl"))
	self.Ball:SetAngles(Angle(0, 0, 20))
	self.Ball:SetViewDistance(25)
	self.Ball:SetOutline(1.07)
	self.Ball.Run = function(icon)
		icon.Entity:SetAngles(icon.Entity:GetAngles() + Angle(0, FrameTime() * 10, 0))
	end

	self.Left = vgui.Create("DImageButton", self)
	self.Left:SetMaterial("zinger/hud/buttonleft")
	self.Left:SizeToContents()
	self.Left:SetPos(0, 256)
	self.Left.DoClick = function(btn)
		self.CurrentTeam = self.CurrentTeam + 1
		if self.CurrentTeam > TEAM_PURPLE then
			self.CurrentTeam = TEAM_SPECTATOR
		end

		-- play sound
		ButtonSoundDefault()
	end

	self.Right = vgui.Create("DImageButton", self)
	self.Right:SetMaterial("zinger/hud/buttonright")
	self.Right:SizeToContents()
	self.Right:SetPos(512 - 64, 256)
	self.Right.DoClick = function(btn)
		self.CurrentTeam = self.CurrentTeam - 1
		if self.CurrentTeam < TEAM_SPECTATOR then
			self.CurrentTeam = TEAM_PURPLE
		end

		-- play sound
		ButtonSoundDefault()
	end

	self.Select = vgui.Create("Button", self)
	self.Select:SetText("join team")
	self.Select:SetPos((self:GetWide() * 0.5) - 128, 512 - 64)
	self.Select.DoClick = function(btn)
		RunConsoleCommand("changeteam", self.CurrentTeam)

		-- play sound
		ButtonSoundOkay()
	end
end

function PANEL:PerformLayout()
end

function PANEL:ApplySchemeSettings()
end

function PANEL:Think()
	local state = GAMEMODE:GetRoundState()

	if (state ~= ROUND_WAITING and state ~= ROUND_INTERMISSION) and LocalPlayer():Team() ~= TEAM_SPECTATOR then
		self.Select:SetVisible(false)
		return
	end

	self.Select:SetVisible(self.CurrentTeam ~= LocalPlayer():Team())
end

function PANEL:OnCursorMoved(x, y)
end

function PANEL:OnCursorExited()
end

function PANEL:Paint(w, h)
	-- draw background
	surface.SetMaterial(Background)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, w, h)

	-- draw.SimpleText("Current Hole: " .. RoundController():GetCurrentHole(), "Zing22", 260, 110, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	draw.SimpleTextOutlined(team.GetName(self.CurrentTeam), "Zing42", w * 0.5, 145, team.GetColor(self.CurrentTeam), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
end

derma.DefineControl("Scorecard", "", PANEL, "DPanel")
