if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Brenner"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/fireman.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 3000

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 110
ENT.RangeAttackRange = 512
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
		if self.FT then self:StopFT() end
		self:PlaySequenceAndMove("att"..math.random(2),1,self.PossessionFaceForward)
	end}},
	[IN_RELOAD] = {{coroutine = true,onkeydown = function(self)
		if self.FT then self:StopFT() end
		self:EmitSound("codz_megapack/ww2/fireman/vox/zvox_fir_spawn_01.wav",80)
		self:EmitSound("codz_megapack/ww2/fireman/vox/zvox_fir_intro_roar.wav",511)
		self.Taunting = true
			self:PlaySequenceAndMove("taunt",1,self.PossessionFaceForward)
		self.Taunting = false
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
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		if not self.CanFT then if self.FT then self:StopFT()end return end
		if not self.FT then
			self.FT = true
			self:EmitSound("codz_megapack/zmb/ai/mechz2/v2/flame/start.wav")
			ParticleEffectAttach("bo3_panzer_flame",PATTACH_POINT_FOLLOW,self,2)
		end
	end}},
	[IN_JUMP] = {{coroutine=false,onkeydown=function(self)self:Jump(350)end}},
	[IN_ATTACK3] = {{coroutine = true,onkeydown = function(self)
		self:Suicide()
	end}},
}

-- Climbing --
ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = math.huge
ENT.LedgeDetectionDistance = 30
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 10
ENT.ClimbSpeed = 600
ENT.ClimbUpAnimation = "climb_2"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 0)

ENT.UseWalkframes = true

game.AddParticles("particles/blackops3zombies_fx.pcf")
	PrecacheParticleSystem("bo3_panzer_landing")
	PrecacheParticleSystem("bo3_panzer_flame")

if SERVER then
function ENT:WhileClimbing(ladder, left)
	self:ResetSequence("climb_2")
	if left < 20 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_3")
end

function ENT:OnSpawn()
	self:EmitSound("codz_megapack/ww2/fireman/vox/zvox_fir_spawn_01.wav",80)
	self:EmitSound("codz_megapack/ww2/fireman/vox/zvox_fir_intro_roar.wav",511)
	self:PlaySequenceAndMove("emerge")
	self.OnIdleSounds = {
		"codz_megapack/ww2/fireman/vox/zvox_fir_charge_01.wav","codz_megapack/ww2/fireman/vox/zvox_fir_charge_02.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_charge_03.wav","codz_megapack/ww2/fireman/vox/zvox_fir_charge_04.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_charge_05.wav","codz_megapack/ww2/fireman/vox/zvox_fir_charge_06.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_charge_07.wav","codz_megapack/ww2/fireman/vox/zvox_fir_charge_08.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_charge_09.wav","codz_megapack/ww2/fireman/vox/zvox_fir_taunt_01.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_taunt_02.wav","codz_megapack/ww2/fireman/vox/zvox_fir_taunt_03.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_taunt_04.wav","codz_megapack/ww2/fireman/vox/zvox_fir_taunt_05.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_taunt_06.wav","codz_megapack/ww2/fireman/vox/zvox_fir_taunt_07.wav",
		"codz_megapack/ww2/fireman/vox/zvox_fir_taunt_08.wav","codz_megapack/ww2/fireman/vox/zvox_fir_taunt_09.wav"
	}
	self.IdleSoundDelay = math.random(5)
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	
	self.WalkAnimation = "walk"
	self.RunAnimation = "run"
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {
		["zmb_fireman_intro_jump_land"] = {"codz_megapack/ww2/brute/zmb_fs_walk_brute_default2_09.wav"},
		["zmb_fireman_axe_whoosh"] = {"codz_megapack/ww2/fol/zmb_follower_mace_whoosh_0",5}
	}
	self.CanFT = true
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-20,0), Vector(15, 20, 85))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 40,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/fireman/zmb_axe_hit_0"..math.random(5)..".wav",100,math.random(95,105))
			else
				self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_whoosh_0"..math.random(5)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "step" then 
		if self:IsRunning() then
			self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_sprint_large_default_0"..math.random(9)..".wav",80)
			util.ScreenShake(self:GetPos(),100000,500000,0.2,300)
		else
			self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_walk_large_default_0"..math.random(9)..".wav",80)
			util.ScreenShake(self:GetPos(),100000,500000,0.2,150)
		end
	elseif e == "bodyfall" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	elseif e == "land" then 
		self:EmitSound("codz_megapack/ww2/brute/zmb_fs_walk_brute_default2_0"..math.random(8)..".wav",511)
		ParticleEffect("bo3_panzer_landing",self:LocalToWorld(Vector(20,0,0)), Angle(0,0,0), nil)
		util.ScreenShake(self:GetPos(),100000,500000,0.5,512)
	elseif e == "flame_start" and not self.FT then
		self.FT = true
		self:EmitSound("codz_megapack/zmb/ai/mechz2/v2/flame/start.wav")
		ParticleEffectAttach("bo3_panzer_flame",PATTACH_POINT_FOLLOW,self,2)
	elseif e == "flame_end" then self:StopFT()
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
	end
