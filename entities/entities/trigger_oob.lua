if not SERVER then return end

ENT.Type = "brush"
ENT.BaseClass = "base_brush"

function ENT:Initialize()
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if IsBall(ent) then
		if self.TreatAsWater then
			ent.MakeWaterSplash = true
		end

		rules.Call("OutOfBounds", ent)
	end
end

function ENT:KeyValue(key, value)
	if key == "spawnflags" then
		self.TreatAsWater = tobool(value)
	end
end
