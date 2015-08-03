local myHero = GetMyHero()
local myTeam = GetTeam(myHero)
local myHeroName = GetObjectName(myHero)
local wardJumpChamps = {["Katarina"] = true, ["Jax"] = true, ["LeeSin"] = true}

if wardJumpChamps[myHeroName] then

  local wardTable = {}
  local wjspell = myHeroName == "LeeSin" and _W or myHeroName == "Katarina" and _E or myHeroName == "Jax" and _Q or nil
  local wjrange = wjspell == _W and 600 or 700
  local wardIDs = {3166, 3361, 3362, 3340, 3350, 2050, 2045, 2049, 2044, 2043}
  local casted, jumped, doObjects = false, false, 0

  WJConfig = scriptConfig("IWadJump", "WardJump.lua")
  WJConfig.addParam("D", "Draw Pos", SCRIPT_PARAM_ONOFF, true)
  WJConfig.addParam("WJ", "Jump", SCRIPT_PARAM_KEYDOWN, string.byte("G"))

  OnObjectLoop(function(obj, myHero)
    if doObjects > GetTickCount() then return end
    local objName = GetObjectBaseName(obj)
    if GetTeam(obj) == myTeam and (objName:lower():find("ward") or objName:lower():find("trinkettotem")) then
      wardTable[GetNetworkID(obj)] = obj
    end
  end)

  OnLoop(function(myHero)
    if doObjects < GetTickCount() then
      doObjects = GetTickCount() + 500
    end
    if WJConfig.D then
      local pos = Vector(myHero) + Vector(Vector(GetMousePos()) - Vector(myHero)):normalized() * wjrange
      Circle(pos,150):draw()
    end
    if WJConfig.WJ then
      WardJump()
    end
  end)

  function WardJump()
    if casted and jumped then casted, jumped = false, false
    elseif CanUseSpell(myHero, wjspell) then
      local pos = Vector(myHero) + Vector(Vector(GetMousePos()) - Vector(myHero)):normalized() * wjrange
      if Jump(pos) then return end
      slot = GetWardSlot()
      if not slot then return end
      CastSkillShot(slot, pos.x, pos.y, pos.z)
      casted = true
    end
  end

  function Jump(pos)
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