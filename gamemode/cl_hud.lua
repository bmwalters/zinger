surface.CreateFont("Zing14", {
	font = "ComickBook",
	size = 14,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing18", {
	font = "ComickBook",
	size = 18,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing20", {
	font = "ComickBook",
	size = 20,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing22", {
	font = "ComickBook",
	size = 22,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing30", {
	font = "ComickBook",
	size = 30,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing42", {
	font = "ComickBook",
	size = 42,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing52", {
	font = "ComickBook",
	size = 52,
	weight = 1,
	antialias = true,
	additive = false,
})
surface.CreateFont("ZingChat", {
	font = "ComickBook",
	size = 18,
	weight = 100,
	antialias = true,
	additive = false,
})
surface.CreateFont("Zing72", {
	font = "ComickBook",
	size = 72,
	weight = 400,
	antialias = true,
	additive = false,
	shadow = false,
	outline = false,
})

local LastMouseMove = CurTime()
local CustomCursor
local Scoreboard
local HelpPanel
local FirstHelp = false
local HelpTopics = {}

function GM:InitializeHUD()
	-- create effects monitor
	self.EffectsMonitor = vgui.Create("ZingEffectsMonitor")
	self.EffectsMonitor:ParentToHUD()

	-- create popup bubble
	self.Bubble = vgui.Create("ZingBubble")
	self.Bubble:ParentToHUD()

	-- create all the hud elements
	self.ChatArea = hud.CreateElement("ChatArea")
	self.Notifications = hud.CreateElement("Notifications")
	self.PointCard = hud.CreateElement("PointCard")
	self.StrokeIndicator = hud.CreateElement("StrokeIndicator")
	hud.CreateElement("StrokeCounter")
	self.SelectedItem = hud.CreateElement("SelectedItem")
	hud.CreateElement("RadarZoom")
	self.Radar = hud.CreateElement("Radar")

	-- create help panel
	HelpPanel = vgui.Create("Help")
	HelpPanel:SetVisible(false)

	-- add any queued topics
	for _, topic in pairs(HelpTopics) do
		HelpPanel:CreateHelpTopic(topic[1], topic[2], topic[3], topic[4])
	end
	HelpPanel:LoadComplete()
end

