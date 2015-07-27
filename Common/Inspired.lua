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
  ["Aatrox"] = _Q, ["Akali"] = _R, ["Alistar"] = _W, ["Ahri"] = _R, ["Amumu"] = _Q, ["Corki"] = _W,
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
        OnLoop(delayedActionsExecuter)
    end
    local t = GetTickCount() + (delay or 0)
    if delayedActions[t] then table.insert(delayedActions[t], { func = func, args = args })
    else delayedActions[t] = { { func = func, args = args } }
    end
end

OnLoop(function(myHero)
    DrawMenu()
    if Ignite and InspiredConfig.Ignite then AutoIgnite() end
end)

OnObjectLoop(function(object, myHero)
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

OnLoop(function(myHero)
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
    OnProcessSpell(function(unit, spell)
      if not unit or not gapcloserTable[GetObjectName(unit)] or not GetButtonValue(GetObjectName(unit)) then return end
      if spell.name == (type(gapcloserTable[GetObjectName(unit)]) == 'number' and GetCastName(unit, gapcloserTable[GetObjectName(unit)]) or gapcloserTable[GetObjectName(unit)]) and (spell.target == GetMyHero() or GetDistanceSqr(spell.endPos) < GapcloseRange*GapcloseRange*4) then
        GapcloseTime = GetTickCount() + 2000
        GapcloseUnit = unit
      end
    end)
    OnLoop(function(myHero)
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

SCRIPT_PARAM_ONOFF = 1
SCRIPT_PARAM_KEYDOWN = 2
SCRIPT_PARAM_SLICE = 3
SCRIPT_PARAM_INFO = 4
SCRIPT_PARAM_LIST = 5
selectedMenuState = ""

function DrawMenu()
  if KeyIsDown(0x10) then
    local c = 0
    local d = 0
    local e = 0
    local f = 0
    for a,b in pairs(menuTable) do
      d = d + 1
    end
    local mPos  = GetMousePos()
    local mmPos = WorldToScreen(1,mPos.x,mPos.y,mPos.z)
    FillRect(currentPos.x-5,currentPos.y+30,210,d*35+40,0x50ffffff)
    c = c + 1
    FillRect(currentPos.x,c*35+currentPos.y,200,30,0x90ffffff)
    DrawText("- - - - ScriptConfig - - - -",20,currentPos.x+10,c*35+currentPos.y+5,0xffffffff)
    for _, menu in pairs(menuTable) do
      c = c + 1
      FillRect(currentPos.x,c*35+currentPos.y,200,30,0x90ffffff)
      DrawText(menu.name,20,currentPos.x+10,c*35+currentPos.y+5,0xffffffff)
      if selectedMenuState == _ then
        FillRect(currentPos.x,c*35+currentPos.y,200,30,0x90ffffff)
        for k, thing in pairs(menu) do
          if type(thing) == "table" then
            f = f + 1
          end
        end
        FillRect(currentPos.x+205,currentPos.y+65,210,f*35+5,0x50ffffff)
        e = e + 1
        for k, thing in pairs(menu) do
          if thing.type == SCRIPT_PARAM_INFO then
            e = e + 1
            FillRect(currentPos.x+210,e*35+currentPos.y,200,30,0x90ffffff)
            DrawText(thing.t,20,currentPos.x+10+210,e*35+currentPos.y+5,0xffffffff)
          elseif thing.type == SCRIPT_PARAM_ONOFF then
            e = e + 1
            if thing.value then
              FillRect(currentPos.x+150+210,e*35+currentPos.y,50,30,0x9000ff00)
            else
              FillRect(currentPos.x+150+210,e*35+currentPos.y,50,30,0x90ff0000)
            end
            FillRect(currentPos.x+210,e*35+currentPos.y,150,30,0x90ffffff)
            DrawText(thing.t,20,currentPos.x+10+210,e*35+currentPos.y+5,0xffffffff)
            DrawText(({[true] = "On", [false] = "Off"})[thing.value],20,currentPos.x+160+210,e*35+currentPos.y+5,0xffffffff)
          end
        end
        for k, thing in pairs(menu) do
          if thing.type == SCRIPT_PARAM_KEYDOWN then
            e = e + 1
            if thing.value then
              FillRect(currentPos.x+150+210,e*35+currentPos.y,50,30,0x9000ff00)
            else
              FillRect(currentPos.x+150+210,e*35+currentPos.y,50,30,0x90ff0000)
            end
            FillRect(currentPos.x+210,e*35+currentPos.y,150,30,0x90ffffff)
            DrawText(thing.t,20,currentPos.x+10+210,e*35+currentPos.y+5,0xffffffff)
            local t = string.char(thing.key)
            if thing.switchNow then
              DrawText("...",20,currentPos.x+165+210,e*35+currentPos.y+5,0xffffffff)
            else
              DrawText(t == " " and "Space" or t,20,currentPos.x+(t == " " and 155 or 170)+210,e*35+currentPos.y+5,0xffffffff)
            end
          end
        end
      elseif selectedMenuState == "" then
        selectedMenuState = _
      end
    end
    if KeyIsDown(1) then
      local c = 1
      local f = 1
      for a,b in pairs(menuTable) do
        d = d + 1
      end
      if moveNow then currentPos = {x = mmPos.x-25, y = mmPos.y-45} end
      if mmPos.x >= currentPos.x and mmPos.x <= currentPos.x+200 and mmPos.y >= (1*35+currentPos.y) and mmPos.y <= (1*35+currentPos.y+30) then
        moveNow = true
      end
      for _, menu in pairs(menuTable) do
        c = c + 1
        if mmPos.x >= currentPos.x and mmPos.x <= currentPos.x+200 and mmPos.y >= (c*35+currentPos.y) and mmPos.y <= (c*35+currentPos.y+30) then
          selectedMenuState = _
        end
        if selectedMenuState == menu.name then
          for k, thing in pairs(menu) do
            if thing.type ~= SCRIPT_PARAM_KEYDOWN then
              if type(thing) == "table" then
                f = f + 1
              end
              if thing.type == SCRIPT_PARAM_ONOFF and thing.lastSwitch + 250 < GetTickCount() and mmPos.x >= currentPos.x+150+210 and mmPos.x <= currentPos.x+200+210 and mmPos.y >= (f*35+currentPos.y) and mmPos.y <= (f*35+currentPos.y+30) then
                thing.lastSwitch = GetTickCount()
                thing.value = not thing.value
              end
            end
          end
          for k, thing in pairs(menu) do
            if thing.type == SCRIPT_PARAM_KEYDOWN then
              if type(thing) == "table" then
                f = f + 1
              end
              if thing.type == SCRIPT_PARAM_KEYDOWN and mmPos.x >= currentPos.x+150+210 and mmPos.x <= currentPos.x+200+210 and mmPos.y >= (f*35+currentPos.y) and mmPos.y <= (f*35+currentPos.y+30) then
                thing.switchNow = true
              end
            end
          end
        end
      end
    else
      moveNow = false
    end
    for _,menu in pairs(menuTable) do
      for _,k in pairs(menu) do
        if k.type and k.type == SCRIPT_PARAM_KEYDOWN and k.switchNow then
          for i=17, 128 do
            if KeyIsDown(i) then
              k.key = i
              k.switchNow = false
            end
          end
        end
      end
    end
  else
    moveNow = false
  end
end
function scriptConfig(id, text, master)
  local Config = {}
  menuTable[id] = {name = text, m = master}
  Config.addSubMenu = function(idSub, textSub) Config[idSub] = scriptConfig(idSub, ">>"..text..": "..textSub, id) end
  Config.addParam   = function(idBut, textBut, type, val1, val2, val3, val4) 
                        if type == SCRIPT_PARAM_ONOFF then
                          Config[idBut] = val1
                          menuTable[id][idBut] = {t = textBut, type = type, value = val1, lastSwitch = 0}
                          OnLoop(function(myHero) Config[idBut] = menuTable[id][idBut].value end)
                        elseif type == SCRIPT_PARAM_KEYDOWN then 
                          Config[idBut] = false
                          menuTable[id][idBut] = {t = textBut, type = type, key = val1, value = false, switchNow = false}
                          OnLoop(function(myHero) Config[idBut] = KeyIsDown(menuTable[id][idBut].key)
                                                  menuTable[id][idBut].value = KeyIsDown(menuTable[id][idBut].key) end)
                        elseif type == SCRIPT_PARAM_SLICE then
                        elseif type == SCRIPT_PARAM_INFO then
                          menuTable[id][idBut] = {t = textBut, type = type}
                        elseif type == SCRIPT_PARAM_LIST then
                        end
                      end
  return Config
end

if Ignite then
  InspiredConfig = scriptConfig("Inspired", "Inspired.lua")
  InspiredConfig.addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
end

local toPrint, toPrintCol = {}, {}
function print(str, time, col)
  local b = 0
  for _, k in pairs(toPrint) do
    b = _
  end
  local index = b + 1
  toPrint[index] = str
  toPrintCol[index] = col or 0xffffffff
  DelayAction(function() toPrint[index] = nil toPrintCol[index] = nil end, time or 2000)
end

OnLoop(function(myHero)
  local c = 0
  for _, k in pairs(toPrint) do
    c = c + 1
    DrawText(k,50,750,200+50*c,toPrintCol[_])
  end
end)

print("hi1")
DelayAction(print, 500, {"hi2"})
DelayAction(print, 750, {"hi3"})
DelayAction(print, 1000, {"hi4"})
DelayAction(print, 1250, {"hi5"})
DelayAction(print, 1500, {"hi6"})