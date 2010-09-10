
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
	GetApexPosition()
------------------------------------*/
function ENT:GetApexPosition()

	local pos = self:GetPos();
	local target = table.Random( self.Destinations );
			
	// apex height
	local apexHeight = ( self.Height or math.max( 128, ( ( pos - target ):Length() * 0.25 ) ) );
		
	// find the mid point
	local midPoint = ( pos + target ) * 0.5;	
	midPoint.z = midPoint.z + apexHeight;
	
	debugoverlay.Box( midPoint, Vector() * -16, Vector() * 16, 5, Color( 0, 255, 0, 255 ) );
	
	return midPoint;

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
	
		local phys = ent:GetPhysicsObject();
		if( IsValid( phys ) ) then
	
			local pos = ent:GetPos();
			local target = table.Random( self.Destinations );
			
			// apex height
			local apexHeight = ( self.Height or math.max( 128, ( ( pos - target ):Length() * 0.25 ) ) );
				
			// find the mid point
			local midPoint = ( pos + target ) * 0.5;	
			midPoint.z = midPoint.z + apexHeight;

			// debug
			debugoverlay.Line( pos, midPoint, 2, color_white );
			debugoverlay.Line( midPoint, target, 2, color_white );
			debugoverlay.Cross( midPoint, 8, 2, color_black );
			debugoverlay.Cross( pos, 8, 2, color_black );
			debugoverlay.Cross( target, 8, 2, color_black );
						
			// how high do we travel to reac the apex?
			local dist1 = midPoint.z - pos.z;
			local dist2 = midPoint.z - target.z;
			
			// how long will it take to travel the distance
			local time1 = math.sqrt( dist1 / ( 0.5 * 600 ) );
			local time2 = math.sqrt( dist2 / ( 0.5 * 600 ) );
			if( time1 < 0.1 ) then
			
				return;
				
			end
			
			// calculate the launch force required
			local force = ( target - pos ) / ( time1 + time2 );
			force.z = 600 * time1;
		
			// fling the ball toward the target
			local phys = ent:GetPhysicsObject();
			if( IsValid( phys ) ) then
			
				// re-enable this when they land or impact something in the air
				local linear, angular = phys:GetDamping();
				ent.HasJumped = true;
				ent.DampingLinear = linear;
				ent.DampingAngular = angular;
			
				phys:EnableDrag( false );
				phys:SetDamping( 0, 0 );
				phys:SetVelocity( force );
			
			end
			
			local effect = EffectData();
			effect:SetEntity( ent );
			effect:SetOrigin( ent:GetPos() );
			util.Effect( "Zinger.Jump", effect );
			
			rules.Call( "PadTouched", self, ent );
			//self:EmitSound( "zinger/boing.wav" );
					
		end
		
	end

end


/*------------------------------------
	KeyValue()
------------------------------------*/
function ENT:KeyValue( key, value )

	if( key == "destination" ) then
	
		self.Destination = value;
		
	elseif( key == "height" ) then
	
		self.Height = tonumber( value );
	
	end

	return self.BaseClass.KeyValue( self, key, value );

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	local pos = self:GetPos();
	
	for k, v in pairs( self.Destinations ) do
	
		local target = v;
		
		// apex height
		local apexHeight = ( self.Height or math.max( 128, ( ( pos - target ):Length() * 0.25 ) ) );
			
		// find the mid point
		local midPoint = ( pos + target ) * 0.5;	
		midPoint.z = midPoint.z + apexHeight;
		
		// debug
		local color_grey = Color( 40, 40, 40, 255 );
		debugoverlay.Line( pos, midPoint, 1.05, color_grey );
		debugoverlay.Line( midPoint, target, 1.05, color_grey );
		debugoverlay.Cross( midPoint, 8, 1.05, color_black );
		debugoverlay.Cross( pos, 8, 1.05, color_black );
		debugoverlay.Cross( target, 8, 1.05, color_black );
		
	end

	self:NextThink( CurTime() + 1 );
	return true;

end