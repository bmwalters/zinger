local PANEL = {}

local Background = Material("zinger/hud/elements/selecteditem")

function PANEL:Init()
	self.BaseClass.Init(self)

	self:SetSize(210, 210)

	-- create 3D icon
	self.Item = vgui.Create("InventoryIcon", self)
	self.Item:SetMouseInputEnabled(false)
	self.Item:SetSize(180, 180)
	self.Item:SetPos(15, 15)
	self.Item:HideCount()
	self.Item.Run = function(icon)
		-- make it drift
		if icon.Entity then
			icon.Entity:SetAngles(icon.Item.InventoryAngles + Angle(0, 0, math.sin(CurTime()) * 2))
		end
	end

	self.DefaultX = ScrW() - 220
	self.DefaultY = 10
	self.ElementTitle = "Selected Item"
	self.Flag = ELEM_FLAG_ITEMEQUIPPED

	self.LastItem = nil
	self.AlertTime = 0
	self.AlertText = nil

	self:InitDone()
end

function PANEL:Think()
	-- check for a new item
	local item = inventory.Equipped()
	if item ~= self.LastItem then
		self.Item:SetItem(item)
	end

	self.LastItem = item
end

function PANEL:SetAlert(alert)
	self.AlertTime = CurTime() + 3
	self.AlertText = alert

	surface.PlaySound("buttons/button10.wav")
end

function PANEL:Paint(w, h)
	if not self:ShouldPaint() then return end

	-- draw material
	surface.SetMaterial(Background)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(0, 0, 256, 256)

	-- must call
	self.BaseClass.Paint(self, w, h)
end

function PANEL:PaintOver()
	if not self:ShouldPaint() then return end

	-- check for an item
	if self.LastItem then
		DisableClipping(true)

		-- draw item name
		draw.SimpleTextOutlined(self.LastItem.Name, "Zing22", self.MidWidth, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)

		-- draw tip
		if self.LastItem.Tip then
			draw.SimpleTextOutlined(self.LastItem.Tip, "Zing18", self.MidWidth, 185, color_yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		end

		DisableClipping(false)
	end

	if self.AlertTime > CurTime() then
		-- blink
		if math.sin(CurTime() * 12) > 0 then
			-- draw marks on item
			draw.SimpleTextOutlined("! ! !", "Zing52", 105, 105, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)

			DisableClipping(true)

			-- draw in center of screen
			local x, y = self:ScreenToLocal(ScrW() * 0.5, ScrH() * 0.5)
			draw.SimpleTextOutlined(self.AlertText, "Zing52", x, y, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)

			DisableClipping(false)
		end
	end
end

derma.DefineControl("SelectedItem", "", PANEL, "BaseElement")
