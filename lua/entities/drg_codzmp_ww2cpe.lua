if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Corpseeater"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/cpe.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 150

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
		self:PlaySequenceAndMove("att"..math.random(3),1,self.PossessionFaceForward)
	end}},
	[IN_JUMP] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("traverse",1,self.PossessionFaceForward)
		if self:IsOnGround() then 
			self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
			self:PlaySequenceAndMoveAbsolute("land",1,self.PossessionFaceForward) 
		end
	end}},
	[IN_USE] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMoveAbsolute("traverse_door",1,self.PossessionFaceForward)
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
function ENT:OnStartClimbing(ladder, height,down)
	self:SetPos(self:LocalToWorld(Vector(-20,0,0)))
	self:PlaySequenceAndMoveAbsolute("climb_1", 1, function()
		if isvector(ladder) then
			self:FaceTowards(ladder)
		else self:FaceTowards(ladder:GetBottom()) end
	end)
end
function ENT:WhileClimbing(ladder, left)
	self:ResetSequence("climb_2")
	if left < 120 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_3")
end

function ENT:OnSpawn()
	self:EmitSound("codz_megapack/ww2/cpe/vox/zmb_corpse_eater_spawn_0"..math.random(3)..".wav")
	self:EmitSound("codz_megapack/ww2/cpe/vox/zmb_corpse_eater_spawn_dist_0"..math.random(3)..".wav",511)
	self:EmitSound("codz_megapack/zmb/ai/standard/dirt_0"..math.random(0,1)..".wav")
	ParticleEffect("strider_impale_ground",self:GetPos(),self:GetAngles(),self)	
	for i=1,60 do
		self:Timer(0.1*i,function()
			ParticleEffect("advisor_healthcharger_break",self:LocalToWorld(Vector(20,0,-10)),self:GetAngles(),self)
		end)
	end
	self:PlaySequenceAndMove("emerge")
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:SetBodygroup(4,math.random(0,2))
	
	self.WalkAnimation = "run"..math.random(3)
	self.RunAnimation = "run"..math.random(3)
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {
		["zvox_siz_sprint"] = {"codz_megapack/ww2/cpe/vox/zmb_corpse_eater_charge_0", 3},
		["zvox_siz_sprint_attack_v3"] = {"codz_megapack/ww2/cpe/vox/zmb_corpse_eater_atk_0", 6},
		["zvox_siz_sprint_attack_v1"] = {"codz_megapack/ww2/cpe/vox/zmb_corpse_eater_atk_0", 6}
	}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-20,0), Vector(15, 20, 85))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 30,
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
	elseif e == "start_ragdoll" then self:BecomeRagdoll(DamageInfo())
	elseif e == "bodyfall" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	elseif e == "breach" then 
		for k,door in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,75)), 50)) do
			if IsValid(door) and door:GetClass() == "prop_door_rotating" then
				door:EmitSound("doors/vent_open3.wav",80)
				door:SetNotSolid(true)
				door:Fire("setspeed",500)
				door:Fire("openawayfrom",self:GetName())
				
				self:Timer(60/30,function()
					door:Fire("setspeed",100)
					door:Fire("close")
					self:Timer(0.2,function()door:SetNotSolid(false)end)
				end)
			elseif IsValid(door) and string.find(door:GetClass(),"door") 
			and not door:GetClass() == "prop_door_rotating" then
				door:Fire("open")
			end
		end
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		if math.random(7)==1 then
			local snd = self.SOUND_EVTTABLE[evt[2]]
			if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
		end
	end
end

function ENT:OnMeleeAttack(enemy)
	self:PlaySequenceAndMove("att"..math.random(3),1,self.FaceEnemy)
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	
	if hg==1 then self:SetBodygroup(4,3) self:Kill(dmg:GetAttacker()) return end
	if dmg:IsDamageType(DMG_BLAST) or ((dmg:GetDamage()>=40) and (math.random(50)<=12)) then
		self.Flinching = true
		self:CICO(function()
			self:EmitSound("codz_megapack/ww2/cpe/vox/zmb_corpse_eater_pain_0"..math.random(5)..".wav",511)
			self:PlaySequenceAndMove("flinch"..math.random(2))
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	if self:GetBodygroup(4)==3 or not self:IsOnGround() then self:BecomeRagdoll(dmg) return end
	self:EmitSound("codz_megapack/ww2/cpe/vox/zmb_corpse_eater_death_0"..math.random(4)..".wav",511)
	self:PlaySequenceAndMove("death"..math.random(3))
end

function ENT:OnChaseEnemy(enemy)
	if self:GetCooldown("CPEOpenDoor")>0 then return end
	for k,ball in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,75)), 50)) do
		if IsValid(ball) and ball:GetClass() == "prop_door_rotating" then
			self:PlaySequenceAndMoveAbsolute("traverse_door",{multiply=Vector(1.5,1.5,1)})
			self:SetCooldown("CPEOpenDoor",1)
		elseif IsValid(ball) and string.find(ball:GetClass(),"func_door") then
			ball:Fire("open")
		end
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
