_G.IOWversion = 2
local myHero = GetMyHero()
local myHeroName = GetObjectName(myHero)

local function Set(list)
	local set = {}
	for _, l in ipairs(list) do 
		set[l] = true 
	end
	return set
end

function GetMaladySlot(unit)
	for slot = 6, 13 do
		if GetCastName(unit, slot) and GetCastName(unit, slot):lower():find("malady") then
			return slot
		end
	end
	return nil
end

local function GetD(p1, p2)
	local dx = p1.x - p2.x
	local dz = p1.z - p2.z
	return dx*dx + dz*dz
end

class "MinionManager"

function MinionManager:__init()
	self.objects = {}
	self.maxObjects = 0
	OnCreateObj(function(o) self:CreateObj(o) end)
end

function MinionManager:CreateObj(o)
	if o and GetObjectType(o) == Obj_AI_Minion then
		if GetObjectBaseName(o):find('_') or GetObjectName(o):find('_') then
			self:insert(o)
		end
	end
end

function MinionManager:insert(o)
	local function FindSpot()
		for i=1, self.maxObjects do
			local o = self.objects[i]
			if not o or not IsObjectAlive(o) then
				return i
			end
		end
		self.maxObjects = self.maxObjects + 1
		return self.maxObjects
	end
	self.objects[FindSpot()] = o
end

class "InspiredsOrbWalker"