function GM:CreateHelpTopic(category, title, text, index)
	HelpTopics[#HelpTopics + 1] = {category, title, text, index}
end

function GM:StartChat(t)
	self.ChatArea:StartChat(t)
	return true
end

function GM:ChatTextChanged(text)
	self.ChatArea:ChatTextChanged(text)
end

function GM:FinishChat()
	self.ChatArea:FinishChat()
end

function GM:OnPlayerChat(ply, text, t, dead)
	self.ChatArea:OnPlayerChat(ply, text, t, dead)
end

function GM:ChatText(pid, name, text, msgtype)
	if msgtype == "chat" then
		return
	end

	self.ChatArea:ChatText(pid, name, text, msgtype)
end


function GM:AddNotification(...)
	self.Notifications:AddNotification(...)
end


function GM:ItemAlert(text)
	self.SelectedItem:SetAlert(text)
end


function GM:GUIMouseMoved(x, y)
	-- update mouse movement time
	LastMouseMove = CurTime()
end


local function getfrags(ply) return ply:Frags() end
local function getdeaths(ply) return ply:Deaths() end

function GM:AddScoreboardKills(scoreboard)
	scoreboard:AddColumn("Score", 72, getfrags, 0.5, nil, 6, 6)
end

function GM:AddScoreboardDeaths(scoreboard)
	scoreboard:AddColumn("Strokes", 72, getdeaths, 0.5, nil, 6, 6)
end


local drawhud = GetConVar("cl_drawhud")
function GM:HUDShouldDraw(name)
	-- allow them to disable the hud
	if not drawhud:GetBool() then
		return false
	end

	return true
end


function GM:HUDPaint()
	local sw = ScrW()
	local sh = ScrH()

	-- round info
	self:HUDPaintRoundInfo(sw, sh)

	-- update popup bubble
	self:UpdateBubble(LocalPlayer())

	-- details
	self:HUDPaintPlayerDetails()

	-- draw custom cursor
	if CustomCursor then
		-- check for custom cursor
		local item = inventory.Equipped()
		if item then
			-- get mouse position
			local mx, my = gui.MousePos()

			-- draw cursor
			surface.SetMaterial(CustomCursor)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRectRotated(mx, my, 64, 64, 0) -- to use center as origin
		else
			-- reset it
			self:SetCursor(nil)
		end
	end
end

function GM:SetCursor(cursor)
	if not cursor then
		vgui.GetWorldPanel():SetCursor("arrow")
		CustomCursor = nil
	else
		CustomCursor = cursor
		vgui.GetWorldPanel():SetCursor("blank")
	end
end

local function DrawTopTip(sw, sh, text, text_color)
	draw.SimpleTextOutlined(text, "Zing18", sw * 0.5, 62, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
end

local function DrawTopBar(sw, sh, text, text_color)
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, 0, sw, 60)

	draw.SimpleTextOutlined(text, "Zing42", sw * 0.5, 30, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
end

local function DrawBottomBar(sw, sh, text, text_color)
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawRect(0, sh - 20, sw, 20)

	draw.SimpleTextOutlined(text, "Zing18", sw * 0.5, sh - 10, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end

local function DrawRoundTip(sw, sh, text, text_color)
	surface.SetFont("Zing22")
	local w, h = surface.GetTextSize(text)

	draw.RoundedBox(6, (sw * 0.5) - (w * 0.5) - 6, 122, w + 12, h + 6, Color(0, 0, 0, 180))

	draw.SimpleTextOutlined(text, "Zing22", sw * 0.5, 125, text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
end

function GM:HUDPaintRoundInfo(sw, sh)
	local ply = LocalPlayer()
	local t = ply:Team()
	local state = self:GetRoundState()

	if t == TEAM_SPECTATOR then
		-- spectator
		DrawTopBar(sw, sh, "Spectator Mode", color_white)

		-- helpful tip :D
		DrawBottomBar(sw, sh, "use the scorecard to select a team", color_white)
	end

	-- waiting
	if state == ROUND_WAITING then
		if team.NumPlayers(TEAM_ORANGE) == 0 or team.NumPlayers(TEAM_PURPLE) == 0 then
			-- waiting for players
			DrawRoundTip(sw, sh, "Waiting for more players", color_yellow)
		else
			-- ready to begin
			local waiting = math.floor(self:GetGameTimeLeft() - (self.GameLength * 60))
			DrawRoundTip(sw, sh, "Ready to begin in " .. waiting, color_yellow)
		end

		if t ~= TEAM_SPECTATOR then
			-- show current team name
			DrawTopBar(sw, sh, team.GetName(t), team.GetColor(t))
		end
	-- active game
	elseif state == ROUND_ACTIVE then
		if t == TEAM_SPECTATOR then
			DrawRoundTip(sw, sh, "Game in progress", color_yellow)
			DrawTopTip(sw, sh, "select a team to join the game", color_white)
		end
	-- intermission
	elseif state == ROUND_INTERMISSION then
		-- waiting for players
		DrawRoundTip(sw, sh, "Intermission", color_yellow)
	end
end

function GM:HUDPaintPlayerDetails()
	for _, ply in pairs(player.GetAll()) do
		local ball = ply:GetBall()
		if IsBall(ball) and not ball:GetNinja() then
			local center, size = ball:GetPos2D()

			-- show names
			if (input.IsKeyDown(KEY_LALT)) then
				draw.SimpleTextOutlined(ply:Name(), "Zing18", center.x, center.y - size, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			end
		end
	end
end

function GM:HUDPaintTips(sw, sh)
end

function GM:UpdateBubble(ply)
	-- run bubble
	self.Bubble:Think()

	-- disable in vgui
	if not vgui.IsHoveringWorld() then
		return
	-- disable when in gestures
	elseif controls.InHitGesture() or controls.InViewGesture() then
		return
	end

	-- run trace
	ply:SetFOV(80, 0)
	local tr = util.TraceLine({
		start = EyePos(),
		endpos = EyePos() + ply:GetAimVector() * (1024 * 3),
	})

	-- moved too recently (this prevents bubble spam)
	if CurTime() - LastMouseMove < 0.3 then
		return
	end

	-- measuring
	if tr.HitWorld and input.IsKeyDown(KEY_LALT) then
		local ball = ply:GetCamera()
		if IsBall(ball) then
			-- check for out of bounds
			if IsOOB(tr) then
				self.Bubble:Show("Out of Bounds!")
			else
				local pos = ball:GetPos() - Vector(0, 0, ball.Size)

				-- measure to trace
				local distance = (tr.HitPos - pos):Length() * DISTANCE_SCALE

				-- calculate height and make it human readable
				local height = math.floor((tr.HitPos.z - pos.z) * DISTANCE_SCALE)
				if height > 0 then
					height = "up"
				elseif height == 0 then
					height = "level"
				else
					height = "down"
				end

				-- use measure information
				self.Bubble:Show(util.InchesToFeet(math.floor(distance)) .. " [" .. height .. "]")
			end
		end
	-- entity target
	elseif IsValid(tr.Entity) then
		local ent = tr.Entity

		-- handle balls (lol)
		if IsBall(ent) then
			-- use owner
			ent = ent:GetOwner()

			if (IsValid(ent) and ent:IsPlayer()) then
				-- use player information
				self.Bubble:Show(ent == ply and "YOU!" or ent:Name(), ent)
			end
		elseif (ent.PrintName and ent.PrintName ~= "") then
			-- let the entity decide
			self.Bubble:Show(ent:GetTipText())
		end
	end
end


function GM:ScoreboardShow()
	gui.EnableScreenClicker(true)

	-- create scorecard
	if not Scoreboard then
		Scoreboard = vgui.Create("Scorecard")
	end

	-- make visible
	Scoreboard.CurrentTeam = LocalPlayer():Team()
	Scoreboard:SetVisible(true)
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)
	Scoreboard:SetVisible(false)
end

function GM:IsScoreboardOpen()
	if IsValid(Scoreboard) then
		-- use visible flag
		return Scoreboard:IsVisible()
	end

	return false
end


function GM:OnSpawnMenuOpen()
	inventory.Show()
end

function GM:OnSpawnMenuClose()
	inventory.Hide()
end

local function ShowHelpPanel()
	-- show panel if its not already up
	if not HelpPanel:IsVisible() then
		HelpPanel:SetVisible(true)
		HelpPanel:MakePopup()
	end
end

local function ShowHelp(ply, cmd, args)
	ShowHelpPanel()

	-- check if this is the first time they've opened the help
	if not FirstHelp then
		-- show introduction topic
		HelpPanel:ShowTopic("Basics:Introduction")
		FirstHelp = true
	end
end
concommand.Add("zinger_help", ShowHelp)


function GM:ShowTopic(key)
	ShowHelpPanel()

	HelpPanel:ShowTopic(key)
end

function ButtonSoundDefault()
	surface.PlaySound(string.format("zinger/ballbounce%d.mp3", math.random(1, 4)))
end

function ButtonSoundCancel()
	surface.PlaySound("zinger/ballcollide.mp3")
end

function ButtonSoundOkay()
	surface.PlaySound("zinger/putt1.mp3")
end
