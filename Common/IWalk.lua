orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
aaResetTable = { ["Diana"] = {_E}, ["Darius"] = {_W}, ["Garen"] = {_Q}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} }
aaResetTable2 = { ["Diana"] = {_Q}, ["Graves"] = {_Q}, ["Kalista"] = {_Q}, ["Lucian"] = {_W}, ["Quinn"] = {_Q}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} }
aaResetTable3 = { ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Quinn"] = {_E}, ["Teemo"] = {_Q}, ["Tristana"] = {_E} }
aaResetTable4 = { ["Graves"] = {_E},  ["Lucian"] = {_E},  ["Vayne"] = {_Q} }
isAAaswellTable = { ["Quinn"] = "QuinnWEnhanced" }
IWalkTarget = nil
myHero = GetMyHero()
myRange = GetRange(myHero)+GetHitBox(myHero)*2
waitTickCount = 0

IWalkConfig = scriptConfig("IWalk", "IWalk.lua")
str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
if aaResetTable3[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable3[GetObjectName(myHero)]) do
    IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
  end
end
if aaResetTable2[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable2[GetObjectName(myHero)]) do
    IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
  end
end
if aaResetTable[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable[GetObjectName(myHero)]) do
    IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
  end
end
if aaResetTable4[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable4[GetObjectName(myHero)]) do
    IWalkConfig.addParam(str[k], "AA Reset with "..str[k], SCRIPT_PARAM_ONOFF, true)
  end
end
if gapcloserTable[GetObjectName(myHero)] then
  k = gapcloserTable[GetObjectName(myHero)]
  IWalkConfig.addParam(str[k].."g", "Gapclose with "..str[k], SCRIPT_PARAM_ONOFF, true)
end
if GetObjectName(myHero) == "Riven" then IWalkConfig.addParam("R", "Use R if Kill", SCRIPT_PARAM_ONOFF, true) end
IWalkConfig.addParam("I", "Cast Items", SCRIPT_PARAM_ONOFF, true)
IWalkConfig.addParam("S", "Skillfarm", SCRIPT_PARAM_ONOFF, true)
IWalkConfig.addParam("D", "Damage Calc", SCRIPT_PARAM_ONOFF, true)
IWalkConfig.addParam("C", "AA Range Circle", SCRIPT_PARAM_ONOFF, true)

IWalkConfig.addParam("LastHit", "LastHit", SCRIPT_PARAM_KEYDOWN, string.byte("X"))
IWalkConfig.addParam("Harass", "Harass", SCRIPT_PARAM_KEYDOWN, string.byte("C"))
IWalkConfig.addParam("LaneClear", "LaneClear", SCRIPT_PARAM_KEYDOWN, string.byte("V"))
IWalkConfig.addParam("Combo", "Combo", SCRIPT_PARAM_KEYDOWN, string.byte(" "))

OnLoop(function()
  if IWalkConfig.D then DmgCalc() end
  if waitTickCount > GetTickCount() then return end
  IWalk()
end)

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
  if GetObjectName(myHero) == "Riven" then
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
    return math.floor(100*dmg/cthp).."% Dmg // "..math.ceil(cthp/dmg).." AA"
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
        if (KeyIsDown(string.byte("X")) or KeyIsDown(string.byte("V"))) and IsInDistance(k, myRange) then
          AttackUnit(k)
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
  IWalkTarget = GetTarget(myRange + ((gapcloserTable[GetObjectName(myHero)] and CanUseSpell(myHero, gapcloserTable[GetObjectName(myHero)]) == READY) and 250 or 0), DAMAGE_PHYSICAL)
  if IWalkConfig.LaneClear then
    IWalkTarget = GetHighestMinion(GetOrigin(myHero), myRange, MINION_ENEMY)
  end
  local unit = IWalkTarget
  if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
    AttackUnit(unit)
  elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
    if GetRange(myHero) < 450 and unit and GetObjectType(unit) == GetObjectType(myHero) and ValidTarget(unit, myRange) then
      local unitPos = GetOrigin(unit)
      if GetDistance(unit) > myRange/2 then
        MoveToXYZ(unitPos.x, unitPos.y, unitPos.z)
      end
    else
      if gapcloserTable[GetObjectName(myHero)] and ValidTarget(unit, myRange + 250) and IWalkConfig[str[gapcloserTable[GetObjectName(myHero)]].."g"] and CanUseSpell(myHero, gapcloserTable[GetObjectName(myHero)]) == READY then
        local unitPos = GetOrigin(unit)
        CastSkillShot(gapcloserTable[GetObjectName(myHero)], unitPos.x, unitPos.y, unitPos.z)
        if GetObjectName(myHero) == "Riven" and IWalkConfig["W"] and CanUseSpell(myHero, _W) == READY then
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
    MoveToXYZ(movePos.x, 0, movePos.z)
  end
end

function GetIWalkTarget()
  return IWalkTarget
end

OnProcessSpell(function(unit, spell)
  if unit and unit == myHero and spell and (spell.name:lower():find("attack") or (isAAaswellTable[GetObjectName(myHero)] and isAAaswellTable[GetObjectName(myHero)] == spell.name)) then
    orbTable.lastAA = GetTickCount() + GetLatency()
    orbTable.windUp = GetObjectName(myHero) == "Kalista" and 0 or spell.windUpTime * 1000
    orbTable.animation = GetAttackSpeed(GetMyHero()) < 1 and spell.animationTime * 1000 or 1000 / GetAttackSpeed(GetMyHero())
    DelayAction(function() if (IWalkConfig.S or IWalkConfig.Combo) and ValidTarget(IWalkTarget, myRange) then WindUp(IWalkTarget) end end, spell.windUpTime * 1000 + GetLatency())
  end
  if unit and unit == myHero and spell and spell.name:lower():find("katarinar") then
    waitTickCount = GetTickCount() + 2500
  end
end)

function WindUp(unit)
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  if aaResetTable4[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable4[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] then
        orbTable.lastAA = 0
        local movePos = GenerateMovePos()
        CastSkillShot(k, movePos.x, movePos.y, movePos.z)
        return true
      end
    end
  end
  if aaResetTable[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        CastSpell(k)
        orbTable.lastAA = 0
        return true
      end
    end
  end
  if aaResetTable2[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable2[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange and (not GetObjectName(myHero) == "Quinn" or CanUseSpell(myHero, _E) ~= READY) then
        CastSkillShot(k, GetOrigin(unit).x, GetOrigin(unit).y, GetOrigin(unit).z)
        if GetObjectName(myHero) == "Riven" then
          local unitPos = GetOrigin(unit)
          MoveToXYZ(unitPos.x, unitPos.y, unitPos.z)
        end
        orbTable.lastAA = 0
        return true
      end
    end
  end
  if aaResetTable3[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable3[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        if GetObjectName(myHero) == "Quinn" then
          if GotBuff(unit, "QuinnW") < 1 then
            orbTable.lastAA = 0
            CastTargetSpell(unit, k)
          end
        else
          orbTable.lastAA = 0
          CastTargetSpell(unit, k)
        end
        return true
      end
    end
  end
  return IWalkConfig.I and CastOffensiveItems(unit)
end