ENT.Base = "spwn_drg_default"
ENT.Type = "point"
ENT.PrintName = "Zombie Spawner"
ENT.Category = "CoDZ Megapack: WW2"
ENT.ToSpawn = {
	["drg_codzmp_ww2zombie"] = 1, 
}
ENT.AutoRemove = false
ENT.Radius = 5000
ENT.Quantity = 24
ENT.Delay = 3

if SERVER then AddCSLuaFile() end

DrGBase.AddSpawner(ENT)