include("shared.lua")

function GM:Initialize()
end

function GM:InitPostEntity()
	-- create round controller
	local rc = ents.Create("zing_round_controller")
	rc:Spawn()

	-- wait for players
	self:SetRoundState(ROUND_WAITING)
	self:UpdateGameplay()

	-- build the course
	self:GenerateCourse()
end

function GM:FinishMove(ply, mv)
end

function GM:ShowHelp(ply)
	-- pass back to client
	ply:ConCommand("zinger_help")
end

function GM:PlaySound(snd, players)
	net.Start("Zing_PlaySound")
		net.WriteString(snd)
	net.Send(players)
end
