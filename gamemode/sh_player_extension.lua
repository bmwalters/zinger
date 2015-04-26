local meta = FindMetaTable("Player")

function meta:GetBall()
	return self:GetNWEntity("Ball", NULL)
end

function meta:GetCamera()
	return self:GetNWEntity("Camera", NULL)
end

function meta:GetStrokes()
	return self:GetNWFloat("Strokes", 0)
end

function meta:CanHit()
	return self:GetNWBool("CanHit", false)
end

function meta:Alive() -- Override
	return true
end

function meta:GetCursorVector()
	return (self.CursorAim or self:GetAimVector())
end

function meta:UpdateAimVector()
	local camera = self:GetCamera()
	if not IsValid(camera) then return end

	-- update player's position
	local pos = camera:GetPos()
	local viewdir = self:GetAimVector()
	local cmd = self:GetCurrentCommand()
	pos = pos - viewdir * cmd:GetMouseX()

	-- calculate the cursor aim vector
	self.CursorAim = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove())
	if not cmd:KeyDown(IN_CANCEL) and IsBall(camera) then
		-- trace players view
		self:SetFOV(80)
		local trace = {}
		trace.start = pos
		trace.endpos = pos + (self:GetCursorVector() * 4096)
		trace.filter = {camera, self}
		trace.mask = MASK_NPCWORLDSTATIC
		local tr = util.TraceLine(trace)

		-- calculate direction
		local dir = ((tr.HitPos + Vector(0, 0, camera.Size)) - camera:GetPos())
		dir:Normalize()

		-- update aim
		camera:SetAimVector(dir)
	end
end

function meta:AllowImmediateDecalPainting()
	self.NextSprayTime = CurTime()
end

function meta:Think() -- Override
	if SERVER then
		inventory.Think(self)

		local ball = self:GetBall()
		if IsBall(ball) and ball.OnTee and (CurTime() > (ball.TeedAt + TEE_TIME)) and #GAMEMODE:GetQueue(self:Team()) > 0 then
			rules.Call("FailedToTee", self, ball)
		end
	end
end

