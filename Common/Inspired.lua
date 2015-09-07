function print(msg, title)
  if not msg then return end
  PrintChat("<font color=\"#00FFFF\">["..(title or "GoS-Library").."]:</font> <font color=\"#FFFFFF\">"..tostring(msg).."</font>")
end

local toPrint, toPrintCol = {}, {}
function Print(str, time, col)
  local b = 0
  for _, k in pairs(toPrint) do
    b = _
  end
  local index = b + 1
  toPrint[index] = str
  toPrintCol[index] = col or 0xffffffff
  GoS:DelayAction(function() toPrint[index] = nil toPrintCol[index] = nil end, time or 2000)
end

function Value()
  if self.__type == "key" and not self.__isToggle then
    return self.Value()
  end
  return self.__val
end

local _SC = { menuKey = 16, menuIndex = -1, instances = {}, keySwitch = nil, listSwitch = nil, sliderSwitch = nil, lastSwitch = 0 }
local _SCP = {x = 15, y = -5}

function __Menu__Draw()
  if KeyIsDown(_SC.menuKey) or _SC.keySwitch or _SC.listSwitch or _SC.sliderSwitch or GoS.Menu.s.Value() then
    __Menu__Browse()
    __Menu__WndMsg()
    FillRect(_SCP.x-2,_SCP.y+18,150+4,4+20*#_SC.instances,ARGB(55, 255, 255, 255))
    for _=1, #_SC.instances do
      local instance = _SC.instances[_]
      FillRect(_SCP.x,_SCP.y+20*_,150,20,ARGB(255, 0, 0, 0))
      FillRect(_SCP.x+5,_SCP.y+20*_+9,70-GoS:GetTextArea(instance.__name,15),1,ARGB(155, 255, 255, 255))
      FillRect(_SCP.x+70+GoS:GetTextArea(instance.__name,15),_SCP.y+20*_+9,70-GoS:GetTextArea(instance.__name,15),1,ARGB(155, 255, 255, 255))
      DrawText(" "..instance.__name.." ",15,_SCP.x+75-GoS:GetTextArea(instance.__name,15),_SCP.y+1+20*_,0xffffffff)
      DrawText(">",15,_SCP.x+135,_SCP.y+1+20*_,0xffffffff)
    end
    for _=1, #_SC.instances do
      local instance = _SC.instances[_]
      if instance.__active then
        if #instance.__subMenus > 0 then
          for i=1, #instance.__subMenus do
            local sub = instance.__subMenus[i]
            __Menu_DrawSubMenu(sub, i+_-1, 1)
          end
        end
        if #instance.__params > 0 then
          for j=1, #instance.__params do
            __Menu_DrawParam(instance.__params[j], 1, j+#instance.__subMenus+_-1)
          end
        end
      end
    end
    if _SC.keySwitch then
      for i=17, 128 do
        if KeyIsDown(i) then
          _SC.keySwitch.__key = i
          _SC.keySwitch = nil
        end
      end
    end
    if _SC.listSwitch then
      __Menu__DrawListSwitch(_SC.listSwitch, _SC.listSwitch.x, _SC.listSwitch.y)
    end
    if _SC.sliderSwitch then
      __Menu__DrawSliderSwitch(_SC.sliderSwitch, _SC.sliderSwitch.x, _SC.sliderSwitch.y)
    end
  end
end

function __Menu_DrawSubMenu(instance, _, num)
  FillRect(_SCP.x-2+150*num,_SCP.y-2+20*_,150+4,4+20,ARGB(55, 255, 255, 255))
  FillRect(_SCP.x+150*num,_SCP.y+20*_,150,20,ARGB(255, 0, 0, 0))
  FillRect(_SCP.x+5+150*num,_SCP.y+20*_+9,70-GoS:GetTextArea(instance.__name,15),1,ARGB(155, 255, 255, 255))
  FillRect(_SCP.x+75+150*num+GoS:GetTextArea(instance.__name,15),_SCP.y+20*_+9,70-GoS:GetTextArea(instance.__name,15),1,ARGB(155, 255, 255, 255))
  DrawText(" "..instance.__name.." ",15,_SCP.x+num*150+75-GoS:GetTextArea(instance.__name,15),_SCP.y+1+20*_,0xffffffff)
  DrawText(">",15,_SCP.x+135+150*num,_SCP.y+1+20*_,0xffffffff)
  if #instance.__subMenus > 0 and instance.__active then
    for i=1, #instance.__subMenus do
      local sub = instance.__subMenus[i]
      __Menu_DrawSubMenu(sub, i+_-1, num+1)
    end
  end
  if #instance.__params > 0 then
    for j=1, #instance.__params do
      __Menu_DrawParam(instance.__params[j], num+1, _-1+j+#instance.__subMenus)
    end
  end
end

function __Menu_DrawParam(param, xoff, yoff)
  if param.__head.__active then
    FillRect(_SCP.x-2+150*xoff,_SCP.y-2+20*yoff,150+4,4+20,ARGB(55, 255, 255, 255))
    FillRect(_SCP.x+150*xoff,_SCP.y+20*yoff,150,20,ARGB(255, 0, 0, 0))
    if param.__type == "boolean" then
      FillRect(_SCP.x+5+150*xoff,_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      FillRect(_SCP.x+75+150*xoff+GoS:GetTextArea(param.__name,15),_SCP.y+20*yoff+9,50-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      DrawText(" "..param.__name.." ",15,_SCP.x+150*xoff+75-GoS:GetTextArea(param.__name,15),_SCP.y+1+20*yoff,0xffffffff)
      FillRect(_SCP.x+130+150*xoff,_SCP.y+20*yoff+2,15,15, param.__val and GoS.Green or GoS.Red)
    elseif param.__type == "key" then
      FillRect(_SCP.x+5+150*xoff,_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      FillRect(_SCP.x+75+150*xoff+GoS:GetTextArea(param.__name,15),_SCP.y+20*yoff+9,50-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      DrawText(" "..param.__name.." ",15,_SCP.x+150*xoff+75-GoS:GetTextArea(param.__name,15),_SCP.y+1+20*yoff,0xffffffff)
      FillRect(_SCP.x+130+150*xoff,_SCP.y+20*yoff+2,15,15, param.Value() and ARGB(150,0,255,0) or ARGB(150,255,0,0))
      DrawText("["..param.__key.."]",15,_SCP.x+125+150*xoff,_SCP.y+20*yoff+1,0xffffffff)
    elseif param.__type == "slider" then
      FillRect(_SCP.x+5+150*xoff,_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      FillRect(_SCP.x+75+150*xoff+GoS:GetTextArea(param.__name,15),_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      DrawText(" "..param.__name.." ",15,_SCP.x+150*xoff+75-GoS:GetTextArea(param.__name,15),_SCP.y+1+20*yoff,0xffffffff)
      DrawText(">",15,_SCP.x+135+150*xoff,_SCP.y+1+20*yoff,0xffffffff)
    elseif param.__type == "list" then
      FillRect(_SCP.x+5+150*xoff,_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      FillRect(_SCP.x+75+150*xoff+GoS:GetTextArea(param.__name,15),_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      DrawText(" "..param.__name.." ",15,_SCP.x+150*xoff+75-GoS:GetTextArea(param.__name,15),_SCP.y+1+20*yoff,0xffffffff)
      DrawText(">",15,_SCP.x+135+150*xoff,_SCP.y+1+20*yoff,0xffffffff)
    elseif param.__type == "info" then
      FillRect(_SCP.x+5+150*xoff,_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      FillRect(_SCP.x+75+150*xoff+GoS:GetTextArea(param.__name,15),_SCP.y+20*yoff+9,70-GoS:GetTextArea(param.__name,15),1,ARGB(155, 255, 255, 255))
      DrawText(" "..param.__name.." ",15,_SCP.x+150*xoff+75-GoS:GetTextArea(param.__name,15),_SCP.y+1+20*yoff,0xffffffff)
    end
  end
end

function __Menu__DrawListSwitch(param, x, y)
  FillRect(x-2, y-2, 154, 20*#param.__list+4, ARGB(55, 255, 255, 255))
  FillRect(x, y, 150, 20*#param.__list,ARGB(255, 0, 0, 0))
  for i = 1, #param.__list do
    local entry = param.__list[i]
    if param.__val == i then
      DrawText("->",15,x+5,20*(i-1)+y,0xffffffff)
    end
    DrawText(entry,15,x+35,20*(i-1)+y,0xffffffff)
  end
end

function __Menu__DrawSliderSwitch(param, x, y)
  FillRect(x-2, y-2, 154, 44, ARGB(55, 255, 255, 255))
  FillRect(x, y, 150, 40,ARGB(255, 0, 0, 0))
  DrawText("Value: "..math.floor(param.__val),15,x+5,y,0xffffffff)
  DrawText("[X]",15,x+130,y,0xffffffff)
  DrawText(param.__min,15,x+5,y+20,0xffffffff)
  DrawText(param.__max,15,x+125,y+20,0xffffffff)
  FillRect(x+15,y+20, 105, 18, ARGB(55, 255, 255, 255))
  FillRect(x+15+105*param.__val/param.__max, y+20, 5, 18, GoS.Blue)
end

function __Menu__Browse()
  if _SC.listSwitch or _SC.sliderSwitch then return end
  local mPos  = GetMousePos()
  local mmPos = WorldToScreen(1,mPos.x,mPos.y,mPos.z)
  for _=1, #_SC.instances do
    local instance = _SC.instances[_]
    local x = _SCP.x
    local y = _SCP.y+20*_
    local width = 150
    local heigth = 20
    if mmPos.x >= x and mmPos.x <= x+width and mmPos.y >= y and mmPos.y <= y+heigth then
      __Menu__ResetActive()
      _SC.instances[_].__active = true
      return;
    end
    if #instance.__subMenus > 0 and instance.__active then
      for i=1, #instance.__subMenus do
        local sub = instance.__subMenus[i]
        __Menu__BrowseSubMenu(sub, i+_-1, 1)
      end
    end
  end
end

function __Menu__BrowseSubMenu(instance, _, num)
  local mPos  = GetMousePos()
  local mmPos = WorldToScreen(1,mPos.x,mPos.y,mPos.z)
  local x = _SCP.x+150*num
  local y = _SCP.y+20*_
  local width = 150
  local heigth = 20
  if mmPos.x >= x and mmPos.x <= x+width and mmPos.y >= y and mmPos.y <= y+heigth then
    if instance.__head then
      for j=1, #instance.__head.__subMenus do
        local ins = instance.__head.__subMenus[j]
        __Menu__ResetSubMenu(ins)
        ins.__active = false
      end
    end
    instance.__active = true
    return;
  end
  if #instance.__subMenus > 0 and instance.__active then
    for i=1, #instance.__subMenus do
      local sub = instance.__subMenus[i]
      __Menu__BrowseSubMenu(sub, i+_-1, num+1)
    end
  end
end

function __Menu__ResetActive()
  for _=1, #_SC.instances do
    _SC.instances[_].__active = false
    for i=1, #_SC.instances[_].__subMenus do
      __Menu__ResetSubMenu(_SC.instances[_].__subMenus[i])
    end
  end
end

function __Menu__ResetSubMenu(sub)
  sub.__active = false
  if #sub.__subMenus > 0 then
    for i=1, #sub.__subMenus do
      __Menu__ResetSubMenu(sub.__subMenus[i])
    end
  end
end

function __Menu__WndMsg()
  if KeyIsDown(1) and _SC.lastSwitch < GetTickCount() then
    local mPos  = GetMousePos()
    local mmPos = WorldToScreen(0,mPos.x,mPos.y,mPos.z)
    if _SC.listSwitch then
      local x = _SC.listSwitch.x
      local y = _SC.listSwitch.y
      if mmPos.x >= x and mmPos.x <= x+150 then
        for i=1, #_SC.listSwitch.__list do
          if mmPos.y >= y-20+i*20 and mmPos.y <= y+i*20 then
            _SC.listSwitch.__val = i
            GoS:DelayAction(function() _SC.listSwitch = nil end, 125)
            _SC.lastSwitch = GetTickCount() + 125
          end
        end
      end
    elseif _SC.sliderSwitch then
      local x = _SC.sliderSwitch.x
      local y = _SC.sliderSwitch.y
      if mmPos.x >= x and mmPos.x <= x+150 and mmPos.y >= y+20 and mmPos.y <= y+40 then
        if mmPos.x <= x+15 then
          _SC.sliderSwitch.__val = 0
        elseif mmPos.x >= x+120 then
          _SC.sliderSwitch.__val = 100
        else
          local v = (mmPos.x - x - 15) / 105
          _SC.sliderSwitch.__val = math.floor(100*v*_SC.sliderSwitch.__inc)
        end
      end
      if mmPos.x >= x+130 and mmPos.x <= x+150 and mmPos.y >= y-5 and mmPos.y <= y+15 then
        _SC.sliderSwitch = nil
        _SC.lastSwitch = GetTickCount() + 125
      end
    else
      local pressedSomething = false
      for _=1, #_SC.instances do
        if _SC.instances[_].__active then
          local yoff = #_SC.instances[_].__subMenus
          for i=1, yoff do
            pressedSomething = __Menu__SubMenuWndMsg(_SC.instances[_].__subMenus[i], _)
          end
          for i=1, #_SC.instances[_].__params do
            local x = _SCP.x+150
            local y = _SCP.y+20*(yoff+i+_-1)
            local width = 150
            local heigth = 20
            if mmPos.x >= x and mmPos.x <= x+width and mmPos.y >= y and mmPos.y <= y+heigth then
              __Menu__SwitchParam(_SC.instances[_].__params[i], x, y)
              return;
            end
          end
        end
      end
      if not pressedSomething then
        __Menu__ResetActive()
      end
    end
  end
end

function __Menu__SubMenuWndMsg(instance, _)
  local mPos  = GetMousePos()
  local mmPos = WorldToScreen(0,mPos.x,mPos.y,mPos.z)
  local yoff = #instance.__subMenus
  local pressedSomething = false
  for i=1, yoff do
    pressedSomething = __Menu__SubMenuWndMsg(instance.__subMenus[i])
  end
  for i=1, #instance.__params do
    local x = _SCP.x+150*(_)
    local y = _SCP.y+20*(yoff+i+_-1)
    local width = 150
    local heigth = 20
    FillRect(x,y,width,heigth,GoS.White)
    if mmPos.x >= x and mmPos.x <= x+width and mmPos.y >= y and mmPos.y <= y+heigth then
      __Menu__SwitchParam(instance.__params[i], x, y)
      return true
    end
  end
  return pressedSomething
end

function __Menu__SwitchParam(param, x, y)
  if param.__type == "boolean" then
    if param.__lastSwitch < GetTickCount() then
      param.__lastSwitch = GetTickCount() + 125
      param.__val = not param.__val
    end
  elseif param.__type == "key" then
    _SC.keySwitch = param
  elseif param.__type == "slider" then
    _SC.sliderSwitch = param
    _SC.sliderSwitch.x = x+150
    _SC.sliderSwitch.y = y
  elseif param.__type == "list" then
    _SC.listSwitch = param
    _SC.listSwitch.x = x+150
    _SC.listSwitch.y = y
  end
end

class "Menu"

function Menu:__init(name, id, head)
  self.__name = name
  self.__id = id
  self.__subMenus = {}
  self.__params = {}
  self.__active = false
  self.__head = head
  if not head then
    table.insert(_SC.instances, self)
  end
  return self
end

function Menu:SubMenu(id, name)
  local id2 = #self.__subMenus+1
  self.__subMenus[id2] = Menu(name, id, self)
  self[id] = self.__subMenus[id2]
end

function Menu:Boolean(id, name, val)
  local id2 = #self.__params+1
  self.__params[id2] = {__id = id, __name = name, __type = "boolean", __val = val, __head = self, __lastSwitch = 0, Value = function() return self.__params[id2].__val end}
  self[id] = self.__params[id2]
end

function Menu:Key(id, name, key, isToggle)
  local id2 = #self.__params+1
  if isToggle then
    OnLoop(function() 
      if self.__params[id2].__lastSwitch < GetTickCount() and KeyIsDown(self.__params[id2].__key) then 
        self.__params[id2].__lastSwitch = GetTickCount() + 125
        self.__params[id2].__val = not self.__params[id2].__val 
      end 
    end)
    self.__params[id2] = {__id = id, __name = name, __type = "key", __key = key, __isToggle = isToggle, __head = self, __lastSwitch = 0, Value = function() return self.__params[id2].__val end}
  else
    self.__params[id2] = {__id = id, __name = name, __type = "key", __key = key, __isToggle = isToggle, __head = self, Value = function() return KeyIsDown(self.__params[id2].__key) end}
  end
  self[id] = self.__params[id2]
end

function Menu:Slider(id, name, starVal, minVal, maxVal, incrVal)
  local id2 = #self.__params+1
  self.__params[id2] = {__id = id, __name = name, __type = "slider", __head = self, __val = starVal, __min = minVal, __max = maxVal, __inc = incrVal, Value = function() return self.__params[id2].__val end}
  self[id] = self.__params[id2]
end

function Menu:List(id, name, starVal, list)
  local id2 = #self.__params+1
  self.__params[id2] = {__id = id, __name = name, __type = "list", __head = self, __val = starVal, __list = list, Value = function() return self.__params[id2].__val end}
  self[id] = self.__params[id2]
end

function Menu:Info(id, name)
  local id2 = #self.__params+1
  self.__params[id2] = {__id = id, __name = name, __type = "info", __head = self}
  self[id] = self.__params[id2]
end

class "goslib"

function goslib:__init()
  self:SetupVars()
  self:SetupMenu()
  self:SetupLocalCallbacks()
  self:MakeObjectManager()
end

function goslib:SetupMenu()
  self.Menu = Menu("GoS-Library", "gos")
  self.Menu:Boolean("s", "Show always", true)
  self.Menu:List("l", "Language", 1, {"English", })
  self.afterObjectLoopEvents[#self.afterObjectLoopEvents+1] = function()
    __Menu__Draw()
  end
end

function goslib:GetTextArea(str, size)
  local width = 0
  for i=1, str:len() do
    width = width + (self:IsUppercase(str:sub(i,i)) and 2 or 1)
  end
  return width * size * 0.2
end

function goslib:IsUppercase(char)
  return char:lower() ~= char
end

function goslib:SetupVars()
  _G.myHero = GetMyHero()
  _G.DAMAGE_MAGIC, _G.DAMAGE_PHYSICAL = 1, 2
  _G.MINION_ALLY, _G.MINION_ENEMY, _G.MINION_JUNGLE = GetTeam(myHero), 300-GetTeam(myHero), 300
  local summonerNameOne = GetCastName(myHero,SUMMONER_1)
  local summonerNameTwo = GetCastName(myHero,SUMMONER_2)
  _G.Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))
  _G.Smite = (summonerNameOne:lower():find("summonersmite") and SUMMONER_1 or (summonerNameTwo:lower():find("summonersmite") and SUMMONER_2 or nil))
  _G.Exhaust = (summonerNameOne:lower():find("summonerexhaust") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerexhaust") and SUMMONER_2 or nil))
  self.White = ARGB(255,255,255,255)
  self.Red = ARGB(255,255,0,0)
  self.Blue = ARGB(255,0,0,255)
  self.Green = ARGB(255,0,255,0)
  self.Pink = ARGB(255,255,0,255)
  self.Black = ARGB(255,0,0,0)
  self.Yellow = ARGB(255,255,255,0)
  self.Cyan = ARGB(255,0,255,255)
  self.objectLoopEvents = {}
  self.afterObjectLoopEvents = {function()local c=0;for _,k in pairs(toPrint)do c=c+1;DrawText(k,30,50,25+30*c,toPrintCol[_])end;end}
  self.delayedActions = {}
  self.delayedActionsExecuter = nil
  self.tableForHPPrediction = {}
  self.gapcloserTable = {
    ["Aatrox"] = _Q, ["Akali"] = _R, ["Alistar"] = _W, ["Ahri"] = _R, ["Amumu"] = _Q, ["Corki"] = _W,
    ["Diana"] = _R, ["Elise"] = _Q, ["Elise"] = _E, ["Fiddlesticks"] = _R, ["Fiora"] = _Q,
    ["Fizz"] = _Q, ["Gnar"] = _E, ["Grags"] = _E, ["Graves"] = _E, ["Hecarim"] = _R,
    ["Irelia"] = _Q, ["JarvanIV"] = _Q, ["Jax"] = _Q, ["Jayce"] = "JayceToTheSkies", ["Katarina"] = _E, 
    ["Kassadin"] = _R, ["Kennen"] = _E, ["KhaZix"] = _E, ["Lissandra"] = _E, ["LeBlanc"] = _W, 
    ["LeeSin"] = "blindmonkqtwo", ["Leona"] = _E, ["Lucian"] = _E, ["Malphite"] = _R, ["MasterYi"] = _Q, 
    ["MonkeyKing"] = _E, ["Nautilus"] = _Q, ["Nocturne"] = _R, ["Olaf"] = _R, ["Pantheon"] = _W, 
    ["Poppy"] = _E, ["RekSai"] = _E, ["Renekton"] = _E, ["Riven"] = _E, ["Sejuani"] = _Q, 
    ["Sion"] = _R, ["Shen"] = _E, ["Shyvana"] = _R, ["Talon"] = _E, ["Thresh"] = _Q, 
    ["Tristana"] = _W, ["Tryndamere"] = "Slash", ["Udyr"] = _E, ["Volibear"] = _Q, ["Vi"] = _Q, 
    ["XinZhao"] = _E, ["Yasuo"] = _E, ["Zac"] = _E, ["Ziggs"] = _W
  }
  self.GapcloseSpell, self.GapcloseTime, self.GapcloseUnit, self.GapcloseTargeted, self.GapcloseRange = 2, 0, nil, true, 450
end

function goslib:SetupLocalCallbacks()
  OnObjectLoop(function(object) self:ObjectLoop(object) end)
  OnLoop(function() self:Loop() end)
  OnProcessSpell(function(x, y) self:ProcessSpell(x, y) end)
end

function goslib:ObjectLoop(object)
  if self.objectLoopEvents then
    for _, func in pairs(self.objectLoopEvents) do
      if func then
        func(object)
      end
    end
  end
end

function goslib:Loop()
  if self.afterObjectLoopEvents then
    for _, func in pairs(self.afterObjectLoopEvents) do
      if func then
        func()
      end
    end
  end
  for i, k in pairs(self.tableForHPPrediction) do
    for j, v in pairs(k) do
      if v.time < os.clock() then
        self.tableForHPPrediction[i][j] = nil
      end
    end
  end
end

function goslib:ProcessSpell(unit, spell)
  local target = spell.target
  if target and not IsDead(target) and GetOrigin(target) then
    if spell.name:lower():find("attack") then
      local timer = 1000*self:GetYDistance(target,unit)/self:GetProjectileSpeed(unit)
      if not self.tableForHPPrediction[GetNetworkID(target)] then self.tableForHPPrediction[GetNetworkID(target)] = {} end
      table.insert(self.tableForHPPrediction[GetNetworkID(target)], {source = unit, dmg = self:GetDmg(unit, target), time = GetTickCount() + timer})
    end
  end
end

function goslib:PredictHealth(unit, delta)
  if self.tableForHPPrediction[GetNetworkID(unit)] then
    local dmg = 0
    for _, attack in pairs(self.tableForHPPrediction[GetNetworkID(unit)]) do
      if IsObjectAlive(attack.source) and GetTickCount() < attack.time then
        dmg = dmg + attack.dmg
      else
        self.tableForHPPrediction[GetNetworkID(unit)][_] = nil
      end
    end
    return GetCurrentHP(unit) - dmg
  else
    return GetCurrentHP(unit)
  end
end

function goslib:GetDmg(from, to)
  return self:CalcDamage(from, to, GetBonusDmg(from)+GetBaseDamage(from))
end

function goslib:MakeObjectManager()
  _G.objectManager = {}
  objectManager.maxObjects = 0
  objectManager.objects = {}
  self.objectLCallbackId = #self.objectLoopEvents+1
  self.objectACallbackId = #self.afterObjectLoopEvents+1
  self.objectLoopEvents[self.objectLCallbackId] = function(object)
    objectManager.maxObjects = objectManager.maxObjects + 1
    objectManager.objects[objectManager.maxObjects] = object
  end
  self.afterObjectLoopEvents[self.objectACallbackId] = function()
    if objectManager.maxObjects > 0 and self.objectLoopEvents[self.objectLCallbackId] then
      self.objectLoopEvents[self.objectLCallbackId] = nil
    end
    if not self.objectLoopEvents[self.objectLCallbackId] then
      self:FindHeroes()
      self:MakeMinionManager()
      self.afterObjectLoopEvents[self.objectACallbackId] = nil
    end
  end
  local function findDeadPlace()
    for i = 1, objectManager.maxObjects do
      local object = objectManager.objects[i]
      if not object or not IsObjectAlive(object) then
        return i
      end
    end
  end
  OnCreateObj(function(object)
    local spot = findDeadPlace()
    if spot then
      objectManager.objects[spot] = object
    else
      objectManager.maxObjects = objectManager.maxObjects + 1
      objectManager.objects[objectManager.maxObjects] = object
    end
  end)
end

function goslib:FindHeroes()
  self.heroes = {myHero}
  for i = 1, objectManager.maxObjects do
    local object = objectManager.objects[i]
    if GetObjectType(object) == Obj_AI_Hero then
      self.heroes[#self.heroes+1] = object
    end
  end
end

function goslib:MakeMinionManager()
  _G.minionManager = {}
  minionManager.maxObjects = 0
  minionManager.objects = {}
  for i = 1, objectManager.maxObjects do
    local object = objectManager.objects[i]
    if GetObjectType(object) == Obj_AI_Minion and IsObjectAlive(object) then
      local objName = GetObjectName(object)
      if objName == "Barrel" or (GetTeam(object) == 300 and GetCurrentHP(object) < 100000 or objName:find('_')) then
        minionManager.maxObjects = minionManager.maxObjects + 1
        minionManager.objects[minionManager.maxObjects] = object
      end
    end
  end
  local function findDeadPlace()
    for i = 1, minionManager.maxObjects do
      local object = minionManager.objects[i]
      if not object or not IsObjectAlive(object) then
        return i
      end
    end
  end
  OnCreateObj(function(object)
    if GetObjectType(object) == Obj_AI_Minion and IsObjectAlive(object) then
      local objName = GetObjectName(object)
      if objName == "Barrel" or (GetTeam(object) == 300 and GetCurrentHP(object) < 100000 or objName:find('_')) then
        local spot = findDeadPlace()
        if spot then
          minionManager.objects[spot] = object
        else
          minionManager.maxObjects = minionManager.maxObjects + 1
          minionManager.objects[minionManager.maxObjects] = object
        end
      end
    end
  end)
end

function goslib:AddGapcloseEvent(spell, range, targeted)
    self.GapcloseSpell = spell
    self.GapcloseTime = 0
    self.GapcloseUnit = nil
    self.GapcloseTargeted = targeted
    self.GapcloseRange = range
    self.str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
    --GapcloseConfig = scriptConfig("gapclose", "Anti-Gapclose ("..str[spell]..")")
    DelayAction(function()
        for _,k in pairs(GetEnemyHeroes()) do
          if self.gapcloserTable[GetObjectName(k)] then
            --GapcloseConfig.addParam(GetObjectName(k).."agap", "On "..GetObjectName(k).." "..(type(gapcloserTable[GetObjectName(k)]) == 'number' and str[gapcloserTable[GetObjectName(k)]] or (GetObjectName(k) == "LeeSin" and "Q" or "E")), SCRIPT_PARAM_ONOFF, true)
          end
        end
    end, 1)
    OnProcessSpell(function(unit, spell)
      if not unit or not self.gapcloserTable[GetObjectName(unit)] or not GapcloseConfig[GetObjectName(unit).."agap"] then return end
      local unitName = GetObjectName(unit)
      if spell.name == (type(self.gapcloserTable[unitName]) == 'number' and GetCastName(unit, self.gapcloserTable[unitName]) or self.gapcloserTable[unitName]) and (spell.target == myHero or self:GetDistanceSqr(spell.endPos) < self.GapcloseRange*self.GapcloseRange*4) then
        self.GapcloseTime = GetTickCount() + 2000
        self.GapcloseUnit = unit
      end
    end)
    OnLoop(function(myHero)
      if CanUseSpell(myHero, self.GapcloseSpell) == READY and self.GapcloseTime and self.GapcloseUnit and self.GapcloseTime >GetTickCount() then
        local pos = GetOrigin(self.GapcloseUnit)
        if self.GapcloseTargeted then
          if self:GetDistanceSqr(pos,self:myHeroPos()) < self.GapcloseRange*self.GapcloseRange then
            CastTargetSpell(self.GapcloseUnit, self.GapcloseSpell)
          end
        else 
          if self:GetDistanceSqr(pos,self:myHeroPos()) < self.GapcloseRange*self.GapcloseRange*4 then
            CastSkillShot(self.GapcloseSpell, pos.x, pos.y, pos.z)
          end
        end
      else
        self.GapcloseTime = 0
        self.GapcloseUnit = nil
      end
    end)
end

function goslib:CountMinions()
    return #GetAllMinions()
end

function goslib:GetAllMinions(team)
    local result = {}
    for i = 1, minionManager.maxObjects do
      local object = minionManager.objects[i]
      if object and not IsDead(object) then
        if not team or GetTeam(object) == team then
          result[#result+1] = object
        end
      end
    end
    return result
end

function goslib:ClosestMinion(pos, team)
    local minion = nil
    local minions = GetAllMinions()
    for k=1, #minions do 
      local v = minions[k]
      local objTeam = GetTeam(v)
      if not minion and v and objTeam == team then minion = v end
      if minion and v and objTeam == team and self:GetDistanceSqr(GetOrigin(minion),pos) > self:GetDistanceSqr(GetOrigin(v),pos) then
        minion = v
      end
    end
    return minion
end

function goslib:GetLowestMinion(pos, range, team)
    local minion = nil
    local minions = GetAllMinions()
    for k=1, #minions do 
      local v = minions[k]
      local objTeam = GetTeam(v)
      if not minion and v and objTeam == team and self:GetDistanceSqr(GetOrigin(v),pos) < range*range then minion = v end
      if minion and v and objTeam == team and self:GetDistanceSqr(GetOrigin(v),pos) < range*range and GetCurrentHP(v) < GetCurrentHP(minion) then
        minion = v
      end
    end
    return minion
end

function goslib:GetHighestMinion(pos, range, team)
    local minion = nil
    local minions = GetAllMinions()
    for k=1, #minions do 
      local v = minions[k] 
      local objTeam = GetTeam(v)
      if not minion and v and objTeam == team and self:GetDistanceSqr(GetOrigin(v),pos) < range*range then minion = v end
      if minion and v and objTeam == team and self:GetDistanceSqr(GetOrigin(v),pos) < range*range and GetCurrentHP(v) > GetCurrentHP(minion) then
        minion = v
      end
    end
    return minion
end

function goslib:GenerateMovePos()
    local mPos = GetMousePos()
    local hPos = self:myHeroPos()
    local tV = {x = (mPos.x-hPos.x), z = (mPos.z-hPos.z)}
    local len = math.sqrt(tV.x * tV.x + tV.z * tV.z)
    return {x = hPos.x + 250 * tV.x / len, y = hPos.y, z = hPos.z + 250 * tV.z / len}
end

function goslib:IsInDistance(p1,r)
    return self:GetDistanceSqr(GetOrigin(p1)) < r*r
end

function goslib:GetDistance(p1,p2)
  p1 = GetOrigin(p1) or p1
  p2 = GetOrigin(p2) or p2 or self:myHeroPos()
  return math.sqrt(self:GetDistanceSqr(p1,p2))
end

function goslib:GetDistanceSqr(p1,p2)
    p2 = p2 or self:myHeroPos()
    local dx = p1.x - p2.x
    local dz = (p1.z or p1.y) - (p2.z or p2.y)
    return dx*dx + dz*dz
end

function goslib:GetYDistance(p1, p2)
  p1 = GetOrigin(p1) or p1
  p2 = GetOrigin(p2) or p2 or self:myHeroPos()
  return math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2 + (p1.z - p2.z) ^ 2)
end

function goslib:ValidTarget(unit, range)
    range = range or 25000
    if unit == nil or GetOrigin(unit) == nil or IsImmune(unit,myHero) or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(myHero) or not self:IsInDistance(unit, range) then return false end
    return true
end

function goslib:myHeroPos()
    return GetOrigin(myHero) 
end

function goslib:GetEnemyHeroes()
  local result = {}
  for _=1, #(self.heroes or {}) do
    local obj = self.heroes[_]
    if GetTeam(obj) ~= GetTeam(GetMyHero()) then
      table.insert(result, obj)
    end
  end
  return result
end

function goslib:GetAllyHeroes()
  local result = {}
  for _=1, #(self.heroes or {}) do
    local obj = self.heroes[_]
    if GetTeam(obj) == GetTeam(GetMyHero()) then
      table.insert(result, obj)
    end
  end
  return result
end

function goslib:DelayAction(func, delay, args)
    if not self.delayedActionsExecuter then
        function goslib:delayedActionsExecuter()
            for t, funcs in pairs(self.delayedActions) do
                if t <= GetTickCount() then
                    for _, f in ipairs(funcs) do f.func(unpack(f.args or {})) end
                    self.delayedActions[t] = nil
                end
            end
        end
        OnLoop(function() self:delayedActionsExecuter() end)
    end
    local t = GetTickCount() + (delay or 0)
    if self.delayedActions[t] then 
      table.insert(self.delayedActions[t], { func = func, args = args })
    else 
      self.delayedActions[t] = { { func = func, args = args } }
    end
end

function goslib:CalcDamage(source, target, addmg, apdmg)
    local ADDmg = addmg or 0
    local APDmg = apdmg or 0
    local ArmorPen = math.floor(GetArmorPenFlat(source))
    local ArmorPenPercent = math.floor(GetArmorPenPercent(source)*100)/100
    local Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
    local ArmorPercent = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
    local MagicPen = math.floor(GetMagicPenFlat(source))
    local MagicPenPercent = math.floor(GetMagicPenPercent(source)*100)/100
    local MagicArmor = GetMagicResist(target)*MagicPenPercent-MagicPen
    local MagicArmorPercent = MagicArmor > 0 and math.floor(MagicArmor*100/(100+MagicArmor))/100 or math.ceil(MagicArmor*100/(100-MagicArmor))/100
    return (GotBuff(source,"exhausted")  > 0 and 0.4 or 1) * math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
end

function goslib:GetTarget(range, damageType)
    damageType = damageType or 2
    local target, steps = nil, 10000
    for _, k in pairs(self:GetEnemyHeroes()) do
        local step = GetCurrentHP(k) / self:CalcDamage(GetMyHero(), k, DAMAGE_PHYSICAL == damageType and 100 or 0, DAMAGE_MAGIC == damageType and 100 or 0)
        if k and self:ValidTarget(k, range) and step < steps then
            target = k
            steps = step
        end
    end
    return target
end

function goslib:CastOffensiveItems(unit)
  i = {3074, 3077, 3142, 3184}
  u = {3153, 3146, 3144}
  for _,k in pairs(i) do
    slot = GetItemSlot(myHero,k)
    if slot ~= nil and slot ~= 0 and CanUseSpell(myHero, slot) == READY then
      CastTargetSpell(GetMyHero(), slot)
      return true
    end
  end
  for _,k in pairs(u) do
    slot = GetItemSlot(myHero,k)
    if slot ~= nil and slot ~= 0 and CanUseSpell(myHero, slot) == READY then
      CastTargetSpell(unit, slot)
      return true
    end
  end
  return false
end

function goslib:Circle(col)
  local circle = {}
  circle.object = nil
  circle.color = col or 0xffffffff
  circle.objectACallbackId = #(self.afterObjectLoopEvents)+1
  circle.contains = function(pos)
    return GoS.GetDistanceSqr(Vector(circle.x, circle.y, circle.z), pos) < circle.r * circle.r
  end
  circle.Color = function(col)
    circle.color = color or 0xffffffff
    return circle
  end
  circle.SetPos = function(x, y, z, r)
    local pos = GetOrigin(x) or type(x) ~= "number" and x or nil
    circle.x = pos and pos.x or x
    circle.y = pos and pos.y or y
    circle.z = pos and pos.z or z
    circle.r = pos and y or r
    return circle
  end
  circle.Attach = function(object, r)
    circle.object = object
    circle.r = r
    return circle
  end
  circle.Draw = function(boolean)
    if boolean then
      self.afterObjectLoopEvents[circle.objectACallbackId] = function()
        if circle.object then local pos = GetOrigin(circle.object) circle.x=pos.x circle.y=pos.y circle.z=pos.z end
        DrawCircle(circle.x, circle.y, circle.z, circle.r, 1, 10, circle.color)
      end
    else
      self.afterObjectLoopEvents[circle.objectACallbackId] = nil
    end
  end
  return circle
end

function goslib:EnemiesAround(pos, range)
  local c = 0
  if pos == nil then return 0 end
  for k,v in pairs(self:GetEnemyHeroes()) do 
    if v and ValidTarget(v) and self:GetDistanceSqr(pos,GetOrigin(v)) < range*range then
      c = c + 1
    end
  end
  return c
end

function goslib:ClosestEnemy(pos)
  local enemy = nil
  for k,v in pairs(self:GetEnemyHeroes()) do 
    if not enemy and v then enemy = v end
    if enemy and v and self:GetDistanceSqr(GetOrigin(enemy),pos) > self:GetDistanceSqr(GetOrigin(v),pos) then
      enemy = v
    end
  end
  return enemy
end

function goslib:AlliesAround(pos, range)
  local c = 0
  if pos == nil then return 0 end
  for k,v in pairs(self:GetAllyHeroes()) do 
    if v and ValidTarget(v) and self:GetDistanceSqr(pos,GetOrigin(v)) < range*range then
      c = c + 1
    end
  end
  return c
end

function goslib:ClosestAlly(pos)
  local ally = nil
  for k,v in pairs(self:GetAllyHeroes()) do 
    if not ally and v then ally = v end
    if ally and v and self:GetDistanceSqr(GetOrigin(ally),pos) > self:GetDistanceSqr(GetOrigin(v),pos) then
      ally = v
    end
  end
  return ally
end

_G.GoS = goslib()
_G.gos = _G.GoS
_G.Gos = _G.GoS
_G.GOS = _G.GoS
_G.gOS = _G.GoS
_G.goS = _G.GoS
_G.gOs = _G.GoS
_G.GOs = _G.GoS

function VectorType(v)
    v = GetOrigin(v) or v
    return v and v.x and type(v.x) == "number" and ((v.y and type(v.y) == "number") or (v.z and type(v.z) == "number"))
end

local function IsClockWise(A,B,C)
    return VectorDirection(A,B,C)<=0
end

local function IsCounterClockWise(A,B,C)
    return not IsClockWise(A,B,C)
end

function IsLineSegmentIntersection(A,B,C,D)
    return IsClockWise(A, C, D) ~= IsClockWise(B, C, D) and IsClockWise(A, B, C) ~= IsClockWise(A, B, D)
end

function VectorIntersection(a1, b1, a2, b2) --returns a 2D point where to lines intersect (assuming they have an infinite length)
    assert(VectorType(a1) and VectorType(b1) and VectorType(a2) and VectorType(b2), "VectorIntersection: wrong argument types (4 <Vector> expected)")
    local x1, y1, x2, y2, x3, y3, x4, y4 = a1.x, a1.z or a1.y, b1.x, b1.z or b1.y, a2.x, a2.z or a2.y, b2.x, b2.z or b2.y
    local r, s, u, v, k, l = x1 * y2 - y1 * x2, x3 * y4 - y3 * x4, x3 - x4, x1 - x2, y3 - y4, y1 - y2
    local px, py, divisor = r * u - v * s, r * k - l * s, v * k - l * u
    return divisor ~= 0 and Vector(px / divisor, py / divisor)
end

function LineSegmentIntersection(A,B,C,D)
    return IsLineSegmentIntersection(A,B,C,D) and VectorIntersection(A,B,C,D)
end

function VectorDirection(v1, v2, v)
    return ((v.z or v.y) - (v1.z or v1.y)) * (v2.x - v1.x) - ((v2.z or v2.y) - (v1.z or v1.y)) * (v.x - v1.x) 
end

function VectorPointProjectionOnLine(v1, v2, v)
    assert(VectorType(v1) and VectorType(v2) and VectorType(v), "VectorPointProjectionOnLine: wrong argument types (3 <Vector> expected)")
    local line = Vector(v2) - v1
    local t = ((-(v1.x * line.x - line.x * v.x + (v1.z - v.z) * line.z)) / line:len2())
    return (line * t) + v1
end

--[[
    VectorPointProjectionOnLineSegment: Extended VectorPointProjectionOnLine in 2D Space
    v1 and v2 are the start and end point of the linesegment
    v is the point next to the line
    return:
        pointSegment = the point closest to the line segment (table with x and y member)
        pointLine = the point closest to the line (assuming infinite extent in both directions) (table with x and y member), same as VectorPointProjectionOnLine
        isOnSegment = if the point closest to the line is on the segment
]]
function VectorPointProjectionOnLineSegment(v1, v2, v)
    assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

class 'Vector'

function Vector:__init(a, b, c)
    if a == nil then
        self.x, self.y, self.z = 0.0, 0.0, 0.0
    elseif b == nil then
        a = GetOrigin(a) or a
        assert(VectorType(a), "Vector: wrong argument types (expected nil or <Vector> or 2 <number> or 3 <number>)")
        self.x, self.y, self.z = a.x, a.y, a.z
    else
        assert(type(a) == "number" and (type(b) == "number" or type(c) == "number"), "Vector: wrong argument types (<Vector> or 2 <number> or 3 <number>)")
        self.x = a
        if b and type(b) == "number" then self.y = b end
        if c and type(c) == "number" then self.z = c end
    end
end

function Vector:__type()
    return "Vector"
end

function Vector:__add(v)
    assert(VectorType(v) and VectorType(self), "add: wrong argument types (<Vector> expected)")
    return Vector(self.x + v.x, (v.y and self.y) and self.y + v.y, (v.z and self.z) and self.z + v.z)
end

function Vector:__sub(v)
    assert(VectorType(v) and VectorType(self), "Sub: wrong argument types (<Vector> expected)")
    return Vector(self.x - v.x, (v.y and self.y) and self.y - v.y, (v.z and self.z) and self.z - v.z)
end

function Vector.__mul(a, b)
    if type(a) == "number" and VectorType(b) then
        return Vector({ x = b.x * a, y = b.y and b.y * a, z = b.z and b.z * a })
    elseif type(b) == "number" and VectorType(a) then
        return Vector({ x = a.x * b, y = a.y and a.y * b, z = a.z and a.z * b })
    else
        assert(VectorType(a) and VectorType(b), "Mul: wrong argument types (<Vector> or <number> expected)")
        return a:dotP(b)
    end
end

function Vector.__div(a, b)
    if type(a) == "number" and VectorType(b) then
        return Vector({ x = a / b.x, y = b.y and a / b.y, z = b.z and a / b.z })
    else
        assert(VectorType(a) and type(b) == "number", "Div: wrong argument types (<number> expected)")
        return Vector({ x = a.x / b, y = a.y and a.y / b, z = a.z and a.z / b })
    end
end

function Vector.__lt(a, b)
    assert(VectorType(a) and VectorType(b), "__lt: wrong argument types (<Vector> expected)")
    return a:len() < b:len()
end

function Vector.__le(a, b)
    assert(VectorType(a) and VectorType(b), "__le: wrong argument types (<Vector> expected)")
    return a:len() <= b:len()
end

function Vector:__eq(v)
    assert(VectorType(v), "__eq: wrong argument types (<Vector> expected)")
    return self.x == v.x and self.y == v.y and self.z == v.z
end

function Vector:__unm()
    return Vector(-self.x, self.y and -self.y, self.z and -self.z)
end

function Vector:__vector(v)
    assert(VectorType(v), "__vector: wrong argument types (<Vector> expected)")
    return self:crossP(v)
end

function Vector:__tostring()
    if self.y and self.z then
        return "(" .. tostring(self.x) .. "," .. tostring(self.y) .. "," .. tostring(self.z) .. ")"
    else
        return "(" .. tostring(self.x) .. "," .. self.y and tostring(self.y) or tostring(self.z) .. ")"
    end
end

function Vector:clone()
    return Vector(self)
end

function Vector:unpack()
    return self.x, self.y, self.z
end

function Vector:len2(v)
    assert(v == nil or VectorType(v), "dist: wrong argument types (<Vector> expected)")
    local v = v and Vector(v) or self
    return self.x * v.x + (self.y and self.y * v.y or 0) + (self.z and self.z * v.z or 0)
end

function Vector:len()
    return math.sqrt(self:len2())
end

function Vector:dist(v)
    assert(VectorType(v), "dist: wrong argument types (<Vector> expected)")
    local a = self - v
    return a:len()
end

function Vector:normalize()
    local a = self:len()
    self.x = self.x / a
    if self.y then self.y = self.y / a end
    if self.z then self.z = self.z / a end
end

function Vector:normalized()
    local a = self:clone()
    a:normalize()
    return a
end

function Vector:center(v)
    assert(VectorType(v), "center: wrong argument types (<Vector> expected)")
    return Vector((self + v) / 2)
end

function Vector:crossP(other)
    assert(self.y and self.z and other.y and other.z, "crossP: wrong argument types (3 Dimensional <Vector> expected)")
    return Vector({
        x = other.z * self.y - other.y * self.z,
        y = other.x * self.z - other.z * self.x,
        z = other.y * self.x - other.x * self.y
    })
end

function Vector:dotP(other)
    assert(VectorType(other), "dotP: wrong argument types (<Vector> expected)")
    return self.x * other.x + (self.y and (self.y * other.y) or 0) + (self.z and (self.z * other.z) or 0)
end

function Vector:projectOn(v)
    assert(VectorType(v), "projectOn: invalid argument: cannot project Vector on " .. type(v))
    if type(v) ~= "Vector" then v = Vector(v) end
    local s = self:len2(v) / v:len2()
    return Vector(v * s)
end

function Vector:mirrorOn(v)
    assert(VectorType(v), "mirrorOn: invalid argument: cannot mirror Vector on " .. type(v))
    return self:projectOn(v) * 2
end

function Vector:sin(v)
    assert(VectorType(v), "sin: wrong argument types (<Vector> expected)")
    if type(v) ~= "Vector" then v = Vector(v) end
    local a = self:__vector(v)
    return math.sqrt(a:len2() / (self:len2() * v:len2()))
end

function Vector:cos(v)
    assert(VectorType(v), "cos: wrong argument types (<Vector> expected)")
    if type(v) ~= "Vector" then v = Vector(v) end
    return self:len2(v) / math.sqrt(self:len2() * v:len2())
end

function Vector:angle(v)
    assert(VectorType(v), "angle: wrong argument types (<Vector> expected)")
    return math.acos(self:cos(v))
end

function Vector:affineArea(v)
    assert(VectorType(v), "affineArea: wrong argument types (<Vector> expected)")
    if type(v) ~= "Vector" then v = Vector(v) end
    local a = self:__vector(v)
    return math.sqrt(a:len2())
end

function Vector:triangleArea(v)
    assert(VectorType(v), "triangleArea: wrong argument types (<Vector> expected)")
    return self:affineArea(v) / 2
end

function Vector:rotateXaxis(phi)
    assert(type(phi) == "number", "Rotate: wrong argument types (expected <number> for phi)")
    local c, s = math.cos(phi), math.sin(phi)
    self.y, self.z = self.y * c - self.z * s, self.z * c + self.y * s
end

function Vector:rotateYaxis(phi)
    assert(type(phi) == "number", "Rotate: wrong argument types (expected <number> for phi)")
    local c, s = math.cos(phi), math.sin(phi)
    self.x, self.z = self.x * c + self.z * s, self.z * c - self.x * s
end

function Vector:rotateZaxis(phi)
    assert(type(phi) == "number", "Rotate: wrong argument types (expected <number> for phi)")
    local c, s = math.cos(phi), math.sin(phi)
    self.x, self.y = self.x * c - self.z * s, self.y * c + self.x * s
end

function Vector:rotate(phiX, phiY, phiZ)
    assert(type(phiX) == "number" and type(phiY) == "number" and type(phiZ) == "number", "Rotate: wrong argument types (expected <number> for phi)")
    if phiX ~= 0 then self:rotateXaxis(phiX) end
    if phiY ~= 0 then self:rotateYaxis(phiY) end
    if phiZ ~= 0 then self:rotateZaxis(phiZ) end
end

function Vector:rotated(phiX, phiY, phiZ)
    assert(type(phiX) == "number" and type(phiY) == "number" and type(phiZ) == "number", "Rotated: wrong argument types (expected <number> for phi)")
    local a = self:clone()
    a:rotate(phiX, phiY, phiZ)
    return a
end

-- not yet full 3D functions
function Vector:polar()
    if math.close(self.x, 0) then
        if (self.z or self.y) > 0 then return 90
        elseif (self.z or self.y) < 0 then return 270
        else return 0
        end
    else
        local theta = math.deg(math.atan((self.z or self.y) / self.x))
        if self.x < 0 then theta = theta + 180 end
        if theta < 0 then theta = theta + 360 end
        return theta
    end
end

function Vector:angleBetween(v1, v2)
    assert(VectorType(v1) and VectorType(v2), "angleBetween: wrong argument types (2 <Vector> expected)")
    local p1, p2 = (-self + v1), (-self + v2)
    local theta = p1:polar() - p2:polar()
    if theta < 0 then theta = theta + 360 end
    if theta > 180 then theta = 360 - theta end
    return theta
end

function Vector:compare(v)
    assert(VectorType(v), "compare: wrong argument types (<Vector> expected)")
    local ret = self.x - v.x
    if ret == 0 then ret = self.z - v.z end
    return ret
end

function Vector:perpendicular()
    return Vector(-self.z, self.y, self.x)
end

function Vector:perpendicular2()
    return Vector(self.z, self.y, -self.x)
end

-- }

print("Loaded.")
