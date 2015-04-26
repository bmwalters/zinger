if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Sign"
ENT.Model		= Model("models/zinger/sign.mdl")

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	function ENT:KeyValue(key, value)
		key = string.lower(key)
		if key == "line1" or key == "line2" or key == "line3" then
			-- print(key, value)
			self:SetNWString(key, value)
		end

		if key == "line1color" or key == "line2color" or key == "line3color" then
			local color = string.Explode(" ", value)
			self:SetNWVector(key, Vector(tonumber(color[1]), tonumber(color[2]), tonumber(color[3])))
			-- print(key, Vector(tonumber(color[1]), tonumber(color[2]), tonumber(color[3])))
		end
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	local RT = GetRenderTarget("Sign")

	local Background = CreateMaterial("SignTexture", "UnlitGeneric", {
		["$basetexture"] = "zinger/models/sign/sign",
		["$nocull"] = "1",
	})

	local SignMaterial = Material("zinger/models/sign/sign")
	SignMaterial:SetMaterialTexture("$basetexture", RT)

	function ENT:Initialize()
		self:SetRenderBounds(self:OBBMins(), self:OBBMaxs())
	end

	function ENT:Draw()
		local scrW, scrH = ScrW(), ScrH()
		local oldRT = render.GetRenderTarget()
		local w, h = 789 / 2, 426 / 2
		-- render the sign material
		render.SetRenderTarget(RT)
			render.SetViewPort(0, 0, 512, 512)
				cam.Start2D()
					render.ClearDepth()
					render.Clear(0, 0, 0, 255)
					render.SetMaterial(Background)
					render.DrawScreenQuad()
					local textHeight = h * 0.25
					surface.SetDrawColor(180, 180, 180, 255)
					-- surface.DrawRect(0, 0, w, h)
					for i = 1, 3 do
						local line = self:GetNWString("line" .. i)
						local linecolor = self:GetNWVector("line"..i.."color")
						if line then
							local color = Color(0, 0, 0, 255)
							if linecolor then
								color.r = linecolor.x
								color.g = linecolor.y
								color.b = linecolor.z
							end

							draw.SimpleText(line, "Zing72", w * 0.5, textHeight * i, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end
					end

				cam.End2D()
			render.SetViewPort(0, 0, scrW, scrH)
		render.SetRenderTarget(oldRT)
		-- draw sign
		self:DrawModel()
	end

	function ENT:GetTipText()
		local text
		for i = 1, 3 do
			local line = self:GetNWString("line" .. i)
			if line then
				if text then
					text = text .. " " .. line
				else
					text = line
				end
			end
		end

		return text
	end
end
