if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Meuchler"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/asn.mdl"}
ENT.BloodColor = BLOOD_COLOR_RED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 750

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
		if self.Stalking then
			self.IdleAnimation = "idle"
			self.Stalking = false
			self:SetRenderFX(0)
			self:SetColor(Color(255,255,255,255))
		end
		if not self:IsRunning() then
			self:PlaySequenceAndMove("att"..math.random(6,7),1,self.PossessionFaceForward)
		else
			self:PlaySequenceAndMove("att"..math.random(5),1,self.PossessionFaceForward)
		end
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		if self:GetCooldown("asstp") <= 0 then
			if not self.Stalking then
				self.IdleAnimation = "idle_stalk"	
				self.Stalking = true
				self:SetRenderFX(16)
				self:SetColor(Color(255,255,255,0))
			else
				self.IdleAnimation = "idle"	
				self.Stalking = false
				self:SetRenderFX(0)
				self:SetColor(Color(255,255,255,255))
			end
			self:SetCooldown("asstp",1)
		end
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
			if IsValid(door) and string.find(door:GetClass(),"button") then door:Fire("press") end
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
ENT.ClimbSpeed = 50
ENT.ClimbUpAnimation = "climb_1"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 0)

ENT.UseWalkframes = true

if SERVER then
function ENT:OnStartClimbing(ladder, height,down)
end
function ENT:WhileClimbing(ladder, left)
	self:PlaySequence("climb_1")
	if left < 155 then return true end 
end
function ENT:OnStopClimbing()
	self:PlaySequenceAndMoveAbsolute("climb_2")
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
	self.OnIdleSounds = {
	}
	self.IdleSoundDelay = math.random(5)^2
	if math.random(2)==1 or not navmesh.IsLoaded() then
		self:PlaySequenceAndMove("emerge1")
	else
		self:PlaySequenceAndMove("emerge2")
		self:BeginStalking()
	end
end

function ENT:OnLandOnGround()
	if self:IsDead() or self:IsClimbing() then return end
	self:CICO(function()self:PlaySequenceAndMove("land")end)
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	self:AddPlayersRelationship(D_HT,2)
	
	self.WalkAnimation = "walk"..math.random(3)
	self.RunAnimation = "run"..math.random(4)
	self.IdleAnimation = "idle"
	self.JumpAnimation = "glide"
	
	self.SOUND_EVTTABLE = {
		["zmb_hand_plant"] = {"player/footsteps/gravel", 4},
		["assassin_intimidate_vox"] = {"codz_megapack/ww2/asn/vox/zmb_vox_ass_intimidate_0", 6},
		["zmb_asn_slide"] = {"codz_megapack/ww2/asn/zmb_asn_slide_0", 9},
		["assassin_pain_vox"] = {"codz_megapack/ww2/asn/vox/zmb_vox_ass_pain_0", 8},
		["assassin_awaken_vox"] = {"codz_megapack/ww2/asn/vox/zmb_vox_ass_awaken_0", 5},
		["custom_bodyfall_knee"] = {"codz_megapack/ww2/global/melee/zmb_slash_0", 9},
		["zmb_asn_melee_whoosh"] = {"codz_megapack/ww2/asn/zmb_asn_melee_whoosh_0", 5},
		["assassin_death_vox"] = {"codz_megapack/ww2/asn/vox/zmb_vox_ass_death_0", 5},
		["assassin_melee_hit_vox"] = {"codz_megapack/ww2/asn/vox/zmb_vox_ass_melee_hit_0", 8}
	}
	self.VFX_EVTTABLE = {["zmb_asn_atk_wisp"]="advisor_healthcharger_break"}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-20,0), Vector(15, 20, 85))
end

function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 60,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/global/gore/zmb_headsplat_splatter_0"..math.random(4)..".wav",100,math.random(95,105))
			end
		end)
	elseif e == "bodyfall" or e == "land" then self:EmitSound("codz_megapack/ww2/global/zmb_death_bodyfall_0"..math.random(2,7)..".wav")
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then
		local snd = self.SOUND_EVTTABLE[evt[2]]
		if #snd==1 then self:EmitSound(snd[1])else self:EmitSound(snd[1]..math.random(snd[2])..".wav")end
	elseif evt[1] == "fx_vfx" then
		local fx = self.VFX_EVTTABLE[evt[2]]
		ParticleEffectAttach(fx,PATTACH_POINT_FOLLOW,self,evt[3])
		self:Timer(1,self.StopParticles)
	end
end

function ENT:OnMeleeAttack(enemy)
	self:PlaySequenceAndMove("att"..math.random(7),1,self.FaceEnemy)
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:BeginStalking()
	self.WantsToHide= false
	self.Flinching = true
	self:PlaySequenceAndMove("sneak_to")
	if not navmesh.IsLoaded() then
		SafeRemoveEntity(self)
		return
	end
	local enemy = (self:HasEnemy() and self:GetEnemy() or self)
	self:SetPos(enemy:DrG_RandomPos(1000))
	
	self.IdleAnimation = "idle_stalk"
	for i=1,9 do table.insert(self.OnIdleSounds, "codz_megapack/ww2/asn/vox/zmb_vox_ass_fog_click_dist_0"..i..".wav")end
	self.Stalking = true
	self.Flinching = false
	self:SetRenderFX(16)
	self:SetColor(Color(255,255,255,0))
	self:PlaySequenceAndMove("sneak_from")
end

function ENT:OnChaseEnemy(enemy)
	if self.WantsToHide then
		self:BeginStalking()
	end
	if self.Stalking 
	and ((enemy:IsNPC() and enemy:Visible(self)) or (enemy:IsPlayer() and enemy:GetEyeTrace().Entity == self))
	and self:GetCooldown("asstp") <=0 then
		self:SetCooldown("asstp",math.random(5))
		self:SetPos(enemy:DrG_RandomPos(1024))
	end
end

function ENT:ShouldRun()return not self.Stalking end

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	if dmg:IsDamageType(DMG_BLAST) then
		self.Flinching = true
		self:CICO(function()
			self:PlaySequenceAndMove("flinch_kd")
			self.Flinching = false
		end)
	elseif dmg:GetDamage() >= 10 and math.random(3) == 1 and not self.Stalking then
		self.Flinching = true
		self:CICO(function(self)
			if self:IsRunning() then
				self:PlaySequenceAndMove("run_flinch"..math.random(2))
			else
				self:PlaySequenceAndMove("flinch"..math.random(2))
			end
			self.WantsToHide = true
			self.Flinching = false
		end)
	elseif self.Stalking then
		self.Flinching = true
		self:CICO(function(self)
			self.IdleAnimation = "idle"	
			self.OnIdleSounds = {}
			self:SetRenderFX(0)
			self:SetColor(Color(255,255,255,255))
			self.Stalking = false
			self:PlaySequenceAndMove("walk_to_run")
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)
	self.OnIdleSounds = {}
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
else
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
