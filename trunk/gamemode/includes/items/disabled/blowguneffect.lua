
ITEM.Name		= "Blow Dart";
ITEM.Description	= "";
ITEM.IsEffect		= true;
ITEM.IsTimed		= true;
ITEM.IsUseable		= false;
ITEM.Duration 		= 30;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/blowgun" );
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration;
	
	if ( CLIENT ) then
	
		self.Percent = 0;
		
	end
	
	if ( SERVER ) then
	
		self.Player:SetDSP( 25, false );
	
	end
	
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function ITEM:Deactivate()

	if ( SERVER ) then
	
		self.Player:SetDSP( 1, false );
		
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.Data.EndTime && self.Data.EndTime > CurTime();

end


if ( CLIENT ) then

	/*------------------------------------
		CalcView()
	------------------------------------*/
	function ITEM:CalcView( view )
	
		local rem = self.Data.EndTime - CurTime();
		
		local target = ( rem < 5.5 ) && 0 || 1;
		
		self.Percent = math.Approach( self.Percent, target, FrameTime() * 0.25 );
	
		local fov = ( math.sin( CurTime() * 1 ) * 15 ) * self.Percent;
		local ang = Angle( math.sin( CurTime() * 1 ) * 8, math.sin( CurTime() * 2 ) * 4, math.sin( CurTime() * 1.5 ) * 6 ) * self.Percent;
		
		view.fov = 80 + fov;
		view.angles = view.angles + ang;
			
	end
	
	/*------------------------------------
		RenderScreenspaceEffects()
	------------------------------------*/
	function ITEM:RenderScreenspaceEffects()
		
		DrawBloom( 0, 0.4 * self.Percent, 1, 1, 1, 1, 1, 1, 1 );
		
	end

end
