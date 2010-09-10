
local Items = {};
local NumItems = 0;
local MaxRow = 0;


// load up the base item because things need it
include( ("%sbase.lua"):format( PATH_ITEMS ) );

// load up the remaining items
LL( PATH_ITEMS, "*.lua", nil, function( f, p )

	local filename = ("%s%s"):format( p, f );

	if( f == "base.lua" ) then
	
		if( SERVER ) then
			AddCSLuaFile( filename );
		end
		return;
		
	end
	
	local _, _, key = string.find( f, "([%w_]*)\.lua" );

	ITEM = CreateItem( key );
		
	sh_include( filename );
	
	// precache
	if ( ITEM.InventoryModel ) then
	
		ITEM.InventoryModel = Model( ITEM.InventoryModel );
		
	end
	if ( ITEM.ViewModel ) then
	
		ITEM.ViewModel = Model( ITEM.ViewModel );
		
	end
	
	if ( CLIENT ) then
	
		if( ITEM.InventoryRow ) then
		
			MaxRow = math.max( MaxRow, ITEM.InventoryRow );
			
		end
		
		if ( ITEM.Help ) then
		
			GM:CreateHelpTopic( "Items", ITEM.Name, ITEM.Help .. "\n" );
		
		end
		
	end

	Items[ key ] = ITEM;
	ITEM = nil;
	
	NumItems = NumItems + 1;

end );


// items module
module( 'items', package.seeall );


/*------------------------------------
	Call()
------------------------------------*/
function Call( pl, item, func, ... )

	// validate function
	if( !item || !item[ func ] ) then
	
		return;
		
	end

	local ball = pl:GetBall();
	if( !IsValid( ball ) ) then
	
		return;
		
	end


	rawset( item, "Ball", ball );
	rawset( item, "Player", pl );
	
	// call the function
	local status, ret = pcall( item[ func ], item, ... );
	
	// cleanup for the next call
	rawset( item, "Player", nil );
	
	if( status == true && ret != nil ) then
	
		return ret;
		
	elseif( status == false ) then
	
		Error( ret );
		
	end
	
end


/*------------------------------------
	Get()
------------------------------------*/
function Get( key )

	return Items[ key ];

end


/*------------------------------------
	GetCount()
------------------------------------*/
function GetCount()

	return NumItems;

end


/*------------------------------------
	GetMaxRow()
------------------------------------*/
function GetMaxRow()

	return MaxRow;

end


/*------------------------------------
	Random()
------------------------------------*/
function Random()

	if( table.Count( Items ) < 0 ) then
	
		return;
		
	end

	return table.Random( Items );
	
end


/*------------------------------------
	GetAll()
------------------------------------*/
function GetAll()

	return Items;
	
end


/*------------------------------------
	Install()
------------------------------------*/
function Install( pl )
	
	if( SERVER ) then
	
		pl.ItemData = {};
		pl.ActiveItems = {};
		
	end
		
end


if( SERVER ) then

	/*------------------------------------
		GetTable()
	------------------------------------*/
	function GetTable( pl, item )

		pl.ItemData[ item ] = pl.ItemData[ item ] or {};
		
		return pl.ItemData[ item ];

	end


	/*------------------------------------
		ResetTable()
	------------------------------------*/
	function ResetTable( pl, item )

		pl.ItemData[ item ] = {};
			
	end

	
	/*------------------------------------
		SpawnCrate()
	------------------------------------*/
	function SpawnCrate()
		
		// get node and radius
		local node = GAMEMODE:GetRandomSupplyNode();
		if( !IsValid( node ) ) then
		
			Error( "tryed to spawn items on a map with no supply nodes" );
			return;
			
		end
		
		local radius = node:SpawnRadius();
		
		// find a random point that is not out of bounds and spawn an item there
		// (incase the mapper fucked up, only give it 50 tries - Brandon)
		for i = 1, 50 do
		
			local angle = math.rad( math.random( 0, 360 ) );
			local dir = Vector( math.cos( angle ), math.sin( angle ), 0 );
			
			local pos = node:GetPos() + dir * math.random( radius * 0.25, radius );
			
			// trace down to see if its inbounds
			local tr = util.TraceHull( {
				start = pos + Vector( 0, 0, radius ),
				endpos = pos - Vector( 0, 0, radius ),
				mins = Vector( -16, -16, -16 ),
				maxs = Vector( 16, 16, 16 ),
			} );
			if( tr.HitWorld && !IsOOB( tr ) && !IsSpaceOccupied( tr.HitPos, Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) ) ) then
			
				local ent = ents.Create( "zing_crate" );
				ent:Spawn();
				ent:SetPos( tr.HitPos );
						
				break;
			
			end
		
		end

	end

end
