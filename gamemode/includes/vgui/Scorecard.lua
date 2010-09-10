
// object
local PANEL = {};

// materials
local Background = Material( "zinger/hud/scorecard" );
local ButtonLeft = Material( "zinger/hud/buttonleft" );
local ButtonRight = Material( "zinger/hud/buttonright" );
local BlackModelSimple = Material( "black_outline" );


/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	// always show this players team first
	self.CurrentTeam = LocalPlayer():Team();
	
	// size and center
	self:SetSize( 512, 512 );
	self:Center();
	
	// create 3D ball
	self.Ball = vgui.Create( "3DIcon", self );
	self.Ball:SetSize( 200, 200 );
	self.Ball:SetPos( 0, -45 );
	self.Ball:SetModel( Model( "models/zinger/ball.mdl" ) );
	self.Ball:SetAngles( Angle( 0, 0, 20 ) );
	self.Ball:SetViewDistance( 25 );
	self.Ball:SetOutline( 1.07 );
	self.Ball.Run = function( icon )
	
		icon.Entity:SetAngles( icon.Entity:GetAngles() + Angle( 0, FrameTime() * 10, 0 ) );
	
	end
	
	self.Left = vgui.Create( "DImageButton", self );
	self.Left:SetMaterial( "zinger/hud/buttonleft" );
	self.Left:SizeToContents();
	self.Left:SetPos( 0, 256 );
	self.Left.DoClick = function( btn )
	
		self.CurrentTeam = self.CurrentTeam + 1;
		if ( self.CurrentTeam > TEAM_PURPLE ) then
		
			self.CurrentTeam = TEAM_SPECTATOR;
			
		end
	
		// play sound
		ButtonSoundDefault();
		
	end
	
	self.Right = vgui.Create( "DImageButton", self );
	self.Right:SetMaterial( "zinger/hud/buttonright" );
	self.Right:SizeToContents();
	self.Right:SetPos( 512 - 64, 256 );
	self.Right.DoClick = function( btn )
	
		self.CurrentTeam = self.CurrentTeam - 1;
		if ( self.CurrentTeam < TEAM_SPECTATOR ) then
		
			self.CurrentTeam = TEAM_PURPLE;
			
		end
	
		// play sound
		ButtonSoundDefault();
		
	end
	
	self.Select = vgui.Create( "Button", self );
	self.Select:SetText( "join team" );
	self.Select:SetPos( ( self:GetWide() * 0.5 ) - 128, 512 - 64 );
	self.Select.DoClick = function( btn )
	
		RunConsoleCommand( "changeteam", self.CurrentTeam );
	
		// play sound
		ButtonSoundOkay();
		
	end

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

	// get round state
	local state = GAMEMODE:GetRoundState();
	
	if ( ( state != ROUND_WAITING && state != ROUND_INTERMISSION ) && LocalPlayer():Team() != TEAM_SPECTATOR ) then
	
		self.Select:SetVisible( false );
		return;
		
	end

	if ( self.CurrentTeam == LocalPlayer():Team() ) then
	
		self.Select:SetVisible( false );
		
	else
	
		self.Select:SetVisible( true );
	
	end

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
	Paint()
------------------------------------*/
function PANEL:Paint()

	// get size
	local w, h = self:GetSize();
	
	// draw background
	surface.SetMaterial( Background );
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, w, h );
	
	//draw.SimpleText( "Current Hole: " .. RoundController():GetCurrentHole(), "Zing22", 260, 110, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP );
	
	draw.SimpleTextOutlined( team.GetName( self.CurrentTeam ), "Zing42", self:GetWide() * 0.5, 145, team.GetColor( self.CurrentTeam ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black );
	
end

// register
derma.DefineControl( "Scorecard", "", PANEL, "DPanel" );
