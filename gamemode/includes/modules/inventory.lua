module("inventory", package.seeall)

if CLIENT then
	local Inventory = {}
	local EquippedItem = nil
	local InventoryPanel = nil

	function Get()
		return Inventory
	end

	local function Equip(item)
		EquippedItem = item
	end

	local function Unequip()
		EquippedItem = nil
	end

	function Equipped()
		return EquippedItem
	end

	function GetMaxRow()
		return items.GetMaxRow()
	end

	function Show()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		if not IsBall(ply:GetBall()) then return end

		if not InventoryPanel then
			InventoryPanel = vgui.Create("Inventory")
		end

		InventoryPanel:Show()
	end

	function Hide()
		if InventoryPanel then
			InventoryPanel:Hide()
		end
	end

	function IsVisible()
		if InventoryPanel then
			return InventoryPanel:IsVisible()
		end

		return false
	end

	function GetPanel()
		return InventoryPanel
	end

	local function GiveItemMessage()
		local key = net.ReadString()
		local count = net.ReadUInt(8)

		local item = items.Get(key)
		if not item then
			Error("Picked up an item that doesn't exist!")
		end

		Inventory[item] = Inventory[item] or 0
		Inventory[item] = Inventory[item] + count
	end
	net.Receive("Zing_GiveItem", GiveItemMessage)

	local function TakeItemMessage()
		local key = net.ReadString()
		local count = net.ReadUInt(8)

		local item = items.Get(key)
		if not item then
			Error("Removed an item that doesn't exist!")
		end

		Inventory[item] = Inventory[item] or 0
		Inventory[item] = math.max(0, Inventory[item] - count)

		if Inventory[item] <= 0 then
			Inventory[item] = nil
		end
	end
	net.Receive("Zing_TakeItem", TakeItemMessage)

	local function EquipItemMessage()
		local key = net.ReadString()

		local item = items.Get(key)
		if not item then
			Error("Equipped an item that doesn't exist!")
		end

		Equip(item)
	end
	net.Receive("Zing_EquipItem", EquipItemMessage)

	net.Receive("Zing_UnequipItem", Unequip)
end

function Install(ply)
	if SERVER then
		ply.Inventory = {}
		ply.EquippedItem = nil
		ply.EquippedItemActive = false
	end
end

if(SERVER) then
	function Get(ply)
		if IsValid(ply) then
			return ply.Inventory
		end
	end

	function Equipped(ply)
		if IsValid(ply) then
			return ply.EquippedItem
		end
	end

	function Give(ply, item, count)
		count = count or 1

		-- no funny business
		if (not IsValid(ply)) or (not item) or count <= 0 then return end

		ply.Inventory[item] = ply.Inventory[item] or 0
		ply.Inventory[item] = ply.Inventory[item] + count

		-- replicate to the client
		net.Start("Zing_GiveItem")
			net.WriteString(item.Key)
			net.WriteUInt(count, 8)
		net.Send(ply)
	end

	function Take(ply, item, count)
		count = count or 1

		-- no funny business
		if (not IsValid(ply)) or (not item) or count <= 0 then return end

		ply.Inventory[item] = ply.Inventory[item] or 0
		ply.Inventory[item] = math.max(0, ply.Inventory[item] - count)

		if ply.Inventory[item] == 0 then
			ply.Inventory[item] = nil
		end

		-- replicate to the client
		net.Start("Zing_TakeItem")
			net.WriteString(item.Key)
			net.WriteUInt(count, 16)
		net.Send(ply)
	end

	function Equip(ply, item)
		if not IsValid(ply) or not item then return end

		local count = ply.Inventory[item]
		if not count or count <= 0 then return end

		-- we can't change weapons if we have something out that is active
		-- such as the uzi, etc.
		if ply.EquippedItemActive then return end

		items.ResetTable(ply, item)
		ply:DeactivateViewModel()

		-- call equip event for the item
		-- lets it override stuff, or whatever
		items.Call(ply, item, "Equip")

		-- activate the view model if we have one
		if item.ViewModel then
			ply:ActivateViewModel(item.ViewModel, item.ViewModelSkin or 0, item.ViewModelPitchLock or false)
		end

		ply.EquippedItem = item

		-- replicate to the client
		net.Start("Zing_EquipItem")
			net.WriteString(item.Key)
		net.Send(ply)
	end

	function Unequip(ply)
		if not IsValid(ply) then return end

		-- remove the view model
		ply:DeactivateViewModel()

		ply.EquippedItem = nil
		ply.EquippedItemActive = false

		-- replicate to the client
		net.Start("Zing_UnequipItem")
		net.Send(ply)
	end

	function Activate(ply)
		if not IsValid(ply) or not ply.EquippedItem or ply.EquippedItemActive then return end

		-- attempt to activate the item
		local override = items.Call(ply, ply.EquippedItem, "Activate")
		if override == true then return end

		ply.EquippedItemActive = true

		-- deduct one from the item count
		Take(ply, ply.EquippedItem, 1)
	end

	function Think(ply)
		-- handle deactivation of the equipped item
		if ply.EquippedItem and ply.EquippedItemActive then
			local finished = items.Call(ply, ply.EquippedItem, "Think")
			if finished ~= true then
				items.Call(ply, ply.EquippedItem, "Deactivate")

				-- it's gone, unequip it
				Unequip(ply)
			end
		end
	end
end
