local menuTable = {}
local currentPos = {x = 150, y = 250}

function DrawMenu()
  if KeyIsDown(0x10) then
    local mPos  = GetMousePos()
    local mmPos = WorldToScreen(1,mPos.x,mPos.y,mPos.z)
    FillRect(currentPos.x-5,currentPos.y+30,210,#menuTable*35+5,0x50ffffff)
    for _,k in pairs(menuTable) do
      if k.id then
        if k.value then
          FillRect(currentPos.x+150,_*35+currentPos.y,50,30,0x9000ff00)
        else
          FillRect(currentPos.x+150,_*35+currentPos.y,50,30,0x90ff0000)
        end
        FillRect(currentPos.x,_*35+currentPos.y,150,30,0x90ffffff)
        DrawText(k.text,20,currentPos.x+10,_*35+currentPos.y+5,0xffffffff)
        DrawText(({[true] = "On", [false] = "Off"})[k.value],20,currentPos.x+160,_*35+currentPos.y+5,0xffffffff)
      end
    end
    if KeyIsDown(1) then
      for _,k in pairs(menuTable) do
        if mmPos.x >= currentPos.x+150 and mmPos.x <= currentPos.x+200 and mmPos.y >= (_*35+currentPos.y) and mmPos.y <= (_*35+currentPos.y+30) and k.lastSwitch + 250 < GetTickCount() then
          k.lastSwitch = GetTickCount()
          k.value = not k.value
        end
      end
    end
  end
end

function AddButton(id, name, defaultValue)
  table.insert(menuTable, {id = id, text = name, lastSwitch = 0, value = defaultValue})
end

function GetButtonValue(id)
  for _,k in pairs(menuTable) do
    if k.id == id then
      return k.value
    end
  end
end

function AddSubMenu(id, name)
end

function AddSlider(id, name, startVal, minVal, maxVal, step)
end

function AddKey(id, name, defaultKey)
end  