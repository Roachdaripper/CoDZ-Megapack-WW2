
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.PrintName		= "Lich Crack"
ENT.Author			= "Roach"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

AccessorFunc(ENT,"m_fRadius","Radius",FORCE_NUMBER)
AccessorFunc(ENT,"m_fTTL","TimeToLive",FORCE_NUMBER)

if SERVER then
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() -Vector(0,0,32768),
		filter = self,
		mask = MASK_NPCWORLDSTATIC
	})
	self.PCF = "env_fire_large" -- What particle to render
	self.FlameOffset = 32 -- How far apart the particles are
	self.m_nextMove = CurTime() +0.1
	self.m_numFlames = 1 -- How many particles to spawn
	self.m_tmRemove = 64-- How far away the entity goes
	self:SetPos(self:GetFloorPos(self:GetPos()))
	self:SpawnFlames()
end

function ENT:SetEntityOwner(ent)
	self.entOwner = ent
	self:SetOwner(ent)
end

function ENT:GetEntityOwner() return self.entOwner || nil end

function ENT:DealFlameDamage(pos)
	local owner = self:GetEntityOwner() or self:GetOwner()
	local attacker = owner:IsValid() && owner || self
	for _, ent in ipairs(ents.FindInSphere(pos,160)) do
		if (ent == attacker) or (ent == self) then continue end
		if SERVER then 
			ent:TakeDamage(ent:IsNPC() && 24 || math.random(1,5), attacker, nil)
			ent:Ignite((ent:IsNPC() or ent:IsPlayer()) and 2 or 0.1,50)
		end
	end
end

function ENT:GetFloorPos(pos)
	local tr = util.TraceLine({
		start = pos +Vector(0,0,130),
		endpos = pos -Vector(0,0,550),
		filter = self,
		mask = MASK_NPCWORLDSTATIC
	})
	return tr.HitPos
end

function ENT:SpawnFlames()
	local pos = self:GetPos()
	local dir = self:GetRight()
	local offset = dir *self.FlameOffset
	self:StopParticles()
	local ang = self:GetAngles()
	ParticleEffect(self.PCF,pos,ang,self)
	self:DealFlameDamage(pos)
	for i = 1,self.m_numFlames -1 do
		local scDir
		if(i %2 == 0) then scDir = -1
		else scDir = 1 end
		local posTgt = self:GetFloorPos(pos +offset *scDir)
		ParticleEffect(self.PCF,posTgt,ang,self)
		self:DealFlameDamage(posTgt)
		if(i %2 == 0) then offset = offset +dir *self.FlameOffset end
	end
	self.m_tmRemove = self.m_tmRemove -1
	if(self.m_tmRemove == 0) then SafeRemoveEntity(self) end
end

function ENT:Think()
	if(CurTime() >= self.m_nextMove) then
		self:SetPos(self:GetPos() +self:GetForward() *120)
		self.m_nextMove = CurTime() +0.1
		self.m_numFlames = self.m_numFlames +2
		self:SpawnFlames()
	end
end
end