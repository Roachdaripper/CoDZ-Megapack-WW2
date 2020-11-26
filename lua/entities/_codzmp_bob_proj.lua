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
		ParticleEffectAttach("ber_bolt_stick",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self.m_speed = self.m_speed || 200
	end
	function ENT:OnContact(ent)
		if ent:GetClass() == self:GetClass() then return false end
		self:EmitSound("codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		ParticleEffectAttach("bo3_mangler_blast",PATTACH_ABSORIGIN,self,0)
		self:RadiusDamage(65,DMG_SHOCK,65)
		SafeRemoveEntityDelayed(self,0.1)
	end
function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:GetTarget()return self.Target end
function ENT:SetTarget(target)self.Target = target end

function ENT:CustomThink()
	local ent = self:GetTarget()
	if(IsValid(ent)) then
		if ent:IsPlayer() and not ent:Alive() then return end
		local phys = self:GetPhysicsObject()
		if(phys:IsValid()) then
			local pos = ent:WorldSpaceCenter() +ent:GetVelocity() *0.5
			local dirVel = self:GetVelocity():GetNormal()
			local dir = (pos -self:GetPos()):GetNormal()
			local dotProd = dir:DotProduct(dirVel)
			if(dotProd <= 0) then phys:SetVelocity(phys:GetVelocity() *0.75) end
			phys:ApplyForceCenter((pos -self:GetPos()):GetNormal() *self.m_speed/10)
		end
	elseif IsValid(self.entOwner) and self.entOwner:IsPossessed() then
		local phys = self:GetPhysicsObject()
		if(phys:IsValid()) then
			phys:ApplyForceCenter(self.entOwner:GetAimVector() *self.m_speed/5)
		end	
	else
		local phys = self:GetPhysicsObject()
		if(phys:IsValid()) then
			phys:ApplyForceCenter(self:GetForward() *self.m_speed/10)
		end
	end
end
end
