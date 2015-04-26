if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= nil

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_NEVER
	end

	function ENT:Think()
		debugoverlay.Sphere(self:GetPos(), self:SpawnRadius(), 1.05, color_transparent) -- why
		self:NextThink(CurTime() + 1)
		return true
	end

	function ENT:SpawnRadius()
		return self.KeyValues["SpawnRadius"] or 1
	end
end
