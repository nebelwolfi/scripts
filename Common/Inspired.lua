enemyHeroes = {}
allyHeroes = {}
minionTable = {}
finishedEnemies = false
finishedAllies = false
lastMinionTick = 0
menuTable = {}
currentPos = {x = 150, y = 250}
MINION_ALLY, MINION_ENEMY, MINION_JUNGLE = GetTeam(GetMyHero()), GetTeam(GetMyHero()) == 100 and 200 or 100, 300
Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
Smite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonersmite") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonersmite") and SUMMONER_2 or nil))
Exhaust = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerexhaust") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerexhaust") and SUMMONER_2 or nil))
objectLoopEvents = {}
afterObjectLoopEvents = {}
onProcessSpells = {}
delayedActions = {}
delayedActionsExecuter = nil
DAMAGE_MAGIC, DAMAGE_MAGICAL, DAMAGE_PHYSICAL = 1, 1, 2
gapcloserTable = {
  ["Aatrox"] = _E, ["Akali"] = _R, ["Alistar"] = _W, ["Ahri"] = _R, ["Amumu"] = _Q, ["Corki"] = _W,
  ["Diana"] = _R, ["Elise"] = _Q, ["Elise"] = _E, ["Fiddlesticks"] = _R, ["Fiora"] = _Q,
  ["Fizz"] = _Q, ["Gnar"] = _E, ["Grags"] = _E, ["Graves"] = _E, ["Hecarim"] = _R,
  ["Irelia"] = _Q, ["JarvanIV"] = _Q, ["Jax"] = _Q, ["Jayce"] = "JayceToTheSkies", ["Katarina"] = _E, 
  ["Kassadin"] = _R, ["Kennen"] = _E, ["KhaZix"] = _E, ["Lissandra"] = _E, ["LeBlanc"] = _W, 
  ["LeeSin"] = "blindmonkqtwo", ["Leona"] = _E, ["Lucian"] = _E, ["Malphite"] = _R, ["MasterYi"] = _Q, 
  ["MonkeyKing"] = _E, ["Nautilus"] = _Q, ["Nocturne"] = _R, ["Olaf"] = _R, ["Pantheon"] = _W, 
  ["Poppy"] = _E, ["RekSai"] = _E, ["Renekton"] = _E, ["Riven"] = _Q, ["Sejuani"] = _Q, 
  ["Sion"] = _R, ["Shen"] = _E, ["Shyvana"] = _R, ["Talon"] = _E, ["Thresh"] = _Q, 
  ["Tristana"] = _W, ["Tryndamere"] = "Slash", ["Udyr"] = _E, ["Volibear"] = _Q, ["Vi"] = _Q, 
  ["XinZhao"] = _E, ["Yasuo"] = _E, ["Zac"] = _E, ["Ziggs"] = _W
}
GapcloseSpell, GapcloseTime, GapcloseUnit, GapcloseTargeted, GapcloseRange = 2, 0, nil, true, 450

function ObjectLoopEvent(object, myHero)
    if objectLoopEvents then
        for _, func in pairs(objectLoopEvents) do
            func(object, myHero)
        end
    end
end

function AfterObjectLoopEvent(myHero)
    DrawMenu()
    if GetButtonValue("Ignite") then AutoIgnite() end
    if afterObjectLoopEvents then
        for _, func in pairs(afterObjectLoopEvents) do
            func(myHero)
        end
    end
    if delayActions then
        for _, dfunc in pairs(delayActions) do
            if delayActions.time <= GetTickCount() then
                dfunc.func(table.unpack(dfunc.args or {}))
            end
        end
    end
end

function OnProcessSpell(unit, spell)
    if onProcessSpells then
        for _, func in pairs(onProcessSpells) do
            func(unit, spell)
        end
    end
end

function AddObjectLoopEvent(func)
    OnObjectLoop(func)
end

function AddAfterObjectLoopEvent(func)
    OnLoop(func)
end

function AddProcessSpell(func)
    OnProcessSpell(func)
end

