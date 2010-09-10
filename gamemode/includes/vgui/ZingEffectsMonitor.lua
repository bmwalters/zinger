
// object
local PANEL = {};

// textures
//local Default = Material( "zinger/hud/items/default" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// setup
	self:SetSize( 256, 256 );
	self:AlignTop( 190 );
	self:AlignLeft( -255 );
	
	// disable mouse
	self:SetMouseInputEnabled( false );
	
	// storage
	self.Monitors = {};
	
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
	ClearAllEffects()
------------------------------------*/
function PANEL:ClearAllEffects()

	if( self.Monitors ) then

		for i = #self.Monitors, 1, -1 do
		
			self.Monitors[ i ]:Remove();
			
		end
		self.Monitors = {};
		
	end

end


/*------------------------------------
	ClearAllEffects()
------------------------------------*/
function PANEL:ClearAllEffects()

	if( self.Monitors ) then

		for i = #self.Monitors, 1, -1 do
		
			self.Monitors[ i ]:Remove();
			
		end
		self.Monitors = {};
		
	end

end


/*------------------------------------
	ClearEffect()
------------------------------------*/
function PANEL:ClearEffect( key )

	if( self.Monitors ) then

		for i = #self.Monitors, 1, -1 do
		
			if( self.Monitors[ i ].Item.Key == key ) then
		
				self.Monitors[ i ]:Remove();
				table.remove( self.Monitors, i );
				
			end
			
		end

	end

end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()

	// cycle through monitors
	for i = #self.Monitors, 1, -1 do
	
		// check if dead
		if ( !self.Monitors[ i ]:Alive() ) then
		
			// kill and remove
			self.Monitors[ i ]:Remove();
			table.remove( self.Monitors, i );
		
		end
	
	end
	
	// starting Y position
	local y = 20;
	
	// cycle through monitors
	for i = 1, #self.Monitors do
	
		// update target Y position
		self.Monitors[ i ].TargetY = y;
		y = y + 32;
	
	end

end


/*------------------------------------
	AddMonitor()
------------------------------------*/
function PANEL:AddMonitor( item, duration )

	// create panel
	local monitor = vgui.Create( "ZingEffectsMonitorLine", self );
	
	// set monitor item
	monitor:SetItem( item, duration );
	
	// save
	table.insert( self.Monitors, monitor );

end


/*------------------------------------
	Paint()
------------------------------------*/
function PANEL:Paint()

	// validate player
	local pl = LocalPlayer();
	if ( !pl.Team || pl:Team() == TEAM_SPECTATOR ) then
	
		return;
		
	// validate ball
	elseif ( !IsBall( pl:GetBall() ) ) then
	
		return;
		
	end
	
	// calculate target X position
	self.TargetX = ( #self.Monitors > 0 ) && 20 || -255;
	
	// get current X position and animate
	local x = self:GetPos();
	self:AlignLeft( math.Approach( x, self.TargetX, FrameTime() * 1000 ) );
	
	// draw title
	draw.SimpleTextOutlined( "Effects Monitor", "Zing18", 3, 3, color_green, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black );

end

// register
derma.DefineControl( "ZingEffectsMonitor", "", PANEL, "DPanel" );


// object
PANEL = {};


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// setup
	self:SetSize( 256, 32 );
	self:AlignTop( 32 );
	self:AlignLeft( -255 );
	
	// disable mouse
	self:SetMouseInputEnabled( false );
	
	// defaults
	self.TargetY = 0;
	self.Text = "";
	
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
	Think()
------------------------------------*/
function PANEL:Think()
end


/*------------------------------------
	SetItem()
------------------------------------*/
function PANEL:SetItem( item, duration )

	// calculate when to die
	self.Die = CurTime() + ( duration or item.Duration );
	
	// use name as text
	self.Item = item;
	self.Text = item.Name;
	self.Image = item.Image;

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
	self:AlignLeft( math.Approach( x, 0, FrameTime() * 1000 ) );
	self:AlignTop( math.Approach( y, self.TargetY, FrameTime() * 300 ) );
	
	// draw image
	surface.SetMaterial( self.Image || Default );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, 32, 32 );
	
	// draw text
	local remaining = math.ceil( self.Die - CurTime() );	
	draw.SimpleTextOutlined( self.Text .. " " .. remaining, "Zing18", 40, 16, ( remaining > 3 ) && color_yellow || color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black );
	
end

// register
derma.DefineControl( "ZingEffectsMonitorLine", "", PANEL, "DPanel" );