function InspiredsOrbWalker:__init()
	self.attacksEnabled = true
	self.movementEnabled = true
	self.altAttacks = Set { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3" }
	self.resetAttacks = Set { "dariusnoxiantacticsonh", "fiorae", "garenq", "hecarimrapidslash", "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak", "luciane", "lucianq", "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq", "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow", "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw", "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie", "volibearq", "xenzhaocombotarget", "yorickspectral", "reksaiq", "riventricleave", "itemtitanichydracleave", "itemtiamatcleave" }
	self.autoAttackT = 0
	self.lastBoundingChange = 0
	self.lastStickChange = 0
	self.callbacks = {[1] = {}, [2] = {}, [3] = {}}
	self.bonusDamageTable = { -- TODO: Lulu, Rumble, Nautilus, TwistedFate, Ziggs
		["Aatrox"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg+(GotBuff(source, "aatroxwpower")>0 and 35*GetCastLevel(source, _W)+25 or 0), APDmg, TRUEDmg
			end,
		["Ashe"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg*(GotBuff(source, "asheqattack")>0 and 5*(0.01*GetCastLevel(source, _Q)+0.22) or GotBuff(target, "ashepassiveslow")>0 and (1.1+GetCritChance(source)*(1)) or 1), APDmg, TRUEDmg
			end,
		["Bard"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg+(GotBuff(source, "bardpspiritammocount")>0 and 30+GetLevel(source)*15+0.3*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Blitzcrank"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg*(GotBuff(source, "powerfist")+1), APDmg, TRUEDmg
			end,
		["Caitlyn"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "caitlynheadshot") > 0 and 1.5*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Chogath"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "vorpalspikes") > 0 and 15*GetCastLevel(source, _E)+5+.3*GetBonusAP(source) or 0), APDmg, TRUEDmg
			end,
		["Corki"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, 0, TRUEDmg + (GotBuff(source, "rapidreload") > 0 and .1*(ADDmg) or 0)
			end,
		["Darius"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "dariusnoxiantacticsonh") > 0 and .4*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Diana"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "dianaarcready") > 0 and math.max(5*GetLevel(source)+15,10*GetLevel(source)-10,15*GetLevel(source)-60,20*GetLevel(source)-125,25*GetLevel(source)-200)+.8*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Draven"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "dravenspinning") > 0 and (.1*GetCastLevel(source, _Q)+.35)*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Ekko"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "ekkoeattackbuff") > 0 and 30*GetCastLevel(source, _E)+20+.2*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Fizz"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "fizzseastonepassive") > 0 and 5*GetCastLevel(source, _W)+5+.3*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Garen"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "garenq") > 0 and 25*GetCastLevel(source, _Q)+5+.4*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Gragas"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "gragaswattackbuff") > 0 and 30*GetCastLevel(source, _W)-10+.3*GetBonusAP(source)+(.01*GetCastLevel(source, _W)+.07)*GetMaxHP(minion) or 0), TRUEDmg
			end,
		["Irelia"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, 0, TRUEDmg + (GotBuff(source, "ireliahitenstylecharged") > 0 and 25*GetCastLevel(source, _Q)+5+.4*(ADDmg) or 0)
			end,
		["Jax"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "jaxempowertwo") > 0 and 35*GetCastLevel(source, _W)+5+.6*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Jayce"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "jaycepassivemeleeatack") > 0 and 40*GetCastLevel(source, _R)-20+.4*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Jinx"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "jinxq") > 0 and .1*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Kalista"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg * 0.9, APDmg, TRUEDmg
			end,
		["Kassadin"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "netherbladebuff") > 0 and 20+.1*GetBonusAP(source) or 0) + (GotBuff(source, "netherblade") > 0 and 25*GetCastLevel(source, _W)+15+.6*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Kayle"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "kaylerighteousfurybuff") > 0 and 5*GetCastLevel(source, _E)+5+.15*GetBonusAP(source) or 0) + (GotBuff(source, "judicatorrighteousfury") > 0 and 5*GetCastLevel(source, _E)+5+.15*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Leona"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "leonashieldofdaybreak") > 0 and 30*GetCastLevel(source, _Q)+10+.3*GetBonusAP(source) or 0), TRUEDmg
			end,
		["Lux"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "luxilluminatingfraulein") > 0 and 10+(GetLevel(source)*8)+(GetBonusAP(source)*0.2) or 0), TRUEDmg
			end,
		["MasterYi"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "doublestrike") > 0 and .5*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Nocturne"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "nocturneumrablades") > 0 and .2*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Orianna"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + 2 + 8 * math.ceil(GetLevel(source)/3) + 0.15*GetBonusAP(source), TRUEDmg
			end,
		["RekSai"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "reksaiq") > 0 and 10*GetCastLevel(source, _Q)+5+.2*(ADDmg) or 0), TRUEDmg
			end,
		["Rengar"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "rengarqbase") > 0 and math.max(30*GetCastLevel(source, _Q)+(.05*GetCastLevel(source, _Q)-.05)*(ADDmg)) or 0) + (GotBuff(source, "rengarqemp") > 0 and math.min(15*GetLevel(source)+15,10*GetLevel(source)+60)+.5*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Shyvana"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "shyvanadoubleattack") > 0 and (.05*GetCastLevel(source, _Q)+.75)*(ADDmg) or 0), APDmg, TRUEDmg
			end,
		["Talon"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "talonnoxiandiplomacybuff") > 0 and 30*GetCastLevel(source, _Q)+.3*(GetBonusDmg(source)) or 0), APDmg, TRUEDmg
			end,
		["Teemo"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + 10*GetCastLevel(source, _E)+0.3*GetBonusAP(source), TRUEDmg
			end,
		["Trundle"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "trundletrollsmash") > 0 and 20*GetCastLevel(source, _Q)+((0.05*GetCastLevel(source, _Q)+0.095)*(ADDmg)) or 0), APDmg, TRUEDmg
			end,
		["Varus"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg, APDmg + (GotBuff(source, "varusw") > 0 and (4*GetCastLevel(source, _W)+6+.25*GetBonusAP(source)) or 0) , TRUEDmg
			end,
		["Vayne"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "vaynetumblebonus") > 0 and (.05*GetCastLevel(source, _Q)+.25)*(ADDmg) or 0), 0, TRUEDmg + (GotBuff(target, "vaynesilvereddebuff") > 1 and 10*GetCastLevel(source, _W)+10+((1*GetCastLevel(source, _W)+3)*GetMaxHP(target)/100) or 0)
			end,
		["Vi"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "vie") > 0 and 15*GetCastLevel(source, _E)-10+.15*(ADDmg)+.7*GetBonusAP(source) or 0) , APDmg, TRUEDmg
			end,
		["Volibear"] = function(source, target, ADDmg, APDmg, TRUEDmg)
				return ADDmg + (GotBuff(source, "volibearq") > 0 and 30*GetCastLevel(source, _Q) or 0), APDmg, TRUEDmg
			end
	}
	self.tableForHPPrediction = {}
	self:MakeMenu()
	self.mobs = MinionManager()
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpell(function(x,y) self:ProcessSpell(x,y) end)
	OnProcessSpellComplete(function(x,y) self:ProcessSpellComplete(x,y) end)
	OnProcessWaypoint(function(x,y) self:ProcessWaypoint(x,y) end)
	return self
end

