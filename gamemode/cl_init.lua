include("shared.lua")

require("controls")
require("music")
require("hud")

game.AddParticles("particles/zinger.pcf")

local simpleoutline = CreateClientConVar("cl_zing_simpleoutline", "0", true, false)
local fpstest = CreateConVar("cl_zing_fpstest", "0", {FCVAR_CHEAT})

function GM:Initialize()
	self.BaseClass:Initialize()

	music.Precache()
end

function GM:InitPostEntity()
	-- devs dont need to see the splash screen
	if not Dev() then
		-- show vgui
		self:ShowSplash()
	end
end

function GM:OnEntityCreated(entity)
	if not IsValid(entity) then return end

	if entity:IsPlayer() then
		-- generic player creation hook
		self:OnPlayerCreated(entity)
	end
end

function GM:OnLocalPlayerCreated(ply)
	-- make our own mouse wheel event
	vgui.GetWorldPanel().OnMouseWheeled = function(p, delta)
		self:GUIMouseWheeled(delta)
	end

	-- make our own mouse move event
	vgui.GetWorldPanel().OnCursorMoved = function(p, x, y)
		self:GUIMouseMoved(x, y)
	end

	-- create the hud
	self:InitializeHUD()

	-- devs dont need to hear the theme song (this shit got annoying after months of developing)
	if not Dev() then
		timer.Simple(1, function()
			-- this is our theme song <3
			music.PlayTheme()
		end)
	end
end

function GM:RenderScene(origin, angles)
	-- save render information
	self.LastSceneOrigin = origin
	self.LastSceneAngles = angles

	return self.BaseClass.RenderScene(self, origin, angles)
end

function GM:PreDrawOpaqueRenderables()
	if fpstest:GetBool() then
		return true
	end
end

function GM:PreDrawTranslucentRenderables()
	if fpstest:GetBool() then
		return true
	end
end

-- hack to allow that panorama mod to work with our sky
local oldRenderView = render.RenderView
render.RenderView = function(view)
	-- save render information
	GAMEMODE.LastSceneOrigin = view.origin
	GAMEMODE.LastSceneAngles = view.angles

	return oldRenderView(view)
end

function GM:RenderScreenspaceEffects()
	if fpstest:GetBool() then
		return true
	end

	-- render sky
	self:RenderSkyScreenspaceEffects()

	return self.BaseClass.RenderScreenspaceEffects(self)
end

function GM:PostDrawTranslucentRenderables()
	-- render aim assist
	controls.DrawAimAssist()

	return self.BaseClass.PostDrawTranslucentRenderables(self)
end

function GM:PostDrawOpaqueRenderables()
	-- show hint areas
	hud.DrawHints()

	return self.BaseClass.PostDrawOpaqueRenderables(self)
end

function GM:PlayerBindPress(ply, bind, down)
	-- stop the inventory binds
	if string.find(bind, "invprev") or string.find(bind, "invnext") then
		return true
	end

	return false
end

function GM:ShouldDrawLocalPlayer(ply)
	return false
end

function GM:GetMotionBlurValues(x, y, fwd, spin)
	-- validate player
	local ply = LocalPlayer()
	if IsValid(ply) then
		local ball = ply:GetBall()
		if IsBall(ball) then
			-- calculate forward motion blur
			local fwd = (ball:GetVelocity():Dot(EyeVector()) - 100) / 30000
			fwd = math.Clamp(fwd, 0, 1)

			return x, y, fwd, spin
		end
	end

	return x, y, fwd, spin
end

