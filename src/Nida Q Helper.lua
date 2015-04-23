--[[
 _   _  _      _           _____    _   _        _                    
| \ | |(_)    | |         |  _  |  | | | |      | |                   
|  \| | _   __| |  __ _   | | | |  | |_| |  ___ | | _ __    ___  _ __ 
| . ` || | / _` | / _` |  | | | |  |  _  | / _ \| || '_ \  / _ \| '__|
| |\  || || (_| || (_| |  \ \/' /  | | | ||  __/| || |_) ||  __/| |   
\_| \_/|_| \__,_| \__,_|   \_/\_\  \_| |_/ \___||_|| .__/  \___||_|   
                                                   | |                
                                                   |_|                
]]--
if myHero.charName ~= "Nidalee" then return end

if FileExist(LIB_PATH .. "/VPrediction.lua") then
  require("VPrediction")
  VP = VPrediction()
end
if FileExist(LIB_PATH .. "/HPrediction.lua") then
  require("HPrediction")
  HP = HPrediction()
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
  Config:addSubMenu("[Misc]: Settings", "misc")
  Config.misc:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
  Config.misc:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.misc:addParam("pro", "Prediction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","HPrediction","Prodiction","DivinePred"})
  Config.misc:addParam("hc", "Hitchance:", SCRIPT_PARAM_SLICE, 2, 0, 3, 1)
  Config.misc:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
  Config.misc:addParam("mana", "Min mana for harass:", SCRIPT_PARAM_SLICE, 30, 0, 101, 0)
  Config:addParam("throwQh", "Throw Q (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
  Config:addParam("throwQ", "Throw Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
  Config:permaShow("throwQh")
  Config:addTS(QTargetSelector)
  Spell_Q.collisionM['Nidalee'] = true
  Spell_Q.collisionH['Nidalee'] = true --or false
  Spell_Q.delay['Nidalee'] = Q.delay
  Spell_Q.range['Nidalee'] = Q.range
  Spell_Q.speed['Nidalee'] = Q.speed
  Spell_Q.type['Nidalee'] = "DelayLine"
  Spell_Q.width['Nidalee'] = Q.width
  print("Nida Q Helper loaded!")
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
  if Config.throwQh and myHero.mana >= Config.misc.mana and not recall then
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
    if Config.misc.pro == 1 then
      local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, true)
      if HitChance >= Config.misc.hc then
        if VIP_USER and Config.misc.pc then
          Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.misc.pro == 2 then
      PrintChat("Attempt to aim!")
      local CastPosition, HitChance = HP:GetPredict("Q", unit, myHero)
      PrintChat("HitChance "..HitChance)
      if HitChance >= Config.misc.hc then
        if VIP_USER and Config.misc.pc then
          Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
        else
          CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
      end
    end
    if Config.misc.pro == 3 and VIP_USER and prodstatus then
      local Position, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
      if Position ~= nil and not info.mCollision() then
        if VIP_USER and Config.misc.pc then
          Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_Q, Position.x, Position.z)
        end 
      end
    end
    if Config.misc.pro == 4 and VIP_USER then
      local unit = DPTarget(unit)
      local NidaQ = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, 0)
      local State, Position, perc = DP:predict(unit, NidaQ, Config.misc.hc)
      if State == SkillShot.STATUS.SUCCESS_HIT then 
        if VIP_USER and Config.misc.pc then
          Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
        else
          CastSpell(_Q, Position.x, Position.z)
        end
      end
    end
  end
end