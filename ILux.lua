require('Inspired')
LoadIOW()
pcall(require, 'IPrediction')
require('OpenPredict')
class "Lux"

function Lux:__init()
	self.Config = MenuConfig("ILux", "ILux")
	self.Config:Menu("Combo", "Combo")
	self.Config.Combo:Boolean("Do", "Execute Combo", true)
	self.Config.Combo:Boolean("DoQ", "Use Q", true)
	self.Config.Combo:Boolean("DoW", "Use W", false)
	self.Config.Combo:Boolean("DoE", "Use E", true)
	self.Config.Combo:Boolean("DoR", "Use R", false)
	self.Config:Menu("Harass", "Harass")
	self.Config.Harass:Boolean("Do", "Execute Harass", true)
	self.Config.Harass:Boolean("DoQ", "Use Q", true)
	self.Config.Harass:Slider("ManaQ", "Mana: Q", 35, 0, 100, 1)
	self.Config.Harass:Boolean("DoW", "Use W", false)
	self.Config.Harass:Slider("ManaW", "Mana: W", 80, 0, 100, 1)
	self.Config.Harass:Boolean("DoE", "Use E", true)
	self.Config.Harass:Slider("ManaE", "Mana: E", 60, 0, 100, 1)
	self.Config:Menu("LaneClear", "LaneClear")
	self.Config.LaneClear:Boolean("Do", "Execute LaneClear", true)
	self.Config.LaneClear:Boolean("DoE", "Use E", true)
	self.Config.LaneClear:Slider("ManaE", "Mana: E", 50, 0, 100, 1)
	self.Config:Menu("LastHit", "LastHit")
	self.Config.LastHit:Boolean("Do", "Execute LastHit", true)
	self.Config.LastHit:Boolean("DoE", "Use E", false)
	self.Config.LastHit:Slider("ManaE", "Mana: E", 50, 0, 100, 1)
	self.Config:Menu("Killsteal", "Killsteal")
	self.Config.Killsteal:Boolean("Do", "Execute Killsteal", true)
	self.Config.Killsteal:Boolean("DoQ", "Use Q", true)
	self.Config.Killsteal:Boolean("DoE", "Use E", true)
	self.Config.Killsteal:Boolean("DoR", "Use R", true)
	self.Config.Killsteal:Boolean("DoC", "Use Killstealcombos", true)
	self.Config:Menu("Draw", "Draw")
	self.Config.Draw:Boolean("Do", "Do Draw", true)
	self.Config.Draw:Boolean("DoQ", "Draw Q Range", true)
	self.Config.Draw:Boolean("DoW", "Draw W Range", false)
	self.Config.Draw:Boolean("DoE", "Draw E Range", true)
	self.Config.Draw:Boolean("DoR", "Draw R Range", false)
	self.Config.Draw:Boolean("DoD", "Draw Damage", true)
	self.Config:Boolean("windup", "Force AA-Weave", true)
	self.Config:Boolean("DoE", "Auto-detonate E", true)

	if IPrediction ~= nil then
		self.Config:Boolean("OnImmobile", "Cast E on Immobile", true)
		self.Config:Boolean("OnDash", "Cast Q on Dash", true)
		IPrediction.OnImmobile(function(target, pos, y)
			if self.Config.OnImmobile:Value() and ValidTarget(target, 1100 + 325 / 2) and y < 325 then
				CastSkillShot(_E, pos)
			end
		end, 1100, 1300, 0.25, 325 / 2)
		IPrediction.OnDash(function(target, y)
			if self.Config.OnDash:Value() and ValidTarget(target, 1175 + 130 / 2) and GetDistance(y) < 1175 + 130 / 2 then
				CastSkillShot(_Q, y)
			end
		end, 1100, 1200, 0.25, 130 / 2)
	end

	self._ = {
		Combo = {
			function() if self.Config.Combo.DoQ:Value() then self:Cast(_Q) end end,
			function() if self.Config.Combo.DoW:Value() then self:Cast(_W) end end,
			function() if self.Config.Combo.DoE:Value() then self:Cast(_E) end end,
			function() if self.Config.Combo.DoR:Value() then self:Cast(_R) end end,
		},
		Harass = {
			function() if self.Config.Harass.DoQ:Value() and self.mana >= self.Config.Harass.ManaQ:Value() then self:Cast(_Q) end end,
			function() if self.Config.Harass.DoW:Value() and self.mana >= self.Config.Harass.ManaW:Value() then self:Cast(_W) end end,
			function() if self.Config.Harass.DoE:Value() and self.mana >= self.Config.Harass.ManaE:Value() then self:Cast(_E) end end
		},
		LaneClear = {
			function() if self.Config.LaneClear.DoE:Value() and self.mana >= self.Config.LaneClear.ManaE:Value() then local x,y = GetFarmPosition(self.spellData[_E].range, self.spellData[_E].width) if x and y > 0 then CastSkillShot(_E, x) end end end
		},
		LastHit = {
			function()
				local doQ, doE = not self.mightDieOfE and false, self.Config.LastHit.DoE:Value() and self.mana >= self.Config.LastHit.ManaE:Value()
				for I = 1, minionManager.maxObjects do
					local minion = minionManager.objects[I]
					if ValidTarget(minion, 1200) then
						if doE and GetCurrentHP(minion) < CalcDamage(myHero, minion, 0, self.spellData[_E].dmg(myHero, minion)) then
							CastSkillShot(_E, GetOrigin(minion))
							self.mightDieOfE = true
							DelayAction(function() CastSpell(_E) end, 250)
							return
						end
						if doQ and GetCurrentHP(minion) < CalcDamage(myHero, minion, 0, self.spellData[_Q].dmg(myHero, minion)) then
							if self:PredCast(_Q, minion, self.spellData[_Q]) then
								return
							end
						end
					end
				end
			end
		},
		Killsteal = {
			function() self:Killsteal() end
		},
		Misc = {
			function() self.mana = 100*GetCurrentMana(myHero)/GetMaxMana(myHero) end,
			function() if self.Config.DoE:Value() then if GetCastName(myHero, _E) == "LuxLightstrikeToggle" then CastSpell(_E) end end end
		}
	}
	
	self.__ = {} self.___ = {} for _,__ in pairs(self._) do self.__[_] = 0 self.___[_] = #__ end self.____ = function(____) self.__[____] = self.__[____] + 1 if self.__[____] > self.___[____] then self.__[____] = 1 end self._[____][self.__[____]]() end

	self.spellData = {
		[_Q] = { name = "LuxLightBinding", speed = 1200, delay = 0.25, range = 1300, width = 130, collision = 1, type = "linear", dmg = function(source) return 10+50*GetCastLevel(myHero, _Q)+0.7*GetBonusAP(myHero) end},
		[_W] = { name = "LuxPrismaticWave", speed = 1630, delay = 0.25, range = 1250, width = 210, collision = false, type = "linear", dmg = function() return 0 end},
		[_E] = { name = "LuxLightStrikeKugel", speed = 1300, delay = 0.25, range = 1100, width = 325, collision = false, type = "circular", aoe = true, dmg = function(source) return 15+45*GetCastLevel(myHero, _E)+0.6*GetBonusAP(myHero) end},
		[_R] = { name = "LuxMaliceCannon", speed = math.huge, delay = 1, range = 3340, width = 250, collision = false, type = "linear", aoe = true, dmg = function(source, target) return self:Enlightened(target, 1) and 220+150*GetCastLevel(myHero, _R)+0.75*GetBonusAP(myHero) or 200+100*GetCastLevel(myHero, _R)+0.75*GetBonusAP(myHero) end}
	}

	self.ts = {}
	for I = 0, 3 do
		self.ts[I] = TargetSelector(self.spellData[I].range + self.spellData[I].width / 2, I==1 and TARGET_LOW_HP_PRIORITY or TARGET_LESS_CAST_PRIORITY, DAMAGE_MAGIC, true, I==1 and true or false)
	end

	self.enlightened = {}
	self.colors = { 0xDFFFE258, 0xDF8866F4, 0xDF55F855, 0xDFFF5858 }
	self.mana = 0
	self.str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}

	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnUpdateBuff(function(unit, buff) if buff.Name == "LuxIlluminatingFraulein" then self.enlightened[GetNetworkID(unit)] = buff.ExpireTime end end)
	OnProcessSpell(function(unit, spell) self:ProcessSpell(unit, spell) end)
	OnProcessSpellComplete(function(unit, spell) self:ProcessSpellComplete(unit, spell) end)

