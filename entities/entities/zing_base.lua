if SERVER then AddCSLuaFile() end

ENT.Type			= "anim"
ENT.PrintName		= nil
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.Model			= Model("models/error.mdl")
ENT.Size			= 0

function ENT:GetHole()
	return tonumber(self:GetNWInt("hole")) -- :/
end

if SERVER then
	function ENT:KeyValue(key, value)
		self.KeyValues = self.KeyValues or {}
		-- save hole
		if key == "hole" then
			self:SetNWInt("hole", value)
		else
			self.KeyValues[key] = value
		end
	end
end

if CLIENT then
	-- materials
	local BlackModel = Material("zinger/models/black")
	local BlackModelSimple = Material("black_outline")
	local White = Material("vgui/white")
	local Circle = Material("zinger/hud/circle")
	local RadarPing = Material("zinger/hud/elements/radarping")

	function ENT:Initialize()
	end

	function ENT:DrawModelOutlined(width, width2)
		DrawModelOutlined(self, width, width2)
	end

	function ENT:Draw()
	end

	function ENT:RadarDrawSquare(x, y, size, color, a)
		-- draw rect
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.DrawRect(x - (size * 0.5), y - (size * 0.5), size, size)
		-- draw directional line if an angle was supplied
		if a then
			a = math.rad(a)
			local ax = x + math.cos(a) * size
			local ay = y + math.sin(a) * size
			surface.DrawLine(x, y, ax, ay)
		end
	end

	function ENT:RadarDrawCircle(x, y, size, color, a, material)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		-- draw directional line if an angle was supplied
		if a then
			local ar = math.rad(a)
			local ax = x + math.cos(ar) * size
			local ay = y + math.sin(ar) * size
			surface.DrawLine(x, y, ax, ay)
			a = (360 - a) + 90
		end

		-- draw circle
		surface.SetMaterial(material or Circle)
		surface.DrawTexturedRectRotated(x, y, size, size, a or 0)
	end

	function ENT:RadarDrawTexturedCircle(x, y, size, color, a, material)
		if a then
			a = (360 - a) + 90
		end

		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.SetMaterial(material or Circle)
		surface.DrawTexturedRectRotated(x, y, size, size, a or 0)
	end

	function ENT:RadarDrawRadius(x, y, radius, color, color2)
		-- grow to full size
		self.RadarGrowTime = self.RadarGrowTime or (CurTime() + 0.25)
		self.RadarPingOffset = self.RadarPingOffset or math.random(1, 360)
		-- grow
		local scale = 1 - math.Clamp((self.RadarGrowTime - CurTime()) / 0.25, 0, 1)
		radius = GAMEMODE.Radar.ScaleRadius * radius * 2 * scale
		-- draw the radius circle
		self:RadarDrawTexturedCircle(x, y, radius, color)
		-- draw the ping line
		self:RadarDrawTexturedCircle(x, y, radius, color2, CurTime() * 100 + self.RadarPingOffset, RadarPing)
	end

	function ENT:RadarDrawRect(x, y, w, h, color, a)
		if a then
			a = (360 - a) + 90
		end

		-- draw rect
		surface.SetMaterial(White)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.DrawTexturedRectRotated(x, y, w, h, a or 0)
	end

	function ENT:ShowHint()
		-- no help topic
		if not self.HintTopic then
			self.DontHint = true
			return
		-- topic is surpressed
		elseif hud.IsHintSuppressed(self.HintTopic) then
			self.DontHint = true
			return
		-- dont hint right now
		elseif not hud.ShouldHint(self.HintTopic) then
			return
		end

		-- check if we've added the hint
		if hud.AddHint(self:GetPos() + (self.HintOffset or vector_origin), self.HintTopic, self) then
			self.DontHint = true
		end
	end

	function ENT:HintThink()
		-- verify player has a ball
		local check, ball = HasBall(LocalPlayer())
		if not check then
			hud.DelayHints()
			return
		end

		-- this prevents people moving flying down the course and having
		-- hints appear behind them that they dont notice
		if ball:GetVelocity():Length() > 40 then
			return
		end

		-- throw a hint if possible
		if not self.DontHint and (ball:GetPos() - self:GetPos()):Length() <= HINT_MIN_DISTANCE then
			self:ShowHint()
		end
	end

	function ENT:Think()
		self:NextThink(CurTime() + 0.5)
		-- update hole
		self.CurrentHole = RoundController():GetCurrentHole()
		-- we need hints!
		self:HintThink()
		return true
	end

	function ENT:GetTipText()
		return self.PrintName
	end
end
