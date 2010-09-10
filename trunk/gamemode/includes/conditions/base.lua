
local BaseCondition = {};


/*------------------------------------
	__index()
------------------------------------*/
function BaseCondition.__index( obj, key )

	// get the key off the object if it exists
	// functions, etc
	local value = rawget( obj, key );
	if( value ) then
		return value;
	end
	
	// fetch off the item table
	local pl = rawget( obj, "Player" );
	if( IsValid( pl ) ) then
	
		return rawget( conditions.GetTable( pl, obj ), key );
	
	end

end


/*------------------------------------
	__newindex()
------------------------------------*/
function BaseCondition.__newindex( obj, key, value )

	// fetch off the item table
	local pl = rawget( obj, "Player" );
	if( IsValid( pl ) ) then
	
		rawset( conditions.GetTable( pl, obj ), key, value );
		
	else
	
		rawset( obj, key, value );
	
	end

end


/*------------------------------------
	Create()
------------------------------------*/
function BaseCondition:Create()

	local obj = table.Inherit( {}, self );
	setmetatable( obj, self );

	// defaults
	obj.Name = "Base";
	obj.Ball = NULL;
	obj.Player = NULL;
	obj.IsCondition = true;
	
	return obj;

end


/*------------------------------------
	Activate()
------------------------------------*/
function BaseCondition:Activate()
end


/*------------------------------------
	Reactivate()
------------------------------------*/
function BaseCondition:Reactivate()

	return false;
	
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function BaseCondition:Deactivate()
end


/*------------------------------------
	Think()
------------------------------------*/
function BaseCondition:Think()

	return false;
	
end


/*------------------------------------
	CreateCondition()
------------------------------------*/
function CreateCondition( key )

	local obj = BaseCondition:Create();
	obj.Key = key;
	
	return obj;

end

