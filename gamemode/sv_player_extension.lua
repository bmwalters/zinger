local meta = FindMetaTable("Player")

AccessorFunc(meta, "Ball", "Ball")
AccessorFunc(meta, "LoadoutState", "LoadoutState")

function meta:SpawnBall()
	local color = team.GetColor(self:Team())

	local ball = ents.Create("zing_ball")
	ball:Spawn()

	-- save
	self:SetBall(ball)
	ball:SetOwner(self)

	self:SetMoveType(MOVETYPE_NONE)

	return ball
end


function meta:HitBall(dir, power)
	local ball = self:GetBall()
	if not IsBall(ball) then return end

	power = rules.Call("BallHit", self, power)

	-- hit the ball
	ball:Hit(dir, power)
	self:SetCanHit(false)

	-- clear notification
	net.Start("Zing_TeeTime")
		net.WriteBit(0)
	net.Send(self)
end


function meta:SetBall(ent)
	-- neuter them first!
	SafeRemoveEntity(self:GetBall())

	self:SetNWEntity("Ball", ent)
end


function meta:SetCamera(ent)
	self:SetNWEntity("Camera", ent)
end


function meta:SetStrokes(num)
	self:SetNWFloat("Strokes", num)

	self:SetDeaths(math.max(0, num))
end

function meta:AddStroke()
	self:SetStrokes(self:GetStrokes() + 1)
end

function meta:RemoveStroke()
	self:SetStrokes(self:GetStrokes() - 1)
end


function meta:SetCanHit(canhit)
	self:SetNWBool("CanHit", num)
end


function meta:AddPoints(amt)
	GAMEMODE:AddPoints(self, amt)
end


function meta:ActivateViewModel(model, skin, locked)
	local ball = self:GetBall()
	if not IsBall(ball) then return end

	local viewmodel = ball.dt.ViewModel
	if not IsValid(viewmodel) then return end

	viewmodel:SetModel(model)
	viewmodel:SetNoDraw(false)
	viewmodel:DrawShadow(true)
	viewmodel:SetSkin(skin or 0)
	viewmodel:SetPitchLocked(locked or false)
	viewmodel:ResetSequence(0)
end

function meta:SetViewModelAnimation(anim, speed)
	local ball = self:GetBall()
	if not IsBall(ball) then return 0 end

	local viewmodel = ball.dt.ViewModel
	if not IsValid(viewmodel) then return 0 end

	viewmodel:ResetSequence(viewmodel:LookupSequence(anim))
	viewmodel:SetPlaybackRate(speed or 1)

	return viewmodel:SequenceDuration()
end

function meta:DeactivateViewModel()
	local ball = self:GetBall()
	if not IsBall(ball) then return end

	local viewmodel = ball.dt.ViewModel
	if not IsValid(viewmodel) then return end

	viewmodel:SetNoDraw(true)
	viewmodel:DrawShadow(false)
end


function meta:ItemAlert(text)
	net.Start("Zing_ItemAlert")
		net.WriteString(text)
	net.Send(self)
end
