
ITEM.Name		= "Blow Gun";
ITEM.Description	= "Disorient enemies with a hallucinogenic dart";
ITEM.IsEffect		= false;
ITEM.IsTimed		= true;
ITEM.Duration 		= 0.5;
ITEM.ViewModel		= "models/zinger/v_blowgun.mdl";
ITEM.ActionText		= "drugged";

if ( CLIENT ) then

	ITEM.Cursor 		= Material( "zinger/hud/reticule" );
	ITEM.Tip		= "Hold USE to aim";
	ITEM.Image		= Material( "zinger/hud/items/blowgun" );
	
end

/*------------------------------------
	Equip()
------------------------------------*/
function ITEM:Equip()

	// select skin
	self.ViewModelSkin = self.Player:Team() == TEAM_ORANGE and 1 or 0;

	self:ActivateViewModel();
	
end


/*------------------------------------
	Activate()
------------------------------------*/
function ITEM:Activate()

	self.Data.EndTime = CurTime() + self.Duration;
	
	if ( SERVER ) then
	
		local pos, ang = self:GetWeaponPosition();
		local dir = self:GetAimVector();
		
		// blow dart trace
		local tr = util.TraceHull( {
			start = pos,
			endpos = pos + dir * 4096,
			filter = self.Ball,
			mins = Vector( -4, -4, -4 ),
			maxs = Vector( 4, 4, 4 ),
		} );
		
		// do the tracer
		util.ParticleTracerEx( "Zinger.BlowDart", tr.StartPos, tr.HitPos, true, self.Ball:EntIndex(), -1 );
				
		// play world sound
		timer.Simple( 0.2, function()
		
			// stick an arrow into it
			local arrow = ents.Create( "prop_dynamic" );
			arrow:SetModel( "models/zinger/dart.mdl" );
			arrow:SetPos( tr.HitPos + tr.Normal * 8 );
			arrow:SetAngles( tr.Normal:Angle() );
			arrow:Spawn();
			arrow:DrawShadow( false );
			if( IsValid( tr.Entity ) ) then
			
				local dir = ( tr.Entity:GetPos() - tr.HitPos ):GetNormal();
				arrow:SetPos( tr.Entity:GetPos() - dir * ( tr.Entity:BoundingRadius() - 8 ) );
				//arrow:SetAngles( dir:Angle() );
				arrow:SetParent( tr.Entity );
				
				// drug them
				if( IsBall( tr.Entity ) && ( tr.Entity:Team() != self.Player:Team() ) ) then
				
					tr.Entity:GetOwner():ForceActivateItem( "blowguneffect" );
					
					umsg.Start( "AddNotfication" );
						umsg.Char( NOTIFY_ITEMPLAYER );
						umsg.Entity( self.Player );
						umsg.Char( self.Index );
						umsg.Entity( tr.Entity:GetOwner() );
					umsg.End();
				
				end
				
			end
			SafeRemoveEntityDelayed( arrow, 10 );
		
			// sound
			WorldSound( "zinger/items/darthit.mp3", tr.HitPos, 80, 120 );

		end );
		
		// muzzle flash
		local effect = EffectData();
		effect:SetNormal( dir );
		effect:SetOrigin( pos );
		effect:SetAngle( dir:Angle() );
		effect:SetEntity( self.Ball );
		util.Effect( "Zinger.MuzzleBlowgun", effect );
			
	end
	
end


/*------------------------------------
	Deactivate()
------------------------------------*/
function ITEM:Deactivate()

	self:DeactivateViewModel();

end


/*------------------------------------
	Think()
------------------------------------*/
function ITEM:Think()

	return self.Data.EndTime && self.Data.EndTime > CurTime();

end
