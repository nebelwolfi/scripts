if myHero.charName ~= "Nidalee" then return end

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

local Q = {name = "Javelin Toss", range = 1500, speed = 1300, delay = 0.125, width = 37, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local QTargetSelector = TargetSelector(TARGET_NEAR_MOUSE, Q.range, DAMAGE_MAGIC)


function OnLoad()
  Config = scriptConfig("Nida Q Helper ", " Nida Q Helper ")
  Config:addSubMenu("[Misc]: Settings", "prConfig")
  Config.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
  Config.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"})
  Config.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.prConfig:addParam("mana", "Min mana for harass:", SCRIPT_PARAM_SLICE, 30, 0, 101, 0)
  Config:addParam("throwQh", "Throw Q (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
  Config:addParam("throwQ", "Throw Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
  Config:permaShow("throwQh")
  Config:addTS(QTargetSelector)
  print("Nida Q Helper loaded!")
end

function GetCustomTarget()
  TargetSelector:update() 
  if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
    return _G.MMA_Target
  end
  if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then 
    return _G.AutoCarry.Attack_Crosshair.target 
  end
  return TargetSelector.target
end


function Check()
  QTargetSelector:update()
  if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
    QCel = SelectedTarget
  else
    QCel = QTargetSelector.target
  end
end

function OnTick()
  Check()
  if Config.throwQh and myHero.mana >= Config.prConfig.mana and not recall then
    if QCel ~= nil then
      ThrowQ(QCel)
    end
  end
  if Config.throwQ and not recall then
    if QCel ~= nil then
      ThrowQ(QCel)
    end
  end
end

function ThrowQ(unit)
  if unit and Q.Ready() and ValidTarget(unit) then
    if Config.prConfig.pro == 1 then
      local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, true)
      if HitChance >= 2 then
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.prConfig.pro == 2 and VIP_USER and prodstatus then
      local Position, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
      if Position ~= nil and not info.mCollision() then
        if VIP_USER and Config.prConfig.pc then
          Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_Q, Position.x, Position.z)
        end 
      end
    end
    if Config.prConfig.pro == 3 and VIP_USER then
      local unit = DPTarget(unit)
      local NidaQ = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, 0)
      local State, Position, perc = DP:predict(unit, NidaQ, 2)
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