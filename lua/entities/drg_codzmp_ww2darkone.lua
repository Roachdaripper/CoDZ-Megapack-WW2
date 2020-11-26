if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Godking"
ENT.Category = "CoDZ Megapack: WW2"
ENT.Models = {"models/roach/codz_megapack/ww2/gdk.mdl"}
ENT.BloodColor = DONT_BLEED

-- Relationships --
ENT.Factions = {"FACTION_CODZOMBIES"}

-- Stats --
ENT.SpawnHealth = 10000

-- AI --
ENT.Omniscient = true
ENT.MeleeAttackRange = 80
ENT.RangeAttackRange = 6000
ENT.ReachEnemyRange = 40
ENT.AvoidEnemyRange = 0
ENT.FollowPlayers = true

-- Detection --
ENT.EyeBone = "j_head"
ENT.EyeOffset = Vector(7.5, 0, 5)
ENT.EyeAngle = Angle(0, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionCrosshair = true
-- ENT.PossessionMovement = POSSESSION_MOVE_4DIR
ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM
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
		local m = math.random(3)
		if m==3 then ParticleEffectAttach("bo3_astronaut_incoming",PATTACH_POINT_FOLLOW,self,4)end
		self:PlaySequenceAndMove("att"..m,1,self.PossessionFaceForward)
	end}},
	[IN_ATTACK2] = {{coroutine = true,onkeydown = function(self)
		local m = self.PossessionAttackMode
		if m==1 then
			if self:GetCooldown("GDKTauntVox") <= 0 then
				local snd = Sound("codz_megapack/ww2/gdk/vox/lightofthesun"..math.random(3)..".wav")
				self:EmitSound(snd,511) 
				self:SetCooldown("GDKTauntVox",SoundDuration(snd) + math.random(10)*2)
			end
			self:Timer(3,function()
				self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_geistblast_charge_01.wav",511)
				self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_geistblast_charge_hi_01.wav",511)
				self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_geistblast_charge_imp_01.wav",511)
			end)
			self:Timer(5,function()
				self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_sun_charge_start_main.wav",511)
				self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_sun_charge_start_sub.wav",511)
			end)
			self:PlaySequenceAndMove("att_lightofthesun",1,self.PossessionFaceForward)
		elseif m==2 then
			self:PlaySequenceAndMove("att_pull",1,self.PossessionFaceForward)
		elseif m==3 then
			self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_buildup_0"..math.random(5)..".wav",511)
			self:PlaySequenceAndMove("att_geistbombs",1,self.PossessionFaceForward)
		elseif m==4 then
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_lightning_0"..math.random(6).."_acct.wav",511)
			
			local mat = math.random(2)
			local att = 2
			if mat==1 then att=3 end
			for i=0,20 do 
				ParticleEffectAttach("electrical_arc_01_system",PATTACH_POINT_FOLLOW,self,att)
				self:Timer(0.1*i,function()
					ParticleEffectAttach("electrical_arc_01_system",PATTACH_POINT_FOLLOW,self,att)
				end)
			end
			self:PlaySequenceAndMove("att_geistbolt"..mat,1,self.PossessionFaceForward)
		elseif m==5 then
			self:PlaySequenceAndMove("att_flame_cast",1,self.PossessionFaceForward)
			self:PlaySequenceAndMove("att_flame_loop",1,self.PossessionFaceForward)
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_flamewave_end.wav",511)
		elseif m==6 then
			self:PlaySequenceAndMove("att_detonate",1,self.PossessionFaceForward)
		end
	end}},
	[KEY_2] = {{coroutine = true,onbuttondown = function(self)
		if self.PossessionAttackMode == 1 then return end
		self:GetPossessor():SendLua("surface.PlaySound('common/wpn_hudoff.wav')")
		self.PossessionAttackMode = 1
		self.PossessionAttackPrint = "Licht der sonne"
		self:GetPossessor():ChatPrint("Attack "..self.PossessionAttackPrint.." selected.")
	end}},
	[KEY_3] = {{coroutine = true,onbuttondown = function(self)
		if self.PossessionAttackMode == 2 then return end
		self:GetPossessor():SendLua("surface.PlaySound('common/wpn_hudoff.wav')")
		self.PossessionAttackMode = 2
		self.PossessionAttackPrint = "Geistziehen"
		self:GetPossessor():ChatPrint("Attack "..self.PossessionAttackPrint.." selected.")
	end}},
	[KEY_4] = {{coroutine = true,onbuttondown = function(self)
		if self.PossessionAttackMode == 3 then return end
		self:GetPossessor():SendLua("surface.PlaySound('common/wpn_hudoff.wav')")
		self.PossessionAttackMode = 3
		self.PossessionAttackPrint = "Geistbomben"
		self:GetPossessor():ChatPrint("Attack "..self.PossessionAttackPrint.." selected.")
	end}},
	[KEY_5] = {{coroutine = true,onbuttondown = function(self)
		if self.PossessionAttackMode == 4 then return end
		self:GetPossessor():SendLua("surface.PlaySound('common/wpn_hudoff.wav')")
		self.PossessionAttackMode = 4
		self.PossessionAttackPrint = "Geistblitz"
		self:GetPossessor():ChatPrint("Attack "..self.PossessionAttackPrint.." selected.")
	end}},
	[KEY_6] = {{coroutine = true,onbuttondown = function(self)
		if self.PossessionAttackMode == 5 then return end
		self:GetPossessor():SendLua("surface.PlaySound('common/wpn_hudoff.wav')")
		self.PossessionAttackMode = 5
		self.PossessionAttackPrint = "Geistwellen"
		self:GetPossessor():ChatPrint("Attack "..self.PossessionAttackPrint.." selected.")
	end}},
	[KEY_7] = {{coroutine = true,onbuttondown = function(self)
		if self.PossessionAttackMode == 6 then return end
		self:GetPossessor():SendLua("surface.PlaySound('common/wpn_hudoff.wav')")
		self.PossessionAttackMode = 6
		self.PossessionAttackPrint = "Geistdetonation"
		self:GetPossessor():ChatPrint("Attack "..self.PossessionAttackPrint.." selected.")
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
ENT.ClimbUpAnimation = "idle"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 0)

ENT.UseWalkframes = true

game.AddParticles("particles/electrical_fx.pcf")
game.AddParticles("particles/advisor_fx.pcf")
game.AddParticles("particles/weapon_fx.pcf")
game.AddParticles("particles/grenade_fx.pcf")
PrecacheParticleSystem("electrical_arc_01_system")
PrecacheParticleSystem("Advisor_Psychic_Beam")
PrecacheParticleSystem("Advisor_Psychic_Blast")

game.AddParticles("particles/blackops3zombies_fx.pcf")
	PrecacheParticleSystem("bo3_mangler_charge")
	PrecacheParticleSystem("bo3_mangler_pulse")
	PrecacheParticleSystem("bo3_mangler_blast")
	PrecacheParticleSystem("bo3_astronaut_incoming")
	PrecacheParticleSystem("bo3_shrieker_scream")
	PrecacheParticleSystem("bo3_napalm_fs")
game.AddParticles("particles/zmb_ber_bob_weapon_glow.pcf")
	PrecacheParticleSystem("zmb_ber_bob_weapon_glow")
game.AddParticles("particles/ber_bolt_stick.pcf")
	PrecacheParticleSystem("ber_bolt_stick")
game.AddParticles("particles/hellhound.pcf")
game.AddParticles("particles/hellhound_2.pcf")
	PrecacheParticleSystem("fx_hellhound_explosion")
game.AddParticles("particles/romero_fx.pcf")
	PrecacheParticleSystem("summon_beam")
	PrecacheParticleSystem("summon_beam_lightning")
game.AddParticles("particles/codww2_meistermeuchler_shockwave.pcf")
	PrecacheParticleSystem("codww2_meistermeuchler_shockwave")

if SERVER then
function ENT:PossessionControls(f,b,r,l)
	if self:IsOnGround() then
		if self:GetPossessor():KeyDown(IN_JUMP) then self:SetPos(self:GetPos()+Vector(0,0,20)) end
		local dir = self._DrGBasePossLast4DIR or ""
		self:PossessionFaceForward()
		if f and (dir == "" or dir == "N") then
			self:PossessionMoveForward()
			self._DrGBasePossLast4DIR = "N"
		elseif b and (dir == "" or dir == "S") then
			self:PossessionMoveBackward()
			self._DrGBasePossLast4DIR = "S"
		elseif r and (dir == "" or dir == "E") then
			self:PossessionMoveRight()
			self._DrGBasePossLast4DIR = "E"
		elseif l and (dir == "" or dir == "W") then
			self:PossessionMoveLeft()
			self._DrGBasePossLast4DIR = "W"
		else self._DrGBasePossLast4DIR = "" end
	else
		local ply = self:GetPossessor()
		local function kd(k) return ply:KeyDown(k) end
		local F,B,R,L,U,D = IN_FORWARD, IN_BACK, IN_MOVERIGHT, IN_MOVELEFT, IN_JUMP, IN_DUCK
		
		self:PossessionFaceForward()
		if kd(F) then self:SetVelocity((self:GetAimVector()):GetNormalized()*450)
		elseif kd(B) then self:SetVelocity((-self:GetAimVector()):GetNormalized()*450)
		elseif kd(R) then self:SetVelocity((self:GetRight()):GetNormalized()*450)
		elseif kd(L) then self:SetVelocity((-self:GetRight()):GetNormalized()*450)
		elseif kd(U) then self:SetVelocity((self:GetUp()):GetNormalized()*450)
		elseif kd(D) then self:SetVelocity((-self:GetUp()):GetNormalized()*450)
		else
			self:SetVelocity(Vector(0,0,0))
		end
		if (kd(F) or kd(B) or kd(R) or kd(L))
		and (not kd(IN_ATTACK) and not kd(IN_ATTACK2) and not kd(IN_RELOAD)) then
			self:SetSequence("move_all")
		end
	end
end

function ENT:OnSpawn()
	self:EmitSound("codz_megapack/zmb/ai/standard/dirt_0"..math.random(0,1)..".wav")
	ParticleEffect("strider_impale_ground",self:GetPos(),self:GetAngles(),self)	
	self:PlaySequenceAndMove("emerge")
end

function ENT:CustomInitialize()
	self:SetDefaultRelationship(D_HT)
	
	self.WalkAnimation = "move_all"
	self.RunAnimation = "move_all"
	self.IdleAnimation = "idle"
	self.JumpAnimation = "idle"
	
	self.loco:SetGravity(0)
	
	self.SOUND_EVTTABLE = {["godking_pain_vox"] = {"codz_megapack/ww2/gdk/vox/ah.wav"}}
	self:SetCooldown("GDK_Ranged",3)
	self.AuraActive = false
	
	self.VFX_EVTTABLE = {
		["gk_overforce_buildup"]="bo3_shrieker_scream",
		["gk_swipe_1"]="ber_bolt_stick",
		["gk_geistbomb_buildup"]="bo3_mangler_charge",
		["gk_geistbolt_pre"]="bo3_mangler_pulse",
		["gk_detonate_hand_shoot"]="fx_hellhound_explosion",
		["gk_detonate_buildup"]="env_fire_small"
	}
	
	self:Timer(0.1,self.SetCollisionBounds, Vector(-15,-25,40), Vector(15, 25, 125))
end
function ENT:OnOtherKilled(v,dmginfo)
	if self:IsDead() then return end
	if self:GetCooldown("GDKTauntVox") <= 0 and (dmginfo:GetAttacker() == self) then
		local snd
		if math.random(2)==1 then
			snd = Sound("codz_megapack/ww2/gdk/vox/kill"..math.random(5)..".wav")
		else
			snd = Sound("codz_megapack/ww2/gdk/vox/taunt"..math.random(6)..".wav")
		end
		self:EmitSound(snd,511) 
		self:SetCooldown("GDKTauntVox",SoundDuration(snd) + math.random(10)*2)
	end
end
function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "attack" then
		self:Attack({
			damage = 90,
			type = DMG_SLASH,
			viewpunch = Angle(20, math.random(-10, 10), 0),
		}, 
		function(self, hit)
			if #hit > 0 then
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_melee_hit_0"..math.random(5)..".wav",100,math.random(45,70))
			else
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_melee_whoosh_0"..math.random(5)..".wav",100,math.random(45,70))
			end
		end)
	elseif e=="stopfx_vfx" then self:StopParticles()
	elseif e=="unleash_force" then
		ParticleEffectAttach("bo3_shrieker_scream",PATTACH_POINT_FOLLOW,self,4)
		self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_force_0"..math.random(3)..".wav",511)
		self:Attack({
			damage = 25,
			range=512,
			type = DMG_BLAST,
			viewpunch = Angle(20, math.random(-10, 10), 0),
			push=true,
			force=Vector(10000,0,650)
		})
	elseif e == "pull_lockon" then
		self.TEMPEnemy = (self:IsPossessed() and self:GetClosestEnemy() or self:GetEnemy())
		if IsValid(self.TEMPEnemy) then
			local x,y,z = self:GetAttachment(2), self.TEMPEnemy:WorldSpaceCenter(), self:EntIndex()
			-- util.ParticleTracerEx("Advisor_Psychic_Attack",x.Pos,y,false,z,2)
			local ent = self:ParticleEffect("advisor_psychic_attack","fx_vfx2",self.TEMPEnemy)
			SafeRemoveEntityDelayed(ent,1)
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_pull_summon_b.wav",511)
		elseif self:IsPossessed() then 
			util.ParticleTracerEx("Advisor_Psychic_Attack",self:GetAttachment(2).Pos,self:PossessorTrace().HitPos,false,self:EntIndex(),2)
		end
	elseif e == "pull_cast" then
		if IsValid(self.TEMPEnemy) then
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_pull_hi.wav",511)
			self.TEMPEnemy:SetVelocity((self:GetPos()-self.TEMPEnemy:GetPos()):GetNormalized()*1024 + Vector(0,0,750))
		end
	elseif e=="light_begin" then
		ParticleEffect("summon_beam_lightning",self:GetAttachment(4).Pos,Angle(0,0,0),self)
		self.TEMPEnemy = (self:IsPossessed() and self:GetClosestEnemy() or self:GetEnemy())
		if IsValid(self.TEMPEnemy) then
			local function dobeam()
				local pos = self.TEMPEnemy:GetPos()
				ParticleEffect("summon_beam",pos,Angle(0,0,0),nil)
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_buildup_0"..math.random(5)..".wav",511,75)
				self:Timer(1.7,function()
					sound.Play("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",pos,511,85)
					local g = self:CreateProjectile("_codzmp_darkone_point_hurt")
					g:SetPos(pos)
				end)
			end
			local hp = self:Health()
			if hp > 5000 and not self:IsPossessed() then dobeam()
			else for i=0,4 do self:Timer(i,dobeam) end end
		elseif self:IsPossessed() then
			local function dobeampos()
				local pos = self:PossessorTrace().HitPos
				ParticleEffect("summon_beam",pos,Angle(0,0,0),nil)
				self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_buildup_0"..math.random(5)..".wav",511,75)
				self:Timer(1.7,function()
					sound.Play("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",pos,511,85)
					local g = self:CreateProjectile("_codzmp_darkone_point_hurt")
					g:SetPos(pos)
				end)
			end
			for i=0,4 do self:Timer(i,dobeampos) end
		end
	elseif e=="bomb_throw" then
		self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_fire_0"..math.random(5)..".wav",511)
		self:CreateGeistBomb(Vector(0,0,0))
		if (self:Health()<=5000 or self:IsPossessed()) then
			self:Timer(0.25,function()
				self:CreateGeistBomb(Vector(0,-150,0))
				self:CreateGeistBomb(Vector(0,150,0))
			end)
		end
		self:StopParticles()
	elseif e=="bolt_throw" then
		self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_lightning_0"..math.random(6).."_main.wav",511)
		local num = 1
		if (self:Health()<=5000 or self:IsPossessed()) then num = 20 end
		for i=0,num do self:Timer(0.01*i,function()
			self.Laser = self:CreateProjectile(nil, {}, "_codzmp_bob_proj")
			
			local att = 2
			if self:GetSequence() == (self:LookupSequence("att_geistbolt1")) then att = 3 end
			self.Laser:SetPos(self:GetAttachment(att).Pos)
			
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
			if !self:IsPossessed() then
				self.Laser:AimAt(self:GetEnemy(), 512)
			else
				self.Laser:SetVelocity(self:GetPossessor():GetAimVector()*512)
			end
			if (self:Health()<=5000 and not self:IsPossessed()) then self.Laser:SetVelocity(Vector(0,0,3000)) end
		end)end
		self:StopParticles()
	elseif e=="flame_cast" then
		self:EmitSound("codz_megapack/zmb/ai/margwa/elemental/fire/attack_slam_swt.wav",511)
		local ent = ents.Create("_codzmp_darkone_firewave")
		ent:SetPos(self:LocalToWorld(Vector(25,0,0)))
		ent:SetAngles(self:GetAngles())
		ent:SetOwner(self)
		ent:Spawn()
		ent:Activate()
		if (self:Health()<=5000 or self:IsPossessed()) and math.random(3)==1 then self:Timer(0.5,function()
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_flamewave_strt.wav",511)
			local ent = ents.Create("_codzmp_darkone_firewave")
			ent:SetPos(self:LocalToWorld(Vector(25,0,0)))
			ent:SetAngles(self:GetAngles())
			ent:SetOwner(self)
			ent:Spawn()
			ent:Activate()		
		end)end
	elseif e=="detonate_shoot" then
		for i=0,math.random(5) do
			self.Laser = self:CreateProjectile(nil, {}, "_codzmp_darkone_proj_fire")
			self.Laser:SetPos(self:GetAttachment(2).Pos)
			if !self:IsPossessed() then self.Laser:AimAt(self:GetEnemy(), 2048)
			else self.Laser:SetVelocity(self:GetPossessor():GetAimVector()*2048)end
		end
	end
	
	local evt = string.Explode(" ", e, false)
	if evt[1] == "ps" then self:EmitSound(self.SOUND_EVTTABLE[evt[2]][1])
	elseif evt[1] == "fx_vfx" then
		if evt[2] == "gk_swipe_1" then 
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_lightning_0"..math.random(6).."_acct.wav",511)
		end
		local fx = self.VFX_EVTTABLE[evt[2]]
		ParticleEffectAttach(fx,PATTACH_POINT_FOLLOW,self,evt[3])
		self:Timer(1,self.StopParticles)
	end
end

function ENT:CreateGeistBomb(vec)
	local c = self:CreateProjectile("proj_drg_smoke_grenade")
	c:SetNoDraw(true)
	
	c.Physgun = false
	c.Gravgun = false
	c:Unpin(true)
	c.OnBounceSounds = {}
	ParticleEffectAttach("bo3_mangler_charge",PATTACH_ABSORIGIN_FOLLOW,c,0)
	c.Contact = function(c,ent)
		if ent == self then return end
		c:EmitSound("codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		ParticleEffectAttach("codww2_meistermeuchler_shockwave",PATTACH_ABSORIGIN,c,0)
		c:RadiusDamage(100,DMG_SHOCK,100)
		c:Timer(0.1, c.Remove)
		return true
	end
	c.OnDetonate = function(c)
		c:EmitSound("codz_megapack/zmb/ai/mechz2/wpn_grenade_fire_mechz.wav")
		ParticleEffectAttach("codww2_meistermeuchler_shockwave",PATTACH_ABSORIGIN,c,0)
		c:RadiusDamage(100,DMG_SHOCK,100)
		c:Timer(0.1, c.Remove)
	end

	c:SetPos(self:GetAttachment(2).Pos)
	if self:IsPossessed() then
		local lockedOn = self:PossessionGetLockedOn()
		if not IsValid(lockedOn) then 
			local dir,info = c:DrG_ThrowAt(self:PossessorTrace().HitPos, {magnitude=100,recursive=true}, true)
			c:SetDelay(info.duration-0.5)
		else 
			local dir,info = c:DrG_ThrowAt(lockedOn, {magnitude=100,recursive=true}, true)
			c:SetDelay(info.duration-0.5)
		end
	elseif self:HasEnemy() then
		local dir,info = c:DrG_ThrowAt(self:GetEnemy(), {magnitude=100,recursive=true}, true)
		c:SetDelay(info.duration-0.5)
	else 
		c:DrG_AimAt(nil, 1000)
	end
end

function ENT:OnMeleeAttack(enemy)
	local m = math.random(3)
	if m==3 then ParticleEffectAttach("bo3_astronaut_incoming",PATTACH_POINT_FOLLOW,self,4)end
	self:PlaySequenceAndMove("att"..m,1,self.FaceEnemy)
end

function ENT:OnRangeAttack(enemy)
	if self:GetCooldown("GDK_Ranged") > 0 then self:Strafe(128,512,enemy) return end
	
	local hp = self:Health()
	if self.AuraActive then 
		self:SetCooldown("GDK_Ranged",0.1)
		if (enemy:IsPlayer() and enemy:GetEyeTrace().Entity == self) or not enemy:IsPlayer() then
			self:Attack({
				damage = math.Clamp((150-((self:GetRangeTo(enemy:GetPos())-100))),1,100),
				range=math.huge,
				viewpunch=Angle(0,0,0),
				type = DMG_DISSOLVE,
			})
		end
	return end
	
	self:SetCooldown("GDK_Ranged",math.random(3,5))
	local m = math.random(6)
	if m==1 then
		if self:GetCooldown("GDKTauntVox") <= 0 then
			local snd = Sound("codz_megapack/ww2/gdk/vox/lightofthesun"..math.random(3)..".wav")
			self:EmitSound(snd,511) 
			self:SetCooldown("GDKTauntVox",SoundDuration(snd) + math.random(10)*2)
		end
		self:Timer(3,function()
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_geistblast_charge_01.wav",511)
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_geistblast_charge_hi_01.wav",511)
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_geistblast_charge_imp_01.wav",511)
		end)
		self:Timer(5,function()
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_sun_charge_start_main.wav",511)
			self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_sun_charge_start_sub.wav",511)
		end)
		self:PlaySequenceAndMove("att_lightofthesun",1,self.FaceEnemy)
	elseif m==2 then
		self:PlaySequenceAndMove("att_pull",1,self.FaceEnemy)
	elseif m==3 then
		self:EmitSound("codz_megapack/ww2/bob/zmb_bob_gun_buildup_0"..math.random(5)..".wav",511)
		self:PlaySequenceAndMove("att_geistbombs",1,self.FaceEnemy)
	elseif m==4 then
		self:EmitSound("codz_megapack/ww2/gdk/zmb_gdk_spell_lightning_0"..math.random(6).."_acct.wav",511)
		local mat = math.random(2)
		local att = 2
		if mat==1 then att=3 end
		for i=0,20 do 
			ParticleEffectAttach("electrical_arc_01_system",PATTACH_POINT_FOLLOW,self,att)
			self:Timer(0.1*i,function()
				ParticleEffectAttach("electrical_arc_01_system",PATTACH_POINT_FOLLOW,self,att)
			end)
		end
		self:PlaySequenceAndMove("att_geistbolt"..mat,1,self.FaceEnemy)
	elseif m==5 then
		self:PlaySequenceAndMove("att_flame_cast",1,self.FaceEnemy)
		self:PlaySequenceAndMove("att_flame_loop",1,self.FaceEnemy)
		self:EmitSound("codz_megapack/ww2/gdk/zmb_gdkng_flamewave_end.wav",511)
	elseif m==6 then
		self:PlaySequenceAndMove("att_detonate",1,self.FaceEnemy)
	end
end

function ENT:Strafe(min,max,enemy)
	if self:GetHullRangeSquaredTo(enemy) <= 120*120
	or self.Strafing or self.AuraActive then return end
	self.Strafing = true
	-- if self:IsOnGround() then self:SetPos(self:GetPos()+Vector(0,0,50)) end
	-- if enemy:GetPos().z > self:GetPos().z then self:Jump() end
	local mdirection = math.random(4) -- 1,3
	if mdirection == 1 then
		self.loco:SetVelocity(self:GetVelocity() + (-self:GetForward()))
		self:MoveBackward(math.random(min,max),function()
			self:FaceEnemy()
			if self:GetHullRangeSquaredTo(enemy) < 120^2 then return true end
			if enemy:GetPos().z > self:GetPos().z then
				self:SetVelocity(self:GetVelocity() + self:GetUp()*1)
			end
		end)
		self.loco:SetVelocity(Vector(0,0,0))
	elseif mdirection == 2 then
		self.loco:SetVelocity(self:GetVelocity() + (-self:GetRight()))
		self:MoveLeft(math.random(min,max),function()
			self:FaceEnemy()
			if self:GetHullRangeSquaredTo(enemy) < 120^2 then return true end
			if enemy:GetPos().z > self:GetPos().z then
				self:SetVelocity(self:GetVelocity() + self:GetUp()*1)
			end
		end)
		self.loco:SetVelocity(Vector(0,0,0))
	elseif mdirection == 3 then
		self.loco:SetVelocity(self:GetVelocity() + (self:GetRight()))
		self:MoveRight(math.random(min,max),function()
			self:FaceEnemy()
			if self:GetHullRangeSquaredTo(enemy) < 120^2 then return true end
			if enemy:GetPos().z > self:GetPos().z then
				self:SetVelocity(self:GetVelocity() + self:GetUp()*1)
			end
		end)
		self.loco:SetVelocity(Vector(0,0,0))
	elseif mdirection == 4 then
		self.loco:SetVelocity(self:GetVelocity() + (self:GetForward()))
		self:MoveForward(math.random(min,max),function()
			self:FaceEnemy()
			if self:GetHullRangeSquaredTo(enemy) < 120^2 then return true end
			if enemy:GetPos().z > self:GetPos().z then
				self:SetVelocity(self:GetVelocity() + self:GetUp()*1)
			end
		end)
		self.loco:SetVelocity(Vector(0,0,0))
	end
	self.Strafing = false
end

function ENT:OnIdle()self:AddPatrolPos(self:RandomPos(1500))end
function ENT:OnReachedPatrol(pos)self:Wait(math.random(3, 7))end 

function ENT:OnTakeDamage(dmg,hg)
	if self.Flinching or self:IsDead() then return end
	
	if dmg:IsDamageType(DMG_BLAST) or ((dmg:GetDamage()>=40) and (math.random(50)<=12)) then
		self.Flinching = true
		self:CICO(function()
			self:PlaySequenceAndMove("flinch"..math.random(3))
			if self:GetCooldown("GDKTauntVox") <= 0 then
				local snd = Sound("codz_megapack/ww2/gdk/vox/postpain"..math.random(4)..".wav")
				self:EmitSound(snd,511) 
				self:SetCooldown("GDKTauntVox",SoundDuration(snd) + math.random(10)*2)
			end
			self.Flinching = false
		end)
	end
end
function ENT:OnDeath(dmg)self:BecomeRagdoll(dmg)end

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
