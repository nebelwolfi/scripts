AddInfo("Yasuo", "Yasuo:")
AddButton("Q", "Use Q", true)
AddButton("R", "Use R", true)

AddAfterObjectLoopEvent(function(myHero)
  IWalk()
  local unit = GetTarget(1200, DAMAGE_PHYSICAL)
  if unit and GetKeyValue("Combo") then
    local QPred = GetPredictionForPlayer(GetMyHeroPos(),unit,GetMoveSpeed(unit),1200,125,1200,65,false,true)
    if IsInDistance(unit, 500) and not IsInDistance(unit, myRange) and GetCastName(myHero,_Q) ~= "yasuoq3w" then
      local pos = GetOrigin(unit)
      CastSkillShot(_Q, pos.x, pos.y, pos.z)
    end
    if GetCastName(myHero,_Q) == "yasuoq3w" and QPred.HitChance == 1 then
      CastSkillShot(_Q, QPred.PredPos.x, QPred.PredPos.y, QPred.PredPos.z)
    end
    if CanUseSpell(myHero, _R) == READY and GetOrigin(unit).y > GetOrigin(myHero).y + 10 then CastTargetSpell(unit, _R) end
  end
end)