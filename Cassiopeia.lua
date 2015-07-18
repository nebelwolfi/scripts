function AfterObjectLoopEvent(myHero)
	if not KeyIsDown(0x20) then return end
	local unit = GetTarget(1000)
	if ValidTarget(unit, 1000) then
		local QPred = GetPredictionForPlayer(_G.myHeroPos,unit,GetMoveSpeed(unit),math.huge,250,850,100,true,true)
		local WPred = GetPredictionForPlayer(_G.myHeroPos,unit,GetMoveSpeed(unit),2500,250,925,90,true,true)
		if CanUseSpell(myHero, _E) == READY and IsInDistance(unit, 700) and (GotBuff(unit,"cassiopeiamiasmapoison") > 0 or GotBuff(unit,"cassiopeianoxiousblastpoison") > 0) then
			CastTargetSpell(unit, _E)
		elseif CanUseSpell(myHero, _W) == READY and IsInDistance(unit, 925) and WPred.HitChance == 1 then
			CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
		elseif CanUseSpell(myHero, _Q) == READY and IsInDistance(unit, 850) and QPred.HitChance == 1 then
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		end
	end
	local movePos = GenerateMovePos()
	if GetDistance(GetMousePos()) > GetHitBox(myHero) then
		MoveToXYZ(movePos.x, 0, movePos.z)
	end
end
