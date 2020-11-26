if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Wuestling"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/follower.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 3000

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 80
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
		if not self:IsRunning() then
			self:PlaySequenceAndMove("att"..math.random(6),1,self.PossessionFaceForward)
		else
			self:EmitSound("codz_megapack/ww2/fol/vox/zmb_vox_fol_charge_attack_0"..math.random(5)..".wav",511)
			util.ScreenShake(self:GetPos(),100000,500000,1,50000)
			self:PlaySequenceAndMove("charge_att",1,self.PossessionFaceForward)
		end
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("traverse",1,self.PossessionFaceForward)
		if self:IsOnGround() then self:PlaySequenceAndMoveAbsolute("land",1,self.PossessionFaceForward) end
	end}},
	[IN_DUCK] = {{coroutine = true,onkeydown = function(self)
		if self:GetCooldown("Fol_ToggleWalk")>0 then return end
		self:SetCooldown("Fol_ToggleWalk",1)
		if self.WalkAnimation == "walk" then self.WalkAnimation = "run"
		else self.WalkAnimation = "walk" end
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

if SERVER then
function ENT:OnStartClimbing(ladder, height,down)
	-- self:SetPos(self:LocalToWorld(Vector(-69,0,0)))
	-- self:PlaySequenceAndMoveAbsolute("climb_1", 1, function()
		-- if isvector(ladder) then
			-- self:FaceTowards(ladder)
		-- else self:FaceTowards(ladder:GetBottom()) end
	-- end)
end
function ENT:WhileClimbing(ladder, left)
	self:ResetSequence("climb_2")
	if left < 40 then return true end 
end
function ENT:OnStopClimbing()
	self:Timer(0.1,self.EmitSound, self.SOUND_EVTTABLE["custom_follower_mace_imp"][1]..math.random(self.SOUND_EVTTABLE["custom_follower_mace_imp"][2])..".wav")
	self:PlaySequenceAndMoveAbsolute("climb_3")
end

function ENT:OnSpawn()
	self:EmitSound("codz_megapack/zmb/ai/standard/dirt_0"..math.random(0,1)..".wav")
	ParticleEffect("strider_impale_ground",self:GetPos(),self:GetAngles(),self)	
	for i=1,60 do
		self:Timer(0.1*i,function()
			ParticleEffect("advisor_healthcharger_break",self:LocalToWorld(Vector(20,0,-10)),self:GetAngles(),self)
		end)
	end
	self:PlaySequenceAndMove("emerge")
	self.OnIdleSounds = {
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_01.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_02.wav",
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_03.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_04.wav",
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_05.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_06.wav",
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_growl_lev4_07.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_01.wav",
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_02.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_03.wav",
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_04.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_05.wav",
		"codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_06.wav","codz_megapack/ww2/fol/vox/zmb_vox_fol_preattack1_07.wav"
	}
	self.IdleSoundDelay = math.random(5)^2
end
function ENT:OnPossessed()self.RunAnimation = "charge_run" end
function ENT:OnDispossessed()self.RunAnimation = "run" end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:AddPlayersRelationship(D_HT,2)
	
	self.WalkAnimation = "walk"
	self.RunAnimation = "run"
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {
		["zmb_follower_mace_whoosh"] = {"codz_megapack/ww2/fol/zmb_follower_mace_whoosh_0", 5},
		["custom_follower_mace_imp"] = {"codz_megapack/ww2/fol/zmb_follower_mace_imp_ground_0", 5},
		["custom_follower_hand_down"] = {"codz_megapack/ww2/global/zmb_death_bodyfall_01.wav"},
	}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-20,0), Vector(15, 20, 85))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		if self.Charging then
			self:Attack({
				damage = 60,
				type = DMG_CRUSH,
				range=256,
				angle=360,
				viewpunch = Angle(20, math.random(-10, 10), 0),
			}) 
		else
			self:Attack({
				damage = 60,
				type = DMG_BLAST,
				viewpunch = Angle(20, math.random(-10, 10), 0),
			}, 
			function(self, hit)
				if #hit > 0 then
					self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_imp_0"..math.random(5)..".wav",100,math.random(95,105))
					self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_gore_0"..math.random(5)..".wav",100,math.random(95,105))
				end
			end)
		end
	elseif e == "step" then 
		if (self:IsPossessed() and self:IsRunning()) or self.Charging then
			self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_sprint_large_default_0"..math.random(9)..".wav",80)
			util.ScreenShake(self:GetPos(),100000,500000,0.2,300)
			self:BlastAttack({
				damage = 1,
				type = DMG_BLAST,
				viewpunch = Angle(20, math.random(-10, 10), 0),
				relationships={D_LI,D_NU,D_HT,D_FR}
			}) 
		else
			self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_walk_large_default_0"..math.random(9)..".wav",80)
			util.ScreenShake(self:GetPos(),100000,500000,0.2,150)
		end
	-- elseif e == "start_ragdoll" then self:BecomeRagdoll(DamageInfo())
	elseif e == "bodyfall" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	elseif e == "aud_follower_charge_vox" then 
		self:EmitSound("codz_megapack/ww2/fol/vox/zmb_vox_fol_charge_attack_0"..math.random(5)..".wav",511)
		util.ScreenShake(self:GetPos(),100000,500000,1,50000)
	elseif e == "aud_follower_mace_ground_imp" then 
		self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_imp_ground_0"..math.random(5)..".wav",511)
		for i=1,(self:IsPossessed() and 2 or 5) do ParticleEffect("bo3_panzer_landing",self:LocalToWorld(Vector(20,0,0)), Angle(0,0,0), nil) end
		util.ScreenShake(self:GetPos(),100000,500000,0.5,512)
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
	end
