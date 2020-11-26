if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "proj_drg_default"
ENT.IsDrGGrenade = true

-- Misc --
ENT.PrintName = "HE Grenade"
ENT.Category = "DrGBase"
ENT.Models = {"models/weapons/w_eq_fraggrenade.mdl"}
ENT.Spawnable = false

-- Physics --
ENT.Physgun = false
ENT.Gravgun = false
ENT.Gravity = false

if SERVER then
  AddCSLuaFile()

	function ENT:_BaseInitialize()
		self:SetNoDraw(true)
		ParticleEffectAttach("burning_gib_01",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self.m_speed = self.m_speed || 200
	end
	function ENT:OnContact(ent)
		self:EmitSound("codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_flamewave_strt.wav")
		ParticleEffectAttach("fx_hellhound_explosion",PATTACH_ABSORIGIN,self,0)
		self:RadiusDamage(65,DMG_BURN,65)
		SafeRemoveEntityDelayed(self,0.1)
	end
end
