require('Inspired')

DelayAction(function() 
    if IWalkConfig == nil then
      iac = IAC(true)
      for _,k in pairs(iac.adcTable) do
        if k == myHeroName then
          PrintChat("<font color=\"#6699ff\"><b>[Inspireds Auto Carry]: Plugin '"..myHeroName.."' - </b></font> <font color=\"#FFFFFF\">Loaded.</font>") 
        end
      end
    end
  end, 100)

  function PredCast(spell, target, speed, delay, range, width, coll)
      local Pred = GetPredictionForPlayer(GetMyHeroPos(),target,GetMoveSpeed(target), speed, delay, range, width, coll, true)
      if Pred.HitChance >= 1 then
        CastSkillShot(spell, Pred.PredPos.x, Pred.PredPos.y, Pred.PredPos.z)
      end
  end

class 'IAC' -- {

  function IAC:__init(bool)
    IWalkTarget = nil
    myHero = GetMyHero()
    myHeroName = GetObjectName(myHero)
    waitTickCount = 0
    IWalkConfig = scriptConfig("IAC", "Inspired's Auto Carry")
    self.move = true
    self.aa = true
    self.orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
    self.aaResetTable = { ["Diana"] = {_E}, ["Darius"] = {_W}, ["Garen"] = {_Q}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} }
    self.aaResetTable2 = { ["Ashe"] = {_W}, ["Diana"] = {_Q}, ["Graves"] = {_Q}, ["Lucian"] = {_W}, ["Quinn"] = {_Q}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} }
    self.aaResetTable3 = { ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Quinn"] = {_E}, ["Teemo"] = {_Q}, ["Tristana"] = {_E} }
    self.aaResetTable4 = { ["Graves"] = {_E},  ["Lucian"] = {_E},  ["Vayne"] = {_Q} }
    self.isAAaswellTable = { ["Quinn"] = "QuinnWEnhanced" }
    self.adcTable = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne"}
    self.gapcloserTable = {
      ["Akali"] = _R, ["Elise"] = _Q, ["Elise"] = _E, ["Fiora"] = _Q, ["Fizz"] = _Q, 
      ["Graves"] = _E, ["Irelia"] = _Q, ["JarvanIV"] = _Q, ["Jax"] = _Q, ["Kennen"] = _E, 
      ["KhaZix"] = _E, ["Lucian"] = _E, ["MasterYi"] = _Q, ["MonkeyKing"] = _E, ["Pantheon"] = _W, 
      ["Poppy"] = _E, ["RekSai"] = _E, ["Renekton"] = _E, ["Riven"] = _E, ["Sejuani"] = _Q, 
      ["Shen"] = _E, ["Talon"] = _E, ["Udyr"] = _E, ["Volibear"] = _Q, ["XinZhao"] = _E
    }
    self.myRange = GetRange(myHero)+GetHitBox(myHero)*2
    self:Load(bool)
    OnProcessSpell(function(unit, spell) self:ProcessSpell(unit, spell) end)
    return self
  end

  function IAC:Load(bool)
    DelayAction(function() -- my OnLoad
      if not bool then self:OverwriteIACPlugins() end
      self:MakeMenu()
      OnLoop(function() self:OnLoop() end)
    end, 0)
  end

  function IAC:OnLoop()
        if IWalkConfig.D then self:DmgCalc() end
        if waitTickCount > GetTickCount() then return end
        self:DoChampionPlugins2()
        self:IWalk()
  end

  function IAC:DmgCalc()
    for _,unit in pairs(GetEnemyHeroes()) do
      if ValidTarget(unit) then
        local hPos = GetHPBarPos(unit)
        DrawText(self:PossibleDmg(unit), 15, hPos.x, hPos.y+20, 0xffffffff)
      end
    end
  end

  function IAC:PossibleDmg(unit)
    local addDamage = GetBonusDmg(myHero)
    local TotalDmg = (GetBonusDmg(myHero)+GetBaseDamage(myHero))*(((IWalkConfig.R and (GetCastName(myHero, _R) ~= "RivenFengShuiEngine" or CanUseSpell(myHero, _R)))) and 1.2 or 1)
    local dmg = 0
    local cthp = GetCurrentHP(unit)
    local mthp = GetMaxHP(unit)
    if myHeroName == "Riven" then
      local dmg = 0
      local mlevel = GetLevel(myHero)
      local pdmg = CalcDamage(myHero, unit, 5+math.max(5*math.floor((mlevel+2)/3)+10,10*math.floor((mlevel+2)/3)-15)*TotalDmg/100)
      if CanUseSpell(myHero, _Q) == READY then
        local level = GetCastLevel(myHero, _Q)
        dmg = dmg + CalcDamage(myHero, unit, 20*level+(0.35+0.05*level)*TotalDmg-10)*3+CalcDamage(myHero, unit, TotalDmg)*3+pdmg*3
      end
      if CanUseSpell(myHero, _W) == READY then
        local level = GetCastLevel(myHero, _W)
        dmg = dmg + CalcDamage(myHero, unit, 20+30*level+TotalDmg)+CalcDamage(myHero, unit, TotalDmg)+pdmg
      end
      if (CanUseSpell(myHero, _R) == READY or GetCastName(myHero, _R) ~= "RivenFengShuiEngine") and IWalkConfig.R then
        local level = GetCastLevel(myHero, _R)
        local rdmg = CalcDamage(myHero, unit, (40+40*level+0.6*addDamage)*(math.min(3,math.max(1,4*(mthp-cthp)/mthp))))
        if rdmg > cthp and ValidTarget(unit, 800) and GetCastName(myHero, _R) ~= "RivenFengShuiEngine" and IWalkConfig.Combo then 
          local unitPos = GetOrigin(unit)
          CastSkillShot(_R, unitPos.x, unitPos.y, unitPos.z) 
        end
        cthp = cthp - dmg
        rdmg = CalcDamage(myHero, unit, (40+40*level+0.6*addDamage)*(math.min(3,math.max(1,4*(mthp-cthp)/mthp))))
        dmg = dmg + rdmg
      end
      return dmg > cthp and "Killable" or math.floor(100*dmg/cthp).."% Dmg"
    else
      dmg = CalcDamage(myHero, unit, TotalDmg)
      return math.ceil(cthp/dmg).." AA"
    end
  end

  function IAC:IWalk()
    if IWalkConfig.LastHit or IWalkConfig.LaneClear or IWalkConfig.Harass then
      for _,k in pairs(GetAllMinions(MINION_ENEMY)) do
        local targetPos = GetOrigin(k)
        local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
        local hp = GetCurrentHP(k)
        local dmg = CalcDamage(myHero, k, GetBonusDmg(myHero)+GetBaseDamage(myHero))
        if dmg > hp then
          if (IWalkConfig.LastHit or IWalkConfig.LaneClear or IWalkConfig.Harass) and IsInDistance(k, self.myRange) and GetTickCount() > self.orbTable.lastAA + self.orbTable.animation then
            AttackUnit(k)
            return
          end
        end
      end
    end
    if IWalkConfig.Combo or IWalkConfig.Harass or IWalkConfig.LastHit or IWalkConfig.LaneClear then
      self:DoWalk()
    end
  end

  function IAC:DoWalk()
    self.myRange = GetRange(myHero)+GetHitBox(myHero)+(IWalkTarget and GetHitBox(IWalkTarget) or GetHitBox(myHero))
    if IWalkConfig.C then Circle(myHero,self.myRange):draw() end
    local addRange = ((self.gapcloserTable[myHeroName] and CanUseSpell(myHero, gapcloserTable[myHeroName]) == READY) and 250 or 0) + (GetObjectName(myHero) == "Jinx" and (GetCastLevel(myHero, _Q)*25+50) or 0)
    IWalkTarget = GetTarget(self.myRange + addRange, DAMAGE_PHYSICAL)
    if IWalkConfig.LaneClear then
      IWalkTarget = GetHighestMinion(GetOrigin(myHero), self.myRange, MINION_ENEMY)
    end
    local unit = IWalkTarget
    if (IWalkConfig.S or IWalkConfig.Combo) and ValidTarget(unit) then self:DoChampionPlugins(unit) end
    if ValidTarget(unit, self.myRange) and GetTickCount() > self.orbTable.lastAA + self.orbTable.animation and self.aa then
      AttackUnit(unit)
    elseif GetTickCount() > self.orbTable.lastAA + self.orbTable.windUp and self.move then
      if GetRange(myHero) < 450 and unit and GetObjectType(unit) == GetObjectType(myHero) and ValidTarget(unit, self.myRange) then
        local unitPos = GetOrigin(unit)
        if GetDistance(unit) > self.myRange/2 then
          MoveToXYZ(unitPos.x, unitPos.y, unitPos.z)
        end
      else
        if IWalkConfig.Combo and self.gapcloserTable[myHeroName] and ValidTarget(unit, self.myRange + 250) and IWalkConfig[str[self.gapcloserTable[myHeroName]].."g"] and CanUseSpell(myHero, gapcloserTable[myHeroName]) == READY then
          local unitPos = GetOrigin(unit)
          CastSkillShot(self.gapcloserTable[myHeroName], unitPos.x, unitPos.y, unitPos.z)
          if myHeroName == "Riven" and IWalkConfig["W"] and CanUseSpell(myHero, _W) == READY then
            if PossibleDmg(unit):find("Killable") and IWalkConfig.R then
              DelayAction(function() CastTargetSpell(myHero, _R) end, 137)
            else
              DelayAction(function() CastTargetSpell(myHero, _W) end, 137)
            end
            self.orbTable.lastAA = 0
          end
        else
          self:Move()
        end
      end
    end
  end

  function IAC:Move()
    local movePos = GenerateMovePos()
    if GetDistance(GetMousePos()) > GetHitBox(myHero) then
      MoveToXYZ(movePos.x, GetMyHeroPos().y, movePos.z)
    end
  end

  function IAC:GetIWalkTarget()
    return IWalkTarget
  end

  function IAC:ProcessSpell(unit, spell)
    if unit and unit == myHero and spell then
      if (spell.name:lower():find("attack") or (self.isAAaswellTable[myHeroName] and self.isAAaswellTable[myHeroName] == spell.name)) then
        self.orbTable.lastAA = GetTickCount() + GetLatency()
        self.orbTable.windUp = myHeroName == "Kalista" and 0 or spell.windUpTime * 1000
        self.orbTable.animation = GetAttackSpeed(GetMyHero()) < 2.25 and spell.animationTime * 1000 or 1000 / GetAttackSpeed(GetMyHero())
        DelayAction(function() 
                            if (IWalkConfig.S or IWalkConfig.Combo) and ValidTarget(IWalkTarget, self.myRange) then 
                              self:WindUp(IWalkTarget) 
                            end
                          end, spell.windUpTime * 1000 + GetLatency())
      elseif spell.name:lower():find("katarinar") then
        waitTickCount = GetTickCount() + 2500
      end
    end
  end

  function IAC:WindUp(unit)
    local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
    if self.aaResetTable4[myHeroName] then
      for _,k in pairs(self.aaResetTable4[myHeroName]) do
        if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] then
          self.orbTable.lastAA = 0
          local movePos = GenerateMovePos()
          CastSkillShot(k, movePos.x, movePos.y, movePos.z)
          return true
        end
      end
    end
    if self.aaResetTable[myHeroName] then
      for _,k in pairs(self.aaResetTable[myHeroName]) do
        if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < self.myRange * self.myRange then
          self.orbTable.lastAA = 0
          CastSpell(k)
          return true
        end
      end
    end
    if self.aaResetTable2[myHeroName] then
      for _,k in pairs(self.aaResetTable2[myHeroName]) do
        if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < self.myRange * self.myRange and (not myHeroName == "Quinn" or CanUseSpell(myHero, _E) ~= READY) then
          local unitPos = GetOrigin(unit)
          CastSkillShot(k, unitPos.x, unitPos.y, unitPos.z)
          if myHeroName == "Riven" then
            local unitPos = GetOrigin(unit)
            MoveToXYZ(unitPos.x, unitPos.y, unitPos.z)
          end
          self.orbTable.lastAA = 0
          return true
        end
      end
    end
    if self.aaResetTable3[myHeroName] then
      for _,k in pairs(self.aaResetTable3[myHeroName]) do
        if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < self.myRange * self.myRange then
          if myHeroName ~= "Quinn" or GotBuff(unit, "QuinnW") < 1 then
            self.orbTable.lastAA = 0
            CastTargetSpell(unit, k)
          end
          return true
        end
      end
    end
    return IWalkConfig.I and CastOffensiveItems(unit)
  end

  function IAC:MakeMenu()
    str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
    if self.aaResetTable3[myHeroName] then
      for _,k in pairs(self.aaResetTable3[myHeroName]) do
        IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, not inbuiltOverwritten)
      end
    end
    if self.aaResetTable2[myHeroName] then
      for _,k in pairs(self.aaResetTable2[myHeroName]) do
        IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, not inbuiltOverwritten)
      end
    end
    if self.aaResetTable[myHeroName] then
      for _,k in pairs(self.aaResetTable[myHeroName]) do
        IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, not inbuiltOverwritten)
      end
    end
    if self.aaResetTable4[myHeroName] then
      for _,k in pairs(self.aaResetTable4[myHeroName]) do
        IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, not inbuiltOverwritten)
      end
    end
    if self.gapcloserTable[myHeroName] then
      k = self.gapcloserTable[myHeroName]
      if type(k) == "number" then
        IWalkConfig.addParam(str[k].."g", "Gapclose with "..str[k], SCRIPT_PARAM_ONOFF, not inbuiltOverwritten)
      end
    end
    if not inbuiltOverwritten then 
      self:DoChampionPluginMenu()
      IWalkConfig.addParam("S", "Skillfarm", SCRIPT_PARAM_ONOFF, true) 
    end
    IWalkConfig.addParam("I", "Cast Items", SCRIPT_PARAM_ONOFF, true)
    IWalkConfig.addParam("D", "Damage Calc", SCRIPT_PARAM_ONOFF, true)
    IWalkConfig.addParam("C", "AA Range Circle", SCRIPT_PARAM_ONOFF, true)

    IWalkConfig.addParam("LastHit", "LastHit", SCRIPT_PARAM_KEYDOWN, string.byte("X"))
    IWalkConfig.addParam("Harass", "Harass", SCRIPT_PARAM_KEYDOWN, string.byte("C"))
    IWalkConfig.addParam("LaneClear", "LaneClear", SCRIPT_PARAM_KEYDOWN, string.byte("V"))
    IWalkConfig.addParam("Combo", "Combo", SCRIPT_PARAM_KEYDOWN, string.byte(" "))
  end

  function IAC:DoChampionPluginMenu()
    local manaPerc = Get
    if myHeroName == "Ashe" then 
      IWalkConfig.addParam("Q", "Use Q (5 stacks)", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("R", "Use R (execute)", SCRIPT_PARAM_ONOFF, true) 
    elseif myHeroName == "Caitlyn" then
      IWalkConfig.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("R", "Use R (execute)", SCRIPT_PARAM_ONOFF, true) 
    elseif myHeroName == "Corki" then
    elseif myHeroName == "Draven" then
    elseif myHeroName == "Ezreal" then
      IWalkConfig.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("R", "Use R (execute)", SCRIPT_PARAM_ONOFF, true) 
    elseif myHeroName == "Graves" then
    elseif myHeroName == "Jinx" then
      IWalkConfig.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("R", "Use R (execute)", SCRIPT_PARAM_ONOFF, true) 
    elseif myHeroName == "Kalista" then
      IWalkConfig.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true) 
      IWalkConfig.addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true) 
    elseif myHeroName == "KogMaw" then
    elseif myHeroName == "Lucian" then
    elseif myHeroName == "MissFortune" then
    elseif myHeroName == "Quinn" then
    elseif myHeroName == "Riven" then 
      IWalkConfig.addParam("R", "Use R if Kill", SCRIPT_PARAM_ONOFF, true) 
    elseif myHeroName == "Sivir" then
    elseif myHeroName == "Teemo" then
    elseif myHeroName == "Tristana" then
    elseif myHeroName == "Twitch" then
    elseif myHeroName == "Varus" then
    elseif myHeroName == "Vayne" then
      IWalkConfig.addParam("E", "Use E (stun)", SCRIPT_PARAM_ONOFF, true) 
    end
  end

  function IAC:DoChampionPlugins(unit)
    if myHeroName == "Ashe" then
      if CanUseSpell(myHero, _Q) == READY and GotBuff(myHero, "asheqcastready") > 0 and IWalkConfig.Q then
        CastSpell(_Q)
      end
      if CanUseSpell(myHero, _W) == READY and IWalkConfig.W then
        local unitPos = GetOrigin(unit)
        CastSkillShot(_W, unitPos.x, unitPos.y, unitPos.z)
      end
    elseif myHeroName == "Corki" then
    elseif myHeroName == "Draven" then
    elseif myHeroName == "Graves" then
    elseif myHeroName == "Jinx" then
      if CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q and GetTickCount() > self.orbTable.lastAA + self.orbTable.windUp then
        if GetRange(myHero) == 525 and GetDistance(unit) > 525 then
          CastSpell(_Q)
        elseif GetRange(myHero) > 525 and GetDistance(unit) < 525 + GetHitBox(myHero) + GetHitBox(unit) then
          CastSpell(_Q)
        end
      end
    elseif myHeroName == "KogMaw" then
    elseif myHeroName == "Lucian" then
    elseif myHeroName == "MissFortune" then
    elseif myHeroName == "Quinn" then
    elseif myHeroName == "Sivir" then
    elseif myHeroName == "Teemo" then
    elseif myHeroName == "Tristana" then
      if CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q then
        CastSpell(_Q)
      end
      if CanUseSpell(myHero, _E) == READY and IWalkConfig.E then
        CastSpell(_E)
      end
    elseif myHeroName == "Twitch" then
    elseif myHeroName == "Varus" then
    elseif myHeroName == "Vayne" then
      if IWalkConfig.E and CanUseSpell(myHero, _E) == READY then
        local Pred = GetPredictionForPlayer(GetMyHeroPos(),unit,GetMoveSpeed(unit), 2000, 0.25, 1000, 1, false, true)
        for _=0,450,GetHitBox(unit) do
          local tPos = Vector(Pred.PredPos)+Vector(Vector(Pred.PredPos)-Vector(myHero)):normalized()*_
          if IsWall(tPos) then
            CastTargetSpell(unit, _E)
          end
        end
      end
    end
  end

  function IAC:DoChampionPlugins2()
    if myHeroName == "Ashe" then
      for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit, 3500) and CanUseSpell(myHero, _R) == READY and IWalkConfig.R then
          if CalcDamage(myHero, unit, 0, 75 + 175*GetCastLevel(myHero,_R) + GetBonusAP(myHero)) >= GetCurrentHP(unit) then
             PredCast(_R, unit, 1600, 250, 20000, 130, false)
          end
        end
      end
    elseif myHeroName == "Caitlyn" then
      for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit, GetCastRange(myHero, _R)) and CanUseSpell(myHero, _R) == READY and IWalkConfig.R then
          if CalcDamage(myHero, unit, 25+225*GetCastLevel(myHero, _R)+GetBonusDmg(myHero)*2) >= GetCurrentHP(unit) then
            CastTargetSpell(unit, _R)
          end
        end
      end
      local unit = GetTarget(1300, DAMAGE_PHYSICAL)
      if unit and CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q and IWalkConfig.Combo then
        PredCast(_Q, unit, 2200, 625, 1300, 90, false)
      end
    elseif myHeroName == "Ezreal" then
      for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit, 3500) and CanUseSpell(myHero, _R) == READY and IWalkConfig.R then
          if CalcDamage(myHero, unit, 0, 200 + 150*GetCastLevel(myHero,_R) + .9*GetBonusAP(myHero)+GetBonusDmg(myHero)) >= GetCurrentHP(unit) then
            PredCast(_R, unit, 2000, 1000, 20000, 160, false)
          end
        end
      end
      local unit = GetTarget(1200, DAMAGE_PHYSICAL)
      if unit and CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q and IWalkConfig.Combo then
        PredCast(_Q, unit, 2000, 250, 1200, 60, false)
      end
      local unit = GetTarget(1050, DAMAGE_PHYSICAL)
      if unit and CanUseSpell(myHero, _W) == READY and IWalkConfig.W and IWalkConfig.Combo then
        PredCast(_W, unit, 1600, 250, 1050, 80, false)
      end
    elseif myHeroName == "Graves" then
      for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit, 1100) and CanUseSpell(myHero, _R) == READY and IWalkConfig.R then
          if CalcDamage(myHero, unit, 100+150*GetCastLevel(myHero, _R)+GetBonusDmg(myHero)*1.5) >= GetCurrentHP(unit) then
            PredCast(_R, unit, 2100, 250, 1100, 100, false)
          end
        end
      end
    elseif myHeroName == "Jinx" then
      for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit, 3500) and CanUseSpell(myHero, _R) == READY and IWalkConfig.R then
          if CalcDamage(myHero, unit, (GetMaxHP(unit)-GetCurrentHP(unit))*(0.2+0.05*GetCastLevel(myHero, _R))+(150+100*GetCastLevel(myHero, _R)+GetBonusDmg(myHero))*math.max(0.1, math.min(1, GetDistance(unit)/1700))) >= GetCurrentHP(unit) then
            PredCast(_R, unit, 2300, 600, 20000, 140, false)
          end
        end
      end
      local unit = GetTarget(1500, DAMAGE_PHYSICAL)
      if unit and CanUseSpell(myHero, _W) == READY and IWalkConfig.W and IWalkConfig.Combo then
        PredCast(_W, unit, 3300, 600, 1500, 60, true)
      end
    elseif myHeroName == "Kalista" then
      local function kalE(x) if x <= 1 then return 10 else return kalE(x-1) + 2 + x end end
      for _,unit in pairs(GetEnemyHeroes()) do
        local TotalDmg = GetBonusDmg(myHero)+GetBaseDamage(myHero)
        local dmgE = (GotBuff(unit,"kalistaexpungemarker") > 0 and (10 + (10 * GetCastLevel(myHero,_E)) + (TotalDmg * 0.6)) + (GotBuff(unit,"kalistaexpungemarker")-1) * (kalE(GetCastLevel(myHero,_E)) + (0.175 + 0.025 * GetCastLevel(myHero,_E))*TotalDmg) or 0)
        local dmg = CalcDamage(myHero, unit, dmgE)
        local hp = GetCurrentHP(unit)
        local targetPos = GetOrigin(unit)
        local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
        if dmg > 0 then 
          DrawText(math.floor(dmg/hp*100).."%",20,drawPos.x,drawPos.y,0xffffffff)
          if hp > 0 and dmg >= hp and ValidTarget(unit, 1000) and IWalkConfig.E then 
            CastTargetSpell(myHero, _E) 
          end
        end
      end
      local unit = GetTarget(1150, DAMAGE_PHYSICAL)
      if unit and CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q and IWalkConfig.Combo then
        PredCast(_Q, unit, 1750, 250, 1150, 70, true)
      end
    end
  end

  function IAC:OverwriteIACPlugins()
    inbuiltOverwritten = true
  end

  function IAC:IsWindingUp()
    return GetTickCount() <= self.orbTable.lastAA + self.orbTable.windUp
  end

  function IAC:SetMove(bool)
    self.move = bool
  end

  function IAC:SetAA(bool)
    self.aa = bool
  end

  function IAC:SetOrb(bool)
    self.aa = bool
    self.move = bool
  end

-- }