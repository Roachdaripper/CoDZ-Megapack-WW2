if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Panzermoerder"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/panzermorder.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 600

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 80
ENT.RangeAttackRange = math.huge
ENT.ReachEnemyRange = 70
ENT.AvoidEnemyRange = 0
ENT.FollowPlayers = true

-- Detection --
ENT.EyeBone = "tongue"
ENT.EyeOffset = Vector(0, 0, 5)
ENT.EyeAngle = Angle(0, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(-20, 90, 80),
    distance = 100
  },
  {
    offset = Vector(0, 0, 0),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self) -- Light Attacks
		if not self:IsMoving() and not self:IsRunning() then
			self:PlaySequenceAndMove("s2_zom_brt_stand_atk_v1",1,self.PossessionFaceForward)
			
		elseif self:IsRunning() then
			self:PlaySequenceAndMove("s2_zom_brt_run_attack_v1",1,self.PossessionFaceForward)
			
		elseif self:IsMoving() and not self:IsRunning() then
			self:PlaySequenceAndMove("s2_zom_brt_walk_attack_v"..math.random(2),1,self.PossessionFaceForward)
		end
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self) -- Heavy Attacks
		if not self:IsRunning() then
			self:PlaySequenceAndMove("s2_zom_brt_walk_attack_ground_v"..math.random(2),1,self.PossessionFaceForward)
		end
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("s2_zom_brt_walk_trav_exit_v1",1,self.PossessionFaceForward)
	end}},
	[IN_RELOAD] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("s2_zom_brt_roar",1,self.PossessionFaceForward)
	end}},
	[IN_ATTACK3] = {{coroutine = true,onkeydown = function(self)
		self:Suicide()
	end}},
}

-- Climbing --
ENT.ClimbLedges = false
ENT.ClimbProps = false
ENT.ClimbLadders = false

ENT.UseWalkframes = true

game.AddParticles("particles/blackops3zombies_fx.pcf")
	PrecacheParticleSystem("bo3_panzer_landing")

if SERVER then

function ENT:OnSpawn()
	self:PlaySequenceAndMove("s2_zom_brt_roar")
end

