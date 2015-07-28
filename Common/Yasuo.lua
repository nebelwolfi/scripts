Config = scriptConfig("IYasuo", "Yasuo.lua")
Config.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
Config.addParam("F", "Rush", SCRIPT_PARAM_KEYDOWN, string.byte("T"))

OnLoop(function(myHero)
  local unit = GetTarget(1200, DAMAGE_PHYSICAL)
  if unit and IWalkConfig.Combo then
    local QPred = GetPredictionForPlayer(GetMyHeroPos(),unit,GetMoveSpeed(unit),1200,125,1200,65,false,true)
    if IsInDistance(unit, 500) and Config.Q and not IsInDistance(unit, myRange) and GetCastName(myHero,_Q) ~= "yasuoq3w" then
      local pos = GetOrigin(unit)
      CastSkillShot(_Q, pos.x, pos.y, pos.z)
    end
    if Config.E and not IsInDistance(unit, 500) and GetCastName(myHero,_Q) ~= "yasuoq3w" then
      if not MoveTo(GetOrigin(unit)) then
        CastTargetSpell(unit, _E)
      end
    end
    if GetCastName(myHero,_Q) == "yasuoq3w" and Config.Q and QPred.HitChance == 1 then
      CastSkillShot(_Q, QPred.PredPos.x, QPred.PredPos.y, QPred.PredPos.z)
    end
    if CanUseSpell(myHero, _R) == READY and Config.R and GetOrigin(unit).y > GetOrigin(myHero).y + 10 then CastTargetSpell(unit, _R) end
  end
  if Config.F then
    MoveTo(GetMousePos())
  end
end)

OnProcessSpell(function(unit, spell)
  myHero = GetMyHero()
  if Config.W and unit and GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == GetObjectType(myHero) and GetDistance(unit) < 1500 then
    if myHero == spell.target and spell.name:lower():find("attack") and GetRange(unit) >= 450 and CalcDamage(unit, myHero, GetBonusDmg(unit)+GetBaseDamage(unit))/GetCurrentHP(myHero) > 0.1337 then
      local wPos = GenerateWallPos(GetOrigin(unit))
      CastSkillShot(_W, wPos.x, wPos.y, wPos.z)
    elseif spell.endPos then
      local makeUpPos = GenerateSpellPos(GetOrigin(unit), spell.endPos, GetDistance(unit, myHero))
      if GetDistanceSqr(makeUpPos) < (GetHitBox(myHero)*3)^2 or GetDistanceSqr(spell.endPos) < (GetHitBox(myHero)*3)^2 then
        local wPos = GenerateWallPos(GetOrigin(unit))
        CastSkillShot(_W, wPos.x, wPos.y, wPos.z)
      end
    end
  end
end)

function MoveTo(pos)
  local dashTarget = nil
  for _,k in pairs(GetAllMinions(MINION_ENEMY)) do
    local dPos = GenerateDashPos(GetOrigin(k))
    if GetDistanceSqr(pos) > GetDistanceSqr(dPos) and GetDistanceSqr(pos, GetMyHeroPos()) > GetDistanceSqr(pos, dPos) and GotBuff(k, "YasuoDashWrapper") < 1 then
      dashTarget = k
    end
  end
  if dashTarget then
    CastTargetSpell(dashTarget, _E)
    return true
  end
  return false
end

function GenerateWallPos(unitPos)
    local tV = {x = (unitPos.x-GetMyHeroPos().x), z = (unitPos.z-GetMyHeroPos().z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = GetMyHeroPos().x + 400 * tV.x / len, y = 0, z = GetMyHeroPos().z + 400 * tV.z / len}
end

function GenerateSpellPos(unitPos, spellPos, range)
    local tV = {x = (spellPos.x-unitPos.x), z = (spellPos.z-unitPos.z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = unitPos.x + range * tV.x / len, y = 0, z = unitPos.z + range * tV.z / len}
end

function GenerateDashPos(unitPos)
    local tV = {x = (unitPos.x-GetMyHeroPos().x), z = (unitPos.z-GetMyHeroPos().z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = GetMyHeroPos().x + 475 * tV.x / len, y = 0, z = GetMyHeroPos().z + 475 * tV.z / len}
end