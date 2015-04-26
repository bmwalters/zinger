
ITEM.Name		= "Ninja"
ITEM.Description	= "You disappear into a cloud of purple velvet and become invisible to enemies"
ITEM.IsEffect		= true
ITEM.IsTimed		= true
ITEM.Duration		= 30
ITEM.ActionText		= "is a"

if (CLIENT) then

	ITEM.Image		= Material("zinger/hud/items/ninja")

end


--[[----------------------------------
	Activate()
----------------------------------]]--
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration

	self.Ball:SetNinja(true)

	if(CLIENT) then

		self.Ball.RenderGroup = RENDERGROUP_TRANSLUCENT

	end

	if(SERVER) then

		-- do the particle effect
		local effect = EffectData()
		effect:SetOrigin(self.Ball:GetPos())
		effect:SetAttachment(1)
		effect:SetEntity(self.Ball)
		util.Effect("Zinger.Ninja", effect)

		-- sound
		self.Ball:EmitSound(Sound("zinger/items/ninja.mp3"))

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

	if(CLIENT) then

		self.Ball.RenderGroup = RENDERGROUP_OPAQUE

	end

	self.Ball:SetNinja(false)

end


--[[----------------------------------
	Think()
----------------------------------]]--
function ITEM:Think()

	return self.Data.EndTime and self.Data.EndTime > CurTime()

end


if(CLIENT) then

	--[[----------------------------------
		PreDrawBall()
	----------------------------------]]--
	function ITEM:PreDrawBall()

		local pl = LocalPlayer()
		if(!IsValid(pl)) then

			return

		end

		if(pl:Team() ~= self.Player:Team()) then

			return false

		end

		render.SetBlend(0.5)

	end
	ITEM.PreDrawViewModel = ITEM.PreDrawBall


	--[[----------------------------------
		PostDrawBall()
	----------------------------------]]--
	function ITEM:PostDrawBall()

		render.SetBlend(1)

	end
	ITEM.PostDrawViewModel = ITEM.PostDrawBall

end
