if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_tee_base"
ENT.PrintName	= "Blue Tee"

if SERVER then
	function ENT:Initialize()
		self.BaseClass.Initialize(self)
		self:SetColor(team.GetColor(TEAM_PURPLE))
	end
end
