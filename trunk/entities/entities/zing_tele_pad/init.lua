
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()
	
	self:DrawShadow( false );
	self:SetModel( self.Model );
	self:SetSolid( SOLID_BBOX );
	self:SetMoveType( MOVETYPE_NONE );
	self:SetCollisionBounds( self:OBBMins(), self:OBBMaxs() );
	self:SetTrigger( true );
	
	self:SetMaterial( "zinger/models/pad/telepad" );
	
	self.Destinations = {};
	
	local targets = ents.FindByName( self.Destination or "" );
	for k, v in pairs( targets ) do
	
		table.insert( self.Destinations, v:GetPos() );
	
	end
	
	// alert the mapper
	if( #self.Destinations == 0 ) then
	
		Error( self, " at ", self:GetPos(), " has no destinations" );
	
	end
	
end

/*------------------------------------
	GetDestination()
------------------------------------*/
function ENT:GetDestination( ent )

	if( #self.Destinations == 0 ) then
	
		return self:GetPos();
		
	end
	
	return table.Random( self.Destinations );
	
end

/*------------------------------------
	StartTouch()
------------------------------------*/
function ENT:StartTouch( ent )

	if( #self.Destinations == 0 ) then
	
		return;
		
	end

	if( IsBall( ent ) ) then
	
		local height = ( ent:GetPos() - self:GetPos() ).z;
		
		local target = table.Random( self.Destinations );
		
		local phys = ent:GetPhysicsObject();
		if( IsValid( phys ) ) then
		
			local velocity = phys:GetVelocity();
			
			constraint.RemoveConstraints( ent, "Weld" );
			ent:GetOwner():ClearEffect( "magnet" );
		
			ent:SetPos( target + Vector( 0, 0, height ) );
			
			if( self.ZeroVelocity ) then
			
				phys:EnableMotion( false );
				phys:EnableMotion( true );
			
			else
			
				phys:SetVelocity( velocity );
			
			end
			
		end
		
		// effect
		local effect = EffectData();
		effect:SetOrigin( ent:GetPos() );
		effect:SetEntity( ent );
		effect:SetScale( 1.5 );
		util.Effect( "Zinger.Teleport", effect );
		
		rules.Call( "PadTouched", self, ent );
		
	end

end


/*------------------------------------
	KeyValue()
------------------------------------*/
function ENT:KeyValue( key, value )

	if( key == "destination" ) then
	
		self.Destination = value;
		
	elseif( key == "spawnflags" ) then
	
		self.ZeroVelocity = ( value == "1" );
	
	end

	return self.BaseClass.KeyValue( self, key, value );

end


