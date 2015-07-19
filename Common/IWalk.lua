orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
aaResetTable = { ["Diana"] = {_E}, ["Darius"] = {_W}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} }
aaResetTable2 = { ["Diana"] = {_Q}, ["Graves"] = {_Q}, ["Kalista"] = {_Q}, ["Lucian"] = {_W}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} }
aaResetTable3 = { ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Teemo"] = {_Q}, ["Tristana"] = {_E}, ["Yasuo"] = {_R} }
aaResetTable4 = { ["Graves"] = {_E},  ["Lucian"] = {_E},  ["Vayne"] = {_Q} }
IWalkTarget = nil
myHero = GetMyHero()
myRange = GetRange(myHero)+GetHitBox(GetMyHero())

str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
if aaResetTable3[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable3[GetObjectName(myHero)]) do
    AddButton(str[k], "AA Reset with "..str[k], true)
  end
end
if aaResetTable2[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable2[GetObjectName(myHero)]) do
    AddButton(str[k], "AA Reset with "..str[k], true)
  end
end
if aaResetTable[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable[GetObjectName(myHero)]) do
    AddButton(str[k], "AA Reset with "..str[k], true)
  end
end
if aaResetTable4[GetObjectName(myHero)] then
  for _,k in pairs(aaResetTable4[GetObjectName(myHero)]) do
    AddButton(str[k], "AA Reset with "..str[k], true)
  end
end

function AfterObjectLoopEvent(x)
  DrawMenu()
  if KeyIsDown(string.byte(" ")) then
    IWalk()
  end
end

function IWalk()
  myRange = GetRange(GetMyHero())+GetHitBox(GetMyHero())
  IWalkTarget = GetTarget(myRange)
  local unit = IWalkTarget
  if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
    AttackUnit(unit)
  elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
    if ValidTarget(unit, myRange) and GetTickCount() < orbTable.lastAA + orbTable.animation and orbTable.lastAA > 0 then WindUp(unit) end
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

function OnProcessSpell(unit, spell)
  IProcessSpell(unit, spell)
end

function IProcessSpell(unit, spell)
  if unit and unit == myHero and spell and spell.name:lower():find("attack") then
    orbTable.lastAA = GetTickCount() + 20 -- 20 as latency.....
    orbTable.windUp = spell.windUpTime * 1000
    orbTable.animation = GetObjectName(GetMyHero()) == "Kalista" and 1000 / GetAttackSpeed(GetMyHero()) or spell.animationTime * 1000
  end
end

function WindUp(unit)
  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  if aaResetTable4[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable4[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and GetButtonValue(str[k]) then
        orbTable.lastAA = 0
        local movePos = GenerateMovePos()
        CastSkillShot(k, movePos.x, movePos.y, movePos.z)
        return true
      end
    end
  end
  if aaResetTable[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and GetButtonValue(str[k]) and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        orbTable.lastAA = 0
        CastTargetSpell(myHero, k)
        return true
      end
    end
  end
  if aaResetTable2[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable2[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and GetButtonValue(str[k]) and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        orbTable.lastAA = 0
        CastSkillShot(k, GetOrigin(unit).x, GetOrigin(unit).y, GetOrigin(unit).z)
        return true
      end
    end
  end
  if aaResetTable3[GetObjectName(myHero)] then
    for _,k in pairs(aaResetTable3[GetObjectName(myHero)]) do
      if CanUseSpell(myHero, k) == READY and GetButtonValue(str[k]) and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
        orbTable.lastAA = 0
        CastTargetSpell(unit, k)
        return true
      end
    end
  end
  return false
end