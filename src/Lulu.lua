if myHero.charName ~= "Lulu" then return end

local version = 0.18 -- REMEMBER: UPDATE .version FILE ASWELL FOR IN-GAME PUSH!
local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/nebelwolfi/scripts/master/src/Lulu.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Lulu.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Lulu:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTO_UPDATE then
  local ServerData = GetWebResult(UPDATE_HOST, "/nebelwolfi/scripts/master/src/Lulu.version")
  if ServerData then
    ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
    if ServerVersion then
      if tonumber(version) < ServerVersion then
        AutoupdaterMsg("New version available v"..ServerVersion)
        AutoupdaterMsg("Updating, please don't press F9")
        DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
      else
        AutoupdaterMsg("Loaded the latest version (v"..ServerVersion..")")
      end
    end
  else
    AutoupdaterMsg("Error downloading version info")
  end
end

if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
  require("SxOrbWalk")
end
if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
if FileExist(LIB_PATH .. "/SourceLib.lua") then
  require "SourceLib"
end

local Orb = _G.SxOrb
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local target = nil
local ignite, igniteReady = nil, false
local BootDone = false
local Spell = { Q = {Range = 925, Width = 50, Speed = 1450, Delay = 0.25},  
                W = {Range = 650},  
                E = {Range = 650},
                R = {Range = 900},}
local InterruptList = {
    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    { charName = "FiddleSticks", spellName = "Crowstorm"},
    { charName = "FiddleSticks", spellName = "DrainChannel"},
    { charName = "Galio", spellName = "GalioIdolOfDurand"},
    { charName = "Karthus", spellName = "FallenOne"},
    { charName = "Katarina", spellName = "KatarinaR"},
    { charName = "Lucian", spellName = "LucianR"},
    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", spellName = "AbsoluteZero"},
    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    { charName = "Shen", spellName = "ShenStandUnited"},
    { charName = "Urgot", spellName = "UrgotSwap2"},
    { charName = "Varus", spellName = "VarusQ"},
    { charName = "Warwick", spellName = "InfiniteDuress"}
}
local ToInterrupt = {}
local enemyMinions = minionManager(MINION_ENEMY, 1500, myHero, MINION_SORT_MAXHEALTH_DEC)
local jungleMinions = minionManager(MINION_JUNGLE, 1500, myHero, MINION_SORT_MAXHEALTH_DEC)

--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()
allies = GetAllyHeroes()
enemies = GetEnemyHeroes()

-- called once when the script is loaded
function OnLoad()
    VP = VPrediction()
    STS   = SimpleTS()
    IgniteSet()
    LoadMenu()
    --PrintChat ("<font color='#4ECB65'>Lulu v" .. tostring(version) .. " - loaded successful!</font>")
end

