local version = 4
local myHero = nil
local myHeroPos = nil

function AfterObjectLoopEvent(myHer0)
	myHero = myHer0
	myHeroPos = GetOrigin(myHero)
	local unit = GetCurrentTarget()
	if not KeyIsDown(0x20) then return end
	if ValidTarget(unit) then
      	local QPred = GetPredictionForPlayer(myHeroPos,unit,GetMoveSpeed(unit),math.huge,250,850,100,true,true)
      	local WPred = GetPredictionForPlayer(myHeroPos,unit,GetMoveSpeed(unit),2500,250,925,90,true,true)
		if CanUseSpell(myHero, _E) == READY and IsDistance(unit, 700) and (GotBuff(unit,"cassiopeiamiasmapoison") > 0 or GotBuff(unit,"cassiopeianoxiousblastpoison") > 0) then
			CastTargetSpell(unit, _E)
		elseif CanUseSpell(myHero, _W) == READY and IsDistance(unit, 925) and WPred.HitChance == 1 then
			CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
		elseif CanUseSpell(myHero, _Q) == READY and IsDistance(unit, 850) and QPred.HitChance == 1 then
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		end
	end
	local movePos = GenerateMovePos()
	if GetDistance(GetMousePos()) > GetHitBox(myHero)*GetHitBox(myHero) then
		MoveToXYZ(movePos.x, 0, movePos.z)
	end
end

function ValidTarget(unit, range)
	range = range or math.huge
	if GetOrigin(unit) == nil or IsDead(unit) or GetTeam(unit) == GetTeam(myHero) or not IsDistance(unit, range) then return false end
	return true
end

function IsDistance(p1,r)
	return GetDistance(GetOrigin(p1)) < r*r
end

function GetDistance(p1,p2)
	p2 = p2 or myHeroPos
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

function GenerateMovePos()
	local mPos = GetMousePos()
	local tV = {x = (mPos.x-myHeroPos.x), z = (mPos.z-myHeroPos.z)}
	local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
	return {x = myHeroPos.x + 250 * tV.x / len, y = 0, z = myHeroPos.z + 250 * tV.z / len}
end
