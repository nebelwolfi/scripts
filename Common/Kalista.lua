AddInfo("Kalista", "Kalista:")
AddButton("Q", "Use Q", true)
AddButton("E", "Use E", true)

-- this gets executed every frame
function AfterObjectLoopEvent(myHero)
  -- draw menu
  DrawMenu()
  -- walk and autoattack
  IWalk()
  -- iterate through all enemy heroes
  for _,unit in pairs(GetEnemyHeroes()) do
    -- is the current unit is a valid target
    if ValidTarget(unit, 1500) then
      -- our total ad
      local TotalDmg = GetBonusDmg(myHero)+GetBaseDamage(myHero)
      -- out e damage, taken stack count into calc
      local dmgE = (GotBuff(unit,"kalistaexpungemarker") > 0 and (10 + (10 * GetCastLevel(myHero,_E)) + (TotalDmg * 0.6)) + (GotBuff(unit,"kalistaexpungemarker")-1) * (kalE(GetCastLevel(myHero,_E)) + (0.175 + 0.025 * GetCastLevel(myHero,_E))*TotalDmg) or 0)
      -- calculates damage on enemy, with armor taken into calc
      -- CalcDamage(source, target, addmg, apdmg)
      local dmg = CalcDamage(myHero, unit, dmgE)
      -- hp of target
      local hp = GetCurrentHP(unit)
      -- get target position
      local targetPos = GetOrigin(unit)
      -- make draw position
      local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
      -- if we do some dmg
      if dmg > 0 then 
        -- draw percentage of dmg
        DrawText(math.floor(dmg/hp*100).."%",20,drawPos.x,drawPos.y,0xffffffff)
        -- if our dmg is greater than target hp
        if hp > 0 and dmg >= hp and ValidTarget(unit, 1000) and GetButtonValue("E") then 
          -- cast e
          CastTargetSpell(myHero, _E) 
        end
      end
    end
  end
  -- if we dont press spacebar we do nothing
  if not GetKeyValue("Combo") then return end
  -- grab best target in 1175 range
  local unit = GetTarget(1175)
  -- if the target is valid and (still) in 1175 range
  if ValidTarget(unit, 1175) and GetButtonValue("Q") then
    -- following line is used to predict enemy position
    -- GetPredictionForPlayer(startPosition, targetUnit, targetUnitMoveSpeed, spellTravelSpeed, spellDelay, spellRange, spellWidth, collision, addHitBox)
    local QPred = GetPredictionForPlayer(myHeroPos,unit,GetMoveSpeed(unit),1750,250,1150,70,true,true)
    -- is q ready? is hitchance high enough?
    if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 then
      -- cast q towards position where enemy will be!
      CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
    end
  end
end

-- recursively calculates stackdmg
function kalE(x) if x <= 1 then return 10 else return kalE(x-1) + 2 + x end end