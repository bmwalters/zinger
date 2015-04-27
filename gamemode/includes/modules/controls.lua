if not CLIENT then return end

module("controls", package.seeall)

local CurrentView
local LastCamera
local ViewGestureX
local ViewGestureY
local ViewAngle = Angle(0, 0, 0)
local ViewDistance
local HitStarted
local HitDirection
local HitPower = -1
local PowerSound
local BallMins = Vector(-BALL_SIZE, -BALL_SIZE, -1)
local BallMaxs = Vector(BALL_SIZE, BALL_SIZE, 1)
local GroundTraceSize = Vector(0, 0, BALL_SIZE * BALL_SIZE)

local WhiteMaterial = CreateMaterial("White", "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
	["$nocull"] = "1",
})

local function ClearHitGesture(pl)
	-- clear values
	HitStarted = nil
	HitDirection = nil
	HitPower = -1

	if PowerSound then
		PowerSound:Stop()
	end
end

function Update(ply)
	local camera = ply:GetCamera()
	if not IsValid(camera) then return end

	-- changing view angle
	if InViewGesture() then
		-- get mouse position
		local x, y = gui.MousePos()

		-- modify view based on mouse movement
		ViewAngle.Pitch = ViewAngle.Pitch - ((y - ViewGestureY) * (GetConVarNumber("m_pitch") * 8))
		ViewAngle.Yaw = ViewAngle.Yaw - ((x - ViewGestureX) * (GetConVarNumber("m_yaw") * 6))

		-- update mouse position
		ViewGestureX, ViewGestureY = gui.MousePos()
	end

	-- balls only (lol)
	if not IsBall(camera) then return end

	-- update hit
	if InHitGesture() then
		local normal = Vector(0, 0, 1)
		local distance = normal:Dot(camera:GetPos())
		local pickingPos = CurrentView.origin
		ply:SetFOV(CurrentView.fov)
		local pickingRay = ply:GetAimVector()

		-- intersect picking ray with the ball hit plane
		local denom = normal:Dot(pickingRay)
		if denom == 0 then return end
		local rayDistance = -(normal:Dot(pickingPos) - distance) / denom
		local hitPos = pickingPos + pickingRay * rayDistance

		-- calculate direction
		local diff = (camera:GetPos() - hitPos)
		local dist = diff:Length()
		local dir = diff:GetNormal()

		-- save direction
		HitDirection = dir

		-- calculate power
		local center = camera:GetPos():ToScreen()
		center = Vector(center.x, center.y, 0)
		local mouse = Vector(gui.MouseX(), gui.MouseY(), 0)
		diff = (center - mouse)
		dist = diff:Length()

		local _, size = camera:GetPos2D()

		-- save power
		HitPower = math.floor(math.Clamp((dist - size) / (ScrH() * 0.3), 0.01, 1) * 100)

		-- power clicks every even number
		if HitPower % 2 == 1 then
			PowerSound:ChangePitch(100 + ((HitPower * 0.01) * 50))
		end
	end
end

function GetPower()
	return HitPower or -1
end

function GetDistance()
	return ViewDistance or 0
end

function SetDistance(val)
	ViewDistance = val
end

function MoveDistance(diff)
	-- modify distance
	ViewDistance = ViewDistance + (-diff * 40)
end

function OnViewGesture(pl, down)
	local camera = pl:GetCamera()
	if not IsValid(camera) then return end

	-- cancelling hit
	if HitDirection ~= nil then
		ClearHitGesture(pl)
		surface.PlaySound(Sound("ui/buttonclickrelease.wav"))
	end

	-- starting
	if down then
		-- store mouse position
		ViewGestureX, ViewGestureY = gui.MousePos()
	-- stopping
	else
		ViewGestureX = nil
		ViewGestureY = nil
	end
end

function OnHitGesture(ply, down)
	if not (down and ply:CanHit()) then return end

	local ball = ply:GetBall()
	if not IsBall(ball) then return end

	-- starting
	if not InHitGesture() then
		local center, size = ball:GetPos2D()

		-- get the mouse position
		local mx, my = gui.MousePos()

		-- check if they clicked the ball
		if math.abs(mx - center.x) > size or math.abs(my - center.y) > size then return end

		-- check for sound
		if not PowerSound then
			PowerSound = CreateSound(ply, Sound("buttons/lightswitch2.wav"))
		end

		-- play
		PowerSound:PlayEx(0.2, 100)
		PowerSound:ChangeVolume(0.2)

		-- start hit
		HitStarted = CurTime()
	-- stopping
	else
		-- slow down quick clicks (most are mistakes)
		if CurTime() - HitStarted < 0.15 then
			return
		end

		-- hit their ball
		RunConsoleCommand("hit", HitDirection.x, HitDirection.y, HitPower)

		-- clear
		ClearHitGesture(ply)
	end
