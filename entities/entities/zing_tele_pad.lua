if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Teleport Pad"
ENT.Model		= Model("models/zinger/pad.mdl")
ENT.IsTelePad	= true

function ENT:SetupDataTables()
end

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(false)
		self:SetModel(self.Model)
		self:SetSolid(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionBounds(self:OBBMins(), self:OBBMaxs())
		self:SetTrigger(true)
		self:SetMaterial("zinger/models/pad/telepad")
		self.Destinations = {}

		local targets = ents.FindByName(self.Destination or "")

		for k, v in pairs(targets) do
			self.Destinations[#self.Destinations + 1] = v:GetPos()
		end

		-- alert the mapper
		if #self.Destinations == 0 then
			Error("Teleport Pad ", self, " at ", self:GetPos(), " has no destinations")
		end
	end

	function ENT:GetDestination(ent)
		if #self.Destinations == 0 then
			return self:GetPos()
		end

		return self.Destinations[math.random(1, #self.Destinations)]
	end

	function ENT:StartTouch(ent)
		if #self.Destinations == 0 then return end

		if IsBall(ent) then
			local height = (ent:GetPos() - self:GetPos()).z
			local target = table.Random(self.Destinations)
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				local velocity = phys:GetVelocity()
				constraint.RemoveConstraints(ent, "Weld")
				ent:GetOwner():ClearEffect("magnet")
				ent:SetPos(target + Vector(0, 0, height))
				if self.ZeroVelocity then
					phys:EnableMotion(false)
					phys:EnableMotion(true)
				else
					phys:SetVelocity(velocity)
				end
			end

			-- effect
			local effect = EffectData()
			effect:SetOrigin(ent:GetPos())
			effect:SetEntity(ent)
			effect:SetScale(1.5)
			util.Effect("Zinger.Teleport", effect)
			rules.Call("PadTouched", self, ent)
		end
	end

	function ENT:KeyValue(key, value)
		if key == "destination" then
			self.Destination = value
		elseif key == "spawnflags" then
			self.ZeroVelocity = (value == "1")
		end

		return self.BaseClass.KeyValue(self, key, value)
	end
end

if CLIENT then
	local WhiteMaterial = CreateMaterial("White", "UnlitGeneric", {
		["$basetexture"] = "color/white",
		["$vertexcolor"] = "1",
		["$vertexalpha"] = "1",
		["$nocull"] = "1",
	})

	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.BaseClass.Initialize(self)
	end

	function ENT:Draw()
		-- calculate outline width
		local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
		width = 1.025 + ((width / MAX_VIEW_DISTANCE) * 0.05)
		self:DrawModelOutlined(Vector(width, width, 1.05))
		local time = CurTime() * 10
		local position = self:GetPos() + Vector(0, 0, 2)
		-- ridge line
		render.SetMaterial(WhiteMaterial)
		mesh.Begin(MATERIAL_LINE_STRIP, 8)
		for i = 1, 8 do
			local angle = time + math.rad((90 / 8) * i)
			local dir = Vector(math.sin(angle), math.cos(angle), 0)
			local frac = 1 - (1 / 4) * math.abs(4 - i)
			mesh.Position(position + dir * 20)
			mesh.Color(48, 226, 82, 255 * frac)
			mesh.AdvanceVertex()
		end
		mesh.End()
	end
end
