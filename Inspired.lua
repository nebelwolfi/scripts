enemyHeroes = {}
enemyMinions = {}
ball = nil

function ObjectLoopEvent(object, myHero)
    if not enemyHeroes[GetNetworkID(object)] and GetObjectType(object) == GetObjectType(myHero) and GetTeam(object) ~= GetTeam(myHero) then
        enemyHeroes[GetNetworkID(object)] = object
    end
    if not enemyMinions[GetNetworkID(object)] and GetObjectType(object) == Obj_AI_Minion and GetTeam(object) ~= GetTeam(myHero) then
        enemyMinions[GetNetworkID(object)] = object
    end
    if GetObjectType(object) ~= GetObjectType(myHero) and GetTeam(object) == GetTeam(myHero) and GetObjectName(object):lower():find("oriannaball") then
        ball = object
    end
end

function GenerateMovePos()
    local mPos = GetMousePos()
    local tV = {x = (mPos.x-GetMyHeroPos().x), z = (mPos.z-GetMyHeroPos().z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = GetMyHeroPos().x + 250 * tV.x / len, y = 0, z = GetMyHeroPos().z + 250 * tV.z / len}
end

function ValidTarget(unit, range)
    range = range or 5000
    if unit == nil or GetOrigin(unit) == nil or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(GetMyHero()) or not IsInDistance(unit, range) then return false end
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

function EnemiesAround(pos, range)
    local c = 0
    if pos == nil then return 0 end
    for k,v in pairs(GetEnemyHeroes()) do 
        if v and ValidTarget(v) and GetDistanceSqr(pos,GetOrigin(v)) < range*range then
            c = c + 1
        end
    end
    return c
end

function ClosestEnemy(pos)
    local enemy = nil
    for k,v in pairs(GetEnemyHeroes()) do 
        if not enemy and v then enemy = v end
        if enemy and v and GetDistanceSqr(GetOrigin(enemy),pos) > GetDistanceSqr(GetOrigin(v),pos) then
            enemy = v
        end
    end
    return enemy
end

function ClosestMinion(pos)
    local minion = nil
    for k,v in pairs(GetEnemyMinions()) do 
        if not minion and v then minion = v end
        if minion and v and GetDistanceSqr(GetOrigin(minion),pos) > GetDistanceSqr(GetOrigin(v),pos) then
            minion = v
        end
    end
    return minion
end

function GetLowestMinion(pos)
    local minion = nil
    for k,v in pairs(GetEnemyMinions()) do 
        if not minion and v then minion = v end
        if minion and v and GetCurrentHP(v) < GetCurrentHP(minion) then
            minion = v
        end
    end
    return minion
end

function GetMyHeroPos()
    return GetOrigin(GetMyHero()) 
end

function GetEnemyHeroes()
    return enemyHeroes
end

function GetEnemyMinions()
    return enemyMinions
end

function GetBall()
    return ball
end

function GetDistanceSqr(p1,p2)
    p2 = p2 or GetMyHeroPos()
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
    local threshold, target = math.huge
    for nID, enemy in pairs(GetEnemyHeroes()) do
        if ValidTarget(enemy, range) then
            local result = (GetCurrentHP(enemy) + GetMagicShield(enemy) + GetDmgShield(enemy)) / (GetBonusAP(enemy) + (GetBaseDamage(enemy) + GetBonusDmg(enemy)) * GetAttackSpeed(enemy))
            if result < threshold then
                target = enemy; threshold = result
            end
        end
    end
    return target
end
