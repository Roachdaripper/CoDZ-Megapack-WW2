if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Zombie"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/zombie.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 125

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
		self:PlaySequenceAndMove("att"..math.random(24),1,self.PossessionFaceForward)
		if self.GenVox==1 then
			self:EmitSound("codz_megapack/ww2/vox_gen1/zmb_zde_ft_gen_taunt_"..math.random(35)..".wav",90)
		else
			self:EmitSound("codz_megapack/ww2/vox_gen2/zmb_zde_gen2_ml_taunt_"..math.random(21)..".wav",90)
		end
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
	self:EmitSound("codz_megapack/zmb/ai/standard/dirt_0"..math.random(0,1)..".wav")
	ParticleEffect("strider_impale_ground",self:GetPos(),self:GetAngles(),self)	
	for i=1,60 do
		self:Timer(0.1*i,function()
			ParticleEffect("advisor_healthcharger_break",self:LocalToWorld(Vector(20,0,-10)),self:GetAngles(),self)
		end)
	end	
	self:PlaySequenceAndMove("emerge"..math.random(2))
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	
	self.WalkAnimation = "walk"..math.random(10)
	self.RunAnimation = "run"..math.random(16)
	self.IdleAnimation = "idle"..math.random(2)
	self.JumpAnimation = "glide"
	
	self.GenVox = math.random(2)
	
	self.SOUND_EVTTABLE = {["custom_bodyfall_knee"] = {"codz_megapack/ww2/global/melee/zmb_slash_0", 9}}	
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
				self:EmitSound("codz_megapack/ww2/global/melee/zmb_hit_0"..math.random(8)..".wav",100,math.random(95,105))
			else
				self:EmitSound("codz_megapack/ww2/global/melee/zmb_slash_crawl_0"..math.random(5)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "start_ragdoll" and self:IsDead() then self:BecomeRagdoll(DamageInfo())
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
		local snd = self.SOUND_EVTTABLE[evt[2]]
		self:EmitSound(snd[1]..math.random(snd[2])..".wav")
	end
end

function ENT:OnMeleeAttack(enemy)
	self:PlaySequenceAndMove("att"..math.random(24),1,self.FaceEnemy)
	if self.GenVox==1 then
		self:EmitSound("codz_megapack/ww2/vox_gen1/zmb_zde_ft_gen_taunt_"..math.random(35)..".wav",90)
	else
		self:EmitSound("codz_megapack/ww2/vox_gen2/zmb_zde_gen2_ml_taunt_"..math.random(21)..".wav",90)
	end
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	
	if dmg:IsDamageType(DMG_BLAST) then
		self.Flinching = true
		self:CICO(function()
			if math.random(2)==1 then
				self:PlaySequenceAndMove("flinch_kd"..math.random(4))
			else
				self:PlaySequenceAndMove("death"..math.random(9))
				self:PlaySequenceAndMove("death_feign"..math.random(2))
			end
			self.Flinching = false
		end)
	elseif ((dmg:GetDamage()>=40) and (math.random(18)<=12)) then
		self.Flinching = true
		self:CICO(function()
			if math.random(2)==1 then
				self:PlaySequenceAndMove("flinch_kd"..math.random(4))
			else
				self:PlaySequenceAndMove("flinch"..math.random(6))
			end
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	self:EmitSound("codz_megapack/ww2/spr/vox/zmb_vox_spr_anm_death_0"..math.random(9)..".wav",90)
	if not dmg:IsDamageType(DMG_BLAST) then
		self:PlaySequenceAndMove("death"..math.random(9))
	end
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
