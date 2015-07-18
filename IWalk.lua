require('Inspired')

orbTable = { lastAA = 0, windUp = 13.37, animation = 13.37 }

function AfterObjectLoopEvent(myHero)
    local myRange = GetRange(GetMyHero())
    local unit = GetTarget(myRange)
    if KeyIsDown(0x20) then
        if ValidTarget(unit, myRange) and GetTickCount() > orbTable.lastAA + orbTable.animation then
            AttackUnit(unit)
        elseif GetTickCount() > orbTable.lastAA + orbTable.windUp then
            local movePos = GenerateMovePos()
            MoveToXYZ(movePos.x, movePos.y, movePos.z)
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
