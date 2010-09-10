
module( 'inventory', package.seeall );


if( CLIENT ) then

	local Inventory = {};
	local EquippedItem = nil;
	local InventoryPanel = nil;
	
	
	/*------------------------------------
		Get()
	------------------------------------*/
	function Get()
	
		return Inventory;
	
	end
	

	/*------------------------------------
		Equip()
	------------------------------------*/
	local function Equip( item )
	
		EquippedItem = item;
	
	end
	
	
	/*------------------------------------
		Unequip()
	------------------------------------*/
	local function Unequip()
	
		EquippedItem = nil;
	
	end
	
	
	/*------------------------------------
		Equipped()
	------------------------------------*/
	function Equipped()
	
		return EquippedItem;
	
	end
	
	
	/*------------------------------------
		GetMaxRow()
	------------------------------------*/
	function GetMaxRow()
	
		return items.GetMaxRow();
	
	end

	
	/*------------------------------------
		Show()
	------------------------------------*/
	function Show()
	
		local pl = LocalPlayer();
		if( !IsValid( pl ) ) then
		
			return;
			
		end
		
		if( !IsBall( pl:GetBall() ) ) then
		
			return;
			
		end
		
		if( !InventoryPanel ) then
		
			InventoryPanel = vgui.Create( "Inventory" );
			
		end
		
		InventoryPanel:Show();

	end
	
	
	/*------------------------------------
		Hide()
	------------------------------------*/
	function Hide()
	
		if( InventoryPanel ) then
		
			InventoryPanel:Hide();
			
		end
		
	end
	
	
	/*------------------------------------
		IsVisible()
	------------------------------------*/
	function IsVisible()
	
		if( InventoryPanel ) then
		
			return InventoryPanel:IsVisible();
			
		end
		
		return false;
		
	end
	
	
	/*------------------------------------
		GetPanel()
	------------------------------------*/
	function GetPanel()
	
		return InventoryPanel;
		
	end
	
	
	/*------------------------------------
		GiveItemMessage()
	------------------------------------*/
	local function GiveItemMessage( msg )

		local key = msg:ReadString();
		local count = msg:ReadShort();
		
		local item = items.Get( key );
		if( !item ) then
		
			Error( "Picked up an item that doesn't exist!" );
			
		end
		
		Inventory[ item ] = Inventory[ item ] or 0;
		Inventory[ item ] = Inventory[ item ] + count;

	end
	usermessage.Hook( "GiveItem", GiveItemMessage );


	/*------------------------------------
		TakeItemMessage()
	------------------------------------*/
	local function TakeItemMessage( msg )

		local key = msg:ReadString();
		local count = msg:ReadShort();
		
		local item = items.Get( key );
		if( !item ) then
		
			Error( "Removed an item that doesn't exist!" );
			
		end
		
		Inventory[ item ] = Inventory[ item ] or 0;
		Inventory[ item ] = math.max( 0, Inventory[ item ] - count );
		
		if( Inventory[ item ] <= 0 ) then
		
			Inventory[ item ] = nil;
			
		end

	end
	usermessage.Hook( "TakeItem", TakeItemMessage );
	
	
	/*------------------------------------
		EquipItemMessage()
	------------------------------------*/
	local function EquipItemMessage( msg )

		local key = msg:ReadString();
		
		local item = items.Get( key );
		if( !item ) then
		
			Error( "Equipped an item that doesn't exist!" );
			
		end
		
		Equip( item );
		
	end
	usermessage.Hook( "EquipItem", EquipItemMessage );


	/*------------------------------------
		UnequipItemMessage()
	------------------------------------*/
	local function UnequipItemMessage( msg )
		
		Unequip();

	end
	usermessage.Hook( "UnequipItem", UnequipItemMessage );
	
end


/*------------------------------------
	Install()
------------------------------------*/
function Install( pl )

	if( SERVER ) then
	
		pl.Inventory = {};
		pl.EquippedItem = nil;
		pl.EquippedItemActive = false;
		
	end
		
end
	

