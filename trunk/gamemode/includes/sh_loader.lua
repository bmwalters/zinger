
// base path
PATH_BASE 						= "zinger/gamemode/";


/*------------------------------------
	_L
------------------------------------*/
local function _L( func, path, files, ignore, callback )
	
	// load all files by default
	files = files || "*";
	
	// gather files
	local filelist = func( ("%s%s"):format( path, files ) );
	for _, f in pairs( filelist ) do
	
		if ( f == "." || f == ".." || f == ".svn" ) then
		
			// ignore
		
		elseif ( !ignore ) then
		
			// call
			callback( f, path );
			
		else
		
			if ( type( ignore ) == "string" && ignore != f  ) then
			
				// call
				callback( f, path );
				
			elseif ( type( ignore ) == "table" && !table.HasValue( ignore, f ) ) then
			
				// call
				callback( f, path );
			
			end
		
		end
		
	end
	
end


/*------------------------------------
	LL
------------------------------------*/
function LL( path, files, ignore, callback )

	_L( file.FindInLua, path, files, ignore, callback );

end


/*------------------------------------
	L
------------------------------------*/
function L( path, files, ignore, callback )

	_L( file.Find, path, files, ignore, callback );

end


/*------------------------------------
	sh_include
------------------------------------*/
function sh_include( f )

	// server should send to client, too
	if ( SERVER ) then
	
		AddCSLuaFile( f );
		
	end
	
	include( f );

end


// load enums
LL( ("%sincludes/enum/"):format( PATH_BASE ), nil, nil, function( f, p )
	
	// include
	sh_include( ("%s%s"):format( p, f ) );

end );