function msg(x)
	PrintChat("<font color=\"#00FFFF\">[InspiredsOrbWalker]:</font> <font color=\"#FFFFFF\">"..tostring(x).."</font>")
end

function InspiredsOrbWalker:MakeMenu()
	self.Config = MenuConfig("Inspired'sOrbWalker", "IOW"..myHeroName)
	self.Config:Menu("h", "Hotkeys")
	self.Config.h:KeyBinding("Combo", "Combo", 32)
	self.Config.h:KeyBinding("Harass", "Harass", string.byte("C"))
	self.Config.h:KeyBinding("LastHit", "LastHit", string.byte("X"))
	self.Config.h:KeyBinding("LaneClear", "LaneClear", string.byte("V"))
	self.Config:Slider("stop", "Stickyradius (mouse)", GetHitBox(myHero), 0, 250, 1, function() self.lastBoundingChange = GetTickCount() + 375 end)
	self.Config:Slider("stick", "Stickyradius (target)", GetRange(myHero)*2, 0, 550, 1, function() self.lastStickChange = GetTickCount() + 375 end)
	self.Config:DropDown("lcm", "Lane Clear method", myHeroName == "Vayne" and 2 or 1, {"Focus Highest", "Stick to 1"})
	self.Config:Boolean("sticky", "Stick to one Target", true)
	self.Config:Boolean("wtt", "Walk to Target", true)
	self.Config:Boolean("drawcircle", "Autoattack Circle", true)
	self.Config:ColorPick("circlecol", "Circle color", {255,255,255,255})
	self.Config:Slider("circlequal", "Circle quality", 4, 0, 8, 1)
	self.Config:Info("space", "")
	self.Config:TargetSelector("ts", "TargetSelector", 2, GetRange(myHero), DAMAGE_PHYSICAL)
	self.Config:Info("space", "")
	self.Config:Info("version", "Version: v"..IOWversion)
	self.Config:Boolean("OrbWalking", "OrbWalking", false)
	self.permaShow = PermaShow(self.Config.OrbWalking)
	for _,p in pairs(self.Config.__params) do
		if p.id == "OrbWalking" then
			table.remove(self.Config.__params, _)
		end
	end
	self.toLoad = true
	msg("Loaded!")
end

function InspiredsOrbWalker:Mode()
	if self.Config.h.Combo:Value() then
		self:SwitchPermaShow("Combo")
		return "Combo"
	elseif self.Config.h.Harass:Value() then
		self:SwitchPermaShow("Harass")
		return "Harass"
	elseif self.Config.h.LastHit:Value() then
		self:SwitchPermaShow("LastHit")
		return "LastHit"
	elseif self.Config.h.LaneClear:Value() then
		self:SwitchPermaShow("LaneClear")
		return "LaneClear"
	else
		self:SwitchPermaShow("OrbWalking")
		return ""
	end
end

function InspiredsOrbWalker:SwitchPermaShow(mode)
	self.permaShow.p.name = mode
	self.Config["OrbWalking"]:Value(mode ~= "OrbWalking")
end

function InspiredsOrbWalker:Draw()
	if self.Config.drawcircle:Value() then
		DrawCircle(GetOrigin(myHero), GetRange(myHero)+GetHitBox(myHero), 1, (512/self.Config.circlequal:Value()), self.Config.circlecol:Value())
	end
	if self.lastBoundingChange > GetTickCount() then
		DrawCircle(GetOrigin(myHero), self.Config.stop:Value(), 2, 32, ARGB(255,255,255,255))
	end
	if self.lastStickChange > GetTickCount() and self.Config.stick then
		DrawCircle(GetOrigin(myHero), self.Config.stick:Value(), 2, 32, ARGB(255,255,255,255))
	end
end

function InspiredsOrbWalker:Tick()
	if self.toLoad then
		if GetRange(myHero) > 0 then
			if self.Config.stick then
				self.Config.stick:Value(GetRange(myHero))
			end
			if GetRange(myHero) >= 450 then
				for _,p in pairs(self.Config.__params) do
					if p.id == "wtt" then
						table.remove(self.Config.__params, _)
					end
				end
				self.Config["wtt"] = nil
				for _,p in pairs(self.Config.__params) do
					if p.id == "stick" then
						table.remove(self.Config.__params, _)
					end
				end
				self.Config["stick"] = nil
			end
			self.toLoad = false
		end
	end
	self.Config.ts.range = GetRange(myHero)+GetHitBox(myHero)
	if self:ShouldOrb() then
		self:Orb()
	end
	if self.isWindingDown then
		self.isWindingDown = (GetTickCount()-(self.autoAttackT+1000/(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero))-GetLatency()-70) < 0)
	end