if( SERVER ) then

	/*------------------------------------
		Get()
	------------------------------------*/
	function Get( pl )
	
		if( IsValid( pl ) ) then
		
			return pl.Inventory;
			
		end
	
	end
	
	
	/*------------------------------------
		Equipped()
	------------------------------------*/
	function Equipped( pl )
	
		if( IsValid( pl ) ) then
		
			return pl.EquippedItem;
			
		end
	
	end
	

	/*------------------------------------
		Give()
	------------------------------------*/
	function Give( pl, item, count )
	
		count = count or 1;
	
		// no funny business
		if( !IsValid( pl ) || !item || count <= 0 ) then
		
			return;
			
		end

		pl.Inventory[ item ] = pl.Inventory[ item ] or 0;
		pl.Inventory[ item ] = pl.Inventory[ item ] + count;
		
		// replicate to the client
		umsg.Start( "GiveItem", pl );
		umsg.String( item.Key );
		umsg.Short( count );
		umsg.End();
		
	end


	/*------------------------------------
		Take()
	------------------------------------*/
	function Take( pl, item, count )

		count = count or 1;
		
		// no funny business
		if( !IsValid( pl ) || !item || count <= 0 ) then
		
			return;
			
		end

		pl.Inventory[ item ] = pl.Inventory[ item ] or 0;
		pl.Inventory[ item ] = math.max( 0, pl.Inventory[ item ] - count );
		
		if( pl.Inventory[ item ] == 0 ) then
		
			pl.Inventory[ item ] = nil;
			
		end
		
		// replicate to the client
		umsg.Start( "TakeItem", pl );
		umsg.String( item.Key );
		umsg.Short( count );
		umsg.End();
		
	end
		

	/*------------------------------------
		Equip()
	------------------------------------*/
	function Equip( pl, item )
	
		if( !IsValid( pl ) || !item ) then
		
			return;
			
		end

		local count = pl.Inventory[ item ];
		if( !count || count <= 0 ) then
		
			return;
		
		end

		// we can't change weapons if we have something out that is active
		// such as the uzi, etc.
		if( pl.EquippedItemActive ) then
		
			return;
			
		end
		
		items.ResetTable( pl, item );
		pl:DeactivateViewModel();
		
		// call equip event for the item
		// lets it override stuff, or whatever
		items.Call( pl, item, "Equip" );
				
		// activate the view model if we have one
		if( item.ViewModel ) then
		
			pl:ActivateViewModel( item.ViewModel, item.ViewModelSkin or 0, item.ViewModelPitchLock or false );
			
		end
		
		pl.EquippedItem = item;
		
		// replicate to the client
		umsg.Start( "EquipItem", pl );
		umsg.String( item.Key );
		umsg.End();
		
	end


	/*------------------------------------
		Unequip()
	------------------------------------*/
	function Unequip( pl )
	
		if( !IsValid( pl ) ) then
		
			return;
			
		end

		// remove the view model
		pl:DeactivateViewModel();
		
		pl.EquippedItem = nil;
		pl.EquippedItemActive = false;
		
		// replicate to the client
		umsg.Start( "UnequipItem", pl );
		umsg.End();

	end


	/*------------------------------------
		Activate()
	------------------------------------*/
	function Activate( pl )

		if( !IsValid( pl ) || !pl.EquippedItem || pl.EquippedItemActive ) then
		
			return;
		
		end
		
		// attempt to activate the item
		local override = items.Call( pl, pl.EquippedItem, "Activate" );
		if( override == true ) then
		
			return;
			
		end
		
		pl.EquippedItemActive = true;
		
		// deduct one from the item count
		Take( pl, pl.EquippedItem, 1 );

	end
	
		
	/*------------------------------------
		Think()
	------------------------------------*/
	function Think( pl )

		// handle deactivation of the equipped item
		if( pl.EquippedItem && pl.EquippedItemActive ) then
		
			local finished = items.Call( pl, pl.EquippedItem, "Think" );
			if( finished != true ) then
			
				items.Call( pl, pl.EquippedItem, "Deactivate" );
				
				// it's gone, unequip it
				Unequip( pl );

			end
		
		end

	end

end