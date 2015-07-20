local menuTable = {}
local currentPos = {x = 150, y = 250}

function DrawMenu()
  if KeyIsDown(0x10) then
    local mPos  = GetMousePos()
    local mmPos = WorldToScreen(1,mPos.x,mPos.y,mPos.z)
    FillRect(currentPos.x-5,currentPos.y+30,210,#menuTable*35+5,0x50ffffff)
    for _,k in pairs(menuTable) do
      if k.isInfo then
        FillRect(currentPos.x,_*35+currentPos.y,200,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,_*35+currentPos.y+5,0xffffffff)
      elseif k.lastSwitch then
        if k.value then
          FillRect(currentPos.x+150,_*35+currentPos.y,50,30,0x9000ff00)
        else
          FillRect(currentPos.x+150,_*35+currentPos.y,50,30,0x90ff0000)
        end
        FillRect(currentPos.x,_*35+currentPos.y,150,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,_*35+currentPos.y+5,0xffffffff)
        DrawText(({[true] = "On", [false] = "Off"})[k.value],20,currentPos.x+160,_*35+currentPos.y+5,0xffffffff)
      elseif k.key then
        if KeyIsDown(k.key) then
          FillRect(currentPos.x+150,_*35+currentPos.y,50,30,0x9000ff00)
        else
          FillRect(currentPos.x+150,_*35+currentPos.y,50,30,0x90ff0000)
        end
        FillRect(currentPos.x,_*35+currentPos.y,150,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,_*35+currentPos.y+5,0xffffffff)
        local t = string.char(k.key)
        if k.switchNow then
          DrawText("...",20,currentPos.x+(t == " " and 155 or 160),_*35+currentPos.y+5,0xffffffff)
        else
          DrawText(t == " " and "Space" or t,20,currentPos.x+(t == " " and 155 or 170),_*35+currentPos.y+5,0xffffffff)
        end
      end
    end
    if KeyIsDown(1) then
      if moveNow then currentPos = {x = mmPos.x-25, y = mmPos.y-45} end
      for _,k in pairs(menuTable) do
        if k.isInfo then
          if mmPos.x >= currentPos.x and mmPos.x <= currentPos.x+200 and mmPos.y >= (_*35+currentPos.y) and mmPos.y <= (_*35+currentPos.y+30) then
            moveNow = true
          end
        elseif k.lastSwitch then
          if mmPos.x >= currentPos.x+150 and mmPos.x <= currentPos.x+200 and mmPos.y >= (_*35+currentPos.y) and mmPos.y <= (_*35+currentPos.y+30) and k.lastSwitch + 250 < GetTickCount() then
            k.lastSwitch = GetTickCount()
            k.value = not k.value
          end
        elseif k.key then
          if mmPos.x >= currentPos.x+150 and mmPos.x <= currentPos.x+200 and mmPos.y >= (_*35+currentPos.y) and mmPos.y <= (_*35+currentPos.y+30) then
            k.switchNow = true
          end
        end
      end
    else 
      moveNow = false
    end
    for _,k in pairs(menuTable) do
      if k.key and k.switchNow then
        for i=17, 128 do
          if KeyIsDown(i) then
            k.key = i
            k.switchNow = false
          end
        end
      end
    end
  end
end

function AddButton(id, name, defaultValue)
  table.insert(menuTable, {id = id, text = name, lastSwitch = 0, value = defaultValue})
end

function RemoveButton(id)
  for _,k in pairs(menuTable) do
    if k.id == id and k.lastSwitch then
      table.remove(menuTable, _)
    end
  end
end

function GetButtonValue(id)
  for _,k in pairs(menuTable) do
    if k.id == id and k.lastSwitch then
      return k.value
    end
  end
end

function AddInfo(id, name)
  table.insert(menuTable, {id = id, text = name, isInfo = true})
end

function AddSlider(id, name, startVal, minVal, maxVal, step)
end

function AddKey(id, name, defaultKey)
  table.insert(menuTable, {id = id, text = name, switchNow = false, key = defaultKey})
end  

function GetKeyValue(id)
  for _,k in pairs(menuTable) do
    if k.id == id and k.key then
      return KeyIsDown(k.key)
    end
  end
end