
// client only 
if ( SERVER ) then return; end

// start module
module( 'hud', package.seeall );


// variables
local SelectedElem;
local EditState = false;
local Elements = {};
local HintEnts = {};
local SurpressedHints = {};
local HintDelay = 0;

local BlackModel = Material( "zinger/models/black" );


/*------------------------------------
	CreateElement()
------------------------------------*/
function CreateElement( class )

	local elem = vgui.Create( class );
	table.insert( Elements, elem );
	
	return elem;
	
end


/*------------------------------------
	EditMode()
------------------------------------*/
function EditMode()

	return EditState;

end


/*------------------------------------
	Select()
------------------------------------*/
function Select( elem )

	if ( SelectedElem && SelectedElem:IsValid() ) then
	
		SelectedElem:MouseCapture( false );
		
	end

	SelectedElem = elem;
	
	if ( SelectedElem && SelectedElem:IsValid() ) then
	
		SelectedElem:MouseCapture( true );
		
	end

end


/*------------------------------------
	GetSelected()
------------------------------------*/
function GetSelected()

	return SelectedElem;

end


/*------------------------------------
	Toggle()
------------------------------------*/
local function Toggle( pl, cmd, args )

	EditState = !EditState;

	for _, e in pairs( Elements ) do
	
		if ( e && e:IsValid() ) then
		
			e:SetMouseInputEnabled( EditState );
			e:EditChanged( EditState );
		
		end
	
	end

end
concommand.Add( "edithud", Toggle );


/*------------------------------------
	RemoveHint()
------------------------------------*/
function RemoveHint( index )

	table.remove( HintEnts, index );

end


/*------------------------------------
	SurpressHint()
------------------------------------*/
function SurpressHint( topic )

	SurpressedHints[ topic ] = true;

end


/*------------------------------------
	DelayHints()
------------------------------------*/
function DelayHints()

	HintDelay = CurTime() + HINT_DELAY;

end


/*------------------------------------
	AddHint()
------------------------------------*/
function AddHint( pos, topic, parent )

	local hint = ClientsideModel( Model( "models/zinger/help.mdl" ), RENDERGROUP_OPAQUE );
	hint:SetPos( pos );
	hint.SpawnTime = CurTime();
	hint.Spin = 90;
	hint.Clicked = false;
	hint.Topic = topic;
	hint:SetNoDraw( true );
	
	table.insert( HintEnts, hint );
	
	hint.Index = #HintEnts;
	
	if ( parent ) then
	
		hint:SetParent( parent );
		
	end
	
	// flash of light
	local light = DynamicLight( 0 );
	light.Pos = pos;
	light.Size = 256;
	light.Decay = 1024;
	light.R = 200;
	light.G = 255;
	light.B = 200;
	light.Brightness = 6;
	light.DieTime = CurTime() + 1.25;
	
	// sparkle
	ParticleEffectAttach( "Zinger.Help", PATTACH_ABSORIGIN_FOLLOW, hint, -1 );
	
	SND( "zinger/hintpopup.mp3" );
	
	SurpressHint( topic );
	DelayHints();
	
	return hint.Index;

end

local OutlineWidth = Vector() * 1.15;

/*------------------------------------
	DrawHints()
------------------------------------*/
function DrawHints()
	
	local hint;

	for i = #HintEnts, 1, -1 do
	
		hint = HintEnts[ i ];
	
		if ( hint.Clicked ) then
		
			hint.Spin = math.Approach( hint.Spin, 1000, FrameTime() * 500 );
		
		end
	
		hint:SetAngles( hint:GetAngles() + Angle( 0, FrameTime() * hint.Spin, 0 ) );
		//hint:SetPos( hint:GetPos() + Vector( 0, 0, math.sin( ( CurTime() - hint.SpawnTime ) ) * ( FrameTime() * 5 ) ) );
		
		DrawModelOutlined( hint, OutlineWidth );
		
		if ( hint.Spin == 1000 ) then
		
			table.remove( HintEnts, i );
			
		end
		
	end
	
end


/*------------------------------------
	ClickHint()
------------------------------------*/
local function ClickHint( hint )

	hint.Clicked = true;
	SND( "zinger/hintclicked.mp3" );
	
	GAMEMODE:ShowTopic( hint.Topic );
	
	// stop the sparkle
	hint:StopParticles();
	
	// explode
	ParticleEffectAttach( "Zinger.HelpExplode", PATTACH_ABSORIGIN_FOLLOW, hint, -1 );

end


/*------------------------------------
	Think()
------------------------------------*/
function Think()

end


/*------------------------------------
	DidClickHint()
------------------------------------*/
local function DidClickHint( hint )

	local pos, dir = controls.GetViewPos(), controls.GetCursorDirection();
	local hit, dist = math.RayIntersectSphere( pos, dir, hint:GetPos(), 28 );
	
	if( hit ) then
	
		// ensure our view of it is unobstructed
		local tr = util.TraceLine( {
			start = pos,
			endpos = pos + dir * dist,
		} );
		
		if( tr.Fraction == 1 ) then
		
			return true, dist;
		
		end
	
	end
	
	return false;
	
end


/*------------------------------------
	ClickHints()
------------------------------------*/
function ClickHints()

	
	if ( #HintEnts == 0 ) then
	
		return;
		
	end

	// find the closest hint our mouse is over
	local closest_dist, closest_hint = math.huge, nil;
	for _, hint in pairs( HintEnts ) do
	
		local hit, dist = DidClickHint( hint );
		
		if ( hit && dist <= closest_dist ) then

			closest_dist = dist;
			closest_hint = hint;
		
		end
	
	end

	// we have a click!
	if( closest_hint ) then
	
		ClickHint( closest_hint );
	
	end
	
end


/*------------------------------------
	IsHintSurpressed()
------------------------------------*/
function IsHintSurpressed( topic )

	return ( SurpressedHints[ topic ] != nil );

end


/*------------------------------------
	ShouldHint()
------------------------------------*/
function ShouldHint( topic )

	if ( CurTime() < HintDelay ) then
	
		return false;
		
	end

	return true;

end

