
ITEM.Name		= "Jihad";
ITEM.Description	= "Make the ultimate sacrifice and gain 72 virgins... or not";
ITEM.IsEffect		= false;
ITEM.IsTimed		= false;

if ( CLIENT ) then

	ITEM.Image		= Material( "zinger/hud/items/jihad" );
	
end

/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	if( SERVER ) then
	
		util.Explosion( self.Ball:GetPos(), 750, self.Ball:Team(), self.Ball );

	end
	
end