function LoadMenu()
    menu = MenuWrapper(player.charName, "unique" .. player.charName:gsub("%s+", ""))
    
    menu:SetTargetSelector(STS)
    --menu:SetOrbwalker(Orb)
    menu = menu:GetHandle()
    menu:addSubMenu("AutoCombo Settings", "combosettings")
    menu.combosettings:addParam("useflashr","Save with Flash+R", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("B"))
    menu.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
    
    menu:addSubMenu("AutoR Settings", "growthsettings")
    menu.growthsettings:addParam("user","Auto use R", SCRIPT_PARAM_ONOFF, true)
    --menu.growthsettings:addParam("autorper", "Auto R ally under health %", SCRIPT_PARAM_SLICE, 30, 1, 100, 0) DEPRECATED
    menu.growthsettings:addParam("smartr","Use if x enemies hitable", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
    
    menu.growthsettings:addSubMenu("Priority","custompriority")
    Boot()
    
    menu:addSubMenu("Harass Settings", "harass")
    menu.harass:addParam("mana","Auto Harass till Mana is under",SCRIPT_PARAM_SLICE, 30, 0, 101, 0)
    menu.harass:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
    menu.harass:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
    menu.harass:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
    
    menu:addSubMenu("Draw Ranges", "drawab")
    menu.drawab:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
    menu.drawab:addParam("draww", "Draw W&E", SCRIPT_PARAM_ONOFF, true)
    menu.drawab:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
   
    menu:addParam("interrupt", "Interrupt with W", SCRIPT_PARAM_ONOFF, true)
    
    menu:addSubMenu("Orbwalker", "orbi")
    Orb:LoadToMenu(menu.orbi)
    
    
    menu:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu:addParam("harasskey", "Hold for Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    menu:addParam("harasstoggle", "Toggle for Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T "))
    menu:permaShow("combokey")
    menu:permaShow("harasskey")
    menu:permaShow("harasstoggle")
    menu:addParam("info2", " >> Version ", SCRIPT_PARAM_INFO, version)
end

function Boot()
  enemyHeros = {}
  enemyHerosCount = 0
    for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
    if hero.team ~= player.team then
      local enemyCount = enemyHerosCount + 1
      enemyHeros[enemyCount] = {object = hero, q = 0, w = 0, e = 0, r = 0, dfg = 0, ig = 0, myDamage = 0, manaCombo = 0}
      enemyHerosCount = enemyCount
    end
  end
  menu.growthsettings.custompriority:addParam("info1"," >> Highest priority to R: ", SCRIPT_PARAM_INFO, 5)
  alliedHeros = {}
  alliedHerosCount = 0
    for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
    if hero.team == player.team then
      local alliedCount = alliedHerosCount + 1
      alliedHeros[alliedCount] = {object = hero, q = 0, w = 0, e = 0, r = 0, dfg = 0, ig = 0, myDamage = 0, manaCombo = 0}
      menu.growthsettings.custompriority:addParam("champ"..alliedHerosCount,hero.charName,SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      alliedHerosCount = alliedCount
    end
  end
  BootDone = true
end

function IgniteSet()
  if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
    ignite = SUMMONER_1 
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
    ignite = SUMMONER_2 
  end
  igniteReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

-- handles script logic, a pure high speed loop
function OnTick()
  if myHero.dead or not BootDone or recall then return end
  tick=GetTickCount()
  CalcAllyDamage()
  Check()
  if menu.combokey then
      Combo()
  end
  SmartR()
  if menu.harasskey or menu.harasstoggle then
      Harass()
  end
end

function Combo()
  local Target = STS:GetTarget(Spell.Q.Range)
  if Target ~= nil then
    if menu.combosettings.usee and EReady then
      CastSpell(_E, Target)
    end
    if menu.combosettings.useq and GetDistance(Target, player) < Spell.Q.Range then
      local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, 0.25,60,950, 1600, myHero, false)
      if CastPosition and HitChance >= 2 then
        CastSpell(_Q, CastPosition.x, CastPosition.z)
      end
    end
  end
end

function SmartR()
  if RReady and menu.growthsettings.user then
    if countEnemy(player, 200) >= menu.growthsettings.smartr then
      CastSpell(_R, player)
    end
    for _, i in pairs (allies) do
      if countEnemy(i, 200) >= menu.growthsettings.smartr and GetDistance(i, player) < Spell.R.Range then
        CastSpell(_R, i)
      end
    end
  end
end

function countEnemy(allyHero, range)
  local nearEnemy = 0
  for i, e in pairs(enemies) do
    if GetDistance(allyHero, e) < range then
      nearEnemy = nearEnemy + 1
    end
  end
  return nearEnemy
end

function Harass()
  local Target = STS:GetTarget(Spell.Q.Range+Spell.E.Range)
  if Target ~= nil then
    if GetDistance(Target, player) < Spell.Q.Range then
      if menu.harass.usew and EReady then
        CastSpell(_W, Target)
      end
      if menu.harass.useq then
        local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, 0.25,60,950, 1600, myHero, false)
        if CastPosition and HitChance >= 2 then
          CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
      end
    elseif GetDistance(Target, player) < Spell.Q.Range+Spell.E.Range then
      SmartE(Target)
      local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, 0.25,60,950, 1600, myHero, false)
      if CastPosition and HitChance >= 2 then
        DelayAction(function() CastSpell(_Q, CastPosition.x, CastPosition.z) end, 0.5)
      end
    end
  end
end

function SmartE(target)
  enemyMinions:update()
  for i, minion in pairs(enemyMinions.objects) do
    if GetDistance(minion, player) < Spell.E.Range and GetDistance(minion, target) < Spell.Q.Range and getDmg("E", minion, player) < minion.health and minion ~= nil then
      CastSpell(_E, minion)
    end
  end
end

