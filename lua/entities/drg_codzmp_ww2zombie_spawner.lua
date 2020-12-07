ENT.Base = "spwn_drg_default"
ENT.Type = "point"
ENT.PrintName = "Zombie Spawner"
ENT.Category = "CoDZ Megapack: WW2"
ENT.ToSpawn = {
	["drg_codzmp_ww2zombie"] = 1,
	["drg_codzmp_ww2spr"] = 0.75,
	["drg_codzmp_ww2siz"] = 0.5,
	["drg_codzmp_ww2grd"] = 0.25,
	["drg_codzmp_ww2follower"] = 0.25,
	["drg_codzmp_ww2fireman"] = 0.25,
	["drg_codzmp_ww2easn"] = 0.25,
	["drg_codzmp_ww2cpe"] = 0.5,
	["drg_codzmp_ww2bomber"] = 0.75,
	["drg_codzmp_ww2bob"] = 0.25,
	["drg_codzmp_ww2asn"] = 0.25,
}
ENT.AutoRemove = false
ENT.Radius = 762
ENT.Quantity = 8
ENT.Delay = 3

if SERVER then AddCSLuaFile() end

DrGBase.AddSpawner(ENT)