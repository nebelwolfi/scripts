local version = 0.01 -- REMEMBER: UPDATE .version FILE ASWELL FOR IN-GAME PUSH!
--[[
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
]]--
if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
  require "DivinePred" 
  DP = DivinePred()
end

function OnLoad()
  Config = scriptConfig("Aimbot v"..version, "Aimbot v"..version)
  Config:addSubMenu("[Prediction]: Settings", "prConfig")
  Config.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
  Config.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","DivinePred"}) 
  Config:addSubMenu("[Skills]: Settings", "skConfig")
  Config.skConfig:addParam("scq", "Cast Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
  Config.skConfig:addParam("scw", "Cast W", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
  Config.skConfig:addParam("sce", "Cast E", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
  Config.skConfig:addParam("scr", "Cast R", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
  Config:addParam("tog", "Aimbot on/off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
  TargetSelector = TargetSelector(TARGET_LOW_HP_PRIORITY, myHero.range+65, DAMAGE_MAGIC)
  TargetSelector.name = "AimMe"
  Config:addTS(TargetSelector)
  PrintChat("Aimbot v"..version.." loaded!")
end

--[[ Packet Cast Helpers ]]--
function CastQ(unit)
  if Q.Ready() then
    if Config.prConfig.pro == 1 then
      local CastPosition, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, from)
      if HitChance >= 2 then
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.prConfig.pro == 2 and VIP_USER then
      local unit = DPTarget(unit)
      local LuluQ = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, math.huge)
      local State, Position, perc = DP:predict(unit, ChampQ, 2, Vector(from))
      if State == SkillShot.STATUS.SUCCESS_HIT then 
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_Q, Position.x, Position.z)
        end
      end
    end
  end
end
function CastW(unit)
  if W.Ready() then
    if Config.prConfig.pro == 1 then
      local CastPosition, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, from)
      if HitChance >= 2 then
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_W, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.prConfig.pro == 2 and VIP_USER then
      local unit = DPTarget(unit)
      local ChampW = LineSS(W.speed, W.range, W.width, W.delay*1000, math.huge)
      local State, Position, perc = DP:predict(unit, ChampW, 2, Vector(from))
      if State == SkillShot.STATUS.SUCCESS_HIT then 
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_W, Position.x, Position.z)
        end
      end
    end
  end
end
function CastE(unit)
  if Q.Ready() then
    if Config.prConfig.pro == 1 then
      local CastPosition, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, from)
      if HitChance >= 2 then
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_E, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.prConfig.pro == 2 and VIP_USER then
      local unit = DPTarget(unit)
      local ChampE = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, math.huge)
      local State, Position, perc = DP:predict(unit, ChampE, 2, Vector(from))
      if State == SkillShot.STATUS.SUCCESS_HIT then 
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_E, Position.x, Position.z)
        end
      end
    end
  end
end
function CastR(unit)
  if Q.Ready() then
    if Config.prConfig.pro == 1 then
      local CastPosition, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, from)
      if HitChance >= 2 then
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.prConfig.pro == 2 and VIP_USER then
      local unit = DPTarget(unit)
      local ChampR = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, math.huge)
      local State, Position, perc = DP:predict(unit, ChampR, 2, Vector(from))
      if State == SkillShot.STATUS.SUCCESS_HIT then 
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_Q, Position.x, Position.z)
        end
      end
    end
  end
end