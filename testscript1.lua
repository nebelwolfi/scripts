local enemyHeroes = {}
local myHero = nil
local myHeroPos = nil

function ObjectLoopEvent(object, myHer0)
	myHero = myHer0
	myHeroPos = GetOrigin(myHer0)
	if not enemyHeroes[GetObjectBaseName(object)] and GetObjectType(object) == GetObjectType(myHero) and GetTeam(object) ~= GetTeam(myHero) then
		enemyHeroes[GetObjectBaseName(object)] = object
	end
end

function AfterObjectLoopEvent(myHer0)
	local target = GetTarget(myHero, 1000)
	if ValidTarget(target) then
		--your code here
		--your code here
		--your code here
		--your code here
		--your code here
	end
end

function GenerateMovePos(myHero)
    local mPos = GetMousePos()
    local myHeroPos = GetOrigin(myHero)
    local tV = {x = (mPos.x-myHeroPos.x), z = (mPos.z-myHeroPos.z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = myHeroPos.x + 250 * tV.x / len, y = 0, z = myHeroPos.z + 250 * tV.z / len}
end

function ValidTarget(unit, range)
    range = range or math.huge
    if unit == nil or GetOrigin(unit) == nil or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(myHero) or not IsInDistance(unit, range) then return false end
    return true
end

function IsInDistance(p1,r)
    return GetDistance(GetOrigin(p1)) < r*r
end

function GetDistance(p1,p2)
    p1 = GetOrigin(p1) or p1
    p2 = GetOrigin(p2) or p2
    return math.sqrt(GetDistanceSqr(p1,p2))
end

function GetDistanceSqr(p1,p2)
​    p2 = p2 or myHeroPos
    local dx = p1.x - p2.x
    local dz = (p1.z or p1.y) - (p2.z or p2.y)
    return dx*dx + dz*dz
end

function CalcDamage(source, target, addmg, apdmg)
    local ADDmg = addmg or 0
    local APDmg = apdmg or 0
    local ArmorPen = math.floor(GetArmorPenFlat(source))
    local ArmorPenPercent = math.floor(GetArmorPenPercent(source)*100)/100
    local Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
    local ArmorPercent = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
    local MagicPen = math.floor(GetMagicPenFlat(source))
    local MagicPenPercent = math.floor(GetMagicPenPercent(source)*100)/100
    local MagicArmor = GetMagicResist(target)*MagicPenPercent-MagicPen
    local MagicArmorPercent = MagicArmor > 0 and math.floor(MagicArmor*100/(100+MagicArmor))/100 or math.ceil(MagicArmor*100/(100-MagicArmor))/100
    return math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
end

function GetTarget(range)
	local LessToKill = 100
	local LessToKilli = 0
	local target = nil
	for baseName, enemy in pairs(enemyHeroes) do
		if ValidTarget(enemy, range) then
			DamageToHero = CalcDamage(myHero, enemy, 100, 100)
			ToKill = GetCurrentHP(enemy) / DamageToHero
			if ((ToKill < LessToKill) or (LessToKilli == 0)) then
				LessToKill = ToKill
				LessToKilli = i
				target = enemy
			end
		end
	end
	return target
end