end

sound.Add({
	channel = CHAN_BODY,
	name = "zmb_ai_panzer_flamethrower_loop",
	level = 100,
	sound = "codz_megapack/zmb/ai/mechz2/v2/flame/loop.wav"
})
function ENT:CustomThink()
	if self.FT then
		if self:GetCooldown("zmb_ai_mechz_ft_loop")<=0 then
			self:EmitSound("zmb_ai_panzer_flamethrower_loop")
			self:SetCooldown("zmb_ai_mechz_ft_loop",3.141)
		end
		if self:GetCooldown("PanzerFT")<=0 then
			if not self.Taunting 
			and (self:IsPossessed() and not self:GetPossessor():KeyDown(IN_ATTACK2)) then
				self:StopFT()
			end
			self:SetCooldown("PanzerFT",0.1)
			if file.Exists("entities/vfire/shared.lua", "LUA") then
				-- self:Ignite(999,0)
				local att = self:GetAttachment(2)
				local pos = util.QuickTrace(att.Pos,att.Ang:Forward()*300,{self,self:GetPossessor()}).HitPos

				local life = math.Rand(10, 50)
				local feed = life / 200
				if math.random(1, 10) == 1 then
					feed = feed * 6
				end
				local vel = VectorRand() * math.Rand(2, 4)
				CreateVFireBall(life, feed, pos, vel)
			end
			self:Attack({range=300,damage = math.random(5), type = DMG_BURN, viewpunch=Angle(0,0,0)})
		end
	end
end

function ENT:StopFT()
	self:StopSound("zmb_ai_panzer_flamethrower_loop")
	self:EmitSound("codz_megapack/zmb/ai/mechz2/v2/flame/stop.wav")
	self:StopParticles()
	self.FT = false
end

  -- AI --
function ENT:OnMeleeAttack(enemy)
	if self.CanFT then return end
	self:PlaySequenceAndMove("att"..math.random(2),1,self.FaceEnemy)
end

function ENT:OnRangeAttack(enemy)
	if not self.CanFT then return end
	if self:GetHullRangeSquaredTo(enemy) > 350*350 and self.FT then self:StopFT() return end
	if not self.FT and self:GetHullRangeSquaredTo(enemy) < 350*350 then
		self.FT = true
		self:EmitSound("codz_megapack/zmb/ai/mechz2/v2/flame/start.wav")
		ParticleEffectAttach("bo3_panzer_flame",PATTACH_POINT_FOLLOW,self,2)
	end
end
function ENT:OnOtherKilled(v,dmginfo)
	if (dmginfo:GetAttacker() == self) and self.FT then self:StopFT() end
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnNewEnemy(enemy)
	self:CallInCoroutine(function(self,delay)
		if delay > 0.1 then return end
		self:PlaySequenceAndMove("enrage",1,self.FaceEnemy)
	end)
end
ENT.BPHP = 200
function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	if hg==2 and self.CanFT then
		if (self.BPHP-dmg:GetDamage()) <=0 then
			self:EmitSound("codz_megapack/ww2/fireman/zmb_fireman_gas_tank_destroyed.wav",511)
			self:StopFT()
			self.CanFT = false
		else
			self.BPHP = self.BPHP-dmg:GetDamage()
		end
	elseif dmg:IsDamageType(DMG_BLAST) or ((dmg:GetDamage()>=8) and (math.random(100)<=3)) then
		self.Flinching = true
		self:CICO(function()
			self:PlaySequenceAndMove("flinch"..math.random(3))
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	self.OnIdleSounds = {}
	self:EmitSound("codz_megapack/ww2/fireman/vox/zvox_fir_death_0"..math.random(8)..".wav")
	self:PlaySequenceAndMove("death"..math.random(2))
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
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
