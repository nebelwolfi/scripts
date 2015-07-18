ballPos = nil
ballDel = 0

function AfterObjectLoopEvent(myHero)
	if GetBall() then
		ballPos = GetOrigin(GetBall())
	end
	if ballPos and ballDel + 1750 < GetTickCount() then
		DrawCircle(ballPos.x,ballPos.y,ballPos.z,150,5,150,0xff00ff00)
	end
	if not KeyIsDown(0x20) then return end
	local unit = GetTarget(1000)
	if ValidTarget(unit, 1000) then
		local uPos = GetOrigin(unit)
		local QPred = GetPredictionForPlayer(GetMyHeroPos(),unit,GetMoveSpeed(unit),1200,250,825,175,true,true)
		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 then
			local tP = GenerateThrowPos(QPred.PredPos)
    		CastSkillShot(_Q,tP.x,tP.y,tP.z)
		end
		if CanUseSpell(myHero, _W) == READY and (ballPos and GetDistanceSqr(ballPos,GetOrigin(unit)) < 225*225 or GetDistanceSqr(GetMyHeroPos(),GetOrigin(unit)) < 225*225) then
    		CastTargetSpell(myHero, _W)
		end
		if CanUseSpell(myHero, _E) == READY and ballPos and GetDistanceSqr(ballPos,GetOrigin(unit)) < 80*80 and GetDistanceSqr(GetMyHeroPos(),GetOrigin(unit)) < GetDistanceSqr(GetMyHeroPos(),ballPos) then
    		CastTargetSpell(myHero, _E)
		end
		local rdmg = 105+105*GetCastLevel(myHero,_R)+1.2*GetBonusAP(myHero)
		if CanUseSpell(myHero, _R) == READY and CalcDamage(myHero, unit, 0, apdmg) >= GetCurrentHP(unit) and (ballPos and GetDistanceSqr(ballPos,GetOrigin(unit)) < 375*375 or GetDistanceSqr(GetMyHeroPos(),GetOrigin(unit)) < 375*375) then
    		CastTargetSpell(myHero, _R)
		end
		if CanUseSpell(myHero, _R) == READY and ballPos and EnemiesAround(ballPos, 375) then
    		CastTargetSpell(myHero, _R)
		end
        local movePos = GenerateMovePos()
        MoveToXYZ(movePos.x, movePos.y, movePos.z)
	end
end

function OnProcessSpell(unit, spell)
	if unit and unit == GetMyHero() and spell and spell.name == "OrianaIzunaCommand" then
		ballPos = nil
	end
	if unit and unit == GetMyHero() and spell and spell.name == "OrianaRedactCommand" then
		ballPos = spell.target
		ballDel = GetTickCount()
	end
end

function GenerateThrowPos(pos)
    local tV = {x = (pos.x-GetMyHeroPos().x), z = (pos.z-GetMyHeroPos().z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = pos.x + 55 * tV.x / len, y = 0, z = pos.z + 55 * tV.z / len}
end