function DelayAction(func, delay, args)
    if not delayedActionsExecuter then
        function delayedActionsExecuter()
            for t, funcs in pairs(delayedActions) do
                if t <= GetTickCount() then
                    for _, f in ipairs(funcs) do f.func(unpack(f.args or {})) end
                    delayedActions[t] = nil
                end
            end
        end
        AddAfterObjectLoopEvent(delayedActionsExecuter)
    end
    local t = GetTickCount() + (delay or 0)
    if delayedActions[t] then table.insert(delayedActions[t], { func = func, args = args })
    else delayedActions[t] = { { func = func, args = args } }
    end
end

AddObjectLoopEvent(function(object, myHero)
    if doMinions then
        if GetObjectType(object) == Obj_AI_Minion and not IsDead(k) then
            minionTable[GetNetworkID(object)] = object
        end
    end
    if not finishedEnemies then
        if not startTick then startTick = GetTickCount() end
        local enemyCount = #enemyHeroes
        if GetObjectType(object) == Obj_AI_Hero and GetTeam(object) ~= GetTeam(myHero) then
            if not enemyHeroes[GetNetworkID(object)] then
                enemyHeroes[GetNetworkID(object)] = object
            end
            if startTick + 1000 < GetTickCount() then finishedEnemies = true end
        end
    end
    if not finishedAllies then
        local allyCount = #allyHeroes
        if GetObjectType(object) == Obj_AI_Hero and GetTeam(object) == GetTeam(myHero) then
            if not allyHeroes[GetNetworkID(object)] then
                allyHeroes[GetNetworkID(object)] = object
            end
            if startTick + 1000 < GetTickCount() then finishedAllies = true end
        end
    end
end)

AddAfterObjectLoopEvent(function(myHero)
    if lastMinionTick < GetTickCount() then
        doMinions = true
        lastMinionTick = GetTickCount() + 1000
    else
        doMinions = false
    end
end)

function AddGapcloseEvent(spell, range, targeted)
    GapcloseSpell = spell
    GapcloseTime = 0
    GapcloseUnit = nil
    GapcloseTargeted = targeted
    GapcloseRange = range
    str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
    DelayAction(function()
        AddInfo("antigap", "Auto "..str[spell].." on gapclose:", SCRIPT_PARAM_ONOFF, true)
        for _,k in pairs(GetEnemyHeroes()) do
          if gapcloserTable[GetObjectName(k)] then
            AddButton(GetObjectName(k), "On "..GetObjectName(k).." "..(type(gapcloserTable[GetObjectName(k)]) == 'number' and str[gapcloserTable[GetObjectName(k)]] or (GetObjectName(k) == "LeeSin" and "Q" or "E")), true)
          end
        end
    end, 1)
    AddProcessSpell(function(unit, spell)
      if not unit or not gapcloserTable[GetObjectName(unit)] or not GetButtonValue(GetObjectName(unit)) then return end
      if spell.name == (type(gapcloserTable[GetObjectName(unit)]) == 'number' and GetCastName(unit, gapcloserTable[GetObjectName(unit)]) or gapcloserTable[GetObjectName(unit)]) and (spell.target == GetMyHero() or GetDistanceSqr(spell.endPos) < GapcloseRange*GapcloseRange*4) then
        GapcloseTime = GetTickCount() + 2000
        GapcloseUnit = unit
      end
    end)
    AddAfterObjectLoopEvent(function(myHero)
      if CanUseSpell(myHero, GapcloseSpell) == READY and GapcloseTime and GapcloseUnit and GapcloseTime > GetTickCount() then
        local pos = GetOrigin(GapcloseUnit)
        if GapcloseTargeted then
          if GetDistanceSqr(pos,GetMyHeroPos()) < GapcloseRange*GapcloseRange then
            CastTargetSpell(GapcloseUnit, GapcloseSpell)
          end
        else 
          if GetDistanceSqr(pos,GetMyHeroPos()) < GapcloseRange*GapcloseRange*4 then
            CastSkillShot(GapcloseSpell, pos.x, pos.y, pos.z)
          end
        end
      else
        GapcloseTime = 0
        GapcloseUnit = nil
      end
    end)
end

function AutoIgnite()
    if Ignite then
        for _, k in pairs(GetEnemyHeroes()) do
            if CanUseSpell(GetMyHero(), Ignite) == READY and (20*GetLevel(GetMyHero())+50) > GetCurrentHP(k)+GetHPRegen(k)*2.5 and GetDistanceSqr(GetOrigin(k)) < 600*600 then
                CastTargetSpell(k, Ignite)
            end
        end
    end
