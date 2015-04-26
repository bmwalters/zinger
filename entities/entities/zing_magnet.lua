if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_base"
ENT.PrintName	= "Magnet"
ENT.Model		= Model("models/zinger/magnet.mdl")
ENT.IsMagnet	= true

function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "Active")
	self.dt.Active = false
end

if SERVER then
	function ENT:Initialize()
		self.DieTime = CurTime() + MAGNET_DURATION
		self.Team = TEAM_SPECTATOR
		self:DrawShadow(true)
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		-- wake and disable drag
		-- we calculate the throw vector as if we have none
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableDrag(false)
			phys:Wake()
			phys:SetMass(10)
		end

		-- magnet sound
		self.Sound = CreateSound(self.Entity, Sound("ambient/machines/combine_shield_loop3.wav"))
	end

	function ENT:OnRemove()
		self.Sound:Stop()
	end

	function ENT:GetSuctionPosition()
		return (self:GetAttachment(1).Pos + self:GetAttachment(2).Pos) * 0.5
	end

	function ENT:Think()
		-- remove magnet
		if self.DieTime <= CurTime() then
			self:Remove()
			return
		end

		if self.dt.Active then
			debugoverlay.Sphere(self:GetPos(), MAGNET_ATTRACT_RADIUS, 0.05, color_transparent) -- why
			local owner = self:GetOwner()
			local balls = ents.FindByClass("zing_ball")
			local suctionPoint = self:GetSuctionPosition()
			if not IsValid(owner) then return end

			-- attract balls
			for k, v in pairs(balls) do
				if not v:IsConstrained() and v:Team() ~= owner:Team() then
					local phys = v:GetPhysicsObject()
					if IsValid(phys) then
						local dir = (suctionPoint - phys:GetPos())
						local dist = dir:Length()
						if dist <= MAGNET_ATTRACT_RADIUS then
							-- no need to use any nasty sqrts unless this is in range
							dir:Normalize()
							local force = dir * phys:GetMass() * (MAGNET_ATTRACT_RADIUS - dist) * MAGNET_ATTRACT_STRENGTH
							if force:LengthSqr() ~= 0 then
								phys:ApplyForceCenter(force)
							end
						end
					end
				end
			end
		end

		self:NextThink(CurTime())
		return true
	end

	function ENT:GetPlaneSide(point)
		local normal = self:GetUp()
		local distance = normal:Dot(self:GetSuctionPosition() - normal * 16)
		local pointDistance = normal:Dot(point) - distance
		-- based on the distance to the plane determine what side we're on
		if pointDistance < 0 then return 1 end
		return 0
	end

	function ENT:PhysicsCollide(data, physobj)
		if not self.dt.Active then
			self.dt.Active = true
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableDrag(true)
				phys:SetDamping(0.1, 0.5)
			end

			self.Sound:Play()
			self.Sound:ChangePitch(150)
			self.Sound:ChangeVolume(0.1)
		else
			if IsBall(data.HitEntity) and data.HitEntity:Team() ~= self.Team and not (data.HitEntity:GetNinja() or data.HitEntity:GetDisguise()) then
				-- ensure its near the tip of the magnet
				if self:GetPlaneSide(data.HitPos) == 0 then
					timer.Simple(0, function()
						-- add a monitor to them with the time remaining
						net.Start("AddMonitorTimer") -- nothing receives this????
						net.WriteUInt(GAMEMODE:GetItemByKey("magnet").Index, 8)
						net.WriteFloat(self.DieTime - CurTime())
						net.Send(data.HitEntity:GetOwner())
						-- weld
						data.HitEntity:EmitSound("Metal.SawbladeStick")
						constraint.Weld(data.HitEntity, self, 0, 0, 0, 0, false)
					end)
				end
			end
		end
	end

end

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Initialize()
		self.GrowEndTime = CurTime() + 0.25
		self:SetRenderBounds(self:OBBMins(), self:OBBMaxs())
	end

	function ENT:Draw()
		local scale = 0.5 + (1 - math.Clamp((self.GrowEndTime - CurTime()) / 0.25, 0, 1)) * 0.5
		if scale < 1 then
			-- render model
			self:SetModelScale(Vector() * scale)
			self:SetupBones()
			self:DrawModel()
		else
			-- calculate outline width
			local width = math.Clamp((self:GetPos() - EyePos()):Length() - 100, 0, 600)
			width = 1.05 + ((width / MAX_VIEW_DISTANCE) * 0.05)
			self:DrawModelOutlined(Vector() * width)
		end
	end

	function ENT:DrawOnRadar(x, y, a)
		self:RadarDrawRadius(x, y, MAGNET_ATTRACT_RADIUS, color_white_translucent, color_white_translucent2)
		self:RadarDrawCircle(x, y, 5, color_red)
	end
end