end

function InspiredsOrbWalker:ShouldOrb()
	return self:Mode() ~= ""
end

_G.BEFORE_ATTACK, _G.ON_ATTACK, _G.AFTER_ATTACK = 1, 2, 3
function InspiredsOrbWalker:AddCallback(type, func)
	table.insert(self.callbacks[type], func)
end

function InspiredsOrbWalker:Execute(k, target)
	for _=1, #self.callbacks[k] do
		local func = self.callbacks[k][_]
		if func then
			func(target, self:Mode())
		end
	end
end

function InspiredsOrbWalker:GetTarget()
	if self.Config.h.Combo:Value() then
		return self:CanOrb(self.forceTarget) and self.forceTarget or (self.Config.sticky:Value() and self:CanOrb(self.target)) and self.target or self.Config.ts:GetTarget()
	elseif self.Config.h.Harass:Value() then
		return self:GetLastHit() or self:CanOrb(self.forceTarget) and self.forceTarget or (self.Config.sticky:Value() and self:CanOrb(self.target)) and self.target or self.Config.ts:GetTarget()
	elseif self.Config.h.LastHit:Value() then
		return self:GetLastHit()
	elseif self.Config.h.LaneClear:Value() then
		return self:GetLastHit() or self:GetLaneClear()
	else
		return nil
	end
end

function InspiredsOrbWalker:GetLastHit()
	for i=1, self.mobs.maxObjects do
		local o = self.mobs.objects[i]
		if o and IsObjectAlive(o) and GetTeam(o) == 300-GetTeam(myHero) then
			if self:CanOrb(o) then
				if self:PredictHealth(o, 1000*GetWindUp(myHero) + 1000*math.sqrt(GetD(GetOrigin(o), GetOrigin(myHero))) / self:GetProjectileSpeed(myHero)) < self:GetDmg(myHero, o) then
					return o
				end
			end
		end
	end
end

function InspiredsOrbWalker:GetLaneClear()
	local m = nil
	for i=1, self.mobs.maxObjects do
		local o = self.mobs.objects[i]
		if o and IsObjectAlive(o) and GetTeam(o) == 300-GetTeam(myHero) then
			if self:CanOrb(o) then
				if GetTeam(o) <= 200 and self:PredictHealth(o, 2000/(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero)) + 2000 * math.sqrt(GetD(GetOrigin(o), GetOrigin(myHero))) / self:GetProjectileSpeed(myHero)) < self:GetDmg(myHero, o) then
					return nil
				else
					m = o
				end
			end
		end
	end
	return m
end

function InspiredsOrbWalker:PredictHealth(unit, delta)
	local nID = GetNetworkID(unit)
	if self.tableForHPPrediction[nID] then
		local dmg = 0
		delta = delta + GetLatency()
		for _, k in pairs(self.tableForHPPrediction[nID]) do
			if k.time < GetTickCount() then
				if (k.time + k.reattacktime) - delta < GetTickCount() then
					dmg = dmg + k.dmg
				end
				self.tableForHPPrediction[nID][_] = nil
			else
				if k.time - delta < GetTickCount() then
					dmg = dmg + k.dmg
				end
			end
		end
		return GetCurrentHP(unit) - dmg
	else
		return GetCurrentHP(unit)
	end
end