end

function CountMinions()
    local m = 0
    for _,k in pairs(GetAllMinions()) do 
        m = m + 1 
    end
    return m
end

function GetAllMinions(team)
    local result = {}
    for _,k in pairs(minionTable) do
        if k and not IsDead(k) then
            if not team or GetTeam(k) == team then
                result[_] = k
            end
        else
            minionTable[_] = nil
        end
    end
    return result
end

function ClosestMinion(pos, team)
    local minion = nil
    for k,v in pairs(GetAllMinions()) do 
        local objTeam = GetTeam(v)
        if not minion and v then minion = v and objTeam == team end
        if minion and v and objTeam == team and GetDistanceSqr(GetOrigin(minion),pos) > GetDistanceSqr(GetOrigin(v),pos) then
            minion = v
        end
    end
    return minion
end

function GetLowestMinion(pos, range, team)
    local minion = nil
    for k,v in pairs(GetAllMinions()) do 
        local objTeam = GetTeam(v)
        if not minion and v and objTeam == team and GetDistanceSqr(GetOrigin(v),pos) < range*range then minion = v end
        if minion and v and objTeam == team and GetDistanceSqr(GetOrigin(v),pos) < range*range and GetCurrentHP(v) < GetCurrentHP(minion) then
            minion = v
        end
    end
    return minion
end

function GetHighestMinion(pos, range, team)
    local minion = nil
    for k,v in pairs(minionTable) do 
        local objTeam = GetTeam(v)
        if not minion and v and objTeam == team and GetDistanceSqr(GetOrigin(v),pos) < range*range then minion = v end
        if minion and v and objTeam == team and GetDistanceSqr(GetOrigin(v),pos) < range*range and GetCurrentHP(v) > GetCurrentHP(minion) then
            minion = v
        end
    end
    return minion
end

