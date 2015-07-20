orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
aaResetTable = { ["Diana"] = {_E}, ["Darius"] = {_W}, ["Garen"] = {_Q}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} }
aaResetTable2 = { ["Diana"] = {_Q}, ["Graves"] = {_Q}, ["Kalista"] = {_Q}, ["Lucian"] = {_W}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} }
aaResetTable3 = { ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Teemo"] = {_Q}, ["Tristana"] = {_E}, ["Yasuo"] = {_R} }
aaResetTable4 = { ["Graves"] = {_E},  ["Lucian"] = {_E},  ["Vayne"] = {_Q} }
IWalkTarget = nil
myHero = GetMyHero()
myRange = GetRange(myHero)+GetHitBox(GetMyHero())*2

AddInfo("info", "IWalk:")
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
AddButton("I", "Cast Items", true)

AddButton("S", "Skillfarm", true)
AddKey("Combo", "Combo", 32)
AddKey("LastHit", "LastHit", string.byte("X"))
AddKey("LaneClear", "LaneClear", string.byte("V"))

AddAfterObjectLoopEvent(function()
  IWalk()
end)

function IWalk()
  if GetButtonValue("Ignite") then AutoIgnite() end
  if GetKeyValue("LastHit") or GetKeyValue("LaneClear") then
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
  if GetKeyValue("Combo") or GetKeyValue("LastHit") or GetKeyValue("LaneClear") then
    DoWalk()
  end
end

function DoWalk()
  myRange = GetRange(GetMyHero())+GetHitBox(GetMyHero())
  IWalkTarget = GetTarget(myRange, DAMAGE_PHYSICAL)
  if GetKeyValue("LaneClear") then
    IWalkTarget = GetHighestMinion(GetOrigin(myHero), myRange, MINION_ENEMY)
  end
  local unit = IWalkTarget
  if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
    AttackUnit(unit)
  elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
    if (GetButtonValue("S") or GetKeyValue("Combo")) and ValidTarget(unit, myRange) and GetTickCount() < orbTable.lastAA + orbTable.animation and orbTable.lastAA > 0 then WindUp(unit) end
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

AddProcessSpell(function(unit, spell)
  if unit and unit == myHero and spell and spell.name:lower():find("attack") then
    orbTable.lastAA = GetTickCount() + 20 -- 20 as latency.....
    orbTable.windUp = spell.windUpTime * 1000
    orbTable.animation = GetAttackSpeed(GetMyHero()) < 1 and spell.animationTime * 1000 or 1000 / GetAttackSpeed(GetMyHero()) -- GetObjectName(GetMyHero()) == "Kalista" and 1 or spell.animationTime * 1000
  end
end)

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
  return GetButtonValue("I") and CastOffensiveItems(unit)
end