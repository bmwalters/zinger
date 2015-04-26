
ITEM.Name		= "Scramble"
ITEM.Description	= "Chance of fate! Randomly swaps with other players"
ITEM.IsEffect		= false
ITEM.IsTimed		= false
ITEM.ActionText		= "mixed things up with"

if (CLIENT) then

	ITEM.Image		= Material("zinger/hud/items/scramble")

end

--[[----------------------------------
	Activate()
----------------------------------]]--
function ITEM:Activate()

	if(SERVER) then

		local balls = {}

		-- get all the active balls
		local players = player.GetAll()
		for _, pl in pairs(players) do

			if(IsValid(pl)) then

				local ball = pl:GetBall()
				if(IsValid(ball) and !ball.OnTee) then

					table.insert(balls, ball)

				end

			end

		end

		local time = 0.05

		-- scramble sound
		GAMEMODE:PlaySound("zinger/scramble.mp3")

		-- scramble them like an omelette
		for _, me in pairs(balls) do

			math.randomseed(SysTime())

			local them = table.Random(balls)
			if(IsValid(them) and IsValid(me) and them ~= me) then

				timer.Simple(time, function()

					-- unweld
					constraint.RemoveConstraints(me, "Weld")
					constraint.RemoveConstraints(them, "Weld")
					me:GetOwner():ClearEffect("magnet")
					them:GetOwner():ClearEffect("magnet")

					-- swap
					local physA = me:GetPhysicsObject()
					local physB = them:GetPhysicsObject()
					if(IsValid(physA) and IsValid(physB)) then

						local velocity = physA:GetVelocity()
						local pos = physA:GetPos()

						physA:SetPos(physB:GetPos())
						physA:SetVelocity(physB:GetVelocity())
						physA:Wake()

						physB:SetPos(pos)
						physB:SetVelocity(velocity)
						physB:Wake()

					end

					-- effect
					local effect = EffectData()
					effect:SetOrigin(me:GetPos())
					effect:SetEntity(me)
					effect:SetScale(0.5)
					util.Effect("Zinger.Teleport", effect)

				end)

				time = time + 0.05

			end

		end

		net.Start("Zing_AddNotfication")
			net.WriteUInt(NOTIFY_ITEMACTION, 4)
			net.WriteEntity(self.Player)
			net.WriteUInt(self.Index, 8)
		net.Broadcast()

	end

end