function InspiredsOrbWalker:GetDmg(source, target)
	if target == nil or source == nil or not IsObjectAlive(source) or not IsObjectAlive(target) then
		return 0
	end
	local ADDmg            = 0
	local APDmg            = 0
	local TRUEDmg          = 0
	local AP               = 0
	local Level            = 0
	local TotalDmg         = GetBonusDmg(source)+GetBaseDamage(source)
	local crit             = 0
	local damageMultiplier = 1
	local sourceType       = GetObjectType(source)
	local targetType       = GetObjectType(target)
	local myHeroType 	   = GetObjectType(myHero)
	local ArmorPen         = 0
	local ArmorPenPercent  = 0
	local MagicPen         = 0
	local MagicPenPercent  = 0
	local Armor             = GetArmor(target)
	local MagicArmor        = GetMagicResist(target)
	local ArmorPercent      = 0
	local MagicArmorPercent = 0

	if targetType == Obj_AI_Turret then
		ArmorPenPercent = 1
		ArmorPen = 0
	end

	if sourceType == Obj_AI_Minion then
		ArmorPenPercent = 1
		if targetType == myHeroType and GetTeam(source) <= 200 then
			damageMultiplier = 0.60 * damageMultiplier
		elseif targetType == Obj_AI_Turret then
			damageMultiplier = 0.475 * damageMultiplier
		end
		Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
		ArmorPercent = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
	elseif sourceType == Obj_AI_Turret then
		ArmorPenPercent = 0.7
		if GetObjectBaseName(target) == "Red_Minion_MechCannon" or GetObjectBaseName(target) == "Blue_Minion_MechCannon" then
			damageMultiplier = 0.8 * damageMultiplier
		elseif GetObjectBaseName(target) == "Red_Minion_Wizard" or GetObjectBaseName(target) == "Blue_Minion_Wizard" or GetObjectBaseName(target) == "Red_Minion_Basic" or GetObjectBaseName(target) == "Blue_Minion_Basic" then
			damageMultiplier = (1 / 0.875) * damageMultiplier
		end
		damageMultiplier = 1.05 * damageMultiplier
		Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
		if targetType == Obj_AI_Minion then
			ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or 0
		else
			ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
		end
	elseif sourceType == myHeroType then
		if targetType == Obj_AI_Turret then
			TotalDmg = math.max(TotalDmg, GetBaseDamage(source) + 0.4 * GetBonusAP(source))
			damageMultiplier = 0.95 * damageMultiplier
		else
			--damageMultiplier = damageMultiplier * 0.95
			AP = GetBonusAP(source)
			crit = GetCritChance(source)
			ArmorPen         = math.floor(GetArmorPenFlat(source))
			ArmorPenPercent  = math.floor(GetArmorPenPercent(source)*100)/100
			MagicPen         = math.floor(GetMagicPenFlat(source))
			MagicPenPercent  = math.floor(GetMagicPenPercent(source)*100)/100
			Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
			if targetType == Obj_AI_Minion then
				ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or 0
			else
				ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
			end
		end
	end
	MagicArmor = GetMagicResist(target)*MagicPenPercent-MagicPen
	local MagicArmorPercent = MagicArmor > 0 and math.floor(MagicArmor*100/(100+MagicArmor))/100 or math.ceil(MagicArmor*100/(100-MagicArmor))/100

	ADDmg = TotalDmg
	if source == myHero and targetType ~= Obj_AI_Turret then
		if GetMaladySlot(source) then
			APDmg = 15 + 0.15*AP
		end
		if GotBuff(source, "itemstatikshankcharge") == 100 then
			APDmg = APDmg + 100
		end
		if source == myHero and not freeze then
			if self.bonusDamageTable[GetObjectName(source)] then
				ADDmg, APDmg, TRUEDmg = self.bonusDamageTable[GetObjectName(source)](source, target, ADDmg, APDmg, TRUEDmg)
			end
			if GotBuff(source, "sheen") > 0 then
				ADDmg = ADDmg + TotalDmg
			end
			if GotBuff(source, "lichbane") > 0 then
				ADDmg = ADDmg + TotalDmg*0.75
				APDmg = APDmg + 0.5*GetBonusAP(source)
			end
			if GotBuff(source, "itemfrozenfist") > 0 then
				ADDmg = ADDmg + TotalDmg*1.25
			end
		end
	end
	dmg = math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
	dmg = math.floor(dmg*damageMultiplier)+TRUEDmg
	return dmg
end

function InspiredsOrbWalker:GetProjectileSpeed(o)
	local s = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000, ["SRU_OrderMinionRanged"] = 650, ["SRU_ChaosMinionRanged"] = 650, ["SRU_OrderMinionSiege"] = 1200, ["SRU_ChaosMinionSiege"] = 1200, ["SRUAP_Turret_Chaos1"]  = 1200, ["SRUAP_Turret_Chaos2"]  = 1200, ["SRUAP_Turret_Chaos3"] = 1200, ["SRUAP_Turret_Order1"]  = 1200, ["SRUAP_Turret_Order2"]  = 1200, ["SRUAP_Turret_Order3"] = 1200, ["SRUAP_Turret_Chaos4"] = 1200, ["SRUAP_Turret_Chaos5"] = 500, ["SRUAP_Turret_Order4"] = 1200, ["SRUAP_Turret_Order5"] = 500, ["HA_ChaosMinionRanged"] = 650, ["HA_OrderMinionRanged"] = 650, ["HA_ChaosMinionSiege"] = 1200, ["HA_OrderMinionSiege"] = 1200 }
	return s[GetObjectName(o)] or math.huge
