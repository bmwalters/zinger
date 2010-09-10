
// object
local PANEL = {};

// textures
local Background = Material( "zinger/hud/elements/pointcard" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self.BaseClass.Init( self );

	self:SetSize( 256, 180 );
	
	self.DefaultX = ScrW() - 256;
	self.DefaultY = ScrH() - 180;
	self.ElementTitle = "Point Card";
	self.Flag = ELEM_FLAG_PLAYERS;
	
	self:InitDone();
	
	self.AddPoints = {};

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	if ( !self:ShouldPaint() ) then
	
		return;
		
	end
	
	// get player
	local pl = LocalPlayer();
	
	// draw material
	surface.SetMaterial( Background );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, 256, 256 );
	
	draw.SimpleTextOutlined( ("%06d"):format( team.GetScore( pl:Team() ) ), "Zing22", self.MidWidth - 5, 78, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black );
	
	self.LastPoints = self.LastPoints or 0;
	if ( self.LastPoints != pl:Frags() ) then
	
		table.insert( self.AddPoints, { "+" .. ( pl:Frags() - self.LastPoints ), 200, 123 } );
		
	end
	self.LastPoints = pl:Frags();
	
	draw.SimpleTextOutlined( ("%06d"):format( self.LastPoints ), "Zing42", 186, 123, color_yellow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, color_black );
	
	local pt;
	for i = #self.AddPoints, 1, -1 do
	
		pt = self.AddPoints[ i ];
		
		// reduce alpha
		pt[ 2 ] = pt[ 2 ] - ( FrameTime() * 450 );
		
		// move up
		pt[ 3 ] = pt[ 3 ] - ( FrameTime() * 120 );
		
		if ( pt[ 2 ] <= 0 ) then
		
			table.remove( self.AddPoints, i );
			
		else
		
			draw.SimpleText( pt[ 1 ], "Zing52", 186, pt[ 3 ], Color( color_yellow.r, color_yellow.g, color_yellow.b, pt[ 2 ] ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER );
		
		end
	
	end
	
	// must call
	self.BaseClass.Paint( self );

end

// register
derma.DefineControl( "PointCard", "", PANEL, "BaseElement" );