end

function Lux:Tick()
	local mode = IOW:Mode()
	if mode ~= "" then
		if self.Config[mode].Do:Value() then
			self.____(mode)
		end
	end
	if self.Config.Killsteal.Do:Value() then
		self.____("Killsteal")
	end
	self.____("Misc")
end

function Lux:ProcessSpell(unit, spell)
	if unit == myHero then
		if spell.name == "LuxLightStrikeKugel" or spell.name == "LuxLightBinding" then
			self.casted = true
			DelayAction(function() self.casted = false end, spell.windUpTime * 1000 + GetWindUp(myHero) * 1000)
		end
		if spell.name == "LuxLightstrikeToggle" then
			self.mightDieOfE = false
		end
	end
end

function Lux:ProcessSpellComplete(unit, spell)
	if unit == myHero then
		if spell.name:lower():find("attack") and self.Config.windup:Value() then
			local mode = IOW:Mode()
			if (mode == "Combo" or (mode == "Harass" and self.mana > self.Config.Harass.ManaQ:Value())) and self.Config[mode].DoQ:Value() then
				self:PredCast(_E, IOW.target, self.spellData[_E])
			end
		end
	end
end

function Lux:Draw()
	if not self.Config.Draw.Do:Value() then return end
	for _, spell in pairs({"Q", "W", "E", "R"}) do
		if self.Config.Draw["Do"..spell]:Value() then
			DrawCircle(myHeroPos(), self.spellData[_-1].range, 1, 100, 0xFFFFFFFF)
		end
	end
	if self.Config.Draw.DoD:Value() then
		for I = 1, #heroes do
			local unit = heroes[I]
			if ValidTarget(unit) then
				local barPos = GetHPBarPos(unit)
				if barPos.x > 0 and barPos.y > 0 then
					local sdmg = {}
					for slot = 0, 3 do
						sdmg[slot] = CanUseSpell(myHero, slot) == 0 and CalcDamage(myHero, unit, 0, self.spellData[slot].dmg(myHero, unit)) or 0
					end
					local mhp = GetMaxHP(unit)
					local chp = GetCurrentHP(unit)
					local offset = 103 * (chp/mhp)
					for __, spell in pairs({"Q", "W", "E", "R"}) do
						if sdmg[__-1] > 0 then
							local off = 103*(sdmg[__-1]/mhp)
							local _ = 2*__
							DrawLine(barPos.x+1+offset-off, barPos.y-1, barPos.x+1+offset, barPos.y-1, 5, self.colors[__])
							DrawLine(barPos.x+1+offset-off, barPos.y-1, barPos.x+1+offset-off, barPos.y+10-10*_, 1, self.colors[__])
							DrawText(spell, 11, barPos.x+1+offset-off, barPos.y-5-10*_, self.colors[__])
							DrawText(""..math.round(sdmg[__-1]), 10, barPos.x+4+offset-off, barPos.y+5-10*_, self.colors[__])
							offset = offset - off
						end
					end
				end
			end
		end
	end