end

function ENT:OnMeleeAttack(enemy)
	if self.Charging then
		self:PlaySequenceAndMove("charge_att")
		self.RunAnimation = "run"
		self.Charging = false
		self.MeleeAttackRange = 80
	else
		self:PlaySequenceAndMove("att"..math.random(6),1,self.FaceEnemy)
		self:EmitSound("codz_megapack/ww2/fol/vox/zmb_vox_fol_taunt_lrg_0"..math.random(8)..".wav",511)
	end
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

-- function ENT:OnNewEnemy(enemy)
	-- self:CallInCoroutine(function(self,delay)
		-- if delay > 0.1 then return end
		-- self:PlaySequenceAndMove("berserk",1,self.FaceEnemy)
	-- end)
-- end

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	if dmg:IsDamageType(DMG_BLAST) then
		self.Flinching = true
		self:CICO(function()
			self:EmitSound("codz_megapack/ww2/fol/vox/zmb_vox_fol_pain_lrg_0"..math.random(9)..".wav",511)
			self:PlaySequenceAndMove("kb_1")
			self:PlaySequenceAndMove("kb_2")
			self.Flinching = false
		end)
	elseif (dmg:GetDamage()>=40) and (math.random(50)<=12) then
		self.Flinching = true
		self:CICO(function()
			self:EmitSound("codz_megapack/ww2/fol/vox/zmb_vox_fol_pain_lrg_0"..math.random(9)..".wav",511)
			self:PlaySequenceAndMove("flinch"..math.random(3))
			self.Flinching = false
		end)
	elseif not self.Charging and not self:IsPossessed() and dmg:IsBulletDamage() then
		self.Flinching = true
		self:CICO(function()
			self.RunAnimation = "charge_run"
			self.Charging = true
			self.MeleeAttackRange = 130
			self:PlaySequenceAndMove("charge_react")
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	self.OnIdleSounds = {}
	self:EmitSound("codz_megapack/ww2/fol/vox/zmb_vox_fol_death_0"..math.random(5)..".wav",511)
	-- if dmg:IsDamageType(DMG_SHOCK) then
		-- self:PlaySequenceAndMove("death_tesla"..math.random(2))
	-- else
		if math.random(2)==1 then
			self:Timer(1,self.EmitSound,"codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
			self:PlaySequenceAndMove("death1")
		else
			self:Timer(77/30,self.EmitSound,"codz_megapack/ww2/global/melee/zmb_slash_0"..math.random(9)..".wav",70,80)			
			self:Timer(118/30,self.EmitSound,"codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")			
			self:PlaySequenceAndMove("death2")
		end
	-- end
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
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