function GM:CreateMove(cmd)
	-- get player
	local ply = LocalPlayer()

	-- validate camera
	local camera = ply:GetCamera()
	if not IsValid(camera) then
		-- allow spectators to fly up/down using jump/duck
		if (cmd:KeyDown(IN_JUMP)) then
			cmd:SetUpMove(1)
		elseif (cmd:KeyDown(IN_DUCK)) then
			cmd:SetUpMove(-1)
		end

		-- clear buttons
		cmd:SetButtons(0)
		return
	end

	-- clear all but the use button
	local buttons = 0
	if cmd:KeyDown(IN_USE) then
		buttons = bit.bor(buttons, IN_USE)
	end
	if controls.InHitGesture() or controls.InViewGesture() then
		buttons = bit.bor(buttons, IN_CANCEL)
	end
	cmd:SetButtons(buttons)

	-- :( PlayerSpray isn't called
	if cmd:GetImpulse() == 201 then
		RunConsoleCommand("spray")
	end

	if controls.IsValid() then
		-- update view angle and distance on server
		cmd:SetViewAngles(controls.GetViewAngles())
		cmd:SetMouseX(controls.GetDistance())

		-- pass the cursor aim vector to the server
		-- hidden inside the movement speeds
		local dir = ply:GetAimVector()
		cmd:SetForwardMove(dir.x)
		cmd:SetSideMove(dir.y)
		cmd:SetUpMove(dir.z)
	end
end

function GM:CalcView(ply, origin, angles, fov)
	local camera = ply:GetCamera()
	if IsValid(camera) then
		return controls.UpdateView(ply, camera, origin, angles, fov)
	end
end

function GM:AdjustMouseSensitivity(num)
end

function GM:GUIMousePressed(mc, aimvec)
	local ply = LocalPlayer()

	if mc == MOUSE_LEFT then
		if not IsValid(ply:GetBall()) then
			RunConsoleCommand("hit")
			return
		end

		hud.ClickHints()

		-- check for use key
		if ply:KeyDown(IN_USE) then
			local item = inventory.Equipped()
			if item and item.Cursor then
				-- use item
				RunConsoleCommand("item", "use")
			end
		else
			controls.OnHitGesture(ply, true)
		end
	elseif mc == MOUSE_RIGHT then
		controls.OnViewGesture(ply, true)
	end
end

function GM:GUIMouseReleased(mc)
	local ply = LocalPlayer()

	if mc == MOUSE_LEFT then
		controls.OnHitGesture(ply, false)
	elseif mc == MOUSE_RIGHT then
		controls.OnViewGesture(ply, false)
	end
end

function GM:GUIMouseWheeled(delta)
	local camera = LocalPlayer():GetCamera()
	if not IsValid(camera) then return end

	-- modify distance
	controls.MoveDistance(delta)
end

local BlackModel = Material("zinger/models/black")
local BlackModelSimple = Material("black_outline")

local function DrawModelOutlinedSimple(ent, width, width2)
	-- render black model
	render.SuppressEngineLighting(true)
	render.MaterialOverride(BlackModelSimple)

	-- render model
	local mat = Matrix()
	mat:Scale(width)
	ent:EnableMatrix("RenderMultiply", mat)
	ent:SetupBones()
	ent:DrawModel()

	-- render second if needed
	if width2 then
		local mat = Matrix()
		mat:Scale(width2)
		ent:EnableMatrix("RenderMultiply", mat)
		ent:SetupBones()
		ent:DrawModel()
	end

	-- clear
	render.MaterialOverride()
	render.SuppressEngineLighting(false)

	-- render model
	local mat = Matrix()
	mat:Scale(Vector() * 1)
	ent:EnableMatrix("RenderMultiply", mat)
	ent:SetupBones()
	ent:DrawModel()
end

function DrawModelOutlined(ent, width, width2)
	if simpleoutline:GetBool() then
		DrawModelOutlinedSimple(ent, width, width2)
		return
	end

	-- start stencil
	render.SetStencilEnable(true)

	-- render the model normally, and into the stencil buffer
	render.ClearStencil()
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilWriteMask(1)
	render.SetStencilReferenceValue(1)
		-- render model
		local mat = Matrix()
		mat:Scale(Vector() * 1)
		ent:EnableMatrix("RenderMultiply", mat)
		ent:SetupBones()
		ent:DrawModel()
	-- render the outline everywhere the model isn't
	render.SetStencilReferenceValue(0)
	render.SetStencilTestMask(1)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)

	-- render black model
	render.SuppressEngineLighting(true)
	render.MaterialOverride(BlackModel)
		-- render model
		local mat = Matrix()
		mat:Scale(width)
		ent:EnableMatrix("RenderMultiply", mat)
		ent:SetupBones()
		ent:DrawModel()

		-- render second if needed
		if width2 then
			local mat = Matrix()
			mat:Scale(width2)
			ent:EnableMatrix("RenderMultiply", mat)
			ent:SetupBones()
			ent:DrawModel()
		end
	-- clear
	render.MaterialOverride()
	render.SuppressEngineLighting(false)

	-- end stencil buffer
	render.SetStencilEnable(false)
end

function GetEntityPos2D(ent, size)
	-- get right based off player view
	local right = LocalPlayer():GetAimVector():Angle():Right()

	-- calculate the 2D area of the ball location
	local pos = ent:GetPos()
	local center = pos:ToScreen()
	local bounds = pos + (right * (size * 2))
	bounds = bounds:ToScreen()

	return center, math.abs(center.x - bounds.x)
end
