local version = 0.01 -- REMEMBER: UPDATE .version FILE ASWELL FOR IN-GAME PUSH!
local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/nebelwolfi/scripts/master/src/Aimbot.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Aimbot.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Lulu:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTO_UPDATE then
  local ServerData = GetWebResult(UPDATE_HOST, "/nebelwolfi/scripts/master/src/Aimbot.version")
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

if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
if VIP_USER and FileExist(LIB_PATH .. "/Prodiction.lua") then
  require("Prodiction")
  prodstatus = true
end
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
  require "DivinePred" 
  DP = DivinePred()
end

--[[ Packet Cast Helpers ]]--
function CastQ(unit)
  if Q.Ready() then
    if VIP_USER and MenuLulu.prConfig.pc then
      Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
    else
      CastSpell(_W, unit)
    end
  end
end
function CastW(unit)
  if W.Ready() then
    if VIP_USER and MenuLulu.prConfig.pc then
      Packet("S_CAST", {spellId = _W, targetNetworkId = unit.networkID}):send()
    else
      CastSpell(_W, unit)
    end
  end
end
function CastE(unit)
  if E.Ready() then
    if VIP_USER and MenuLulu.prConfig.pc then
      Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
    else
      CastSpell(_E, unit)
    end
  end
end
function CastR(unit)
  if R.Ready() then
    if VIP_USER and MenuLulu.prConfig.pc then
      Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
    else
      CastSpell(_R, unit)
    end
  end
end