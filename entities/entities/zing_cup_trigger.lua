if SERVER then AddCSLuaFile() end

ENT.Type	= "anim"
ENT.Base	= "zing_base"

if SERVER then
	AccessorFunc(ENT, "Cup", "Cup")

	function ENT:UpdateTransmitState()
		-- this is merely a serverisde trigger that has to be an anim :(
		-- the client never needs to know we exist
		return TRANSMIT_NEVER
	end

	function ENT:Initialize()
		self:SetCup(NULL)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:SetTrigger(true)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:SetNoDraw(true)
		self:SetCollisionBounds(Vector(-BALL_SIZE, -BALL_SIZE, 0), Vector(BALL_SIZE, BALL_SIZE, BALL_SIZE * 2))
	end

	function ENT:Touch(ent)
		if not IsBall(ent) then return end

		if rules.Call("CanBallSink", ent) then
			-- check if they've stopped
			if ent:GetVelocity():Length() < 5 then
				-- validate cup
				local cup = self:GetCup()
				if not IsValid(cup) then return end

				-- call event
				rules.Call("BallSunk", cup, ent)
			end

		else
			-- push away!
			local dir = (ent:GetPos() - self:GetPos())
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceOffset(dir * (phys:GetMass() * 2), self:GetPos())
			end

			-- play the hole denied sound
			if CurTime() > (ent.DenySoundTime or 0) then
				ent.DenySoundTime = CurTime() + 3
				ent:EmitSoundTeam(ent:Team(), Sound("zinger/cupdeny.mp3"), 85, 100)
			end
		end
	end
end

if CLIENT then
	function ENT:Initialize()
	end

	function ENT:Draw()
	end
end
