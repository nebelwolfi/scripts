--[[

             _               _               _   
     /\     (_)             | |             | |  
    /  \     _   _ __ ___   | |__     ___   | |_ 
   / /\ \   | | | '_ ` _ \  | '_ \   / _ \  | __|
  / ____ \  | | | | | | | | | |_) | | (_) | | |_ 
 /_/    \_\ |_| |_| |_| |_| |_.__/   \___/   \__|
                                                 
                                                  

]]--

if not VIP_USER then return end -- VIP only since we use packets everywhere

--[[ Skillshot list start ]]--
_G.Champs = {
    ["Aatrox"] = {
        [_Q] = { speed = 450, delay = 0.25, range = 650, width = 145, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1200, delay = 0.25, range = 1075, width = 75, collision = false, aoe = false, type = "linear"}
    },
        ["Ahri"] = {
        [_Q] = { speed = 2500, delay = 0.25, range = 900, width = 100, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 1000, delay = 0.25, range = 1000, width = 60, collision = true, aoe = false, type = "linear"}
    },
        ["Amumu"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1100, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Anivia"] = {
        [_Q] = { speed = 850, delay = 0.250, range = 1100, width = 110, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = math.huge, delay = 0.100, range = 615, width = 350, collision = false, aoe = true, type = "circular"}
    },
        ["Annie"] = {
        [_W] = { speed = math.huge, delay = 0.25, range = 625, width = 0, collision = false, aoe = true, type = "cone"},
        [_R] = { speed = math.huge, delay = 0.1, range = 600, width = 300, collision = false, aoe = true, type = "circular"}
    },
        ["Ashe"] = {
        [_W] = { speed = 2000, delay = 0.120, range = 1200, width = 85, collision = true, aoe = false, type = "cone"},
        [_R] = { speed = 1600, delay = 0.25, range = 25000, width = 120, collision = false, aoe = false, type = "linear"}
    },
        ["Blitzcrank"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 900, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Brand"] = {
        [_Q] = { speed = 1600, delay = 0.625, range = 1100, width = 90, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = 900, delay = 0.25, range = 1100, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["Braum"] = {
        [_Q] = { speed = 1600, delay = 225, range = 1000, width = 100, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1250, delay = 500, range = 1250, width = 0, collision = false, aoe = false, type = "linear"}
    },    
        ["Caitlyn"] = {
        [_Q] = { speed = 2200, delay = 0.625, range = 1300, width = 0, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 2000, delay = 0.400, range = 1000, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Cassiopeia"] = {
        [_Q] = { speed = math.huge, delay = 0.535, range = 850, width = 0, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = math.huge, delay = 0.350, range = 850, width = 80, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = math.huge, delay = 0.535, range = 850, width = 350, collision = false, aoe = false, type = "linear"}
    },
        ["Chogath"] = {
        [_Q] = { speed = 950, delay = 0, range = 950, width = 0, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = math.huge, delay = 0.25, range = 700, width = 0, collision = false, aoe = false, type = "linear"},
        },
        ["Corki"] = {
        [_Q] = { speed = 1500, delay = 0.350, range = 840, width = 0, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 2000, delay = 0.200, range = 1225, width = 60, collision = false, aoe = false, type = "linear"},
    },
        ["Darius"] = {
        [_E] = { speed = 1500, delay = 0.550, range = 530, width = 0, collision = false, aoe = true, type = "cone"}
    },
        ["Diana"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 830, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["DrMundo"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1050, width = 75, collision = true, aoe = false, type = "linear"}
    },
        ["Draven"] = {
        [_E] = { speed = 1400, delay = 0.250, range = 1100, width = 130, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 2000, delay = 0.5, range = 25000, width = 160, collision = false, aoe = false, type = "linear"}
    },
        ["Elise"] = {
        [_E] = { speed = 1450, delay = 0.250, range = 975, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Ezreal"] = {
        [_Q] = { speed = 2000, delay = 0.25, range = 1200, width = 80, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 1500, delay = 0.25, range = 1050, width = 80, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 2000, delay = 1, range = 20000, width = 160, collision = false, aoe = false, type = "linear"}
    },
        ["Fizz"] = {
        [_R] = { speed = 1350, delay = 0.250, range = 1275, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Galio"] = {
        [_Q] = { speed = 1300, delay = 0.25, range = 900, width = 175, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 2000, delay = 0.400, range = 1000, width = 40, collision = false, aoe = false, type = "linear"}
    },
        ["Gragas"] = {
        [_Q] = { speed = 1000, delay = 0.250, range = 1100, width = 180, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1000, delay = 0.250, range = 1050, width = 400, collision = false, aoe = true, type = "circular"}
    },
        ["Graves"] = {
        [_Q] = { speed = 1950, delay = 0.265, range = 750, width = 85, collision = false, aoe = false, type = "cone"},
        [_W] = { speed = 1650, delay = 0.300, range = 700, width = 250, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 2100, delay = 0.219, range = 1000, width = 30, collision = false, aoe = false, type = "linear"}
    },
        ["Heimerdinger"] = {
        [_W] = { speed = 900, delay = 0.500, range = 1325, width = 100, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 2500, delay = 0.250, range = 970, width = 180, collision = false, aoe = true, type = "circular"}
    },
        ["Irelia"] = {
        [_R] = { speed = 1700, delay = 0.250, range = 1200, width = 10, collision = false, aoe = false, type = "linear"}
    },
        ["JarvanIV"] = {
        [_Q] = { speed = 1400, delay = 0.2, range = 770, width = 0, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 200, delay = 0.2, range = 850, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["Jinx"] = {
        [_W] = { speed = 3300, delay = 0.600, range = 1450, width = 70, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 887, delay = 0.500, range = 830, width = 0, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1700, delay = 0.600, range = 20000, width = 120, collision = false, aoe = true, type = "circular"}
    },
        ["Karma"] = {
        [_Q] = { speed = 1700, delay = 0.250, range = 1050, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Karthus"] = {
        [_Q] = { speed = 1750, delay = 0.25, range = 875, width = 140, collision = false, aoe = true, type = "circular"}
    },
        ["Kennen"] = {
        [_Q] = { speed = 1700, delay = 0.180, range = 1050, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["Khazix"] = {
        [_W] = { speed = 1700, delay = 0.25, range = 1025, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["KogMaw"] = {
        [_Q] = { speed = 1050, delay = 0.250, range = 1000, width = 10, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 500, delay = 0.250, range = 1000, width = 180, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1050, delay = 0.250, range = 2200, width = 225, collision = false, aoe = true, type = "circular"}
    },
        ["Leblanc"] = {
        [_E] = { speed = 1600, delay = 0.250, range = 960, width = 70, collision = true, aoe = false, type = "linear"}
    },
        ["LeeSin"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 1100, width = 100, collision = true, aoe = false, type = "linear"}
    },
        ["Leona"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 950, width = 110, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1500, delay = 0.250, range = 1200, width = 300, collision = false, aoe = true, type = "circular"}
    },
        ["Lissandra"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 725, width = 20, collision = true, aoe = false, type = "linear"}
    },
        ["Lucian"] = {
        [_W] = { speed = 1600, delay = 0.300, range = 1000, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Lulu"] = {
        [_Q] = { speed = 1450, delay = 0.250, range = 1000, width = 50, collision = false, aoe = false, type = "linear"}
    },
        ["Lux"] = {
        [_Q] = { speed = 1200, delay = 0.245, range = 1300, width = 50, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 1400, delay = 0.245, range = 1100, width = 0, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = math.huge, delay = 0.245, range = 3500, width = 0, collision = false, aoe = false, type = "linear"},
    },
        ["Malphite"] = {
        [_R] = { speed = 550, delay = 0.0, range = 1000, width = 300, collision = false, aoe = true, type = "circular"}
    },
        ["Malzahar"] = {
        [_Q] = { speed = 1170, delay = 0.600, range = 900, width = 50, collision = false, aoe = false, type = "linear"},
        [_W] = { speed = math.huge, delay = 0.125, range = 800, width = 250, collision = false, aoe = true, type = "circular"}
    },
        ["Mordekaiser"] = {
        [_E] = { speed = math.huge, delay = 0.25, range = 700, width = 0, collision = false, aoe = true, type = "cone"},
    },
        ["Morgana"] = {
        [_Q] = { speed = 1200, delay = 0.250, range = 1300, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Nami"] = {
        [_Q] = { speed = math.huge, delay = 0.8, range = 850, width = 0, collision = false, aoe = true, type = "circular"}
    },
        ["Nautilus"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1080, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Nidalee"] = {
        [_Q] = { speed = 1300, delay = 0.125, range = 1500, width = 60, collision = true, aoe = false, type = "linear"},
    },
        ["Nocturne"] = {
        [_Q] = { speed = 1400, delay = 0.250, range = 1125, width = 60, collision = false, aoe = false, type = "linear"}
    },
        ["Olaf"] = {
        [_Q] = { speed = 1600, delay = 0.25, range = 1000, width = 90, collision = false, aoe = false, type = "linear"}
    },
        ["Quinn"] = {
        [_Q] = { speed = 1550, delay = 0.25, range = 1050, width = 80, collision = true, aoe = false, type = "linear"}
    },
        ["Rengar"] = {
        [_E] = { speed = 1500, delay = 0.50, range = 1000, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Riven"] = {
        [_R] = { speed = 2200, delay = 0.5, range = 1100, width = 200, collision = false, aoe = false, type = "cone"}
    },
        ["Rumble"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 950, width = 80, collision = false, aoe = false, type = "linear"}
    },
        ["Sejuani"] = {
        [_R] = { speed = 1600, delay = 0.250, range = 1200, width = 110, collision = false, aoe = false, type = "linear"}
    },
        ["Shyvana"] = {
        [_E] = { speed = 1500, delay = 0.250, range = 925, width = 60, collision = false, aoe = false, type = "linear"}
    },
        ["Sivir"] = {
        [_Q] = { speed = 1330, delay = 0.250, range = 1075, width = 0, collision = false, aoe = false, type = "linear"}
    },
        ["Skarner"] = {
        [_E] = { speed = 1200, delay = 0.600, range = 350, width = 60, collision = false, aoe = false, type = "linear"}
    },
        ["Sona"] = {
        [_R] = { speed = 2400, delay = 0.240, range = 1000, width = 160, collision = true, aoe = false, type = "linear"}
    },
        ["Swain"] = {
        [_W] = { speed = math.huge, delay = 0.850, range = 900, width = 125, collision = false, aoe = true, type = "circular"}
    },
        ["Syndra"] = {
        [_Q] = { speed = math.huge, delay = 0.600, range = 790, width = 125, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 2500, delay = 0.250, range = 700, width = 45, collision = false, aoe = true, type = "cone"}
    },
        ["Thresh"] = {
        [_Q] = { speed = 1900, delay = 0.500, range = 1100, width = 65, collision = true, aoe = false, type = "linear"}
    },
        ["Twitch"] = {
        [_W] = {speed = 1750, delay = 0.250, range = 950, width = 275, collision = false, aoe = true, type = "circular"}
    },
        ["TwistedFate"] = {
        [_Q] = { speed = 1500, delay = 0.250, range = 1200, width = 80, collision = false, aoe = false, type = "cone"}
    },
        ["Urgot"] = {
        [_Q] = { speed = 1600, delay = 0.175, range = 1400, width = 80, collision = true, aoe = false, type = "linear"},
        [_E] = { speed = 1600, delay = 0.25, range = 920, width = 100, collision = false, aoe = true, type = "circular"}
    },
        ["Varus"] = {
       --[_Q] = { speed = 1850, delay = 0.1, range = 1475, width = 0},
        [_E] = { speed = 1500, delay = 0.25, range = 925, width = 240, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1950, delay = 0.5, range = 800, width = 100, collision = false, aoe = false, type = "linear"}
    },
        ["Veigar"] = {
        [_Q] = { speed = 1200, delay = 0.25, range = 875, width = 75, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 900, delay = 1.25, range = 900, width = 110, collision = false, aoe = true, type = "circular"}
    },
        ["Viktor"] = {
        [_W] = { speed = 750, delay = 0.6, range = 700, width = 125, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1200, delay = 0.25, range = 1200, width = 0, collision = false, aoe = false, type = "linear"},
        [_R] = { speed = 1000, delay = 0.25, range = 700, width = 0, collision = false, aoe = true, type = "circular"},
    },
        ["Velkoz"] = {
        [_Q] = { speed = 1300, delay = 0.066, range = 1050, width = 50, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 1700, delay = 0.064, range = 1050, width = 80, collision = false, aoe = false, type = "linear"},
        [_E] = { speed = 1500, delay = 0.333, range = 850, width = 120, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = math.huge, delay = 0.333, range = 1550, width = 50, collision = false, aoe = false, type = "linear"}
    },    
        ["Xerath"] = {
        [_W] = { speed = math.huge, delay = 0.5, range = 1100, width = 325, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1600, delay = 0.25, range = 1050, width = 125, collision = true, aoe = false, type = "linear"},
        [_R] = { speed = 300, delay = 0.25, range = 5600, width = 265, collision = false, aoe = true, type = "circular"}
    },
        ["Yasuo"] = {
        [_Q] =  { speed = math.huge, delay = 250, range = 475, width = 40, collision = false, aoe = false, type = "linear"},
    },
        ["Zac"] = {
        [_Q] = { speed = 2500, delay = 0.110, range = 500, width = 110, collision = false, aoe = false, type = "linear"},
    },
        ["Zed"] = {
        [_Q] = { speed = 1700, delay = 0.25, range = 925, width = 50, collision = false, aoe = false, type = "linear"},
    },
        ["Ziggs"] = {
        [_Q] = { speed = 1750, delay = 0.5, range = 1400, width = 80, collision = true, aoe = false, type = "linear"},
        [_W] = { speed = 1800, delay = 0.25, range = 970, width = 275, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 2700, delay = 0.8, range = 900, width = 235, collision = false, aoe = true, type = "circular"},
        [_R] = { speed = 1750, delay = 0.1014, range = 5300, width = 525, collision = false, aoe = true, type = "circular"},
    },
        ["Zilean"] = {
        [_Q] = { speed = math.huge, delay = 0.5, range = 900, width = 150, collision = false, aoe = true, type = "circular"},
    },
        ["Zyra"] = {
        [_Q] = { speed = math.huge, delay = 0.7, range = 800, width = 85, collision = false, aoe = true, type = "circular"},
        [_E] = { speed = 1150, delay = 0.25, range = 1100, width = 70, collision = false, aoe = false, type = "linear"}
    }
}
--[[ Skillshot list end ]]--

--[[ Auto updater start ]]--
local version = 0.31
local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/nebelwolfi/scripts/master/Aimbot.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Aimbot.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Aimbot:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTO_UPDATE then
  local ServerData = GetWebResult(UPDATE_HOST, "/nebelwolfi/scripts/master/Aimbot.version")
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
--[[ Auto updater end ]]--

--[[ Libraries start ]]--
if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
if VIP_USER and FileExist(LIB_PATH .. "/Prodiction.lua") then
  require("Prodiction")
  prodstatus = true
end
if VIP_USER and FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac") then
  require "DivinePred"
  DP = DivinePred() 
end
--[[ Libraries end ]]--

--[[ Encryption start ]]--
if not Champs[myHero.charName] then return end -- not supported :(
HookPackets() -- Credits to iCreative
local data = Champs[myHero.charName]
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local Target 
local ts2 = TargetSelector(TARGET_NEAR_MOUSE, 1500, DAMAGE_MAGIC, true) -- make these local
local str = { [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" }
--local key = { [_Q] = "Y", [_W] = "X", [_E] = "C", [_R] = "V" } soon
local ConfigType = SCRIPT_PARAM_ONKEYDOWN
local predictions = {}
local toCast = {false, false, false, false}
local toAim = {false, false, false, false}

function OnLoad()

  Config = scriptConfig("Aimbot v"..version, "Aimbot v"..version)
  
  
  Config:addSubMenu("[Prediction]: Settings", "prConfig")
  Config.prConfig:addParam("pc", "Use Packets To Cast Spells", SCRIPT_PARAM_ONOFF, false)
  Config.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.prConfig:addParam("hitchance", "Accuracy", SCRIPT_PARAM_SLICE, 2, 0, 3, 0)
  Config.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  local predToUse = {"", "", ""}
  if FileExist(LIB_PATH.."VPrediction.lua") then predToUse[1] = "VPrediction" end
  if VIP_USER then
    if FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac") then predToUse[3] = "DivinePred" end
    if prodstatus then predToUse[2] = "Prodiction" end
  end
  if predToUse == {"", "", ""} then PrintChat("PLEASE DOWNLOAD A PREDICTION!") return end
  Config.prConfig:addParam("pro",  "Type of prediction", SCRIPT_PARAM_LIST, 1, predToUse)


  Config:addSubMenu("Supported skills", "skConfig")
  for i, spell in pairs(data) do
    Config.skConfig:addParam(str[i], "", ConfigType, false, string.byte(str[i]))
    predictions[str[i]] = {spell.range, spell.speed, spell.delay, spell.width, i}
    toAim[i] = true
  end
  
  --Config:addSubMenu("Additional keys", "kConfig")
  --for i, spell in pairs(data) do
  --  Config.kConfig:addParam(key[i], "Aim "..str[i], ConfigType, false, string.byte(key[i]))
  --end soon
  
  
  Config:addTS(ts2)
  Config:addParam("tog", "Aimbot on/off", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("T"))
  Config:addParam("rangeoffset", "Range Decrease Offset", SCRIPT_PARAM_SLICE, 0, 0, 200, 0)
  
  Config:permaShow("tog")
  ts2.name = "Target"
end

function OnTick()
  if Config.tog then
      Target = GetCustomTarget()
      if Target == nil then return end
      for i, spell in pairs(data) do
          if toCast[i] == true and myHero:CanUseSpell(i) then
            if Config.prConfig.pro == 1 then -- VPrediction
              if spell.type == "linear" then
                if spell.aoe then
                    local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(Target, spell.delay, spell.width, spell.range, spell.speed, myHero)
                else
                    local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, spell.delay, spell.width, spell.range, spell.speed, myHero, spell.collision)
                end
              elseif spell.type == "circular" then
                if spell.aoe then
                    local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(Target, spell.delay, spell.width, spell.range, spell.speed, myHero)
                else
                    local CastPosition, HitChance, Position = VP:GetCircularCastPosition(Target, spell.delay, spell.width, spell.range, spell.speed, myHero, spell.collision)
                end
              elseif spell.type == "cone" then
                if spell.aoe then
                    local CastPosition, HitChance, Position = VP:GetConeAOECastPosition(Target, spell.delay, spell.width, spell.range, spell.speed, myHero)
                else
                    local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, spell.delay, spell.width, spell.range, spell.speed, myHero, spell.collision)
                end
              end
              if HitChance >= Config.prConfig.hitchance then
                  CCastSpell(i, CastPosition.x, CastPosition.z)
              elseif HitChance >= Config.prConfig.hitchance-1 then
                  CCastSpell(i, CastPosition.x, CastPosition.z)
              else
                  CCastSpell(i, mousePos.x, mousePos.z)
              end toCast[i] = false
            elseif Config.prConfig.pro == 2 and VIP_USER and prodstatus then -- Prodiction
              local Position, info = Prodiction.GetPrediction(Target, spell.range, spell.speed, spell.delay, spell.width, myHero)
              if Position ~= nil and not info.mCollision() then
                  CCastSpell(i, Position.x, Position.z)
              else
                  CCastSpell(i, mousePos.x, mousePos.z)
              end toCast[i] = false
            elseif Config.prConfig.pro == 3 and VIP_USER then -- DivinePrediction
              local unit = DPTarget(Target)
              local col = spell.collision and 0 or math.huge
              if IsVeigarLux(i) then col = 1 end
              if spell.type == "linear" then
                Spell = LineSS(spell.speed, spell.range, spell.width, spell.delay * 1000, col)
              elseif spell.type == "circular" then
                Spell = CircleSS(spell.speed, spell.range, spell.width, spell.delay * 1000, col)
              elseif spell.type == "cone" then
                Spell = ConeSS(spell.speed, spell.range, spell.width, spell.delay * 1000, col)
              end
              local State, Position, perc = DP:predict(unit, Spell, 2)
              if State == SkillShot.STATUS.SUCCESS_HIT then 
                  CCastSpell(i, Position.x, Position.z)
              else
                  CCastSpell(i, mousePos.x, mousePos.z)
              end toCast[i] = false
            end
          end
      end 
  end
end   
          -- NOW DEPRECATED! TODO: remove..
          --if (Config.throw or Config[str[i]] or Config[key[i]]) and myHero:CanUseSpell(i) and IsLeeThresh() then -- move spell ready check to top
          --    toCast[i] = true
          --    if HitChance >= Config.prConfig.hitchance and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CCastSpell(i, CastPosition.x, CastPosition.z) 
          --    toCast[i] = false end   
          --else
          --    local CastPosition, HitChance, Position = prediction:GetPrediction(Target, spell.delay, spell.width, spell.range, spell.speed, myHero, spell.type, spell.collision, spell.aoe)
          --    if HitChance >= Config.prConfig.hitchance and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CCastSpell(i, CastPosition.x, CastPosition.z)
          --    elseif HitChance >= Config.prConfig.hitchance-1 and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CCastSpell(i, CastPosition.x, CastPosition.z) 
          --    else CCastSpell(i, mousePos.x, mousePos.z) end
              --toCast[i] = false 

function OnWndMsg(msg, key)
   if msg == KEY_UP and key == GetKey("Q") and toAim[0] then
     toCast[0] = false
   elseif msg == KEY_UP and key == GetKey("W") and toAim[1] then 
     toCast[1] = false
   elseif msg == KEY_UP and key == GetKey("E") and toAim[2] then 
     toCast[2] = false
   elseif msg == KEY_UP and key == GetKey("R") and toAim[3] then
     toCast[3] = false
   end
end

function IsVeigarLux(i)
  if myHero.charName == 'Lux' then
    if i == 1 then
      return true
    else
      return false
    end
  elseif myHero.charName == 'Veigar' then
    if i == 1 then
      return true
    else
      return false
    end 
  else
    return false
  end
end

function OnSendPacket(p)
  Target = GetCustomTarget()
  if Config.tog then
    if p.header == 0x00E9 then -- Credits to PewPewPew
      p.pos=27
      local opc = p:Decode1()
      if Target ~= nil then
        if opc == 0x02 and not toCast[0] and toAim[0] then 
          p:Block()
          p.skip(p, 1)
          toCast[0] = true
        elseif opc == 0xD8 and not toCast[1] and toAim[1] then 
          p:Block()
          p.skip(p, 1)
          toCast[1] = true
        elseif opc == 0xB3 and not toCast[2] and toAim[2] then 
          p:Block()
          p.skip(p, 1)
          toCast[2] = true
        elseif opc == 0xE7 and not toCast[3] and toAim[3] then
          p:Block()
          p.skip(p, 1)
          toCast[3] = true
        end
      end
    end
  end
end

--Credit Trees
function GetCustomTarget()
    ts2:update()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    --print('tstarget called')
    return ts2.target
end
--End Credit Trees

--[[ Packet Cast Helper ]]--
function CCastSpell(Spell, xPos, zPos)
  if VIP_USER and Config.prConfig.pc then
    Packet("S_CAST", {spellId = Spell, fromX = xPos, fromY = zPos, toX = xPos, toY = zPos}):send()
  else
    CastSpell(Spell, xPos, zPos)
  end
end