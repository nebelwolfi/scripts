local version = 1.0
if myHero.charName ~= "Lulu" then return end
local VP = VPrediction()
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local target = nil
local ignite, igniteReady = nil, false
local AUTOUPDATE = true

InterruptList = {"CaitlynAceintheHole", "Crowstorm", "DrainChannel", "GalioIdolOfDurand", "KatarinaR", "InfiniteDuress", "AbsoluteZero", "MissFortuneBulletTime", "AlZaharNetherGrasp"}
  
if AUTOUPDATE then
   LazyUpdater("Lulu", version, "https://github.com/nebelwolfi/scripts/raw/master/src/", "Lulu.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME):SetSilent(false):CheckUpdate()
end

--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()
allies = GetAllyHeros()

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
    menu.custompriority: addParam(allie[1].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.custompriority: addParam(allie[2].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.custompriority: addParam(allie[3].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.custompriority: addParam(allie[4].charName, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    
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
    PrintChat ("<font color='#4ECB65'>Lulu script - loaded successful!</font>")
end

-- handles script logic, a pure high speed loop
function OnTick()
  if not Menu.Combo or myHero.dead then return end
end

function EnemysAround(Unit, range)
  local c=0
  for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end