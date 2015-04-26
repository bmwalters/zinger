function GM:TeamChangeNotification(ply, oldteam, newteam)
	self:ChatText(ply:UserID(), ply:Name(), ply:Name() .. " changed team to " .. team.GetName(newteam), "team")
end

local function Cleanup()
	RunConsoleCommand("r_cleardecals")
	hud.RemoveHints()
end
net.Receive("Zing_Cleanup", Cleanup)

local function PlaySound()
	surface.PlaySound(net.ReadString())
end
net.Receive("Zing_PlaySound", PlaySound)

local function TeeTime()
	GAMEMODE.StrokeIndicator:SetTeeTime(net.ReadBit())
end
net.Receive("Zing_TeeTime", TeeTime)

local function AddNotfication()
	local typ = net.ReadUInt(4)
	if typ == NOTIFY_RING then
		GAMEMODE:AddNotification(net.ReadEntity(), "activated", net.ReadEntity())
		return
	elseif typ == NOTIFY_CRATE then
		GAMEMODE:AddNotification(net.ReadEntity(), "picked up", items.Get(net.ReadString()))
		return
	elseif typ == NOTIFY_ITEMACTION then
		local ply = net.ReadEntity()
		local item = items.Get(net.ReadUInt(8))

		GAMEMODE:AddNotification(ply, item.ActionText, item)
		return
	elseif typ == NOTIFY_ITEMPLAYER then
		local ply = net.ReadEntity()
		local item = items.Get(net.ReadUInt(8)) -- was String but sending Char??

		GAMEMODE:AddNotification(ply, item.ActionText, net.ReadEntity(), "with", item)
		return
	elseif t == NOTIFY_SINKCUP then
		GAMEMODE:AddNotification(net.ReadEntity(), "reached the", net.ReadEntity())
		return
	end
end
net.Receive("Zing_AddNotfication", AddNotfication)

local function ItemAlert(msg)
	GAMEMODE:ItemAlert(net.ReadString())
end
net.Receive("Zing_ItemAlert", ItemAlert)


function GM:ShowTeam()
end
