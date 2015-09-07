local IOWversion = 1

class "InspiredsOrbWalker"

function InspiredsOrbWalker:__init()
  self.lastAttack = 0
  self.lastCooldown = 0
  self.attacksEnabled = true
  self.movementEnabled = true
  self.altAttacks = Set { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3" }
  self.resetAttacks = Set { "dariusnoxiantacticsonh", "fioraflurry", "garenq", "hecarimrapidslash", "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak", "luciane", "lucianq", "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq", "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow", "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw", "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie", "volibearq", "xenzhaocombotarget", "yorickspectral", "reksaiq", "riventricleave", "itemtitanichydracleave", "itemtiamatcleave" }
  self.rangeCircle = GoS:Circle(GoS.White).Attach(myHero, GetRange(myHero)+GetHitBox(myHero))
  self:MakeMenu()
  OnLoop(function() self:Loop() end)
  OnProcessSpell(function(x,y) self:ProcessSpell(x,y) end)
  return self
end

function Set(list)
  local set = {}
  for _, l in ipairs(list) do 
    set[l] = true 
  end
  return set
end

function msg(x)
  print(x, "InspiredsOrbWalker")
end

function InspiredsOrbWalker:MakeMenu()
  self.Config = Menu("Inspired'sOrbWalker", "IOW")
  self.Config:SubMenu("h", "Hotkeys")
  self.Config.h:Key("Combo", "Combo", 32)
  self.Config.h:Key("Harass", "Harass", string.byte("C"))
  self.Config.h:Key("LastHit", "LastHit", string.byte("X"))
  self.Config.h:Key("LaneClear", "LaneClear", string.byte("V"))
  self.Config:Boolean("items", "Use Items", true)
  GoS:DelayAction(function()
    if GetRange(myHero) < 450 then
      self.Config:Boolean("sticky", "Stick to Target", true)
    end
    self.Config:Boolean("drawcircle", "Autoattack Circle", true)
    self.Config:Info("space", "")
    self.Config:Info("version", "Version: v"..IOWversion)
    self.loaded = true
    msg("Loaded!")
  end, 333)
end

function InspiredsOrbWalker:Mode()
  if self.Config.h.Combo:Value() then
    return "Combo"
  elseif self.Config.h.Harass:Value() then
    return "Harass"
  elseif self.Config.h.LastHit:Value() then
    return "LastHit"
  elseif self.Config.h.LaneClear:Value() then
    return "LaneClear"
  else
    return ""
  end
end

function InspiredsOrbWalker:Loop()
  if not self.loaded then return end
  self.rangeCircle.Draw(self.Config.drawcircle:Value())
  self.myRange = GetRange(myHero)+GetHitBox(myHero)+(self.Target and GetHitBox(self.Target) or GetHitBox(myHero))
  self.Target = self:GetTarget()
  self:Orb(self:GetTarget())
end

function InspiredsOrbWalker:GetTarget()
  if self.Config.h.Combo:Value() then
    return GoS:GetTarget(self.myRange, DAMAGE_PHYSICAL)
  elseif self.Config.h.Harass:Value() then
    for i=1, minionManager.maxObjects do
      local minion = minionManager.objects[i]
      if minion and IsObjectAlive(minion) and GetTeam(minion) ~= GetTeam(myHero) and GoS:IsInDistance(minion, self.myRange) then
        local health = GoS:PredictHealth(minion, 1000*GoS:GetDistance(minion)/self:GetProjectileSpeed(myHero) + GetWindUp(myHero)*1000)
        if health < self:GetDmg(minion) and health > 0 then
          return minion
        end
      end
    end
    return GoS:GetTarget(self.myRange, DAMAGE_PHYSICAL)
  elseif self.Config.h.LaneClear:Value() then
    local highestMinion, highestHealth = nil, 0
    for i=1, minionManager.maxObjects do
      local minion = minionManager.objects[i]
      if minion and IsObjectAlive(minion) and GetTeam(minion) ~= GetTeam(myHero) and GoS:IsInDistance(minion, self.myRange) then
        local health = GoS:PredictHealth(minion, 1000*GoS:GetDistance(minion)/self:GetProjectileSpeed(myHero) + GetWindUp(myHero)*1000)
        if not highestMinion then highestMinion = minion highestHealth = health end
        if health > 0 then
          if health < self:GetDmg(minion) then
            return minion
          elseif health > highestHealth then
            highestHealth = health 
            highestMinion = minion
          end
        end
      end
    end
    return highestMinion
  elseif self.Config.h.LastHit:Value() then
    for i=1, minionManager.maxObjects do
      local minion = minionManager.objects[i]
      if minion and IsObjectAlive(minion) and GetTeam(minion) ~= GetTeam(myHero) and GoS:IsInDistance(minion, self.myRange) then
        local health = GoS:PredictHealth(minion, 1000*GoS:GetDistance(minion)/self:GetProjectileSpeed(myHero) + GetWindUp(myHero)*1000)
        if health < self:GetDmg(minion) and health > 0 then
          return minion
        end
      end
    end
  end
end

function InspiredsOrbWalker:GetDmg(to)
  return GoS:CalcDamage(myHero, to, GetBonusDmg(myHero)+GetBaseDamage(myHero))
end
  
function InspiredsOrbWalker:GetProjectileSpeed(unit)
  return self.projectilespeeds[GetObjectName(unit)] and self.projectilespeeds[GetObjectName(unit)] or math.huge
end

function InspiredsOrbWalker:Orb(target)
  if self:DoAttack() and GoS:ValidTarget(target) and self.lastAttack+self.lastCooldown < GetTickCount() then
    AttackUnit(target)
  elseif self:DoWalk() and self.lastAttack+GetWindUp(myHero)*1000 < GetTickCount() then
    MoveToXYZ(GetMousePos())
  end
end

function InspiredsOrbWalker:DoAttack()
  return (self.Config.h.Combo:Value() or self.Config.h.Harass:Value() or self.Config.h.LaneClear:Value() or self.Config.h.LastHit:Value()) and self.attacksEnabled
end

function InspiredsOrbWalker:DoWalk()
  return (self.Config.h.Combo:Value() or self.Config.h.Harass:Value() or self.Config.h.LaneClear:Value() or self.Config.h.LastHit:Value()) and self.movementEnabled
end

function InspiredsOrbWalker:ProcessSpell(unit, spell)
  if unit and unit == myHero and spell and spell.name then
    if spell.name:lower():find("attack") or self.altAttacks[spell.name] then
      self.lastAttack = GetTickCount()
      self.lastCooldown = spell.animationTime*1000
    end
    if self.resetAttacks[spell.name] then
      self.lastAttack = 0
    end
  end
end

function InspiredsOrbWalker:EnableAutoAttacks()
  self.attacksEnabled = true
end

function InspiredsOrbWalker:DisableAutoAttacks()
  self.attacksEnabled = false
end

function InspiredsOrbWalker:EnableMovement()
  self.movementEnabled = true
end

function InspiredsOrbWalker:DisableMovement()
  self.movementEnabled = false
end

function InspiredsOrbWalker:EnableOrbwalking()
  self.attacksEnabled = true
  self.movementEnabled = true
end

function InspiredsOrbWalker:DisableOrbwalking()
  self.attacksEnabled = false
  self.movementEnabled = false
end

_G.IOW = InspiredsOrbWalker()
