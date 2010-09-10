
local Conditions = {};


// load up the base item because things need it
include( ("%sbase.lua"):format( PATH_CONDITIONS ) );

// load up the remaining conditions
LL( PATH_CONDITIONS, "*.lua", nil, function( f, p )

	local filename = ("%s%s"):format( p, f );

	if( f == "base.lua" ) then
	
		if( SERVER ) then
			AddCSLuaFile( filename );
		end
		return;
		
	end
	
	local _, _, key = string.find( f, "([%w_]*)\.lua" );

	CONDITION = CreateCondition( key );
		
	sh_include( filename );

	Conditions[ key ] = CONDITION;
	CONDITION = nil;
	
end );


// conditions module
module( 'conditions', package.seeall );


/*------------------------------------
	Call()
------------------------------------*/
function Call( pl, condition, func, ... )

	// validate function
	if( !condition || !condition[ func ] ) then
	
		return;
		
	end

	local ball = pl:GetBall();
	if( !IsValid( ball ) ) then
	
		return;
		
	end


	rawset( condition, "Ball", ball );
	rawset( condition, "Player", pl );
	
	// call the function
	local status, ret = pcall( condition[ func ], condition, ... );
	
	// cleanup for the next call
	rawset( condition, "Player", nil );
	
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

	return Conditions[ key ];

end


/*------------------------------------
	GetAll()
------------------------------------*/
function GetAll()

	return Conditions;
	
end


/*------------------------------------
	Install()
------------------------------------*/
function Install( pl )
	
	if( SERVER ) then
	
		pl.ConditionData = {};
		pl.ActiveConditions = {};
		
	end
		
end


if( SERVER ) then

	/*------------------------------------
		GetTable()
	------------------------------------*/
	function GetTable( pl, condition )

		pl.ConditionData[ condition ] = pl.ConditionData[ condition ] or {};
		
		return pl.ConditionData[ condition ];

	end


	/*------------------------------------
		ResetTable()
	------------------------------------*/
	function ResetTable( pl, condition )

		pl.ConditionData[ condition ] = {};
			
	end

end
