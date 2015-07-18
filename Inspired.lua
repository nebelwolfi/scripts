_G.enemyHeroes = {}
_G.myHero = nil
_G.myHeroPos = nil

function ObjectLoopEvent(object, myHer0)
    _G.myHero = myHer0
    _G.myHeroPos = GetOrigin(myHer0)
    if not _G.enemyHeroes[GetObjectBaseName(object)] and GetObjectType(object) == GetObjectType(myHero) and GetTeam(object) ~= GetTeam(myHero) then
        _G.enemyHeroes[GetObjectBaseName(object)] = object -- ty Jorj
    end
end

function GenerateMovePos()
    local mPos = GetMousePos()
    local tV = {x = (mPos.x-_G.myHeroPos.x), z = (mPos.z-_G.myHeroPos.z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = _G.myHeroPos.x + 250 * tV.x / len, y = 0, z = _G.myHeroPos.z + 250 * tV.z / len}
end

function ValidTarget(unit, range)
    range = range or 2500
    if unit == nil or GetOrigin(unit) == nil or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(_G.myHero) or not IsInDistance(unit, range) then return false end
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
    p2 = p2 or _G.myHeroPos
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

function GetTarget(range) -- ty Jorj
    local threshold, target = math.huge
    for baseName, enemy in pairs(enemyHeroes) do
        if ValidTarget(enemy, range) then
            local result = (GetCurrentHP(enemy) + GetMagicShield(enemy) + GetDmgShield(enemy)) / (GetBonusAP(enemy) + (GetBaseDamage(enemy) + GetBonusDmg(enemy)) * GetAttackSpeed(enemy))
            if result < threshold then
                target = enemy; threshold = result
            end
        end
    end
    return target
end
