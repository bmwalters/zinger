
// shared file
include( 'shared.lua' );

// materials
local WhiteMaterial = CreateMaterial( "White", "UnlitGeneric", {
	[ "$basetexture" ] = "color/white",
	[ "$vertexcolor" ] = "1",
	[ "$vertexalpha" ] = "1",
	[ "$nocull" ] = "1",
} );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.BaseClass.Initialize( self );

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	// calculate outline width
	local width = math.Clamp( ( self:GetPos() - EyePos() ):Length() - 100, 0, 600 );
	width = 1.025 + ( ( width / MAX_VIEW_DISTANCE ) * 0.05 );

	self:DrawModelOutlined( Vector( width, width, 1.05 ) );
	
	local time = CurTime() * 10;
	local position = self:GetPos() + Vector( 0, 0, 2 );
	
	// ridge line
	render.SetMaterial( WhiteMaterial );
	mesh.Begin( MATERIAL_LINE_STRIP, 8 );
	for i = 1, 8 do
	
		local angle = time + math.rad( ( 90 / 8 ) * i );
		local dir = Vector( math.sin( angle ), math.cos( angle ), 0 );
		
		local frac = 1 - ( 1 / 4 ) * math.abs( 4 - i );
		
		mesh.Position( position + dir * 20 );
		mesh.Color( 48, 226, 82, 255 * frac );
		mesh.AdvanceVertex();
	
	end
	mesh.End();

end
