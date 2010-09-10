
local BaseItem = {};


/*------------------------------------
	__index()
------------------------------------*/
function BaseItem.__index( obj, key )

	// get the key off the object if it exists
	// functions, etc
	local value = rawget( obj, key );
	if( value ) then
		return value;
	end
	
	// fetch off the item table
	local pl = rawget( obj, "Player" );
	if( IsValid( pl ) ) then
	
		return rawget( items.GetTable( pl, obj ), key );
	
	end

end


/*------------------------------------
	__newindex()
------------------------------------*/
function BaseItem.__newindex( obj, key, value )

	// fetch off the item table
	local pl = rawget( obj, "Player" );
	if( IsValid( pl ) ) then
	
		rawset( items.GetTable( pl, obj ), key, value );
		
	else
	
		rawset( obj, key, value );
	
	end

end


/*------------------------------------
	Create()
------------------------------------*/
function BaseItem:Create()

	local obj = table.Inherit( {}, self );
	setmetatable( obj, self );

	// defaults
	obj.Name = "Base";
	obj.Description = "none";
	obj.ViewModelSkin = 0;
	obj.Ball = NULL;
	obj.Player = NULL;
	obj.IsItem = true;
	
	return obj;

end


/*------------------------------------
	Initialize()
------------------------------------*/
function BaseItem:Initialize()

	self.ConVar = CreateConVar( "zing_item_" .. self.Key, "0", FCVAR_NONE );

end


/*------------------------------------
	Activate()
------------------------------------*/
function BaseItem:Activate()
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function BaseItem:Deactivate()
end


/*------------------------------------
	Think()
------------------------------------*/
function BaseItem:Think()

	return false;
	
end


/*------------------------------------
	GetTrace()
------------------------------------*/
function BaseItem:GetTrace()

	// we use an 80 degree fov
	// we need to set it before tracing otherwise the trace will be off
	self.Player:SetFOV( 80 );
	
	local tr = util.TraceLine( {
		start = self.Player:GetPos(),
		endpos = self.Player:GetPos() + self.Player:GetCursorVector() * 4096,
		filter = self.Player,
	
	} );

	return tr;

end


/*------------------------------------
	GetWeaponPosition()
------------------------------------*/
function BaseItem:GetWeaponPosition()

	return self.Ball:GetWeaponPosition();

end


/*------------------------------------
	GetViewModel()
------------------------------------*/
function BaseItem:GetViewModel()

	return self.Ball.dt.ViewModel;

end


/*------------------------------------
	GetAimVector()
------------------------------------*/
function BaseItem:GetAimVector()

	return self.Ball.AimVec;

end


/*------------------------------------
	ItemAlert()
------------------------------------*/
function BaseItem:ItemAlert( message )

	self.Player:ItemAlert( message );

end


/*------------------------------------
	Notify()
------------------------------------*/
function BaseItem:Notify( filter )

	umsg.Start( "AddNotfication", filter );
		umsg.Char( NOTIFY_ITEMACTION );
		umsg.Entity( self.Player );
		umsg.String( self.Key );
	umsg.End();

end


/*------------------------------------
	SetViewModelAnimation()
------------------------------------*/
function BaseItem:SetViewModelAnimation( anim, speed )

	return self.Player:SetViewModelAnimation( anim, speed );

end


/*------------------------------------
	CreateItem()
------------------------------------*/
function CreateItem( key )

	local obj = BaseItem:Create();
	obj.Key = key;
	
	obj:Initialize();
	
	return obj;

end

