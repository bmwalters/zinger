
// start module
module( 'rules', package.seeall );

// rule variables
local Rules = {};
local CurrentRule;


/*------------------------------------
	Clear()
------------------------------------*/
function Clear()

	// clear table
	CurrentRule = nil;

end


/*------------------------------------
	Call()
------------------------------------*/
function Call( name, ... )

	// make sure we've got our table
	if ( !CurrentRule ) then
	
		// grab a unique copy
		CurrentRule = table.Copy( Rules[ GAMEMODE:GetCurrentRules() ] );
		
	end
	
	// validate event
	if ( CurrentRule[ name ] ) then
	
		if ( SERVER ) then
		
			// pass every event to stats
			stats.Call( name, unpack( arg ) );
			
		end
		
		return CurrentRule[ name ]( CurrentRule, unpack( arg ) );
	
	end
	
	// TODO: add a debug message?
	
end

// server only
if ( SERVER ) then

	/*------------------------------------
		Pick()
	------------------------------------*/
	function Pick()

		GAMEMODE:SetCurrentRules( 1 );

	end

end

// load base rule
include( ("%sbase.lua"):format( PATH_RULES ) );

// load rules
LL( PATH_RULES, nil, "base.lua", function( f, p )

	// extract name
	local _, _, key = string.find( f, "([%w_]*)\.lua" );
	
	// create base
	RULE = CreateRule();
	RULE.Key = key;
	
	// include
	sh_include( ("%s%s"):format( p, f ) );
	
	// add to list
	table.insert( Rules, RULE );
	RULE.Index = #Rules;
	
	RULE = nil;
	
end );

table.insert( Rules, CreateRule() );
