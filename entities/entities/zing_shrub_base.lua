if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "base_anim"
ENT.PrintName	= nil
ENT.Model		= Model("models/zinger/shrub.mdl")

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:SetTrigger(true)
		self:SetAngles(Angle(0, math.random(0, 360), 0))
	end

	function ENT:StartTouch(ent)
		self:EmitSound("zinger/bush.wav", 100, math.random(100, 110))
		ParticleEffect("Zinger.BushLeaves", ent:GetPos(), (ent:GetPos() - self:GetPos()):GetNormal():Angle(), -1)
	end

	function ENT:EndTouch(ent)
		self:EmitSound("zinger/bush.wav", 100, math.random(100, 110))
		ParticleEffect("Zinger.BushLeaves", ent:GetPos(), (ent:GetPos() - self:GetPos()):GetNormal():Angle(), -1)
	end
end

if CLIENT then
	local show_foliage = GetConVar("cl_zing_show_foliage")

	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.SwayOffset = math.random() * 4
		self.SwayAngle = Angle(math.random(2, 8), 0, math.random(2, 8))
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

		-- dirty the shadow
		self:MarkShadowAsDirty(true)
	end

	function ENT:Draw()
		if show_foliage:GetBool() then
			self:DrawModel()
		end
	end
end
