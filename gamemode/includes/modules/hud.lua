if not CLIENT then return end

module("hud", package.seeall)

local SelectedElem
local EditState = false
local Elements = {}
local HintEnts = {}
local SuppressedHints = {}
local HintDelay = 0
local OutlineWidth = Vector() * 1.15

local BlackModel = Material("zinger/models/black")

function CreateElement(class)
	-- create the element and save
	local elem = vgui.Create(class)
	Elements[#Elements + 1] = elem

	return elem
end

function EditMode()
	return EditState
end

function Select(elem)
	-- check if we had an old element selected
	if IsValid(SelectedElem) then
		-- release
		SelectedElem:MouseCapture(false)
	end

	SelectedElem = elem

	if IsValid(SelectedElem) then
		-- capture mouse
		SelectedElem:MouseCapture(true)
	end
end

function GetSelected()
	return SelectedElem
end

local function Toggle(ply, cmd, args)
	EditState = not EditState

	for _, e in pairs(Elements) do
		-- validate the element
		if IsValid(e) then
			-- toggle mouse input
			e:SetMouseInputEnabled(EditState)

			-- call the event
			e:EditChanged(EditState)
		end
	end
end
concommand.Add("edithud", Toggle)

function RemoveHint(index)
	HintEnts[index]:Remove() -- -Zerf
	table.remove(HintEnts, index)
end

function SuppressHint(topic)
	SuppressedHints[topic] = true
end

function DelayHints()
	HintDelay = CurTime() + HINT_DELAY
end

function AddHint(pos, topic, parent)
	-- create hint
	local hint = ClientsideModel(Model("models/zinger/help.mdl"), RENDERGROUP_OPAQUE)
	hint:SetPos(pos)
	hint.SpawnTime = CurTime()
	hint.Spin = 90
	hint.Clicked = false
	hint.Topic = topic
	hint:SetNoDraw(true)

	-- store in table
	HintEnts[#HintEnts + 1] = hint

	-- give it an index
	hint.Index = #HintEnts

	-- if a parent was supplied, save the offset
	if IsValid(parent) then
		hint.Parent = parent
		hint.ParentOffset = pos - parent:GetPos()
	end

	-- flash of light
	local light = DynamicLight(0)
	light.Pos = pos
	light.Size = 256
	light.Decay = 1024
	light.R = 200
	light.G = 255
	light.B = 200
	light.Brightness = 6
	light.DieTime = CurTime() + 1.25

	-- sparkle
	ParticleEffectAttach("Zinger.Help", PATTACH_ABSORIGIN_FOLLOW, hint, -1)

	-- notification sound
	surface.PlaySound("zinger/hintpopup.mp3")

	-- suppress the hint and delay the next hint
	SuppressHint(topic)
	DelayHints()

	return hint.Index
end

function DrawHints()
	local hint

	-- loop through each hint
	for i = #HintEnts, 1, -1 do
		hint = HintEnts[i]

		-- if the hint has been clicked, speed up spin velocity
		if hint.Clicked then
			hint.Spin = math.Approach(hint.Spin, 1000, FrameTime() * 500)
		end

		-- spin at chosen velocity
		hint:SetAngles(hint:GetAngles() + Angle(0, FrameTime() * hint.Spin, 0))

		-- draw the model
		DrawModelOutlined(hint, OutlineWidth)

		-- check if we've reached maximum spin velocity and destroy
		if hint.Spin == 1000 then
			HintEnts[i]:Remove() -- -Zerf
			table.remove(HintEnts, i)
		elseif hint.Parent then
			if not IsValid(hint.Parent) then
				if not hint.Clicked then
					-- enable the hint again
					SuppressedHints[hint.Topic] = nil
				end

				HintEnts[i]:Remove() -- -Zerf
				table.remove(HintEnts, i)
			else
				hint:SetPos(hint.Parent:GetPos() + hint.ParentOffset)
			end
		end
	end
end

local function ClickHint(hint)
	-- flag as clicked
	hint.Clicked = true

	-- notification sound
	surface.PlaySound("zinger/hintclicked.mp3")

	-- display the topic in game
	GAMEMODE:ShowTopic(hint.Topic)

	-- stop the sparkle
	hint:StopParticles()

	-- explode
	ParticleEffectAttach("Zinger.HelpExplode", PATTACH_ABSORIGIN_FOLLOW, hint, -1)
end

function Think()
end

local function DidClickHint(hint)
	local pos, dir = controls.GetViewPos(), controls.GetCursorDirection()
	local hit, dist = math.RayIntersectSphere(pos, dir, hint:GetPos(), 28)

	if hit then
		-- ensure our view of it is unobstructed
		local tr = util.TraceLine({
			start = pos,
			endpos = pos + dir * dist,
		})

		if tr.Fraction == 1 then
			return true, dist
		end
	end

	return false
end

function ClickHints()
	-- no hints to click, ignore
	if #HintEnts == 0 then return end

	-- find the closest hint our mouse is over
	local closest_dist, closest_hint = math.huge, nil
	for _, hint in pairs(HintEnts) do
		local hit, dist = DidClickHint(hint)

		if hit and dist <= closest_dist then
			closest_dist = dist
			closest_hint = hint
		end
	end

	-- we have a click!
	if closest_hint then
		ClickHint(closest_hint)
	end
end

function IsHintSuppressed(topic)
	return (SuppressedHints[topic] ~= nil)
end

function ShouldHint(topic)
	if CurTime() < HintDelay then
		return false
	end

	return true
end

function RemoveHints()
	-- loop through each active hint
	for i = 1, #HintEnts do
		local hint = HintEnts[i]

		-- make sure it hasn't been clicked
		if not hint.Clicked then
			-- unsuppress the hint
			SuppressedHints[hint.Topic] = nil
		end

		hint:Remove() -- -Zerf
	end

	-- set a delay and remove all
	DelayHints()
	HintEnts = {}
end
