-- BACKWARDS COMPATIBILITY; DO NOT USE
if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_shrub_base"
ENT.PrintName	= nil
ENT.Model		= Model("models/zinger/shrub.mdl")

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE
end
