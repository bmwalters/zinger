if SERVER then AddCSLuaFile() end

ENT.Type		= "anim"
ENT.Base		= "zing_tree_base"
ENT.PrintName	= nil
ENT.Model		= Model("models/zinger/tree_small.mdl")

if CLIENT then
	ENT.RenderGroup = RENDERGROUP_OPAQUE
end