function GenerateMovePos()
    local mPos = GetMousePos()
    local tV = {x = (mPos.x-GetMyHeroPos().x), z = (mPos.z-GetMyHeroPos().z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = GetMyHeroPos().x + 250 * tV.x / len, y = 0, z = GetMyHeroPos().z + 250 * tV.z / len}
end

function ValidTarget(unit, range)
    range = range or 25000
    if unit == nil or GetOrigin(unit) == nil or IsImmune(unit,GetMyHero()) or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(GetMyHero()) or not IsInDistance(unit, range) then return false end
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

function GetMyHeroPos()
    return GetOrigin(GetMyHero()) 
end

function GetEnemyHeroes()
    return enemyHeroes
end

function GetAllyHeroes()
    return allyHeroes
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
    return (GotBuff(source,"exhausted")  > 0 and 0.4 or 1) * math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
end

function GetTarget(range, damageType)
    damageType = damageType or 2
    local target, steps = nil, 10000
    for _, k in pairs(GetEnemyHeroes()) do
        local step = GetCurrentHP(k) / CalcDamage(GetMyHero(), k, DAMAGE_PHYSICAL == damageType and 100 or 0, DAMAGE_MAGIC == damageType and 100 or 0)
        if k and ValidTarget(k, range) and step < steps then
            target = k
            steps = step
        end
    end
    return target
end

function CastOffensiveItems(unit)
  i = {3074, 3077, 3142, 3184}
  u = {3153, 3146, 3144}
  for _,k in pairs(i) do
    slot = GetItemSlot(GetMyHero(),k)
    if slot and CanUseSpell(GetMyHero(), slot) == READY then
      CastTargetSpell(GetMyHero(), slot)
      return true
    end
  end
  for _,k in pairs(u) do
    slot = GetItemSlot(GetMyHero(),k)
    if slot and CanUseSpell(GetMyHero(), slot) == READY then
      CastTargetSpell(unit, slot)
      return true
    end
  end
  return false
end

function DrawMenu()
  if KeyIsDown(0x10) then
    local mPos  = GetMousePos()
    local mmPos = WorldToScreen(1,mPos.x,mPos.y,mPos.z)
    FillRect(currentPos.x-5,currentPos.y+30,210,#menuTable*35+40,0x50ffffff)
    local c = 0
    for _,k in pairs(menuTable) do
      if k.isInfo then
        c = c + 1
        FillRect(currentPos.x,c*35+currentPos.y,200,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,c*35+currentPos.y+5,0xffffffff)
      elseif k.lastSwitch then
        c = c + 1
        if k.value then
          FillRect(currentPos.x+150,c*35+currentPos.y,50,30,0x9000ff00)
        else
          FillRect(currentPos.x+150,c*35+currentPos.y,50,30,0x90ff0000)
        end
        FillRect(currentPos.x,c*35+currentPos.y,150,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,c*35+currentPos.y+5,0xffffffff)
        DrawText(({[true] = "On", [false] = "Off"})[k.value],20,currentPos.x+160,c*35+currentPos.y+5,0xffffffff)
      end
    end
    c = c + 1
    FillRect(currentPos.x,c*35+currentPos.y,200,30,0x90ffffff)
    DrawText("KeySettings:",20,currentPos.x+10,c*35+currentPos.y+5,0xffffffff)
    for _,k in pairs(menuTable) do
      if k.key then
        c = c + 1
        if KeyIsDown(k.key) then
          FillRect(currentPos.x+150,c*35+currentPos.y,50,30,0x9000ff00)
        else
          FillRect(currentPos.x+150,c*35+currentPos.y,50,30,0x90ff0000)
        end
        FillRect(currentPos.x,c*35+currentPos.y,150,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,c*35+currentPos.y+5,0xffffffff)
        local t = string.char(k.key)
        if k.switchNow then
          DrawText("...",20,currentPos.x+(t == " " and 155 or 160),c*35+currentPos.y+5,0xffffffff)
        else
          DrawText(t == " " and "Space" or t,20,currentPos.x+(t == " " and 155 or 170),c*35+currentPos.y+5,0xffffffff)
        end
      end
    end
    if KeyIsDown(1) then
      if moveNow then currentPos = {x = mmPos.x-25, y = mmPos.y-45} end
      local c = 0
      for _,k in pairs(menuTable) do
        if k.isInfo then
          c = c + 1
          if mmPos.x >= currentPos.x and mmPos.x <= currentPos.x+200 and mmPos.y >= (1*35+currentPos.y) and mmPos.y <= (1*35+currentPos.y+30) then
            moveNow = true
          end
        elseif k.lastSwitch then
          c = c + 1
          if mmPos.x >= currentPos.x+150 and mmPos.x <= currentPos.x+200 and mmPos.y >= (c*35+currentPos.y) and mmPos.y <= (c*35+currentPos.y+30) and k.lastSwitch + 250 < GetTickCount() then
            k.lastSwitch = GetTickCount()
            k.value = not k.value
          end
        end
      end
      c = c + 1
      for _,k in pairs(menuTable) do
        if k.key then
          c = c + 1
          if mmPos.x >= currentPos.x+150 and mmPos.x <= currentPos.x+200 and mmPos.y >= (c*35+currentPos.y) and mmPos.y <= (c*35+currentPos.y+30) then
            k.switchNow = true
          end
        end
      end
    else 
      moveNow = false
    end
    for _,k in pairs(menuTable) do
      if k.key and k.switchNow then
        for i=17, 128 do
          if KeyIsDown(i) then
            k.key = i
            k.switchNow = false
          end
        end
      end
    end
  end
end

function AddInfo(id, name)
  table.insert(menuTable, {id = id, text = name, isInfo = true})
end

function AddButton(id, name, defaultValue)
  table.insert(menuTable, {id = id, text = name, lastSwitch = 0, value = defaultValue})
end

function RemoveButton(id)
  for _,k in pairs(menuTable) do
    if k.id == id and k.lastSwitch then
      table.remove(menuTable, _)
    end
  end
end

function GetButtonValue(id)
  for _,k in pairs(menuTable) do
    if k.id == id and k.lastSwitch then
      return k.value
    end
  end
  return false
end

function AddSlider(id, name, startVal, minVal, maxVal, step)
end

function AddKey(id, name, defaultKey)
  table.insert(menuTable, {id = id, text = name, switchNow = false, key = defaultKey})
end  

function GetKeyValue(id)
  for _,k in pairs(menuTable) do
    if k.id == id and k.key then
      return KeyIsDown(k.key)
    end
  end
  return false
end

AddInfo("Inspired", "General:")
AddButton("Ignite", "Auto Ignite", true)