local BaseItem = {}

function BaseItem.__index(obj, k)
	-- get the key off the object if it exists
	-- functions, etc
	local value = rawget(obj, k) or BaseItem[k]
	if value then
		return value
	end

	-- fetch off the item table
	local ply = rawget(obj, "Player")
	if IsValid(ply) then
		return rawget(items.GetTable(ply, obj), k)
	end
end

function BaseItem.__newindex(obj, k, v)
	-- fetch off the item table
	local ply = rawget(obj, "Player")
	if IsValid(ply) then
		rawset(items.GetTable(ply, obj), k, v)
	else
		rawset(obj, k, v)
	end
end

function BaseItem:Create()
	local obj = setmetatable({}, self)

	-- defaults
	obj.Name = "Base"
	obj.Description = "none"
	obj.ViewModelSkin = 0
	obj.Ball = NULL
	obj.Player = NULL
	obj.IsItem = true

	return obj
end

function BaseItem:Initialize()
	self.ConVar = CreateConVar("zing_item_" .. self.Key, "0", FCVAR_NONE)
end

function BaseItem:Activate()
end

function BaseItem:Deactivate()
end

function BaseItem:Think()
	return false
end

function BaseItem:GetTrace()
	-- we use an 80 degree fov
	-- we need to set it before tracing otherwise the trace will be off
	self.Player:SetFOV(80)

	local tr = util.TraceLine({
		start = self.Player:GetPos(),
		endpos = self.Player:GetPos() + self.Player:GetCursorVector() * 4096,
		filter = self.Player,
	})

	return tr
end

function BaseItem:GetWeaponPosition()
	return self.Ball:GetWeaponPosition()
end

function BaseItem:GetViewModel()
	return self.Ball.dt.ViewModel
end

function BaseItem:GetAimVector()
	return self.Ball.AimVec
end

function BaseItem:ItemAlert(message)
	self.Player:ItemAlert(message)
end

function BaseItem:Notify(players)
	net.Start("Zing_AddNotfication")
		net.WriteUInt(NOTIFY_ITEMACTION, 4)
		net.WriteEntity(self.Player)
		net.WriteString(self.Key)
	net.Send(players)
end

function BaseItem:SetViewModelAnimation(anim, speed)
	return self.Player:SetViewModelAnimation(anim, speed)
end

function CreateItem(key)
	local obj = BaseItem:Create()
	obj.Key = key

	obj:Initialize()

	return obj
end
