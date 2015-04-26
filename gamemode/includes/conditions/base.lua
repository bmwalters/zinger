local BaseCondition = {}

function BaseCondition.__index(obj, k)
	-- get the key off the object if it exists
	-- functions, etc
	local value = rawget(obj, k) or BaseCondition[k]
	if value then
		return value
	end

	-- fetch off the item table
	local ply = rawget(obj, "Player")
	if IsValid(ply) then
		return rawget(conditions.GetTable(ply, obj), k)
	end
end

function BaseCondition.__newindex(obj, k, v)
	-- fetch off the item table
	local ply = rawget(obj, "Player")
	if IsValid(ply) then
		rawset(conditions.GetTable(ply, obj), k, v)
	else
		rawset(obj, k, v)
	end
end

function BaseCondition:Create()
	local obj = setmetatable({}, self)

	-- defaults
	obj.Name = "Base"
	obj.Ball = NULL
	obj.Player = NULL
	obj.IsCondition = true

	return obj
end

function BaseCondition:Activate()
end

function BaseCondition:Reactivate()
	return false
end

function BaseCondition:Deactivate()
end

function BaseCondition:Think()
	return false
end

function CreateCondition(key)
	local obj = BaseCondition:Create()
	obj.Key = key

	return obj
end
