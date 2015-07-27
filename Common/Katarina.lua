Config = scriptConfig("IKatarina", "Katarina.lua")
Config.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)

OnLoop(function(myHero)
  if waitTickCount > GetTickCount() then return end
  local unit = GetTarget(1000, DAMAGE_MAGIC)
  if unit then
    local dmg = 0
    local hp  = GetCurrentHP(unit)
    local AP = GetBonusAP(myHero)
    local TotalDmg = GetBonusDmg(myHero)+GetBaseDamage(myHero)
    local targetPos = GetOrigin(unit)
    local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
    if CanUseSpell(myHero, _Q) == READY then
      dmg = dmg + CalcDamage(myHero, unit, 0, 35+25*GetCastLevel(myHero,_Q)+0.45*AP) * 1.25
    end
    if CanUseSpell(myHero, _W) == READY then
      dmg = dmg + CalcDamage(myHero, unit, 0, 5+35*GetCastLevel(myHero,_W)+0.25*AP+0.6*TotalDmg)
    end
    if CanUseSpell(myHero, _E) == READY then
      dmg = dmg + CalcDamage(myHero, unit, 0, 10+30*GetCastLevel(myHero,_E)+0.25*AP)
    end
    if CanUseSpell(myHero, _R) ~= ONCOOLDOWN and GetCastLevel(myHero,_R) > 0 then
      dmg = dmg + CalcDamage(myHero, unit, 0, 30+10*GetCastLevel(myHero,_R)+0.2*AP+0.3*GetBonusDmg(myHero)) * 10
    end
    if dmg > hp then
      DrawText("Killable",20,drawPos.x,drawPos.y,0xffffffff)
      DrawDmgOverHpBar(unit,hp,0,hp,0xffffffff)
    else
      DrawText(math.floor(100 * dmg / hp).."%",20,drawPos.x,drawPos.y,0xffffffff)
      DrawDmgOverHpBar(unit,hp,0,dmg,0xffffffff)
    end
    if not IWalkConfig.Combo then return end
    if IsInDistance(unit, 675) and CanUseSpell(myHero, _Q) == READY and Config.Q then
      CastTargetSpell(unit, _Q)
    elseif IsInDistance(unit, 375) and CanUseSpell(myHero, _W) == READY and Config.W then
      CastTargetSpell(myHero, _W)
    elseif IsInDistance(unit, 700) and CanUseSpell(myHero, _E) == READY and Config.E then
      CastTargetSpell(unit, _E)
    elseif IsInDistance(unit, 550) and CanUseSpell(myHero, _Q) ~= READY and Config.R and CanUseSpell(myHero, _W) ~= READY and CanUseSpell(myHero, _E) ~= READY and CanUseSpell(myHero, _R) ~= ONCOOLDOWN and GetCastLevel(myHero,_R) > 0 then
      HoldPosition()
      waitTickCount = GetTickCount() + 50
      CastTargetSpell(myHero, _R)
    end
    lastTargetName = GetObjectName(unit)
  end
end)

OnProcessSpell(function(unit, spell)
  if unit and unit == myHero and spell then
    if spell.name:lower():find("katarinar") then
      waitTickCount = GetTickCount() + 2500
    end
  end
end)