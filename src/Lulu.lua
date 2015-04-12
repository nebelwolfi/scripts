if myHero.charName ~= "Lulu" then return end
print("<b>IF THE SCRIPT DOESNT SAY SOMETHING IN CHAT AFTER 1-3 MINUTES THEN</b>")
print("<b>CHECK IF SCRIPT IS NAMED : Lulu.lua</b>")
print("<b>IF IT STILL DOESNT WORK PRESS DOUBLE F9 OR DOWNLOAD SoW - SourceLib and VPrediction manually.</b>")
local version = 1.0
local AUTOUPDATE = true

local REQUIRED_LIBS = {
    ["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
    ["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
    ["SourceLib"] = "https://bitbucket.org/TheRealSource/public/raw/master/common/SourceLib.lua",}
  
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
require "SOW"
require "SourceLib"

if AUTOUPDATE then
   LazyUpdater("Lulu", version, "https://github.com/nebelwolfi/scripts/raw/master/src/", "Lulu.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME):SetSilent(false):CheckUpdate()
end

local VP = VPrediction()
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local target = nil
local ignite, igniteReady = nil, false
local BootDone = false
InterruptList = {"CaitlynAceintheHole", "Crowstorm", "DrainChannel", "GalioIdolOfDurand", "KatarinaR", "InfiniteDuress", "AbsoluteZero", "MissFortuneBulletTime", "AlZaharNetherGrasp"}
EnemyMinions = minionManager(MINION_ENEMY, Ranges[_Q], myHero, MINION_SORT_MAXHEALTH_DEC)
JungleMinions = minionManager(MINION_JUNGLE, Ranges[_Q], myHero, MINION_SORT_MAXHEALTH_DEC)

  
--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()
allies = GetAllyHeros()
enemies = GetEnemyHeros()

-- called once when the script is loaded
function OnLoad()
    PrintChat(" >> Lulu script")
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,950)
    menu = scriptConfig("Lulu script", "Lulu")
    menu:addSubMenu("AutoCombo Settings", "combosettings")
    menu.combosettings:addParam("useflashr","Use Flash+R", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
    menu.combosettings:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
    
    menu:addSubMenu("AutoGrowth Settings", "growthsettings")
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
    Config:addSubMenu("Packets", "Packets")
    Config.Packets:addParam("QPACK", "Q Packest", SCRIPT_PARAM_ONOFF, false)
    Config.Packets:addParam("EPACK", "E Packest", SCRIPT_PARAM_ONOFF, false)
    end
    Config:addParam("info4", " >> Version ", SCRIPT_PARAM_INFO, version)
    PrintChat ("<font color='#4ECB65'>Lulu' .. tostring(version) .. ' - loaded successful!</font>")
end

function Boot()
  ts1 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 950, DAMAGE_MAGIC, nil, false)
  ts1.name = "Ally"
  menu.growthsettings.custompriority:addTS(ts1)
  ts2 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 950)
  ts2.name = "Enemy"
  menu.growthsettings.custompriority:addTS(ts2)
  BootDone = true
end

-- handles script logic, a pure high speed loop
function OnTick()
  if not Menu.Combo or myHero.dead or not bootDone then return end
end

function EnemysAround(Unit, range)
  local c=0
  for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end