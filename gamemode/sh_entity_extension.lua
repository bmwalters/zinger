local meta = FindMetaTable("Entity")

if SERVER then
	function meta:EmitSoundTeam(t, snd, vol, pitch)
		-- send data
		net.Start("Zing_EmitSoundTeam")
			net.WriteEntity(self)
			net.WriteString(snd)
			net.WriteFloat(vol)
			net.WriteUInt(pitch, 8)
		net.Send(team.GetPlayers(t))
	end
else
	local function EmitSoundTeam()
		local ent = net.ReadEntity()
		local snd = net.ReadString()
		local vol = net.ReadFloat()
		local pitch = net.ReadUInt(8)

		if IsValid(ent) then
			ent:EmitSound(snd, vol, pitch)
		end
	end
	net.Receive("EmitSoundTeam", EmitSoundTeam)
end
