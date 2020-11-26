if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Bomber Zombie"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/bmb.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 1000

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 110
ENT.ReachEnemyRange = 70
ENT.AvoidEnemyRange = 0
ENT.FollowPlayers = true

-- Detection --
ENT.EyeBone = "j_head"
ENT.EyeOffset = Vector(7.5, 0, 5)
ENT.EyeAngle = Angle(0, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 30, 20),
    distance = 100
  },
  {
    offset = Vector(1.5, 1, -3),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		if self.LostBomb then
			self:PlaySequenceAndMove("att"..math.random(3),1,self.PossessionFaceForward)
		else
			self:DoExplode()
		end
	end}},
	[IN_USE] = {{coroutine = true,onkeydown = function(self)
		for k,door in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,75)), 50)) do
			if IsValid(door) and door:GetClass() == "prop_door_rotating" then
				door:Fire("openawayfrom",self:GetName())
			elseif IsValid(door) and string.find(door:GetClass(),"door") 
			and door:GetClass() != "prop_door_rotating" then
				door:Fire("open")
			end
		end
	end}},
	[IN_JUMP] = {{coroutine=false,onkeydown=function(self)self:Jump(350)end}},
	[IN_ATTACK3] = {{coroutine = true,onkeydown = function(self)self:Suicide()end}},
}

ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = math.huge
ENT.LedgeDetectionDistance = 30
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 10
ENT.ClimbSpeed = 400
ENT.ClimbUpAnimation = "climb_2"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 0)

ENT.UseWalkframes = true

game.AddParticles("particles/blackops3zombies_fx.pcf")
	PrecacheParticleSystem("bo3_panzer_landing")
	PrecacheParticleSystem("bo3_panzer_explosion")

if SERVER then

function ENT:OnSpawn()
	self:EmitSound("codz_megapack/ww2/bomber/vox/zvox_bmb_spawn_01.wav",511)
	self:PlaySequenceAndMove("emerge")
	self.OnIdleSounds = {
		"codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev3_01.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev3_02.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev3_03.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev3_04.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev3_05.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev4_01.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev4_02.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev4_03.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev4_04.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_growl_lev4_05.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_01.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_02.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_03.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_04.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_05.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_06.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_07.wav","codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_08.wav",
		"codz_megapack/ww2/bomber/vox/zvox_bmb_taunt_09.wav"
	}
	self.IdleSoundDelay = math.random(5)
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	
	self.WalkAnimation = "walk"..math.random(3)
	self.RunAnimation = "run"
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {["zmb_bomber_hit_head"] = {"codz_megapack/ww2/bomber/zmb_bomber_hit_head_0",7}}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-20,-20,0), Vector(20, 20, 85))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 20,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/global/melee/zmb_hit_0"..math.random(8)..".wav",100,math.random(95,105))
			else
				self:EmitSound("codz_megapack/ww2/global/melee/zmb_slash_0"..math.random(9)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "bodyfall" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
	end
end

function ENT:DoExplode()
	self:SetBodygroup(7,1)
	local pos = self:LocalToWorld(Vector(20,0,0))
	self:BlastAttack({
		damage = 256,
		range=256,
		type = DMG_BLAST,
		viewpunch = Angle(20, math.random(-10, 10), 0),
		relationships={D_LI,D_NU,D_HT,D_FR}
	}) 
	local ent = ents.Create("env_explosion")
	ent:SetPos(pos)
	ent:SetAngles(Angle(0,0,0))
	ent:Spawn()
	ent:SetKeyValue("imagnitude", "128")
	ent:Fire("explode")
	util.ScreenShake(pos,12,400,3,1000)
	ParticleEffect("bo3_panzer_explosion",pos,Angle(0,0,0),nil)
	self:Suicide()
end
function ENT:OnMeleeAttack(enemy)
	if self.LostBomb then
		self:PlaySequenceAndMove("att"..math.random(3),1,self.FaceEnemy)
	else
		self:DoExplode()
	end
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

ENT.BombHP = 45
function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	if dmg:GetAttacker():GetModel() == "models/roach/codz_megapack/ww2/bmb_bomb.mdl" or dmg:GetInflictor():GetModel() == "models/roach/codz_megapack/ww2/bmb_bomb.mdl" then self:Kill() end
	if hg==2 and not self.LostBomb then
		if (self.BombHP-dmg:GetDamage()) <=0 then
			if math.random(2)==1 then
				self:CICO(function()
					if not self.LostBomb then
						self:EmitSound("codz_megapack/ww2/fireman/zmb_fireman_gas_tank_destroyed.wav",511)
						self.LostBomb = true
						self:SetBodygroup(7,1)
						local prop = ents.Create("prop_physics")
						prop:SetPos(self:LocalToWorld(Vector(-10,0,70)))
						prop:SetModel("models/roach/codz_megapack/ww2/bmb_bomb.mdl")
						prop:SetAngles(self:GetAngles())
						prop:Spawn()
						prop:Activate()
						prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
					end
					self:PlaySequenceAndMove("drop_bomb")
					self.Flinching = false
				end)
			else
				self:DoExplode()
			end
		else
			self.BombHP = self.BombHP-dmg:GetDamage()
		end
	elseif (dmg:GetDamage()>=8) and (math.random(100)<=2) then
		self.Flinching = true
		self:CICO(function()
			self:PlaySequenceAndMove("flinch"..math.random(3))
			self.Flinching = false
		end)
	end
end

function ENT:ShouldRun()
	return not self.LostBomb and (self:HasEnemy() and (self:Visible(self:GetEnemy()) and (self:GetHullRangeSquaredTo(self:GetEnemy()) < 400^2)))
end

function ENT:OnDeath(dmg)
	self.OnIdleSounds = {}
	self:EmitSound("codz_megapack/ww2/bomber/vox/zvox_bmb_death_0"..math.random(8)..".wav")
	self:PlaySequenceAndMove("death"..math.random(3))
	self:SetCollisionBounds(Vector(-1,-1,0),Vector(1,1,1))
	self:PauseCoroutine(false)
end

function ENT:OnUpdateAnimation()
	if self:IsDead() then return end
	if not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
	elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
	elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
	else return self.IdleAnimation, self.IdleAnimRate end
end

function ENT:CICO(callback)
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function()
		callback(self)
		self.BehaveThread = oldThread
	end)
end

function ENT:OnStartClimbing(ladder, height,down)
	self:SetPos(self:LocalToWorld(Vector(-69,0,0)))
	self:PlaySequenceAndMoveAbsolute("climb_1", 1, function()
		if isvector(ladder) then
			self:FaceTowards(ladder)
		else self:FaceTowards(ladder:GetBottom()) end
	end)
end
function ENT:WhileClimbing(ladder, left)
	-- self:ResetSequence("climb_2")
	if left < 100 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_3")
end
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
