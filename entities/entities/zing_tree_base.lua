if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "base_anim"
ENT.PrintName	= nil
ENT.Model		= Model("models/zinger/tree.mdl")

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

if CLIENT then
	local show_foliage = GetConVar("cl_zing_show_foliage")

	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.SwayOffset = math.random() * 4
		self.SwayAngle = Angle(math.random(0, 2), 0, math.random(0, 2))
		-- render bounds
		self:SetRenderBounds(self:OBBMins(), self:OBBMaxs())
	end

	function ENT:BuildBonePositions(numBones)
		local sway = math.sin(CurTime() + self.SwayOffset)
		for i = 0, numBones - 1 do
			local amt = sway * (i / numBones)
			local bone = self:GetBoneMatrix(i)
			bone:Rotate(Angle(self.SwayAngle.p * amt, 0, self.SwayAngle.r * amt))
			self:SetBoneMatrix(i, bone)
		end

		-- trees sway, their shadows should too
		self:MarkShadowAsDirty(true)
	end

	function ENT:Draw()
		if show_foliage:GetBool() then
			self:DrawModel()
		end
	end
end
