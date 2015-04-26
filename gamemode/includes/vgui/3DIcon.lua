local PANEL = {}

local BlackModelSimple = Material("black_outline")

AccessorFunc(PANEL, "Distance", "Distance", FORCE_NUMBER)
AccessorFunc(PANEL, "Outline", "Outline", FORCE_NUMBER)
AccessorFunc(PANEL, "AnimationSpeed", "AnimationSpeed", FORCE_NUMBER)

function PANEL:Init()
	self:SetViewDistance(45)
	self:SetOutline(0)

	self.Entity = nil
	self:SetAnimationSpeed(0)
	self.LastPaint = 0
end

function PANEL:SetModel(model)
	-- create
	self.Entity = ClientsideModel(Model(model), RENDER_GROUP_OPAQUE_ENTITY)
	self.Entity:SetNoDraw(true)
	self.Entity:SetPos(vector_origin)
	self.Entity:SetAngles(Angle(0, 0, 0))
end

function PANEL:OnRemove()
	self.Entity:Remove() -- -Zerf
end

function PANEL:SetViewDistance(dist)
	-- setup render view position
	self.ViewPos = Vector(dist, 0, 0)
	self.ViewAng = (vector_origin - self.ViewPos):Angle()
end

function PANEL:SetOffset(pos)
	self.Entity:SetPos(pos)
end

function PANEL:SetAngles(ang)
	self.Entity.Angles = ang
	self.Entity:SetAngles(ang)
end

function PANEL:Think()
	if self:GetAnimationSpeed() > 0 then
		self.Entity:FrameAdvance((RealTime() - self.LastPaint) * self:GetAnimationSpeed())
	end

	self:Run()
end

function PANEL:Run()
end

function PANEL:Paint(w, h)
	local p = self:GetParent()
	if p.ShouldPaint and not p:ShouldPaint() then return end

	self.LastPaint = RealTime()

	-- validate
	if not IsValid(self.Entity) then return end

	-- setup renderer
	render.SuppressEngineLighting(true)
	render.SetLightingOrigin(Vector(256, 0, 0))
	render.ResetModelLighting(0, 0, 0)
	render.SetModelLighting(BOX_FRONT, 1, 1, 1)
	render.SetModelLighting(BOX_TOP, 1, 1, 1)
	render.SetColorModulation(1, 1, 1)

	-- get position
	local x, y = self:LocalToScreen(0, 0)

	-- start camera
	cam.Start3D(self.ViewPos, self.ViewAng, 80, x, y, w, h)
		if self:GetOutline() > 0 then
			render.MaterialOverride(BlackModelSimple)

			self.Entity:SetModelScale(Vector() * self:GetOutline())
			self.Entity:SetupBones()
			self.Entity:DrawModel()

			-- reset everything
			render.MaterialOverride()
			self.Entity:SetModelScale(Vector() * 1)
			self.Entity:SetupBones()
		end

		local col = self.Entity:GetColor()
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)

		self.Entity:DrawModel()

		render.SetColorModulation(1, 1, 1)
	cam.End3D()

	-- reset view
	cam.Start3D(GAMEMODE.LastSceneOrigin, GAMEMODE.LastSceneAngles)
	cam.End3D()

	-- reset lighting
	render.SuppressEngineLighting(false)
end

derma.DefineControl("3DIcon", "", PANEL, "DPanel")
