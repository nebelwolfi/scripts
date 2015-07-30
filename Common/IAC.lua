orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
aaResetTable = { ["Diana"] = {_E}, ["Darius"] = {_W}, ["Garen"] = {_Q}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} }
aaResetTable2 = { ["Ashe"] = {_W}, ["Diana"] = {_Q}, ["Graves"] = {_Q}, ["Lucian"] = {_W}, ["Quinn"] = {_Q}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} }
aaResetTable3 = { ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Quinn"] = {_E}, ["Teemo"] = {_Q}, ["Tristana"] = {_E} }
aaResetTable4 = { ["Graves"] = {_E},  ["Lucian"] = {_E},  ["Vayne"] = {_Q} }
isAAaswellTable = { ["Quinn"] = "QuinnWEnhanced" }
adcTable = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne"}
IWalkTarget = nil
myHero = GetMyHero()
myHeroName = GetObjectName(myHero)
myRange = GetRange(myHero)+GetHitBox(myHero)*2
waitTickCount = 0

DelayAction(function() -- my OnLoad
  MakeMenu()
  OnLoop(function()
    if IWalkConfig.D then DmgCalc() end
    if waitTickCount > GetTickCount() then return end
    DoChampionPlugins2()
    IWalk()
  end)
end, 0)

function DmgCalc()
  for _,unit in pairs(GetEnemyHeroes()) do
    if ValidTarget(unit) then
      local hPos = GetHPBarPos(unit)
      DrawText(PossibleDmg(unit), 15, hPos.x, hPos.y+20, 0xffffffff)
    end
  end
end

function PossibleDmg(unit)
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

function IWalk()
  if IWalkConfig.LastHit or IWalkConfig.LaneClear or IWalkConfig.Harass then
    for _,k in pairs(GetAllMinions(MINION_ENEMY)) do
      local targetPos = GetOrigin(k)
      local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
      local hp = GetCurrentHP(k)
      local dmg = CalcDamage(myHero, k, GetBonusDmg(myHero)+GetBaseDamage(myHero))
      if dmg > hp then
        if (IWalkConfig.LastHit or IWalkConfig.LaneClear or IWalkConfig.Harass) and IsInDistance(k, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
          AttackUnit(k)
          return
        end
      end
    end
  end
  if IWalkConfig.Combo or IWalkConfig.Harass or IWalkConfig.LastHit or IWalkConfig.LaneClear then
    DoWalk()
  end
end

function DoWalk()
  myRange = GetRange(myHero)+GetHitBox(myHero)+(IWalkTarget and GetHitBox(IWalkTarget) or GetHitBox(myHero))
  if IWalkConfig.C then Circle(myHero,myRange):draw() end
  local addRange = ((gapcloserTable[myHeroName] and CanUseSpell(myHero, gapcloserTable[myHeroName]) == READY) and 250 or 0) + (GetObjectName(myHero) == "Jinx" and (GetCastLevel(myHero, _Q)*25+50) or 0)
  IWalkTarget = GetTarget(myRange + addRange, DAMAGE_PHYSICAL)
  if IWalkConfig.LaneClear then
    IWalkTarget = GetHighestMinion(GetOrigin(myHero), myRange, MINION_ENEMY)
  end
  local unit = IWalkTarget
  if ValidTarget(unit) and GetObjectType(unit) == GetObjectType(myHero) then DoChampionPlugins(unit) end
  if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
    AttackUnit(unit)
  elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
    if GetRange(myHero) < 450 and unit and GetObjectType(unit) == GetObjectType(myHero) and ValidTarget(unit, myRange) then
      local unitPos = GetOrigin(unit)
      if GetDistance(unit) > myRange/2 then
        MoveToXYZ(unitPos.x, unitPos.y, unitPos.z)
      end
    else
      if IWalkConfig.Combo and gapcloserTable[myHeroName] and ValidTarget(unit, myRange + 250) and IWalkConfig[str[gapcloserTable[myHeroName]].."g"] and CanUseSpell(myHero, gapcloserTable[myHeroName]) == READY then
        local unitPos = GetOrigin(unit)
        CastSkillShot(gapcloserTable[myHeroName], unitPos.x, unitPos.y, unitPos.z)
        if myHeroName == "Riven" and IWalkConfig["W"] and CanUseSpell(myHero, _W) == READY then
          if PossibleDmg(unit):find("Killable") and IWalkConfig.R then
            DelayAction(function() CastTargetSpell(myHero, _R) end, 137)
          else
            DelayAction(function() CastTargetSpell(myHero, _W) end, 137)
          end
          orbTable.lastAA = 0
        end
      else
        Move()
      end
    end
  end
end

function Move()
  local movePos = GenerateMovePos()
  if GetDistance(GetMousePos()) > GetHitBox(myHero) then
    MoveToXYZ(movePos.x, GetMyHeroPos().y, movePos.z)
  end
end

function GetIWalkTarget()
  return IWalkTarget
end

OnProcessSpell(function(unit, spell)
  if unit and unit == myHero and spell then
    if (spell.name:lower():find("attack") or (isAAaswellTable[myHeroName] and isAAaswellTable[myHeroName] == spell.name)) then
      orbTable.lastAA = GetTickCount() + GetLatency()
      orbTable.windUp = myHeroName == "Kalista" and 0 or spell.windUpTime * 1000
      orbTable.animation = GetAttackSpeed(GetMyHero()) < 2.25 and spell.animationTime * 1000 or 1000 / GetAttackSpeed(GetMyHero())
      DelayAction(function() 
                          if (IWalkConfig.S or IWalkConfig.Combo) and ValidTarget(IWalkTarget, myRange) then 
                            WindUp(IWalkTarget) 
                          end
                        end, spell.windUpTime * 1000 + GetLatency())
    elseif spell.name:lower():find("katarinar") then
      waitTickCount = GetTickCount() + 2500
    end
  end
end)

function WindUp(unit)
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  if aaResetTable4[myHeroName] then
    for _,k in pairs(aaResetTable4[myHeroName]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] then
        orbTable.lastAA = 0
        local movePos = GenerateMovePos()
        CastSkillShot(k, movePos.x, movePos.y, movePos.z)
        return true
      end
    end
  end
  if aaResetTable[myHeroName] then
    for _,k in pairs(aaResetTable[myHeroName]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        orbTable.lastAA = 0
        CastSpell(k)
        return true
      end
    end
  end
  if aaResetTable2[myHeroName] then
    for _,k in pairs(aaResetTable2[myHeroName]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange and (not myHeroName == "Quinn" or CanUseSpell(myHero, _E) ~= READY) then
        local unitPos = GetOrigin(unit)
        CastSkillShot(k, unitPos.x, unitPos.y, unitPos.z)
        if myHeroName == "Riven" then
          local unitPos = GetOrigin(unit)
          MoveToXYZ(unitPos.x, unitPos.y, unitPos.z)
        end
        orbTable.lastAA = 0
        return true
      end
    end
  end
  if aaResetTable3[myHeroName] then
    for _,k in pairs(aaResetTable3[myHeroName]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        if myHeroName ~= "Quinn" or GotBuff(unit, "QuinnW") < 1 then
          orbTable.lastAA = 0
          CastTargetSpell(unit, k)
        end
        return true
      end
    end
  end
  return IWalkConfig.I and CastOffensiveItems(unit)
end

function MakeMenu()
  IWalkConfig = scriptConfig("IWalk", "IWalk.lua")
  str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  if aaResetTable3[myHeroName] then
    for _,k in pairs(aaResetTable3[myHeroName]) do
      IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
    end
  end
  if aaResetTable2[myHeroName] then
    for _,k in pairs(aaResetTable2[myHeroName]) do
      IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
    end
  end
  if aaResetTable[myHeroName] then
    for _,k in pairs(aaResetTable[myHeroName]) do
      IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
    end
  end
  if aaResetTable4[myHeroName] then
    for _,k in pairs(aaResetTable4[myHeroName]) do
      IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
    end
  end
  if gapcloserTable[myHeroName] then
    k = gapcloserTable[myHeroName]
    if type(k) == "number" then
      IWalkConfig.addParam(str[k].."g", "Gapclose with "..str[k], SCRIPT_PARAM_ONOFF, true)
    end
  end
  DoChampionPluginMenu()
  IWalkConfig.addParam("I", "Cast Items", SCRIPT_PARAM_ONOFF, true)
  IWalkConfig.addParam("S", "Skillfarm", SCRIPT_PARAM_ONOFF, true)
  IWalkConfig.addParam("D", "Damage Calc", SCRIPT_PARAM_ONOFF, true)
  IWalkConfig.addParam("C", "AA Range Circle", SCRIPT_PARAM_ONOFF, true)

  IWalkConfig.addParam("LastHit", "LastHit", SCRIPT_PARAM_KEYDOWN, string.byte("X"))
  IWalkConfig.addParam("Harass", "Harass", SCRIPT_PARAM_KEYDOWN, string.byte("C"))
  IWalkConfig.addParam("LaneClear", "LaneClear", SCRIPT_PARAM_KEYDOWN, string.byte("V"))
  IWalkConfig.addParam("Combo", "Combo", SCRIPT_PARAM_KEYDOWN, string.byte(" "))
end

function DoChampionPluginMenu()
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

function DoChampionPlugins(unit)
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
    if CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q and GetTickCount() > orbTable.lastAA + orbTable.windUp then
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

function DoChampionPlugins2()
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
    if unit and CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q then
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
    if unit and CanUseSpell(myHero, _Q) == READY and IWalkConfig.Q then
      PredCast(_Q, unit, 2000, 250, 1200, 60, false)
    end
    local unit = GetTarget(1050, DAMAGE_PHYSICAL)
    if unit and CanUseSpell(myHero, _W) == READY and IWalkConfig.W then
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
    if unit and CanUseSpell(myHero, _W) == READY and IWalkConfig.W then
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
        if hp > 0 and dmg >= hp and ValidTarget(unit, 1000) and Config.E then 
          CastTargetSpell(myHero, _E) 
        end
      end
    end
    local unit = GetTarget(1150, DAMAGE_PHYSICAL)
    if unit and CanUseSpell(myHero, _W) == READY and IWalkConfig.W then
      PredCast(_W, unit, 1750, 250, 1150, 70, true)
    end
  end
end

for _,k in pairs(adcTable) do
  if k == myHeroName then
    PrintChat("<font color=\"#6699ff\"><b>[Inspireds Auto Carry]: Plugin '"..myHeroName.."' - </b></font> <font color=\"#FFFFFF\">Loaded.</font>") 
  end
end

function PredCast(spell, target, speed, delay, range, width, coll)
    local Pred = GetPredictionForPlayer(GetMyHeroPos(),target,GetMoveSpeed(target), speed, delay, range, width, coll, true)
    if Pred.HitChance >= 1 then
      CastSkillShot(spell, Pred.PredPos.x, Pred.PredPos.y, Pred.PredPos.z)
    end
end