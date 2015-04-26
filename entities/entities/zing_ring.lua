if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_ring_base"
ENT.PrintName	= "Ring"
ENT.Model		= Model("models/zinger/arch.mdl")

if CLIENT then
	ENT.HintOffset = Vector(0, 0, 100)
end
