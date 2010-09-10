
// object
local PANEL = {};

// materials
local Background = Material( "zinger/hud/help" );
local ButtonLeft = Material( "zinger/hud/buttonleft" );
local ButtonRight = Material( "zinger/hud/buttonright" );
local BlackModelSimple = Material( "black_outline" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()
	
	// size and center
	self:SetSize( 512, 512 );
	self:Center();
	
	// create 3D help icon
	self.HelpIcon = vgui.Create( "3DIcon", self );
	self.HelpIcon:SetSize( 200, 200 );
	self.HelpIcon:SetPos( 7, -45 );
	self.HelpIcon:SetModel( Model( "models/zinger/help.mdl" ) );
	self.HelpIcon:SetAngles( Angle( 0, 0, 20 ) );
	self.HelpIcon:SetViewDistance( 60 );
	self.HelpIcon:SetOutline( 1.08 );
	self.HelpIcon.Run = function( icon )
	
		icon.Entity:SetAngles( icon.Entity:GetAngles() + Angle( 0, FrameTime() * 20, 0 ) );
	
	end
	
	self.Left = vgui.Create( "DImageButton", self );
	self.Left:SetMaterial( "zinger/hud/buttonleft" );
	self.Left:SizeToContents();
	self.Left:SetPos( 0, 256 );
	self.Left.DoClick = function( btn )
	
		self:PreviousCategory();
	
		// play sound
		ButtonSoundDefault();
		
	end
	
	self.Right = vgui.Create( "DImageButton", self );
	self.Right:SetMaterial( "zinger/hud/buttonright" );
	self.Right:SizeToContents();
	self.Right:SetPos( 512 - 64, 256 );
	self.Right.DoClick = function( btn )
	
		self:NextCategory();
	
		// play sound
		ButtonSoundDefault();
		
	end
	
	self.Close = vgui.Create( "Button", self );
	self.Close:SetText( "close" );
	self.Close:SetPos( ( self:GetWide() * 0.5 ) - 128, 512 - 64 );
	self.Close.DoClick = function( btn )
	
		// play sound
		ButtonSoundOkay();
		self:SetVisible( false );
		
	end
	
	self.Categories = {};
	self.CurrentCategory = nil;
	
	// load help
	L( "zinger/help/", "*.txt", nil, function( f, p )
		
		self:LoadHelpFile( f );

	end );

end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()
end


/*------------------------------------
	ApplySchemeSettings()
------------------------------------*/
function PANEL:ApplySchemeSettings()
end


/*------------------------------------
	OnCursorMoved()
------------------------------------*/
function PANEL:OnCursorMoved( x, y )
end


/*------------------------------------
	OnCursorExited()
------------------------------------*/
function PANEL:OnCursorExited()
end


/*------------------------------------
	ShowTopic()
------------------------------------*/
function PANEL:ShowTopic( key )

	local category, topic = unpack( string.Explode( ":", key ) );

	if ( self.CurrentCategory ) then
	
		self.CurrentCategory.Panel:SetVisible( false );
		
	end
	
	if ( self.Categories[ category ] ) then
	
		self.Categories[ category ].Panel:SetVisible( true );
	
	end
	
	self.CurrentCategory = self.Categories[ category ];
	
	if ( topic ) then
	
		for _, t in pairs( self.Categories[ category ].Topics ) do
		
			if ( t.Panel.Topic == topic ) then
			
				timer.Simple( FrameTime() + 0.001, function()
				
					t.Panel:SetClosed( false );
					
				end );
				
				return;
				
			end
			
		end
	
	end

end


/*------------------------------------
	PreviousCategory()
------------------------------------*/
function PANEL:PreviousCategory()

	local found = false;

	for key, category in pairs( self.Categories ) do
	
		if( found ) then
		
			self:ShowTopic( key );
			break;
		
		end
	
		if( category == self.CurrentCategory ) then
		
			found = true;
		
		end
	
	end

end



/*------------------------------------
	NextCategory()
------------------------------------*/
function PANEL:NextCategory()

	local last = nil;

	for key, category in pairs( self.Categories ) do
	
		if( category == self.CurrentCategory ) then
		
			if( last ) then
		
				self:ShowTopic( last );
				break;
				
			end
		
		end
		
		last = key;
		
	end

end


/*------------------------------------
	CreateHelpTopic()
------------------------------------*/
function PANEL:CreateHelpTopic( category, title, text, index )

	if ( !self.Categories[ category ] ) then
	
		self.Categories[ category ] = {};
		self.Categories[ category ].Title = category;
		self.Categories[ category ].Topics = {};
		self.Categories[ category ].Panel = vgui.Create( "DPanelList", self );
		self.Categories[ category ].Panel:StretchToParent( 60, 145, 60, 60 );
		self.Categories[ category ].Panel:SetDrawBackground( false );
		self.Categories[ category ].Panel:SetVisible( false );
		self.Categories[ category ].Panel:SetZPos( -99 );
		self.Categories[ category ].Panel:SetSpacing( 2 );
		self.Categories[ category ].Panel:EnableVerticalScrollbar();
		self.Categories[ category ].Panel.VBar:SetSkin( "zinger" );
	
	end
	
	table.insert( self.Categories[ category ].Topics, { index or ( #self.Categories[ category ].Topics + 1 ), title, text } );

end



/*------------------------------------
	LoadHelpFile()
------------------------------------*/
function PANEL:LoadHelpFile( f )

	local d = file.Read( "zinger/help/" .. f );
	local text = string.Explode( "\n", d );
	local category, title, index = unpack( string.Explode( ":", text[ 1 ] ) );
	index = tonumber( index );
	table.remove( text, 1 );
	text = table.concat( text, "\n" );
	
	self:CreateHelpTopic( category, title, text, index );
	
end


/*------------------------------------
	LoadComplete()
------------------------------------*/
function PANEL:LoadComplete()

	for _, category in pairs( self.Categories ) do
		
		table.sort( category.Topics, function( a, b ) return a[ 1 ] < b[ 1 ] end );
	
		for _, topic in pairs( category.Topics ) do
		
			local v = vgui.Create( "HelpTopic", category.Panel );
			v:Create( topic[ 2 ], topic[ 3 ] );
			v.Category = category;
			topic.Panel = v;
			category.Panel:AddItem( v );
			
		end
	
	end

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	// get size
	local w, h = self:GetSize();
	
	// draw background
	surface.SetMaterial( Background );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, w, h );
	
	if ( self.CurrentCategory ) then
	
		draw.SimpleText( self.CurrentCategory.Title, "Zing30", self:GetWide() * 0.5, 115, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP );
		
	end
	
end

// register
derma.DefineControl( "Help", "", PANEL, "DPanel" );



PANEL = {};


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self:SetSize( self:GetParent():GetWide(), 22 );
	
	self:SetPaintBackground( false );
	
	self.Closed = true;
	
	self.NameLabel = vgui.Create( "DLabel", self );
	self.NameLabel:SetFont( "Zing18" );
	self.NameLabel:AlignTop();
	self.NameLabel:SetContentAlignment( 5 );
	self.NameLabel:SetSize( self:GetWide(), 22 );
	self.NameLabel:SetExpensiveShadow( 1, color_black );
	self.NameLabel:SetMouseInputEnabled( true );
	self.NameLabel:SetCursor( "hand" );
	self.NameLabel.OnMousePressed = function( lbl, mc )
	
		self:Toggle();
		
		// play sound
		ButtonSoundDefault();
		
	end
	
	self.TextLabel = vgui.Create( "DLabel", self );
	self.TextLabel:SetContentAlignment( 7 );
	self.TextLabel:SetFont( "Zing18" );
	self.TextLabel:MoveBelow( self.NameLabel );
	self.TextLabel:AlignLeft( 10 );
	self.TextLabel:SetWide( self:GetWide() - 20 );
	self.TextLabel:SetWrap( true );
	self.TextLabel:SetAutoStretchVertical( true );
	self.TextLabel:SetExpensiveShadow( 1, color_black );
	
end


/*------------------------------------
	ApplySchemeSettings()
------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.NameLabel:SetFont( "Zing18" );
	self.NameLabel:SetTextColor( color_yellow );
	
	self.TextLabel:SetFont( "Zing18" );
	self.TextLabel:SetTextColor( color_white );
	
end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()

	//self:SetTall( self.TextLabel:GetTall() );
	if ( self:GetTall() != self.LastTall ) then
	
		self:GetParent():InvalidateLayout();
		
	end
	
	self.LastTall = self:GetTall();
	
end


/*------------------------------------
	Toggle()
------------------------------------*/
function PANEL:Toggle()

	self:SizeTo( self:GetWide(), self.NameLabel:GetTall() + ( ( self.Closed ) && self.TextLabel:GetTall() || 0 ), 0.2, 0, 2 );
	self.Closed = !self.Closed;
	
	if ( !self.Closed ) then
	
		if ( self.Category.CurrentTopic && self.Category.CurrentTopic:IsValid() && self.Category.CurrentTopic != self ) then
		
			self.Category.CurrentTopic:SetClosed( true );
		
		end
	
	end
	
	self.Category.CurrentTopic = self;

end


/*------------------------------------
	SetClosed()
------------------------------------*/
function PANEL:SetClosed( bool )

	if ( self.Closed != bool ) then
	
		self:Toggle();
		
	end

end


/*------------------------------------
	Create()
------------------------------------*/
function PANEL:Create( title, text )

	self.Topic = title;
	
	self:SetWide( self:GetParent():GetWide() );

	self.NameLabel:SetText( title );
	
	self.TextLabel:SetText( text );
	
	self:InvalidateLayout();
	
end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	local w, h = self:GetSize();

	surface.SetDrawColor( 0, 0, 0, 100 );
	surface.DrawRect( 0, 0, w, h );

end

// register
derma.DefineControl( "HelpTopic", "", PANEL, "DPanel" );

