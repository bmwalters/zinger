
// object
local PANEL = {};


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// should always be first
	self.BaseClass.Init( self );
	
	// position and size
	self:SetSize( 800, 256 );
	self.ElementTitle = "Notification Area";
	self.DefaultX = ( ScrW() * 0.5 ) - ( self:GetWide() * 0.5 );
	self.DefaultY = 10;
	
	self.Flag = ELEM_FLAG_PLAYERS;
	
	// storage
	self.Notifications = {};
	
	self:InitDone();
	
end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()

	self.BaseClass.PerformLayout( self );

end


/*------------------------------------
	ApplySchemeSettings()
------------------------------------*/
function PANEL:ApplySchemeSettings()
end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()

	self.BaseClass.Think( self );

	// cycle through monitors
	for i = #self.Notifications, 1, -1 do
	
		// check if dead
		if ( !self.Notifications[ i ]:Alive() ) then
		
			// kill and remove
			self.Notifications[ i ]:Remove();
			table.remove( self.Notifications, i );
		
		end
	
	end
	
	// starting Y position
	local y = 0;
	
	// cycle through monitors
	for i = 1, #self.Notifications do
	
		// update target Y position
		self.Notifications[ i ].TargetY = y;
		y = y + 32;
	
	end

end


/*------------------------------------
	AddNotification()
------------------------------------*/
function PANEL:AddNotification( ... )

	// create note
	local note = vgui.Create( "NotificationLine", self );
	
	// add each text
	for _, text in pairs( { ... } ) do
	
		note:AddText( text );
	
	end
	
	// save
	table.insert( self.Notifications, note );

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	if ( !self:ShouldPaint() ) then
	
		return;
		
	end
	
	// must call
	self.BaseClass.Paint( self );
	
end

// register
derma.DefineControl( "Notifications", "", PANEL, "BaseElement" );


// object
PANEL = {};


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// setup
	self:SetSize( 512, 32 );
	self:AlignTop( -31 );
	self:CenterHorizontal();
	
	// disable mouse
	self:SetMouseInputEnabled( false );
	
	// defaults
	self.TargetY = 0;
	self.Die = CurTime() + 8;
	self.Items = {};
	
end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()

	// last item
	local last;
	
	// cycle through all items
	for _, v in pairs( self.Items ) do
	
		if ( last ) then
		
			// move right of last item
			v:MoveRightOf( last, 8 );
			
		else
		
			// starting spot
			v:AlignLeft( 0 );
			
		end
		
		// save last
		last = v;
	
	end
	
	// update size
	self:SetWide( last.X + last:GetWide() + 4 );
	self:CenterHorizontal();

end


/*------------------------------------
	ApplySchemeSettings()
------------------------------------*/
function PANEL:ApplySchemeSettings()
end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	AddText()
------------------------------------*/
function PANEL:AddText( item )

	// create label
	local label = vgui.Create( "DLabel", self );
	label:SetFont( "Zing22" );
	
	// override paint function
	label.Paint = function( p )
	
		// outlined text
		draw.SimpleTextOutlined( p:GetValue(), "Zing22", 2, 2, p:GetTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black );
		return true
		
	end
	
	// get what type the item is
	local t = type( item );
	
	// players
	if ( t == "Player" ) then
	
		// use player name and team color
		label:SetText( item:Name() );
		label:SetTextColor( team.GetColor( item:Team() ) );
		
	// entities
	elseif ( t == "Entity" && item.PrintName ) then
	
		// use print name and notify color
		label:SetText( item.PrintName );
		label:SetTextColor( item.NotifyColor || color_white );
		
	// items
	elseif ( t == "table" && item.IsItem ) then
	
		// item name and brown
		label:SetText( item.Name );
		label:SetTextColor( color_brown );
	
	else
	
		// just turn it into a string and white
		label:SetText( tostring( item ) );
		label:SetTextColor( color_white );
	
	end
	
	// reisze
	label:SizeToContents();
	label:SetWide( label:GetWide() + 4 );
	label:SetTall( 32 );
	
	// save
	table.insert( self.Items, label );
	
	// dirty
	self:InvalidateLayout();

end


/*------------------------------------
	Alive()
------------------------------------*/
function PANEL:Alive()

	// assume alive if this doesnt exist
	if ( !self.Die ) then
	
		return true;
		
	end
	
	return ( CurTime() < self.Die );

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	// get size
	local w, h = self:GetSize();
	
	// get position
	local x, y = self:GetPos();
	
	// animate position
	self:AlignTop( math.Approach( y, self.TargetY, FrameTime() * 450 ) );

end

// register
derma.DefineControl( "NotificationLine", "", PANEL, "DPanel" );
