
// get entity metatable

local meta = FindMetaTable( "Entity" );
assert( meta, "Unable to find the Entity meta table" );


if ( SERVER ) then

	/*------------------------------------
		EmitSoundTeam()
	------------------------------------*/
	function meta:EmitSoundTeam( t, snd, vol, pitch )
	
		// send data
		umsg.Start( "EmitSoundTeam", util.TeamOnlyFilter( t ) );
			umsg.Entity( self );
			umsg.String( snd );
			umsg.Char( vol );
			umsg.Char( pitch );
		umsg.End();

	end
	
else

	/*------------------------------------
		EmitSoundTeam()
	------------------------------------*/
	local function EmitSoundTeam( msg )

		// read data
		local ent = msg:ReadEntity();
		local snd = msg:ReadString();
		local vol = msg:ReadChar();
		local pitch = msg:ReadChar();
		
		if ( IsValid( ent ) ) then
		
			ent:EmitSound( Sound( snd ), vol, pitch );
		
		end

	end
	usermessage.Hook( "EmitSoundTeam", EmitSoundTeam );

end
