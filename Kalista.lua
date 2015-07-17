  local version = 5
  local myHero = nil
  local myHeroPos = nil
  local walk = false

  function ObjectLoopEvent(unit, myHer0)
    myHero = myHer0
    if (GetObjectType(unit) == Obj_AI_Hero or GetObjectType(unit) == Obj_AI_Minion or GetObjectType(unit) == Obj_AI_Camp) and ValidTarget(unit, 1000) then
      MessageBox(0,"hi","hi",0)
      local TotalDmg = GetBonusDmg(myHero)+GetBaseDamage(myHero)
      local dmgE = (GotBuff(unit,"kalistaexpungemarker") > 0 and (10 + (10 * GetCastLevel(myHero,_E)) + (TotalDmg * 0.6)) + (GotBuff(unit,"kalistaexpungemarker")-1) * (kalE(GetCastLevel(myHero,_E)) + (0.15 + 0.03 * GetCastLevel(myHero,_E))*TotalDmg) or 0)
      local dmg = CalcDamage(unit, dmgE, "AD")
      local hp = GetCurrentHP(unit)
      local targetPos = GetOrigin(unit)
      local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
      if dmg > 0 then 
        DrawText(math.floor(dmg/hp*100).."%",20,drawPos.x,drawPos.y,0xffffffff)
        if hp > 0 and dmg >= hp then CastTargetSpell(unit, _E) end
      end
    end
  end

  function AfterObjectLoopEvent(myHer0)
    myHero = myHer0
    myHeroPos = GetOrigin(myHero)
    local movePos = GenerateMovePos()
    local unit = GetCurrentTarget()
    if not KeyIsDown(0x20) then return end
    if ValidTarget(unit, GetRange(myHero)) then
      local QPred = GetPredictionForPlayer(myHeroPos,unit,GetMoveSpeed(unit),1750,250,1150,70,true,true)
      if walk then
        walk = false
        MoveToXYZ(mousePos.x, mousePos.y, mousePos.z)
      elseif CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 then
        walk = true
        CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
      else
        walk = true
        AttackUnit(unit)
      end
    else
      MoveToXYZ(movePos.x, movePos.y, movePos.z)
    end
  end

  function kalE(x)
    if x <= 1 then 
      return 10
    else 
      return kalE(x-1) + 2 + x
    end 
  end

  function ValidTarget(unit, range)
    range = range or math.huge
    if unit == nil or GetOrigin(unit) == nil or IsDead(unit) or GetTeam(unit) == GetTeam(myHero) or GetDistance(GetOrigin(unit)) > range*range then return false end
    return true
  end

  function GetDistance(p1,p2)
    p2 = p2 or myHeroPos
    local dx = p1.x - p2.x
    local dz = (p1.z or p1.y) - (p2.z or p2.y)
    return dx*dx + dz*dz
  end

  function CalcDamage(source, target, addmg, apdmg)
    local ADDmg             = addmg or 0
    local APDmg             = apdmg or 0
    local ArmorPen          = math.floor(GetArmorPenFlat(source))
    local ArmorPenPercent   = math.floor(GetArmorPenPercent(source)*100)/100
    local Armor             = GetArmor(target)*ArmorPenPercent-ArmorPen
    local ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
    local MagicPen          = math.floor(GetMagicPenFlat(source))
    local MagicPenPercent   = math.floor(GetMagicPenPercent(source)*100)/100
    local MagicArmor        = GetMagicResist(target)*MagicPenPercent-MagicPen
    local MagicArmorPercent = MagicArmor > 0 and math.floor(MagicArmor*100/(100+MagicArmor))/100 or math.ceil(MagicArmor*100/(100-MagicArmor))/100
    return math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
  end

  function GenerateMovePos()
    local mPos = GetMousePos()
    local tV = {x = (mPos.x-myHeroPos.x), z = (mPos.z-myHeroPos.z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = myHeroPos.x + 250 * tV.x / len, y = 0, z = myHeroPos.z + 250 * tV.z / len}
  end
