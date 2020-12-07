if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Stadtjaeger"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/bob.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 2000

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 80
ENT.RangeAttackRange = 2600
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
		self:PSAM("att"..math.random(2),1,self.PossessionFaceForward)
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		self:PSAM("infect",1,self.PossessionFaceForward)
	end}},
	[IN_RELOAD] = {{coroutine = true,onkeydown = function(self)
		self:Timer(57/30,function()
			self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",511)
		end)
		self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_buildup_0"..math.random(5)..".wav")
		self:Timer(175/30,self.EmitSound,"codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		self:Timer(175/30,self.StopParticles)
		self:PSAM("powerup",1,self.PossessionFaceForward)
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("traverse",1,self.PossessionFaceForward)
		if self:IsOnGround() then self:PlaySequenceAndMoveAbsolute("land",1,self.PossessionFaceForward) end
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
	PrecacheParticleSystem("bo3_napalm_fs")
	PrecacheParticleSystem("bo3_mangler_blast")
	PrecacheParticleSystem("bo3_panzer_landing")
game.AddParticles("particles/hellhound.pcf")
game.AddParticles("particles/hellhound_2.pcf")
	PrecacheParticleSystem("fx_hellhound_explosion")
game.AddParticles("particles/zmb_ber_bob_weapon_glow.pcf")
	PrecacheParticleSystem("zmb_ber_bob_weapon_glow")
game.AddParticles("particles/ber_bolt_stick.pcf")
	PrecacheParticleSystem("ber_bolt_stick")

if SERVER then
function ENT:OnStartClimbing(ladder, height,down)
	self:SetPos(self:LocalToWorld(Vector(-80,0,0)))
	self:PlaySequenceAndMoveAbsolute("climb_1", 1, function()
		if isvector(ladder) then
			self:FaceTowards(ladder)
		else self:FaceTowards(ladder:GetBottom()) end
	end)
end
function ENT:WhileClimbing(ladder, left)
	self:PlaySequence("climb_2")
	if left < 40 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_3")
end

function ENT:OnSpawn()
	self:Timer(16/30,function()util.ScreenShake(self:GetPos(),3,100,2,5000)end)
	self:PSAM("emerge")
end
function ENT:PSAM(...)
	self:PlaySequenceAndMove(...)
	self:EmitSound("codz_megapack/ww2/bob/zmb_berl_bob_smoke_atk_end.wav")
	self:ElectricalDischarge(math.Rand(0.2,0.8), math.random(3,5))
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:CICO(function()self:PSAM("land")end)
end
function ENT:OnCombineBall(ball)
	local dmg = DamageInfo()
	dmg:SetAttacker(IsValid(ball:GetOwner()) and ball:GetOwner() or ball)
	dmg:SetInflictor(ball)
	dmg:SetDamageType(DMG_BLAST)
	dmg:SetDamage(1)
	
	self:TakeDamageInfo(dmg)
	ball:Fire("explode", 0)
	
	return true
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:AddPlayersRelationship(D_HT,2)
	
	self.WalkAnimation = "walk"
	self.RunAnimation = "run"
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {
		["bob_power_up_vox"] = {"codz_megapack/ww2/bob/vox/zvox_bob_attack_lrg_0", 7},
		["zmb_bob_gun_buildup"] = {"codz_megapack/ww2/bob/zmb_bob_gun_buildup_0", 5},
		["bob_punch_vox"] = {"codz_megapack/ww2/bob/vox/zvox_bob_snarl_0", 6},
		["bob_roar_vox"] = {"codz_megapack/ww2/bob/vox/zvox_bob_roar_0", 3},
		["bob_intro_vox"] = {"codz_megapack/ww2/bob/vox/zvox_bob_intro.wav"},
		["zmb_bob_intro_land_main"] = {"codz_megapack/ww2/bob/zmb_bob_intro_land_main.wav"},
		["zmb_berl_bob_death_explo_c"] = {"common/null.wav"},
		["zmb_berl_bob_death_explo_b"] = {"codz_megapack/ww2/bob/zmb_berl_bob_death_explo",2},
		["zmb_berl_bob_death_explo_a"] = {"codz_megapack/ww2/bob/zmb_berl_bob_death_explo",2},
		["zmb_berl_bob_death_shot"] = {"codz_megapack/ww2/bob/zmb_berl_bob_death_shot.wav"},
		["bob_death_seq_vox"] = {"codz_megapack/ww2/bob/vox/zvox_bob_death_seq.wav"},
		["zmb_bob_melee_whoosh"] = {"codz_megapack/ww2/bob/zmb_bob_melee_whoosh_0", 5},
	}
	self.VFX_EVTTABLE = {
		["zmb_asn_atk_wisp"]="advisor_healthcharger_break",
		["bob_land_impact"]="bo3_panzer_landing",
		["bob_ambient_smoke"]="smoke_exhaust_01",
		["bob_weapon_glow"]="zmb_ber_bob_weapon_glow",
		["zmb_ber_bob_wv"]="bo3_mangler_blast",
		["ber_bolt_stick_exp"]="bo3_mangler_blast",
		["ber_bolt_stick"]="ber_bolt_stick",
		["bob_engine_blow"]="fx_hellhound_explosion",
		["zmb_ber_bob_weapon_glow"]="zmb_ber_bob_weapon_glow",
		["bob_engine_fire"]="bo3_napalm_fs"
	}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-20,-20,0), Vector(20, 20, 90))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 25,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_melee_hit_0"..math.random(5)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "bodyfall" or e == "land" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	elseif e == "step" then 
		if self:IsRunning() then
			self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_sprint_large_default_0"..math.random(9)..".wav",80)
		else
			self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_walk_large_default_0"..math.random(9)..".wav",80)
		end
	elseif e == "ex_torso" then
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,5)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,5)
		local bpos,bang = self:GetBonePosition(self:LookupBone("j_spinelower"))
		ParticleEffect("fx_hellhound_explosion",bpos,bang,self)
	elseif e == "ex_back_r_shoulder" then
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,5)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,5)
		self:EmitSound("codz_megapack/ww2/bob/zmb_berl_bob_death_explo3.wav",511)
		local bpos,bang = self:GetBonePosition(self:LookupBone("j_shoulder_ri"))
		ParticleEffect("fx_hellhound_explosion",bpos+(self:GetForward()*-5),bang,self)
	elseif e == "ex_front_r_shoulder" then
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,5)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,5)
		self:EmitSound("codz_megapack/ww2/bob/zmb_berl_bob_death_explo3.wav",511)
		local bpos,bang = self:GetBonePosition(self:LookupBone("j_shoulder_ri"))
		ParticleEffect("fx_hellhound_explosion",bpos+(self:GetForward()*5),bang,self)
	elseif e == "ex_back_l_shoulder" then
		-- for i=41,44 do self:ManipulateBoneScale(i,Vector(0,0,0)) end
		-- for i=50,56 do self:ManipulateBoneScale(i,Vector(0,0,0)) end
		-- for i=75,87 do self:ManipulateBoneScale(i,Vector(0,0,0)) end
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,5)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,5)
		self:EmitSound("codz_megapack/ww2/bob/zmb_berl_bob_death_explo3.wav",511)
		local bpos,bang = self:GetBonePosition(self:LookupBone("j_shoulder_le"))
		ParticleEffect("fx_hellhound_explosion",bpos+(self:GetForward()*-5),bang,self)
	elseif e == "ex_neck" then
		-- for i=20,21 do self:ManipulateBoneScale(i,Vector(0,0,0)) end
		-- for i=127,129 do self:ManipulateBoneScale(i,Vector(0,0,0)) end
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,1)
		ParticleEffectAttach("env_embers_small",PATTACH_POINT_FOLLOW,self,5)
		ParticleEffectAttach("env_fire_tiny_smoke",PATTACH_POINT_FOLLOW,self,5)
		self:EmitSound("codz_megapack/ww2/bob/zmb_berl_bob_death_explo3.wav",511)
		local bpos,bang = self:GetBonePosition(self:LookupBone("j_neck"))
		ParticleEffect("fx_hellhound_explosion",bpos,bang,self)
	elseif e == "stopvfx_fx" then self:StopParticles()
	elseif e == "fire" then 
		self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",511)
		self.Laser = self:CreateProjectile(nil, {}, "_codzmp_bob_proj")
		self.Laser:SetPos(self:GetAttachment(2).Pos)
		
		self.Laser:SetEntityOwner(self)

		local enemy
		if(!self:IsPossessed()) then enemy = self:GetEnemy()
		else enemy = self:GetClosestEnemy() end
		
		if IsValid(enemy) then 
			if (self:IsPossessed() and self:GetHullRangeSquaredTo(enemy) < 512*512)
			or not self:IsPossessed() then
				self.Laser:SetTarget(enemy)
			end
		end

		local vec = self:GetAttachment(3).Ang:Forward()*200
		self.Laser:SetVelocity(Vector(vec.x,vec.y,10))
		self:StopParticles()
	elseif e == "aud_bob_charge_run_vox" then
		if math.random(3)==1 then
			self:EmitSound("codz_megapack/ww2/bob/vox/zvox_bob_charge_0"..math.random(3)..".wav",511)
			util.ScreenShake(self:GetPos(),100000,500000,1,50000)
		end
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
	elseif evt[1] == "fx_vfx" then
		if evt[2]!="bob_engine_blow" then self:StopParticles() end
		if evt[2] == "ber_bolt_stick_exp" and not self:IsDead() then
			local num = math.random(4)
			local mul=1
			if num==1 then mul=2.5
			elseif num==2 then mul=2 
			elseif num==3 then mul=1.5 end
			self:SetHealth(self:Health() + (math.random(250,500)*mul))
		end
		local fx = self.VFX_EVTTABLE[evt[2]]
		ParticleEffectAttach(fx,PATTACH_POINT_FOLLOW,self,evt[3]-1)
		-- self:Timer(1,self.StopParticles)
	end
