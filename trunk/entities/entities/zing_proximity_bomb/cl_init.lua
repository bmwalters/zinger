
// shared file
include( 'shared.lua' );

// setup
ENT.RenderGroup = RENDERGROUP_OPAQUE;


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self.NextAlert = CurTime();

end


/*------------------------------------
	BuildBonePositions()
------------------------------------*/
function ENT:BuildBonePositions( numBones )

	if( self.dt.Active ) then

		local bone = self:GetBoneMatrix( 1 );
		if( bone ) then
		
			bone:Rotate( Angle( 0, 0, math.sin( CurTime() * 0.75 ) * 90 ) );
			self:SetBoneMatrix( 1, bone );
		
		end
		
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	if( self.dt.Active ) then
	
		if( self.NextAlert <= CurTime() ) then
		
			self.NextAlert = CurTime() + 1;
			
			local owner = self:GetOwner();
			if( IsValid( owner ) ) then
			
				local attachment = self:GetAttachment( self:LookupAttachment( "Light" ) );
				if( attachment ) then
		
					// sound
					self:EmitSound( "Buttons.snd16" );
					
					// light
					local light = DynamicLight( self:EntIndex() );
					light.Pos = attachment.Pos;
					light.Size = 64;
					light.Decay = 256;
					
					if( owner:Team() == TEAM_PURPLE ) then
					
						light.R = 64;
						light.G = 64;
						light.B = 255;
						
					else
					
						light.R = 255;
						light.G = 64;
						light.B = 64;
					
					end
					
					light.Brightness = 8;
					light.DieTime = CurTime() + 0.5;
					
				end
				
			end
			
		end
		
	end

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()
	
	self:DrawModel();
	
end



/*------------------------------------
	DrawOnRadar()
------------------------------------*/
function ENT:DrawOnRadar( x, y, a )
	
	self:RadarDrawRadius( x, y, 96, color_white_translucent, color_white_translucent2 );
	self:RadarDrawCircle( x, y, 5, color_black );
	
end