end

function Lux:Enlightened(unit, windup)
	return self.enlightened[GetNetworkID(unit)] and self.enlightened[GetNetworkID(unit)] > GetGameTimer() + (windup or 0)
end

function Lux:Cast(spell)
	if spell ~= _R and self.Config.windup:Value() and IOW.target and (IOW.isWindingUp or self.casted) then return end
	local target = self.ts[spell]:GetTarget()
	if target then
		self:PredCast(spell, target, self.spellData[spell])
	else
		if spell == _W then
			CastSkillShot(_W, GetMousePos())
		end
	end
end

function Lux:PredCast(spell, target, t)
	if target == nil or GetOrigin(target) == nil or not IsTargetable(target) or IsImmune(target, myHero) or IsDead(target) or not IsVisible(target) then return false end
	if t.aoe then
		local pred = ({["linear"]=GetLinearAOEPrediction, ["circular"]=GetCircularAOEPrediction})[t.type]
		local p = pred(target, t)
		if p.hitChance >= 0.25 then
			myHero:CastSpell(spell, p.castPos.x, p.castPos.z)
		end
	else
		local p = GetPrediction(target, t)
		if p.hitChance >= 0.25 and (not t.collision or not p:mCollision(t.collision)) then
			myHero:CastSpell(spell, p.castPos.x, p.castPos.z)
		end
	end
end

function Lux:CastFirstPlusNext(unit, Table)
	local spell = Table[1]
	if spell then
		table.remove(Table, 1)
		local data = self.spellData[spell]
		if self:PredCast(spell, unit, data) then
			DelayAction(function() self:CastFirstPlusNext(unit, Table) end, data.delay * 1000)
		end
	end
end

function Lux:Killsteal()
	for I=1, #heroes do
		local unit = heroes[I]
		if GetTeam(unit) ~= GetTeam(myHero) then
			if ValidTarget(unit, 1300) then
				local chp = GetCurrentHP(unit)
				local sdmg = {}
				for slot = 0, 3 do
					sdmg[slot] = CanUseSpell(myHero, slot) == 0 and CalcDamage(myHero, unit, 0, self.spellData[slot].dmg(myHero, unit)) or 0
				end
				local allowedSpells = {}
				for i=0, 3 do
					if i ~= 1 and self.Config.Killsteal["Do"..self.str[i]]:Value() then
						if sdmg[i] > chp then
							self:PredCast(i, unit, self.spellData[i])
							return
						else
							table.insert(allowedSpells, i)
						end
					end
				end
				if self.Config.Killsteal.DoC:Value() then
					local cdmg = 0
					local toUse = {}
					for i = 1, #allowedSpells do
						local spell = allowedSpells[i]
						cdmg = cdmg + sdmg[spell]
						table.insert(toUse, spell)
						if cdmg > chp then
							break;
						end
					end
					if cdmg > chp then
						self:CastFirstPlusNext(unit, toUse)
					end
				end
			elseif ValidTarget(unit, 3340) then
				if self.Config.Killsteal["DoR"]:Value() then
					if GetCurrentHP(unit) < CalcDamage(myHero, unit, 0, self.spellData[_R].dmg(myHero, unit)) then
						local p = GetPrediction(unit, self.spellData[_R])
						if p.hitChance >= 0.25 then
							myHero:CastSpell(_R, p.castPos.x, p.castPos.z)
						end
					end
				end
			end
		end
	end
end

if GetObjectName(myHero) == "Lux" then Lux() end