end

function ENT:OnMeleeAttack(enemy)
	if self:Health() < 1000 and math.random(3)==1 then
		self:Timer(57/30,function()
			self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",511)
		end)
		self:Timer(175/30,self.EmitSound,"codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		self:Timer(175/30,self.StopParticles)
		self:PSAM("powerup",1,self.FaceEnemy)
	else
		self:PSAM("att"..math.random(2),1,self.FaceEnemy)
	end
end
function ENT:OnRangeAttack(enemy)
	if self:GetCooldown("BobShoot")>0 then return end
	if self:Health() < 1000 and math.random(3)==1 then
		self:Timer(57/30,function()
			self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",511)
		end)
		self:Timer(175/30,self.EmitSound,"codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		self:Timer(175/30,self.StopParticles)
		self:PSAM("powerup",1,self.FaceEnemy)
	else
		self:PSAM("infect",1,function(self,cycle)
			if cycle > 50/133 and cycle < 65/133 then self:SetPlaybackRate(0.4) end
		end)
	end
	self:SetCooldown("BobShoot",math.random(3,6)*2)
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:ShouldRun()return self.Charging end

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	if dmg:IsDamageType(DMG_BLAST) or dmg:GetDamage() >= 40 and math.random(3) == 1 then
		self.Flinching = true
		self:CICO(function(self)
			self:EmitSound("codz_megapack/ww2/bob/vox/zvox_bob_pain_lrg_0"..math.random(9)..".wav",511)
			if self:IsRunning() then
				self:PSAM("flinch_run"..math.random(3))
			else
				self:PSAM("flinch"..math.random(2))
			end
			self.Flinching = false
		end)
	end
	if self:Health() < 1000 and not self.Charging then
		self.Flinching = true
		self:CICO(function(self)
			self:PSAM("enrage")
			self.Charging = true
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	self.OnIdleSounds = {}
	self:Timer(0.5,self.EmitSound,"codz_megapack/ww2/bob/zmb_bob_gun_buildup_0"..math.random(5)..".wav")
	self:PSAM("death")
	for i=1,5 do ParticleEffectAttach("bo3_napalm_fs",PATTACH_POINT_FOLLOW,self,1) end
	self:SetCollisionBounds(Vector(-1,-1,0),Vector(1,1,1))
	self:PauseCoroutine(false)
end
function ENT:ElectricalDischarge(delay,reps,start)
	start = start or 0
	for i=start,start+reps do
		self:Timer(delay*i,function()
			self:ParticleEffect("electrical_arc_01","fx_vfx"..math.random(2,6),
				self:RandomPos(128))
			util.ParticleTracerEx("electrical_arc_01",
				self:GetAttachment(math.random(5)).Pos,
				self:GetAttachment(math.random(5)).Pos,
				false, self:EntIndex(), math.random(2,6))
		end)
	end
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
