orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
aaResetTable = { ["Diana"] = {_E}, ["Darius"] = {_W}, ["Garen"] = {_Q}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} }
aaResetTable2 = { ["Diana"] = {_Q}, ["Graves"] = {_Q}, ["Kalista"] = {_Q}, ["Lucian"] = {_W}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} }
aaResetTable3 = { ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Teemo"] = {_Q}, ["Tristana"] = {_E} }
aaResetTable4 = { ["Graves"] = {_E},  ["Lucian"] = {_E},  ["Vayne"] = {_Q} }
IWalkTarget = nil
myHero = GetMyHero()
myRange = GetRange(myHero)+GetHitBox(GetMyHero())*2
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
IWalkConfig.addParam("I", "Cast Items", SCRIPT_PARAM_ONOFF, true)
IWalkConfig.addParam("S", "Skillfarm", SCRIPT_PARAM_ONOFF, true)

IWalkConfig.addParam("LastHit", "LastHit", SCRIPT_PARAM_KEYDOWN, string.byte("X"))
IWalkConfig.addParam("Harass", "Harass", SCRIPT_PARAM_KEYDOWN, string.byte("C"))
IWalkConfig.addParam("LaneClear", "LaneClear", SCRIPT_PARAM_KEYDOWN, string.byte("V"))
IWalkConfig.addParam("Combo", "Combo", SCRIPT_PARAM_KEYDOWN, string.byte(" "))

OnLoop(function()
  if waitTickCount > GetTickCount() then return end
  IWalk()
end)

function IWalk()
  if IWalkConfig.LastHit or IWalkConfig.LaneClear or IWalkConfig.Harass then
    for _,k in pairs(GetAllMinions(MINION_ENEMY)) do
      local targetPos = GetOrigin(k)
      local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
      local hp = GetCurrentHP(k)
      local dmg = CalcDamage(GetMyHero(), k, GetBonusDmg(myHero)+GetBaseDamage(myHero))
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
  myRange = GetRange(GetMyHero())+GetHitBox(GetMyHero())
  IWalkTarget = GetTarget(myRange, DAMAGE_PHYSICAL)
  if IWalkConfig.LaneClear then
    IWalkTarget = GetHighestMinion(GetOrigin(myHero), myRange, MINION_ENEMY)
  end
  local unit = IWalkTarget
  if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
    AttackUnit(unit)
  elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
    Move()
  end
end

function Move()
  local movePos = GenerateMovePos()
  if GetDistance(GetMousePos()) > GetHitBox(GetMyHero()) then
    MoveToXYZ(movePos.x, 0, movePos.z)
  end
end

function GetIWalkTarget()
  return IWalkTarget
end

OnProcessSpell(function(unit, spell)
  if unit and unit == myHero and spell and spell.name:lower():find("attack") then
    orbTable.lastAA = GetTickCount() + 20 -- 20 as latency.....
    orbTable.windUp = GetObjectName(myHero) == "Kalista" and 0 or spell.windUpTime * 1000
    orbTable.animation = (spell.animationTime-spell.windUpTime) * 1000
    DelayAction(function() if (IWalkConfig.S or IWalkConfig.Combo) and ValidTarget(IWalkTarget, myRange) then WindUp(IWalkTarget) end end, spell.windUpTime * 1000)
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
        orbTable.lastAA = 0
        CastTargetSpell(myHero, k)
        return true
      end
    end
  end
  if aaResetTable2[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable2[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        orbTable.lastAA = 0
        CastSkillShot(k, GetOrigin(unit).x, GetOrigin(unit).y, GetOrigin(unit).z)
        return true
      end
    end
  end
  if aaResetTable3[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable3[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and IWalkConfig[str[k]] and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        orbTable.lastAA = 0
        CastTargetSpell(unit, k)
        return true
      end
    end
  end
  return IWalkConfig.I and CastOffensiveItems(unit)
end