function ENT:OnLandOnGround()
	if self:IsDead() then return end
	self:CICO(function()self:PlaySequenceAndMove("s2_zom_brt_land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:AddPlayersRelationship(D_HT,2)
	
	self.WalkAnimation = "s2_zom_brt_walk"
	self.RunAnimation = "s2_zom_brt_run"
	self.IdleAnimation = "s2_zom_brt_idle"
	self.JumpAnimation = "s2_zom_brt_glide"
	
	self.SOUND_EVTTABLE = {
		["s2_zom_brt_walk_trav_exit_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_walk_trav_exit_v1_0", 3},
		["s2_zom_brt_run"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_run_0", 5},
		["s2_zom_brt_roar"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_roar_0", 5},
		["s2_zom_brt_stun_up_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_stun_up_v1_0", 3},
		["s2_zom_brt_stun_loop_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_stun_loop_v1_0", 3},
		["s2_zom_brt_stun_down_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_stun_down_v1_0", 3},
		["s2_zom_brt_walk_attack_v2"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_walk_attack_v2_0", 3},
		["s2_zom_brt_walk_attack_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_walk_attack_v1_0", 3},
		["s2_zom_brt_walk_attack_ground_v2"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_walk_attack_ground_v2_0", 3},
		["s2_zom_brt_walk_attack_ground_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_walk_attack_ground_v1_0", 3},
		["s2_zom_brt_stand_atk_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_stand_atk_v1_0", 3},
		["s2_zom_brt_stand_atk_lurch_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_stand_atk_lurch_v1_0", 3},
		["s2_zom_brt_run_attack_v1"] = {"codz_megapack/ww2/brute/vox/s2_zom_brt_run_attack_v1_0", 5}
	}
	-- self:SetModelScale(1.5,0)
	self:Timer(0.1,self.SetCollisionBounds, Vector(-80,-80,0), Vector(80, 80, 220))
	self:Timer(0.2,self.PhysicsInitShadow)
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 80,
			type = DMG_CRUSH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_imp_0"..math.random(5)..".wav",100,math.random(95,105))
				self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_gore_0"..math.random(5)..".wav",100,math.random(95,105))
			end
		end)
	
	elseif e == "footstep_walk_right_brute" or e == "footstep_walk_left_brute" then 
		if self:IsRunning() then
			self:EmitSound("codz_megapack/ww2/brute/zmb_fs_run_brute_default2_0"..math.random(9)..".wav",80)
			util.ScreenShake(self:GetPos(),100000,500000,0.2,300)
		else
			self:EmitSound("codz_megapack/ww2/brute/zmb_fs_walk_brute_default2_0"..math.random(7)..".wav",80)
			util.ScreenShake(self:GetPos(),100000,500000,0.2,150)
		end
	
	-- elseif e == "start_ragdoll" then self:BecomeRagdoll(DamageInfo())
	elseif e == "bodyfall_large" then 
		self:EmitSound("codz_megapack/ww2/brute/zmb_fs_walk_brute_default2_0"..math.random(8,9)..".wav",511,math.random(80,100))
		for i=1,3 do ParticleEffect("bo3_panzer_landing",self:LocalToWorld(Vector(math.random(-20,20),0,0)), Angle(0,0,0), nil) end
		util.ScreenShake(self:GetPos(),100000,500000,1,512)
	elseif e == "fx_vfx zmb_brute_slam" then 
		self:BlastAttack({
			damage = 180,
			type = DMG_CRUSH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}) 
		self:EmitSound("codz_megapack/ww2/brute/zmb_fs_walk_brute_default2_0"..math.random(8,9)..".wav",511,math.random(80,100))
		util.ScreenShake(self:GetPos(),100000,500000,0.5,512)
		ParticleEffect("bo3_panzer_landing",self:LocalToWorld(Vector(math.random(-20,20),-30,0)), Angle(0,0,0), nil)
	end
	
	if string.StartWith(e, "TurnSpeed_") then
		local nb = tonumber(string.sub(e, 11))
		self:SetMaxYawRate(nb)
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
	end
end

function ENT:OnMeleeAttack(enemy)
	if self.Charging then
		self.Charging = false
		self:PlaySequenceAndMove("s2_zom_brt_run_attack_v1",1,self.FaceEnemy)
	end
	
	if not self:IsMoving() and not self:IsRunning() then
		local atk = math.random(1,2)
		if atk == 1 then
			self:PlaySequenceAndMove("s2_zom_brt_stand_atk_v1",1,self.FaceEnemy)
		else
			self:PlaySequenceAndMove("s2_zom_brt_walk_attack_ground_v"..math.random(2),1,self.FaceEnemy)
		end

	elseif self:IsMoving() and not self:IsRunning() then
		self:PlaySequenceAndMove("s2_zom_brt_walk_attack_v"..math.random(2),1,self.FaceEnemy)

	end
end
function ENT:OnRangeAttack(enemy)
	if self:GetHullRangeSquaredTo(enemy) <= 2000*2000 then return end
	self.Charging = true
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnNewEnemy(enemy)
	self:CallInCoroutine(function(self,delay)
		if delay > 0.1 then return end
		self:PlaySequenceAndMove("s2_zom_brt_roar",1,self.FaceEnemy)
	end)
end

function ENT:ShouldRun()
	return self.Charging
end

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDown() then return end
	if dmg:IsDamageType(DMG_BLAST) or ((dmg:GetDamage()>=40) and (math.random(50)<=12)) then
		self.Flinching = true
		self.Charging = false
		self:CICO(function()
			self:PlaySequenceAndMove("s2_zom_brt_stand_atk_lurch_v1")
			self.Flinching = false
		end)
	end
end

function ENT:OnFatalDamage()return true end
function ENT:OnDowned(dmg)
	self.Charging = false
	self:PlaySequenceAndMove("s2_zom_brt_stun_down_v1")
	
	local duration = 30
	self:SetHealthRegen(math.ceil((self:GetMaxHealth()-self:Health())/duration))
	while self:Health() < self:GetMaxHealth() do
		self:PlaySequenceAndMove("s2_zom_brt_stun_loop_v1")
		self:YieldCoroutine(false)
	end
	self:PlaySequenceAndMove("s2_zom_brt_stun_up_v1")
	self:SetHealthRegen(0)
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
