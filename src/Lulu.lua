if myHero.charName ~= "Lulu" then return end
local version = 1.0
local AUTOUPDATE = true

local REQUIRED_LIBS = {
    ["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
    ["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
    ["SourceLib"] = "https://raw.githubusercontent.com/TheRealSource/public/master/common/SourceLib.lua",}
  
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""
  
function AfterDownload()
  DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
  if DOWNLOAD_COUNT == 0 then
    DOWNLOADING_LIBS = false
    print("<b>[Lulu]: Required libraries downloaded successfully, please reload (double F9).</b>")
  end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
  if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
    require(DOWNLOAD_LIB_NAME)
  else
    DOWNLOADING_LIBS = true
    DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
  end
end

if DOWNLOADING_LIBS then return end

require "VPrediction"
require "SxOrbWalk"
require "SourceLib"

local VP = VPrediction()
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
    Orb = SxOrbWalk()
    PrintChat(" >> Lulu script")
    IgniteSet()
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,950)
    menu = scriptConfig("Lulu script", "Lulu")
    menu:addSubMenu("AutoCombo Settings", "combosettings")
    menu.combosettings:addParam("useflashr","Use Flash+R", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
    
    menu:addSubMenu("AutoR Settings", "growthsettings")
    menu.growthsettings:addParam("user","Use R", SCRIPT_PARAM_ONOFF, true)
    
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
    PrintChat ("<font color='#4ECB65'>Lulu v" .. tostring(version) .. " - loaded successful!</font>")
end

function Boot()
  ts1 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 950, DAMAGE_MAGIC, nil, false)
  ts1.name = "Ally"
  menu.custompriority:addTS(ts1)
  ts2 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 950)
  ts2.name = "Enemy"
  menu.custompriority:addTS(ts2)
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
    if ValidTarget(target, 1200) and not target.dead then
      Combo(target)
    end
  end
  if menu.Harass then
   if ValidTarget(target, 1200) and not target.dead then
      Harass(target)
    end
  end
end

function Combo(Target)
  Orb:DisableAttacks()
  
  -- combo logic here
  
  Orb:EnableAttacks()
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


function getMousePos(range)
local temprange = range or SkillWard.range
local MyPos = Vector(myHero.x, myHero.y, myHero.z)
local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)

return MyPos - (MyPos - MousePos):normalized() * SkillWard.range
end