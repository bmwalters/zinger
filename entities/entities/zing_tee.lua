-- BACKWARDS COMPATIBILITY; DO NOT USE
if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_tee_base"
ENT.PrintName	= "Tee"

if SERVER then
	function ENT:Initialize()
		self.BaseClass.Initialize(self)
		self:SetColor(Color(200, 200, 200))
	end
end
