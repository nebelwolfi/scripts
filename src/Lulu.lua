if myHero.charName ~= "Lulu" then return end

local version = 0.13
local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/nebelwolfi/scripts/master/src/Lulu.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = LIB_PATH.."Lulu.lua"
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
        AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
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
InterruptList = {"CaitlynAceintheHole", "Crowstorm", "DrainChannel", "GalioIdolOfDurand", "KatarinaR", "InfiniteDuress", "AbsoluteZero", "MissFortuneBulletTime", "AlZaharNetherGrasp"}
EnemyMinions = minionManager(MINION_ENEMY, Spell.Q.Range, myHero, MINION_SORT_MAXHEALTH_DEC)
JungleMinions = minionManager(MINION_JUNGLE, Spell.Q.Range, myHero, MINION_SORT_MAXHEALTH_DEC)

--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()
allies = GetAllyHeroes()
enemies = GetEnemyHeroes()

-- called once when the script is loaded
function OnLoad()
    VP = VPrediction()
    IgniteSet()
    LoadMenu()
    PrintChat ("<font color='#4ECB65'>Lulu v" .. tostring(version) .. " - loaded successful!</font>")
end

function LoadMenu()
    menu = scriptConfig("Lulu script", "Lulu")
    menu:addSubMenu("AutoCombo Settings", "combosettings")
    menu.combosettings:addParam("useflashr","Use Flash+R", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
    
    menu:addSubMenu("AutoR Settings", "growthsettings")
    menu.growthsettings:addParam("user","Use R", SCRIPT_PARAM_ONOFF, true)
    menu.growthsettings:addParam("smartr","Use if x enemies hitable", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
    
    menu:addSubMenu("Custom Save Priority","custompriority")
    --[[ old 
    menu.custompriority: addParam(allie[1].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.custompriority: addParam(allie[2].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.custompriority: addParam(allie[3].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.custompriority: addParam(allie[4].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    ]]--
    Boot()
    
    menu:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu:addSubMenu("Harass Settings", "harass")
    menu.harass:addParam("harass", "Toogle Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
    menu.harass:addParam("mana","Auto Harass till Mana is under",SCRIPT_PARAM_SLICE, 30, 0, 101, 0)
    
    menu:addSubMenu("Draw Ranges", "drawab")
    menu.drawab:addParam("drawauto", "Draw Auto", SCRIPT_PARAM_ONOFF, true)
    menu.drawab:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
    menu.drawab:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
    menu.drawab:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
    menu.drawab:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
    if VIP_USER then
    menu:addSubMenu("Packets", "Packets")
    menu.Packets:addParam("QPACK", "Q Packets", SCRIPT_PARAM_ONOFF, false)
    menu.Packets:addParam("EPACK", "E Packets", SCRIPT_PARAM_ONOFF, false)
    end
    menu:addSubMenu("Orbwalker", "orbi")
    Orb:LoadToMenu(menu.orbi)
    menu:addParam("info", " >> Version ", SCRIPT_PARAM_INFO, version)
end

function Boot()
  ts1 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 950, DAMAGE_MAGIC, nil, false)
  ts1.name = "Ally"
  menu.custompriority:addTS(ts1)
  ts2 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 950)
  ts2.name = "Enemy"
  menu.custompriority:addTS(ts2)
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
  if not menu.Combo or myHero.dead or not bootDone then return end
  Check()
  Orb:EnableAttacks()
  ts2:update()
  target = ts2.target
  if menu.Combo then
    if ValidTarget(target, 900) and not target.dead then
      Combo(target)
    end
  end
  SmartR()
  if menu.Harass then
   if ValidTarget(target, 900) and not target.dead then
      Harass(target)
    end
  end
end

function Combo(Target)
  Orb:DisableAttacks()
  
  local Target = STS:GetTarget(Qrance)
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

  Orb:EnableAttacks()
end

function SmartR()
  if RReady and menu.growthsettings.user then
    if countEnemy(player, 200) >= menu.growthsettings.smartr then
      CastSpell(_R, player)
    end
    for _, i in pairs (allyHeroes) do
      if countEnemy(i, 200) >= menu.growthsettings.smartr and GetDistance(i, player) < Spell.R.Range then
        CastSpell(_R, i)
      end
    end
  end
end

function Harass(Target)
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
  if unit.isMe and spell.name:lower():find("attack") then
    --PrintChat("Is attack!")
  end
end 

function getMousePos(range)
  local temprange = range or SkillWard.range
  local MyPos = Vector(myHero.x, myHero.y, myHero.z)
  local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
  return MyPos - (MyPos - MousePos):normalized() * SkillWard.range
end