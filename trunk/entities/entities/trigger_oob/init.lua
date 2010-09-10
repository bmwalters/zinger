
ENT.Type = "brush";
ENT.BaseClass = "base_brush";

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize( )

	self:SetTrigger( true );
	
end

/*------------------------------------
	StartTouch()
------------------------------------*/
function ENT:StartTouch( ent )

	if( IsBall( ent ) ) then
	
		if( self.TreatAsWater ) then
		
			ent.MakeWaterSplash = true;
			
		end
		
		rules.Call( "OutOfBounds", ent );
	
	end

end

/*------------------------------------
	KeyValue()
------------------------------------*/
function ENT:KeyValue( key, value )

	if( key == "spawnflags" ) then
	
		self.TreatAsWater = util.tobool( value );
	
	end

end

