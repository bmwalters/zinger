
// client only 
if ( SERVER ) then return; end

// start module
module( 'hud', package.seeall );


// variables
local SelectedElem;
local EditState = false;
local Elements = {};
local HintEnts = {};
local SuppressedHints = {};
local HintDelay = 0;
local OutlineWidth = Vector() * 1.15;

// materials
local BlackModel = Material( "zinger/models/black" );


/*------------------------------------
	CreateElement()
------------------------------------*/
function CreateElement( class )

	// create the element and save
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

	// check if we had an old element selected
	if ( SelectedElem && SelectedElem:IsValid() ) then
	
		// release
		SelectedElem:MouseCapture( false );
		
	end
	
	// select element
	SelectedElem = elem;
	
	// validate it
	if ( SelectedElem && SelectedElem:IsValid() ) then
	
		// capture mouse
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

	// switch the flag
	EditState = !EditState;

	// loop through all elements
	for _, e in pairs( Elements ) do
	
		// validate the element
		if ( e && e:IsValid() ) then
		
			// toggle mouse input
			e:SetMouseInputEnabled( EditState );
			
			// call the event
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
	SuppressHint()
------------------------------------*/
function SuppressHint( topic )

	SuppressedHints[ topic ] = true;

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

	// create hint
	local hint = ClientsideModel( Model( "models/zinger/help.mdl" ), RENDERGROUP_OPAQUE );
	hint:SetPos( pos );
	hint.SpawnTime = CurTime();
	hint.Spin = 90;
	hint.Clicked = false;
	hint.Topic = topic;
	hint:SetNoDraw( true );
	
	// store in table
	table.insert( HintEnts, hint );
	
	// give it an index
	hint.Index = #HintEnts;
	
	// if a parent was supplied, save the offset
	if ( parent && IsValid( parent ) ) then
	
		hint.Parent = parent;
		hint.ParentOffset = pos - parent:GetPos();
		
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
	
	// notification sound
	SND( "zinger/hintpopup.mp3" );
	
	// suppress the hint and delay the next hint
	SuppressHint( topic );
	DelayHints();
	
	return hint.Index;

end


/*------------------------------------
	DrawHints()
------------------------------------*/
function DrawHints()
	
	local hint;
	
	// loop through each hint
	for i = #HintEnts, 1, -1 do
	
		hint = HintEnts[ i ];
	
		// if the hint has been clicked, speed up spin velocity
		if ( hint.Clicked ) then
		
			hint.Spin = math.Approach( hint.Spin, 1000, FrameTime() * 500 );
		
		end
		
		// spin at chosen velocity
		hint:SetAngles( hint:GetAngles() + Angle( 0, FrameTime() * hint.Spin, 0 ) );
		
		// draw the model
		DrawModelOutlined( hint, OutlineWidth );
		
		// check if we've reached maximum spin velocity and destroy
		if ( hint.Spin == 1000 ) then
		
			table.remove( HintEnts, i );
			
		elseif ( hint.Parent ) then
		
			// validate the parent
			if ( !IsValid( hint.Parent ) ) then
			
				if ( !hint.Clicked ) then
				
					// enable the hint again
					SuppressedHints[ hint.Topic ] = nil;
				
				end
			
				table.remove( HintEnts, i );			
				
			else
				
				hint:SetPos( hint.Parent:GetPos() + hint.ParentOffset );
			
			end
		
		end
		
	end
	
end


/*------------------------------------
	ClickHint()
------------------------------------*/
local function ClickHint( hint )

	// flag as clicked
	hint.Clicked = true;
	
	// notification sound
	SND( "zinger/hintclicked.mp3" );
	
	// display the topic in game
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

	// no hints to click, ignore
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
	IsHintSuppressed()
------------------------------------*/
function IsHintSuppressed( topic )

	return ( SuppressedHints[ topic ] != nil );

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


/*------------------------------------
	RemoveHints()
------------------------------------*/
function RemoveHints()

	local hint;
	
	// loop through each active hint
	for i = 1, #HintEnts do
	
		hint = HintEnts[ i ];
		
		// make sure it hasn't been clicked
		if ( !hint.Clicked ) then
		
			// unsuppress the hint
			SuppressedHints[ hint.Topic ] = nil;
		
		end
		
	end
	
	// set a delay and remove all
	DelayHints();
	HintEnts = {};
	
end
