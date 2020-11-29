if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Guardian"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/grd.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 4500

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 90
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
		self:PlaySequenceAndMove("att"..math.random(3),1,self.PossessionFaceForward)
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMove("enrage",1,self.PossessionFaceForward)
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("traverse",{multiply=Vector(1.5,1.5,1)},self.PossessionFaceForward)
		if self:IsOnGround() then 
			self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
			self:PlaySequenceAndMoveAbsolute("land",1,self.PossessionFaceForward) 
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

if SERVER then
function ENT:WhileClimbing(ladder, left)
	self:ResetSequence("climb_2")
	if left < 50 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_3")
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:SetBodygroup(4,math.random(0,2))
	
	self.WalkAnimation = "walk"..math.random(3)
	self.RunAnimation = "run"..math.random(3)
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {
		["zmb_grd_chain_foley"] = {"codz_megapack/ww2/grd/zmb_grd_chain_foley_0", 9},
		["zmb_grd_chain_foley_shrt"] = {"codz_megapack/ww2/grd/zmb_grd_chain_foley_shrt_0", 9},
		["zmb_grd_smash_impact"] = {"codz_megapack/ww2/grd/zmb_grd_smash_impact_0", 5},
		["zmb_grd_smash_sml_imp"] = {"codz_megapack/ww2/grd/zmb_grd_smash_sml_imp_0", 4},
		["zmb_grd_melee_chain_sngl"] = {"codz_megapack/ww2/grd/zmb_grd_melee_chain_sngl_0", 5},
		["zmb_grd_melee_fx_sngl"] = {"codz_megapack/ww2/grd/zmb_grd_melee_fx_sngl_0", 6},
		["zmb_grd_melee_chain_dbl"] = {"codz_megapack/ww2/grd/zmb_grd_melee_chain_dbl_0", 3},
		["zmb_grd_melee_fx_dbl"] = {"codz_megapack/ww2/grd/zmb_grd_melee_fx_dbl_0", 3},
		["grd_land_vox"] = {"codz_megapack/ww2/grd/vox/zvox_grd_attack_lrg_0", 9},
		["grd_pain_vox"] = {"codz_megapack/ww2/grd/vox/zvox_grd_pain_0", 9},
		["grd_melee_sngl_hit_vox"] = {"codz_megapack/ww2/grd/vox/zvox_grd_attack_lrg_0", 9},
		["grd_melee_dbl_hit_vox"] = {"codz_megapack/ww2/grd/vox/zvox_grd_attack_dbl_0", 5},
	}
	self.VFX_EVTTABLE = {
		["guardian_atk_trail"]="bo3_mangler_charge",
		["guardian_ground_impact_02"]="bo3_panzer_landing",
	}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-20,0), Vector(15, 20, 85))
end

function ENT:OnSpawn()self:PlaySequenceAndMove("enrage")end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 30,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_imp_0"..math.random(5)..".wav",100,math.random(95,105))
				self:EmitSound("codz_megapack/ww2/fol/zmb_follower_mace_gore_0"..math.random(5)..".wav",100,math.random(95,105))
			else
				self:EmitSound("codz_megapack/ww2/grd/zmb_grd_melee_whoosh_sngl_0"..math.random(5)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "bodyfall" or e == "land" then 
		self:EmitSound("codz_megapack/ww2/brute/zmb_fs_walk_brute_default2_0"..math.random(8,9)..".wav",511,math.random(80,100))
	elseif e == "step" then 
		self:EmitSound("codz_megapack/ww2/global/fs/zmb_fs_default_walk_large_default_0"..math.random(9)..".wav",80)
		util.ScreenShake(self:GetPos(),100000,500000,0.2,150)
	elseif e == "grd_roar" then 
		self:EmitSound("codz_megapack/ww2/grd/vox/zvox_grd_roar_0"..math.random(5)..".wav",511)
		util.ScreenShake(self:GetPos(),100000,500000,1.8,10000)
	elseif e == "dmg_slam_down" then 
		self:EmitSound("codz_megapack/ww2/grd/zmb_grd_smash_debris_0"..math.random(5)..".wav",511)
		self:EmitSound("codz_megapack/ww2/grd/zmb_grd_smash_sml_imp_0"..math.random(4)..".wav")
		self:EmitSound("codz_megapack/ww2/grd/zmb_grd_smash_impact_0"..math.random(5)..".wav",511)
		ParticleEffectAttach("bo3_panzer_landing",PATTACH_POINT,self,0)
		self:BlastAttack({
			damage = 128,
			type = DMG_BLAST,
			viewpunch = Angle(20, math.random(-10, 10), 0),
			relationships={D_LI,D_NU,D_HT,D_FR}
		})
	elseif e == "stopfx_vfx" then self:StopParticles()
	elseif e == "rumble_heavy_1s" then util.ScreenShake(self:GetPos(),100000,500000,1,10000)
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		if math.random(7)==1 then
			local snd = self.SOUND_EVTTABLE[evt[2]]
			if #snd==1 then self:EmitSound(snd[1],80)else self:EmitSound(snd[1]..math.random(snd[2])..".wav",80)end
		end
	elseif evt[1] == "fx_vfx" then
		local fx = self.VFX_EVTTABLE[evt[2]]
		ParticleEffectAttach(fx,PATTACH_POINT_FOLLOW,self,evt[3])
	end
end

function ENT:OnMeleeAttack(enemy)
	self:PlaySequenceAndMove("att"..math.random(3),1,self.FaceEnemy)
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	
	if dmg:IsDamageType(DMG_BLAST) then
		self.Flinching = true
		self:CICO(function()
			self:PlaySequenceAndMove("kb_1")
			self:PlaySequenceAndMove("kb_2")
			self:PlaySequenceAndMove("kb_3")
			self.Flinching = false
		end)
	elseif ((dmg:GetDamage()>=40) and (math.random(50)<=12)) then
		self.Flinching = true
		self:CICO(function()
			self:PlaySequenceAndMove("flinch"..math.random(3))
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	if self:GetBodygroup(4)==3 or not self:IsOnGround() then self:BecomeRagdoll(dmg) return end
	self:EmitSound("codz_megapack/ww2/grd/vox/zvox_grd_death_0"..math.random(4)..".wav",511)
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
