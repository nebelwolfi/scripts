-- this gets executed every frame
function AfterObjectLoopEvent(myHero)
	-- if we dont press spacebar we do nothing
	if not KeyIsDown(0x20) then return end 
	-- grab best target in 1000 range
	local unit = GetTarget(1000) 
	-- if the target is valid and (still) in 1000 range
	if ValidTarget(unit, 1000) then 
		-- following 2 lines are used to predict enemy position
		-- GetPredictionForPlayer(startPosition, targetUnit, targetUnitMoveSpeed, spellTravelSpeed, spellDelay, spellRange, spellWidth, collision, addHitBox)
		local QPred = GetPredictionForPlayer(GetMyHeroPos(),unit,GetMoveSpeed(unit),math.huge,250,850,100,true,true)
		local WPred = GetPredictionForPlayer(GetMyHeroPos(),unit,GetMoveSpeed(unit),2500,250,925,90,true,true)
		-- is e ready? is unit in distance? is unit poisoned?
		if CanUseSpell(myHero, _E) == READY and IsInDistance(unit, 700) and (GotBuff(unit,"cassiopeiamiasmapoison") > 0 or GotBuff(unit,"cassiopeianoxiousblastpoison") > 0) then
			-- cast e targeted!
			CastTargetSpell(unit, _E)
		-- is w ready? is unit in distance? is hitchance high enough?
		elseif CanUseSpell(myHero, _W) == READY and IsInDistance(unit, 925) and WPred.HitChance == 1 then
			-- cast w towards position where enemy will be!
			CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
		-- is q ready? is unit in distance? is hitchance high enough?
		elseif CanUseSpell(myHero, _Q) == READY and IsInDistance(unit, 850) and QPred.HitChance == 1 then
			-- cast q towards position where enemy will be!
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		end
	end
	-- walk and autoattack
	IWalk()
end