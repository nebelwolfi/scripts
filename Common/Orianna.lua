ballPos = nil
rComboDmg = 0
AddInfo("Orianna", "Orianna:")
AddButton("Q", "Use Q", true)
AddButton("W", "Use W", true)
AddButton("E", "Use E", true)
AddButton("R", "Use R", true)
AddButton("Ra", "Use R if 3 hit", true)

OnLoop(function(myHero)
	if ballPos and (GetDistanceSqr(ballPos) <= (GetHitBox(myHero)*2+7)^2 or GetDistanceSqr(ballPos) > 1250*1250) then
      ballPos = nil
    end
	if ballPos then
		DrawCircle(ballPos.x,ballPos.y,ballPos.z,150,5,1000,0xff00ff00)
	end
	for _, unit in pairs(GetEnemyHeroes()) do
		if unit and CanUseSpell(myHero, _R) == READY then
			rComboDmg = CalcDamage(myHero, unit, 0, 105+105*GetCastLevel(myHero,_R)+1.2*GetBonusAP(myHero))
			if rComboDmg > 0 then
				DrawDmgOverHpBar(unit,GetCurrentHP(unit),0,rComboDmg,0xffffffff)
			end
		end
	end
	if not GetKeyValue("Combo") then return end
	local unit = GetTarget(1000, DAMAGE_MAGIC)
	if unit then
		local uPos = GetOrigin(unit)
		local QPred = GetPredictionForPlayer(ballPos or GetMyHeroPos(),unit,GetMoveSpeed(unit),1200,250,825,175,true,true)
		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 and GetButtonValue("Q") then
			local pos = GenerateThrowPos(QPred.PredPos)
    		CastSkillShot(_Q,pos.x,pos.y,pos.z)
		end
		if CanUseSpell(myHero, _W) == READY and GetButtonValue("W") and GetDistanceSqr(ballPos or GetMyHeroPos(),GetOrigin(unit)) < 225*225 then
    		CastTargetSpell(myHero, _W)
		end
		if CanUseSpell(myHero, _E) == READY and GetButtonValue("E") and ballPos and GetDistanceSqr(ballPos,GetOrigin(unit)) < 80*80 and GetDistanceSqr(GetMyHeroPos(),GetOrigin(unit)) < GetDistanceSqr(GetMyHeroPos(),ballPos) then
    		CastTargetSpell(myHero, _E)
		end
		if CanUseSpell(myHero, _R) == READY and GetButtonValue("R") and CalcDamage(myHero, unit, 0, 105+105*GetCastLevel(myHero,_R)+1.2*GetBonusAP(myHero)) >= GetCurrentHP(unit) and CalcDamage(myHero, unit, 0, 105+105*GetCastLevel(myHero,_R)+1.2*GetBonusAP(myHero)) <= 0.25*GetCurrentHP(unit) and (GetDistanceSqr(ballPos or GetMyHeroPos(),GetOrigin(unit)) < 375*375) then
    		CastTargetSpell(myHero, _R)
		end
		if CanUseSpell(myHero, _R) == READY and GetButtonValue("Ra") and EnemiesAround(ballPos or GetMyHeroPos(), 375) >= 3 then
    		CastTargetSpell(myHero, _R)
		end
	end
end)

OnProcessSpell(function(unit, spell)
	if unit and unit == GetMyHero() and spell and spell.name == "OrianaIzunaCommand" then
		ballPos = spell.endPos
	end
	if unit and unit == GetMyHero() and spell and spell.name == "OrianaRedactCommand" then
		ballPos = nil
	end
end)

function GenerateThrowPos(pos)
    local tV = {x = (pos.x-GetMyHeroPos().x), z = (pos.z-GetMyHeroPos().z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = pos.x + 55 * tV.x / len, y = 0, z = pos.z + 55 * tV.z / len}
end