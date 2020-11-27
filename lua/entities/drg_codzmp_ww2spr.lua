if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Pest"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/spr.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 50

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
		self:PlaySequenceAndMove("att"..math.random(2),1,self.PossessionFaceForward)
	end}},
	[IN_JUMP] = {{coroutine = false,onkeydown = function(self)self:Jump(350)end}},
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
	if left < 90 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_3")
end

function ENT:OnSpawn()
	self:EmitSound("codz_megapack/zmb/ai/standard/dirt_0"..math.random(0,1)..".wav")
	self:EmitSound("codz_megapack/ww2/spr/vox/zmb_vox_spr_spawn_0"..math.random(9)..".wav",90)
	ParticleEffect("strider_impale_ground",self:GetPos(),self:GetAngles(),self)	
	self:PlaySequenceAndMove("emerge")
	self.OnIdleSounds = {
		"codz_megapack/ww2/spr/vox/zmb_vox_spr_charge_01.wav","codz_megapack/ww2/spr/vox/zmb_vox_spr_charge_02.wav",
		"codz_megapack/ww2/spr/vox/zmb_vox_spr_charge_03.wav","codz_megapack/ww2/spr/vox/zmb_vox_spr_charge_04.wav",
		"codz_megapack/ww2/spr/vox/zmb_vox_spr_charge_05.wav","codz_megapack/ww2/spr/vox/zmb_vox_spr_charge_06.wav"
	}
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	self:CICO(function()self:PlaySequenceAndMove("land_scare")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	
	self.WalkAnimation = "walk"
	self.RunAnimation = "run"..math.random(3)
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {["custom_bodyfall_knee"] = {"codz_megapack/ww2/global/melee/zmb_slash_0", 9}}	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-20,0), Vector(15, 20, 85))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 15,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_melee_hit_0"..math.random(5)..".wav",100,math.random(95,105))
			else
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_melee_whoosh_0"..math.random(5)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "bodyfall" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		self:EmitSound(snd[1]..math.random(snd[2])..".wav")
	end
end

function ENT:OnMeleeAttack(enemy)
	self:EmitSound("codz_megapack/ww2/spr/vox/zmb_vox_spr_anm_sprint_attack_"..math.random(3).."_0"..math.random(4)..".wav",90)
	self:PlaySequenceAndMove("att"..math.random(2),1,self.FaceEnemy)
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	
	if dmg:IsDamageType(DMG_BLAST) or ((dmg:GetDamage()>=40) and (math.random(50)<=12)) then
		self.Flinching = true
		self:CICO(function()
			if math.random(2)==1 then
				self:EmitSound("codz_megapack/ww2/spr/vox/zmb_vox_spr_anm_hit_react_left_0"..math.random(5)..".wav",90)
			else
				self:EmitSound("codz_megapack/ww2/spr/vox/zmb_vox_spr_anm_hit_react_right_0"..math.random(5)..".wav",90)
			end
			self:PlaySequenceAndMove("flinch"..math.random(2))
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	self:EmitSound("codz_megapack/ww2/spr/vox/zmb_vox_spr_anm_death_0"..math.random(9)..".wav",90)
	if self:IsRunning() then
		self:PlaySequenceAndMove("death_run")
	else
		self:PlaySequenceAndMove("death")
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