function Check()
  QReady = (myHero:CanUseSpell(_Q) == READY)
  WReady = (myHero:CanUseSpell(_W) == READY)
  EReady = (myHero:CanUseSpell(_E) == READY)
  RReady = (myHero:CanUseSpell(_R) == READY)
  igniteReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function EnemysAround(Unit, range)
  local c=0
  for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end

function OnProcessSpell(unit, spell)
  if #ToInterrupt > 0 and WReady and menu.interrupt then
    for _, ability in pairs(ToInterrupt) do
      if spell.name == ability and unit.team ~= myHero.team and GetDistance(unit) < Spell.W.Range then
        CastSpell(_W, unit.x, unit.z)
      end
    end
  end
end

function getMousePos(range)
  local temprange = range or SkillWard.range
  local MyPos = Vector(myHero.x, myHero.y, myHero.z)
  local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
  return MyPos - (MyPos - MousePos):normalized() * SkillWard.range
end

local OldHP = {0,0,0,0,0,0,0,0,0,0}
local ChampDMG = {0,0,0,0,0,0,0,0,0,0}
local lastDMGtick = {0,0,0,0,0,0,0,0,0,0}
local tick=0
function CalcAllyDamage()
  for i = 1, heroManager.iCount, 1 do
    local target = heroManager:getHero(i)
    if (target.team == myHero.team) then
      if (target.health >= OldHP[i]) then
        if (tick-lastDMGtick[i] > 1000) then ChampDMG[i] = 0 end
      else
        lastDMGtick[i]=tick
        ChampDMG[i] = ChampDMG[i] + (OldHP[i] - target.health)
        local DamageLvlTaken=math.round(DamageImpactTaken(i)*10)
        if (DamageLvlTaken>=1) then
          if (Plugin_FocusedAlly) then
            Plugin_FocusedAlly(target,DamageLvlTaken)
          end
        end
      end
      OldHP[i] = target.health
    end
  end
end

function DamageImpactTaken(iHero)
  local target = heroManager:getHero(iHero)
  if (target.health==0) then return 0 end
  local x=(ChampDMG[iHero]/target.health)
  if x > 9 then 
    return 10
  else
    return x
  end
end

function Plugin_FocusedAlly(target,DamageLvlTaken)
  local targetP = 1
  for i = 1, 5 do
    local hero = allies[i]
      if target == myHero then 
        targetP = menu.growthsettings.custompriority.champ1
        return
      elseif hero == target then
        if i == 1 then
          targetP = menu.growthsettings.custompriority.champ1
        elseif i == 2 then
          targetP = menu.growthsettings.custompriority.champ2
        elseif i == 3 then
          targetP = menu.growthsettings.custompriority.champ3
        elseif i == 4 then
          targetP = menu.growthsettings.custompriority.champ4
        elseif i == 5 then
          targetP = menu.growthsettings.custompriority.champ5
        end
    end
  end
  --PrintChat("Dmglvl: "..DamageLvlTaken..", Champ: "..target.charName..", Priority: "..targetP)
  if DamageLvlTaken>=30 and (myHero:CanUseSpell(_R) == READY) and (GetDistance(target) < 900 ) then
    if targetP > 4 and DamageLvlTaken>=30 then
      CastSpell(_R, target)
    elseif targetP > 3 and DamageLvlTaken>=40 then
      CastSpell(_R, target)
    elseif targetP > 2 and DamageLvlTaken>=55 then
      CastSpell(_R, target)
    elseif targetP > 1 and DamageLvlTaken>=70 then
      CastSpell(_R, target)
    elseif targetP > 0 and DamageLvlTaken>=85 then
      CastSpell(_R, target)
    end
  elseif DamageLvlTaken>=4 and (myHero:CanUseSpell(_E) == READY) and (GetDistance(target) < 650 ) then
    if target == myHero then
      CastSpell(_E, target)
    elseif DamageLvlTaken>6 then
      CastSpell(_E, target)
    end
  end
end

function OnDraw()
  if menu.drawab.drawq then DrawCircle(player.x, player.y, player.z, Spell.Q.Range, 0xffff0000) end
  if menu.drawab.draww then DrawCircle(player.x, player.y, player.z, Spell.W.Range, 0xffff0000) end
  if menu.drawab.drawr then DrawCircle(player.x, player.y, player.z, Spell.R.Range, 0xffff0000) end
end