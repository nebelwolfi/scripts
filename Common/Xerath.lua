IXerathConfig = scriptConfig("IXerath", "Xerath.lua")
IXerathConfig.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true) 
IXerathConfig.addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true) 
IXerathConfig.addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true) 
IXerathConfig.addParam("R", "Use R (execute)", SCRIPT_PARAM_ONOFF, true) 

OnLoop(function(myHero)
  if IWalkConfig.Combo and waitTickCount < GetTickCount() then
    local target = GetTarget(1500, DAMAGE_MAGIC)
    if CanUseSpell(myHero, _Q) == READY and ValidTarget(target, 1500) and IXerathConfig.Q then
      local myHeroPos = GetMyHeroPos()
      CastSkillShot(_Q, myHeroPos.x, myHeroPos.y, myHeroPos.z)
      for i=250, 1500, 250 do
        DelayAction(function()
            local _Qrange = 750 + math.min(750, i/2)
              local Pred = GetPredictionForPlayer(GetMyHeroPos(),target,GetMoveSpeed(target),math.huge,600,_Qrange,100,false,true)
              if Pred.HitChance >= 1 then
                CastSkillShot2(_Q, Pred.PredPos.x, Pred.PredPos.y, Pred.PredPos.z)
              end
          end, i)
      end
    end
    local target = GetTarget(1100, DAMAGE_MAGIC)
    if CanUseSpell(myHero, _W) == READY and ValidTarget(target, 1100) and IXerathConfig.W then
      PredCast(_W, target, math.huge, 250, 1100, 200, false)
    end
    local target = GetTarget(1050, DAMAGE_MAGIC)
    if CanUseSpell(myHero, _E) == READY and ValidTarget(target, 1050) and IXerathConfig.E then
      PredCast(_E, target, 1600, 250, 1050, 70, true)
    end
  end
  for _, target in pairs(GetEnemyHeroes()) do
    if CanUseSpell(myHero, _R) == READY and ValidTarget(target, 3200) and IXerathConfig.R and CalcDamage(myHero, target, 0, 135+55*GetCastLevel(myHero, _R)+0.43*GetBonusAP(myHero)) >= GetCurrentHP(target) then
      waitTickCount = GetTickCount() + 1000
      PredCast(_R, target, math.huge, 750, 3200, 245, true)
      DelayAction(function() PredCast(_R, target, math.huge, 750, 3200, 245, true) end, 250)
      DelayAction(function() PredCast(_R, target, math.huge, 750, 3200, 245, true) end, 750)
    end
  end
end)

function PredCast(spell, target, speed, delay, range, width, coll)
    local Pred = GetPredictionForPlayer(GetMyHeroPos(),target,GetMoveSpeed(target), speed, delay, range, width, coll, true)
    if Pred.HitChance >= 1 then
      CastSkillShot(spell, Pred.PredPos.x, Pred.PredPos.y, Pred.PredPos.z)
    end
end