if SERVER then AddCSLuaFile() end

ENT.Type					= "anim"
ENT.Base					= "base_anim"
ENT.PrintName				= "Insect"
ENT.AutomaticFrameAdvance	= true

if SERVER then
	function ENT:Initialize()
		self:SetMoveType(MOVETYPE_NOCLIP)
		self:DrawShadow(false)
		-- default delays
		self.NextTargetTime = CurTime() + math.random(6, 12)
		self.NextPositionTime = CurTime() + math.random(0.5, 1.5)
		-- storage
		self.Target = NULL
		self.Offset = Vector()
	end

	local goodents = {zing_ball = true, zing_shroom = true, zing_shrub = true, zing_ring = true, zing_cup = true, zing_crate = true}
	function ENT:GetTargets()
		-- generate a list of entities we can select from
		local entities = {}
		for k, v in pairs(ents.GetAll()) do
			if goodents[v:GetClass()] then
				entities[#entities + 1] = v
			end
		end

		for i = #entities, 1, -1 do
			local ent = entities[i]
			-- measure distance
			if ((ent:GetPos() - self:GetPos()):Length()) > INSECT_MAX_RANGE then
				-- remove from choices
				table.remove(entities, i)
			end
		end

		return entities
	end

	function ENT:OnNewOffset()
	end

	function ENT:OnNewTarget()
	end

	function ENT:MoveToTarget(target)
	end

	function ENT:Think()
		-- get current target
		local target = self.Target
		-- time to change position
		if self.NextPositionTime <= CurTime() then
			-- delay next position change
			self.NextPositionTime = CurTime() + math.random(1, 3)

			if IsValid(target) then
				-- get a new offset
				self.Offset = VectorRand() * target:BoundingRadius() * math.Rand(1.1, 2.1)
				self.Offset.z = math.abs(self.Offset.z) + 8
				-- call event
				self:OnNewOffset()
			end
		end

		-- time to change target
		if self.NextTargetTime <= CurTime() then
			-- set delay
			self.NextTargetTime = CurTime() + math.random(2, 6)
			-- get targets
			local entities = self:GetTargets()
			if #entities > 0 then
				-- now pick a random target
				self.Target = entities[math.random(1, #entities)]
				if self.Target ~= target then
					self:OnNewTarget()
				end
			end
		end

		-- validate target
		if IsValid(target) then
			-- move
			self:MoveToTarget(target)
		else
			-- find another target
			self.NextTargetTime = CurTime()
		end

		self:NextThink(CurTime())
		return true
	end
end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

	function ENT:Initialize()
	end

	function ENT:Think()
	end

	function ENT:Draw()
	end
end
