if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "proj_drg_default"
ENT.IsDrGGrenade = true

-- Misc --
ENT.PrintName = "HE Grenade"
ENT.Category = "DrGBase"
ENT.Models = {"models/weapons/w_knife_t.mdl"}
ENT.Spawnable = false

-- Physics --
ENT.Physgun = false
ENT.Gravgun = false
ENT.Gravity = false

if SERVER then
  AddCSLuaFile()
	
	function ENT:_BaseInitialize()
		self:SetNoDraw(true)
		SafeRemoveEntityDelayed(self,3)
	end
	function ENT:CustomThink()
		self:RadiusDamage(256,DMG_SHOCK,256)
		return 0.1
	end
else
	language.Add("_codzmp_darkone_point_hurt", "Godking")
end