end

function InspiredsOrbWalker:Orb()
	if self.Config.wtt and self.Config.wtt:Value() then
		self.targetPos = self.forcePos or GetOrigin(self.target)
	else
		self.targetPos = nil
	end
	if self.isWindingUp then
		if self.target and IsDead(self.target) then
			self:ResetAA()
		end
		if self.autoAttackT + 1000*GetWindUp(myHero) + GetLatency() + 70 < GetTickCount() then
			self.isWindingUp = false
		end
	else
		self.target = self:GetTarget()
		if self.isWindingDown or not self.target or not self.attacksEnabled then
			if GetD(GetOrigin(myHero), GetMousePos()) > self.Config.stop:Value()^2 and self.movementEnabled then
				if self.targetPos and GetD(self.targetPos, GetOrigin(myHero)) < (self.Config.stick:Value())^2 then
					if GetD(GetOrigin(myHero), self.targetPos) > GetRange(myHero)^2 then
						MoveToXYZ(self:MakePos(self.targetPos))
					end
				else
					MoveToXYZ(self:MakePos(self.forcePos or GetMousePos()))
				end
			else
				HoldPosition()
			end
		else
			self:Execute(1, self.target)
			self.autoAttackT = GetTickCount()
			AttackUnit(self.target)
		end
	end
end

function InspiredsOrbWalker:MakePos(p)
	local mPos = p
	local hPos = GetOrigin(myHero)
	local tV = {x = (mPos.x-hPos.x), y = (mPos.z-hPos.z), z = (mPos.z-hPos.z)}
	local len = math.sqrt(tV.x * tV.x + tV.y * tV.y + tV.z * tV.z)
	local ran = math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)
	return {x = hPos.x + (250+ran) * tV.x / len, y = hPos.y, z = hPos.z + (250+ran) * tV.z / len}
end

function InspiredsOrbWalker:CanOrb(t)
	local r = GetRange(myHero)+GetHitBox(myHero)
	if t == nil or GetOrigin(t) == nil or not IsTargetable(t) or IsImmune(t,myHero) or IsDead(t) or not IsVisible(t) or (r and GetD(GetOrigin(t), GetOrigin(myHero)) > r^2) then
		return false
	end
	return true
end

function InspiredsOrbWalker:ProcessSpell(unit, spell)
	if unit and spell and unit == myHero and spell.name then
		local spellName = spell.name:lower()
		if spellName:find("attack") or self.altAttacks[spellName] then
			self.isWindingDown = false
			self.isWindingUp = true
			self:Execute(2, spell.target)
			self.autoAttackT = GetTickCount()
		end
		if self.resetAttacks[spellName] then
			self:ResetAA()
		end
	end
end

function InspiredsOrbWalker:ProcessSpellComplete(unit, spell)
	if unit and spell and unit == myHero and spell.name then
		local spellName = spell.name:lower()
		if spellName:find("attack") or self.altAttacks[spellName] then
			self.isWindingUp = false
			self.isWindingDown = true
			self.windUpT = GetTickCount()-self.autoAttackT
			self:Execute(3, spell.target)
		end
	end
	local target = spell.target
	if target and IsObjectAlive(target) and GetOrigin(target) then
		if spell.name:lower():find("attack") then
			local nID = GetNetworkID(target)
			local timer = math.sqrt(GetD(GetOrigin(target),GetOrigin(unit)))/self:GetProjectileSpeed(unit)
			if not self.tableForHPPrediction[nID] then self.tableForHPPrediction[nID] = {} end
			table.insert(self.tableForHPPrediction[nID], {source = unit, dmg = self:GetDmg(unit, target), time = GetTickCount() + 1000*timer, reattacktime = spell.animationTime})
		end
	end
end

function InspiredsOrbWalker:ProcessWaypoint(unit, waypoint)
	if unit and waypoint and unit == myHero and waypoint.index > 1 then
		if self.isWindingUp then
			self.isWindingUp = false
		end
	end
end

function InspiredsOrbWalker:ResetAA()
	self.isWindingUp = false
	self.isWindingDown = false
	self.autoAttackT = 0
end

_G.IOW = InspiredsOrbWalker()
