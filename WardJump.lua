local myHero = GetMyHero()
local myTeam = GetTeam(myHero)
local myHeroName = GetObjectName(myHero)
local wardJumpChamps = {["Katarina"] = true, ["Jax"] = true, ["LeeSin"] = true}

if wardJumpChamps[myHeroName] then

  local wardTable = {}
  local wjspell = myHeroName == "LeeSin" and _W or myHeroName == "Katarina" and _E or myHeroName == "Jax" and _Q or nil
  local wjrange = wjspell == _W and 600 or 700
  local wardIDs = {3166, 3361, 3362, 3340, 3350, 2050, 2045, 2049, 2044, 2043}
  local casted, jumped = false, false

  WJConfig = Menu("IWardJump", "WardJump.lua")
  WJConfig:Boolean("D", "Draw Pos", true)
  WJConfig:Key("WJ", "Jump", string.byte("G"))

  OnObjectLoop(function(obj, myHero)
    if not WJConfig.WJ:Value() then return end
    local objName = GetObjectBaseName(obj)
    if GetTeam(obj) == myTeam and (objName:lower():find("ward") or objName:lower():find("trinkettotem")) then
      wardTable[GetNetworkID(obj)] = obj
    end
  end)

  OnLoop(function(myHero)
    if WJConfig.D:Value() then
      local pos = Vector(myHero) + Vector(Vector(GetMousePos()) - Vector(myHero)):normalized() * wjrange
      Circle(pos,150):draw()
    end
    if WJConfig.WJ:Value() or casted then
      WardJump()
    end
  end)

  function WardJump()
    if casted and jumped then casted, jumped = false, false
    elseif CanUseSpell(myHero, wjspell) == READY then
      local pos = Vector(myHero) + Vector(Vector(GetMousePos()) - Vector(myHero)):normalized() * wjrange
      if Jump(pos) then return end
      slot = GetWardSlot()
      if not slot or casted then return end
      CastSkillShot(slot, pos.x, pos.y, pos.z)
      casted = true
    end
  end

  function Jump(pos)
    for i, minion in pairs(GetAllMinions(MINION_ALLY)) do
      if GetDistanceSqr(GetOrigin(minion), pos) <= 250*250 then
        CastTargetSpell(minion, wjspell)
        jumped = true
        return true
      end
    end
    for i, ward in pairs(wardTable) do
      if GetDistanceSqr(GetOrigin(ward), pos) <= 250*250 then
        CastTargetSpell(ward, wjspell)
        jumped = true
        return true
      end
    end
  end

  function GetWardSlot()
    for _, id in pairs(wardIDs) do
      local slot = GetItemSlot(myHero, id)
      if slot > 0 and CanUseSpell(myHero, slot) == READY then
        return slot
      end
    end
    return nil
  end

end
