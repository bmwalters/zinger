
include( 'shared.lua' );

ENT.RenderGroup = RENDERGROUP_OPAQUE;

local RT = GetRenderTarget( "Sign" );
local Background = CreateMaterial( "SignTexture", "UnlitGeneric", {
	["$basetexture"] = "zinger/models/sign/sign",
	["$nocull"] = "1",
} );
local SignMaterial = Material( "zinger/models/sign/sign" );
SignMaterial:SetMaterialTexture( "$basetexture", RT );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() );

end

surface.CreateFont( "ComickBook", 72, 400, true, false, "Zing72", false, false );

/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	local scrW, scrH = ScrW(), ScrH();
	local oldRT = render.GetRenderTarget();
		
	local w, h = 789, 426;
	w = w / 2;
	h = h / 2;
	
	// render the sign material
	render.SetRenderTarget( RT );
		render.SetViewPort( 0, 0, 512, 512 );
			cam.Start2D();
				render.ClearDepth();
				render.Clear( 0, 0, 0, 255 );
				
				render.SetMaterial( Background );
				render.DrawScreenQuad();
				
				local textHeight = h * 0.25;
				
				surface.SetDrawColor( 180, 180, 180, 255 );
				//surface.DrawRect( 0, 0, w, h );
				
				for i = 1, 3 do
				
					local line = self:GetNetworkedString( string.format( "line%d", i ) );
					local linecolor = self:GetNetworkedVector( string.format( "line%dcolor", i ) );
					if( line ) then
					
						local color = Color( 0, 0, 0, 255 );
						if( linecolor ) then
							color.r = linecolor.x;
							color.g = linecolor.y;
							color.b = linecolor.z;
						end

						draw.SimpleText( line, "Zing72", w * 0.5, textHeight * i, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
						
					end
					
				end
				
			cam.End2D();
		render.SetViewPort( 0, 0, scrW, scrH );
	render.SetRenderTarget( oldRT );

	// draw sign
	self:DrawModel();

end


/*------------------------------------
	GetTipText()
------------------------------------*/
function ENT:GetTipText()

	local text;

	for i = 1, 3 do
	
		local line = self:GetNetworkedString( string.format( "line%d", i ) );
		if( line ) then
		
			if ( text ) then
			
				text = text .. " " .. line;
				
			else
			
				text = line;
				
			end
			
		end
		
	end
	
	return text;

end
