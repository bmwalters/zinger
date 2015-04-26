
ITEM.Name		= "Disguise"
ITEM.Description	= "Confuse the enemy team by changing to their ball color"
ITEM.IsEffect		= true
ITEM.IsTimed		= true
ITEM.Duration		= 60
ITEM.ActionText		= "is using a"

if (CLIENT) then

	ITEM.Image		= Material("zinger/hud/items/disguise")

end


--[[----------------------------------
	Activate()
----------------------------------]]--
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration

	self.Ball:SetDisguise(true)

	if (SERVER) then

		net.Start("Zing_AddNotfication")
			net.WriteUInt(NOTIFY_ITEMACTION, 4)
			net.WriteEntity(self.Player)
			net.WriteUInt(self.Index, 8)
		net.Send(team.GetPlayers(self.Player:Team()))

	end

end


--[[----------------------------------
	Deactivate()
----------------------------------]]--
function ITEM:Deactivate()

	self.Ball:SetDisguise(false)

end


--[[----------------------------------
	Think()
----------------------------------]]--
function ITEM:Think()

	return self.Data.EndTime and self.Data.EndTime > CurTime()

end
