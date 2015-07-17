local version = 1
local myHero = nil
local myHeroPos = nil
local waitTickCount = 0

function AfterObjectLoopEvent(myHer0)
	myHero = myHer0
	myHeroPos = GetOrigin(myHero)
	waitTickCount = waitTickCount - 1
	local unit = GetCurrentTarget()
	if waitTickCount > 0 and lastTargetName == GetObjectName(unit) then return end
	if not KeyIsDown(0x20) then return end
	local movePos = GenerateMovePos()
	if GetDistanceSqr(GetMousePos()) > GetHitBox(myHero)*GetHitBox(myHero) then
		MoveToXYZ(movePos.x, 0, movePos.z)
	end
	if ValidTarget(unit) then
    	if IsInDistance(unit, 675) and CanUseSpell(myHero, _Q) == READY then
    		CastTargetSpell(unit, _Q)
		elseif IsInDistance(unit, 375) and CanUseSpell(myHero, _W) == READY then
    		CastTargetSpell(myHero, _W)
		elseif IsInDistance(unit, 700) and CanUseSpell(myHero, _E) == READY then
    		CastTargetSpell(unit, _E)
		elseif IsInDistance(unit, 550) and CanUseSpell(myHero, _R) == READY then
    		CastTargetSpell(myHero, _R)
		end
		lastTargetName = GetObjectName(unit)
	end
end

function OnProcessSpell(unit, spell)
	if unit and unit == myHero and spell then
		if spell.name:lower():find("katarinar") then
			waitTickCount = 250
		end
	end
end

function ValidTarget(unit, range)
	range = range or math.huge
	if GetOrigin(unit) == nil or IsDead(unit) or GetTeam(unit) == GetTeam(myHero) or not IsInDistance(unit, range) then return false end
	return true
end

function IsInDistance(p1,r)
	return GetDistanceSqr(GetOrigin(p1)) < r*r
end

function GetDistance(p1,p2)
	p1 = GetOrigin(p1) or p1
	p2 = GetOrigin(p2) or p2
	return math.sqrt(GetDistanceSqr(p1,p2))
end

function GetDistanceSqr(p1,p2)
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