end

function InHitGesture()
	return HitStarted ~= nil
end

function InViewGesture()
	return ViewGestureX ~= nil and ViewGestureY ~= nil
end

function IsValid()
	return CurrentView ~= nil
end

function GetViewAngles()
	return CurrentView.angles
end

function GetViewFOV()
	return CurrentView.fov
end

function GetViewPos()
	return CurrentView.origin
end

function GetCursorDirection()
	local ply = LocalPlayer()
	if IsValid(ply) then
		-- hack to make sure that the trace is accurate.
		ply:SetFOV(CurrentView.fov, 0)
		return ply:GetAimVector()
	end

	return vector_up
end

function UpdateView(ply, camera, origin, angles, fov)
	if not vgui.CursorVisible() then
		gui.EnableScreenClicker(true)
	end

	-- check for view reset
	if not LastCamera then
		ViewAngle.Pitch = 45
		ViewDistance = 400
		ViewAngle.Yaw = camera:GetAngles().Yaw
	end

	-- clamp
	ViewAngle.Pitch = math.Clamp(ViewAngle.Pitch, 0, 90)
	ViewDistance = math.Clamp(ViewDistance, MIN_VIEW_DISTANCE, MAX_VIEW_DISTANCE)

	local cameraPos = camera:GetPos()
	local camPos = cameraPos + (ViewAngle:Forward() * -ViewDistance)

	-- create default view
	local view = {
		origin = camPos,
		angles = ViewAngle,
		fov = 80
	}

	-- if new camera or no previous view, reset current
	if (not CurrentView) or camera ~= LastCamera then
		CurrentView = view
	end

	-- do interpolation on position
	view.origin = LerpVector(FrameTime() * 5, CurrentView.origin, view.origin)

	-- always face camera
	view.angles = (cameraPos - view.origin):Angle()

	-- save current view
	CurrentView = view
	LastCamera = camera

	--[[
	for k, v in pairs(ply.ActiveItems or {}) do
		GAMEMODE:ItemCall(ply, v, "CalcView", view)
	end
	]]--

	view.origin, view.angles = cam.ApplyShake(view.origin, view.angles, 1)

	-- override
	return view
end

function DrawAimAssist()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	-- don't call unless we have a direction (UpdateGestures makes this)
	if not HitDirection then return end

	local ball = ply:GetCamera()
	if not IsBall(ball) then return end

	if InHitGesture() then
		local points = {}

		local lastDirection = HitDirection
		local lastPosition = ball:GetPos()
		local len = ball.Size * 2

		render.SetMaterial(WhiteMaterial)
		mesh.Begin(MATERIAL_LINE_STRIP, 16)

		for i = 1, 16 do
			local position = lastPosition + lastDirection * (i * len)

			-- hit a wall or slope?
			local tr = util.TraceHull({
				start = lastPosition,
				endpos = position,
				filter = ball,
				mins = BallMins,
				maxs = BallMaxs,
				mask = MASK_NPCSOLID_BRUSHONLY
			})

			if tr.HitWorld then
				position = tr.HitPos

				-- enough to reflect?
				if tr.HitNormal:Dot(vector_up) < 0.5 then
					lastDirection = (2 * tr.HitNormal * tr.HitNormal:Dot(tr.Normal * -1)) + tr.Normal
				end
			end

			local tr = util.TraceHull({
				start = position + GroundTraceSize,
				endpos = position - GroundTraceSize,
				filter = ball,
				mins = BallMins,
				maxs = BallMaxs,
				mask = MASK_NPCSOLID_BRUSHONLY
			})

			if tr.Hit then
				local newPos = tr.HitPos + Vector(0, 0, ball.Size)
				if newPos.z > position.z then
					position = newPos
				end
			end

			local frac = 1 - (i / 16)

			-- add vertex
			mesh.Position(position)
			mesh.Color(255, 255, 255, 255 * frac)
			mesh.AdvanceVertex()

			lastPosition = position
			len = math.Clamp((HitPower * 0.02) * 3, 0.3, 3)
		end

		mesh.End()
	end
end

if CLIENT then
	function ResetViewMessage()
		LastCamera = nil
	end
	net.Receive("Zing_ResetView", ResetViewMessage)
end
