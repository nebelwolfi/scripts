require('Inspired')

orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }
myRange = GetRange(GetMyHero())
aaResetTable = ({ ["Diana"] = {_E}, ["Darius"] = {_W}, ["Hecarim"] = {_Q}, ["Jax"] = {_W}, ["Jayce"] = {_W}, ["Rengar"] = {_Q}, ["Riven"] = {_W}, ["Sivir"] = {_W}, ["Talon"] = {_Q} })[GetObjectName(GetMyHero())]
aaResetTable2 = ({ ["Diana"] = {_Q}, ["Kalista"] = {_Q}, ["Riven"] = {_Q}, ["Talon"] = {_W}, ["Yasuo"] = {_Q} })[GetObjectName(GetMyHero())]
aaResetTable3 = ({ ["Jax"] = {_Q}, ["Lucian"] = {_Q}, ["Teemo"] = {_Q}, ["Tristana"] = {_E}, ["Yasuo"] = {_R} })[GetObjectName(GetMyHero())]
aaResetTable4 = ({ ["Lucian"] = {_E},  ["Vayne"] = {_Q} })[GetObjectName(GetMyHero())]

function AfterObjectLoopEvent(myHero)
    myRange = GetRange(GetMyHero())
    local unit = GetTarget(myRange)
    if KeyIsDown(0x20) then
        if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
            AttackUnit(unit)
        elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
        	if ValidTarget(unit, myRange) and GetTickCount() < orbTable.lastAA + orbTable.animation and WindUp(unit) then orbTable.lastAA = 0 end
        	if GetDistanceSqr(GetMousePos()) > 75*75 then
	            local movePos = GenerateMovePos()
	            MoveToXYZ(movePos.x, movePos.y, movePos.z)
	        end
        end
    end
end

function OnProcessSpell(unit, spell)
    if unit and unit == myHero and spell and spell.name:lower():find("attack") then
        orbTable.lastAA = GetTickCount()
        orbTable.windUp = spell.windUpTime * 1000
        orbTable.animation = spell.animationTime * 1000
    end
end

function WindUp(unit)
    if ValidTarget(unit) then
      	local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
        if aaResetTable then
          for _,k in pairs(aaResetTable) do
            if CanUseSpell(myHero, k) and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
              orbTable.lastAA = 0
              CastTargetSpell(myHero, k)
              return true
            end
          end
        end
        if aaResetTable2 then
          for _,k in pairs(aaResetTable2) do
            if CanUseSpell(myHero, k) and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
              orbTable.lastAA = 0
              CastSkillShot(k, GetOrigin(unit).x, GetOrigin(unit).y, GetOrigin(unit).z)
              return true
            end
          end
        end
        if aaResetTable3 then
          for _,k in pairs(aaResetTable3) do
            if CanUseSpell(myHero, k) and GetDistanceSqr(GetOrigin(unit)) < myRange * myRange then
              orbTable.lastAA = 0
              CastTargetSpell(unit, k)
              return true
            end
          end
        end
        if aaResetTable4 then
          for _,k in pairs(aaResetTable4) do
            if CanUseSpell(myHero, k) then
              orbTable.lastAA = 0
              local movePos = GenerateMovePos()
              CastSkillShot(k, movePos.x, movePos.y, movePos.z)
              return true
            end
          end
        end
    end
    return false
end
