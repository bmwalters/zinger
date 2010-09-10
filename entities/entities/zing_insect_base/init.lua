
// download files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );

// shared file
include( 'shared.lua' );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	// setup
	self:SetMoveType( MOVETYPE_NOCLIP );
	self:DrawShadow( false );
	
	// default delays
	self.NextTargetTime = CurTime() + math.random( 6, 12 );
	self.NextPositionTime = CurTime() + math.random( 0.5, 1.5 );
	
	// storage
	self.Target = NULL;
	self.Offset = Vector();

end


/*------------------------------------
	GetTargets()
------------------------------------*/
function ENT:GetTargets()

	// generate a list of entities we can select from
	local entities = {};
	table.Add( entities, ents.FindByClass( "zing_ball" ) );
	table.Add( entities, ents.FindByClass( "zing_shroom" ) );
	table.Add( entities, ents.FindByClass( "zing_shrub" ) );
	table.Add( entities, ents.FindByClass( "zing_ring" ) );
	table.Add( entities, ents.FindByClass( "zing_cup" ) );
	table.Add( entities, ents.FindByClass( "zing_crate" ) );
	
	// cycle through entities
	for i = #entities, 1, -1 do
	
		local ent = entities[ i ];
	
		// measure distance
		if( ( ( ent:GetPos() - self:GetPos() ):Length() ) > INSECT_MAX_RANGE ) then

			// remove from choices
			table.remove( entities, i );
		
		end
	
	end
	
	return entities;

end


/*------------------------------------
	OnNewOffset()
------------------------------------*/
function ENT:OnNewOffset()
end


/*------------------------------------
	OnNewTarget()
------------------------------------*/
function ENT:OnNewTarget()
end


/*------------------------------------
	MoveToTarget()
------------------------------------*/
function ENT:MoveToTarget( target )
end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// get current target
	local target = self.Target;
	
	// time to change position
	if( self.NextPositionTime <= CurTime() ) then
	
		// delay next position change
		self.NextPositionTime = CurTime() + math.random( 1, 3 );
		
		// validate target
		if( IsValid( target ) ) then
		
			// get a new offset
			self.Offset = VectorRand() * target:BoundingRadius() * math.Rand( 1.1, 2.1 );
			self.Offset.z = math.abs( self.Offset.z ) + 8;
			
			// call event
			self:OnNewOffset();
		
		end
		
	end
	
	// time to change target
	if( self.NextTargetTime <= CurTime() ) then
	
		// set delay
		self.NextTargetTime = CurTime() + math.random( 2, 6 );
		
		// get targets
		local entities = self:GetTargets();
		
		if( #entities > 0 ) then
	
			// now pick a random target
			self.Target = table.Random( entities );
			if ( self.Target != target ) then
			
				self:OnNewTarget();
			
			end
			
		end
			
	end
	
	// validate target
	if( IsValid( target ) ) then
	
		// move
		self:MoveToTarget( target );
		
	else
	
		// find another target
		self.NextTargetTime = CurTime();
		
	end
	
	self:NextThink( CurTime() );
	return true;

end
