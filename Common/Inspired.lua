_G.InspiredVersion = 30

function Set(list)
  local set = {}
  for _, l in ipairs(list) do 
    set[l] = true 
  end
  return set
end

function ctype(t)
    local _type = type(t)
    if _type == "userdata" then
        local metatable = getmetatable(t)
        if not metatable or not metatable.__index then
            t, _type = "userdata", "string"
        end
    end
    if _type == "userdata" or _type == "table" then
        local _getType = t.type or t.Type or t.__type
        _type = type(_getType)=="function" and _getType(t) or type(_getType)=="string" and _getType or _type
    end
    return _type
end

function ctostring(t)
    local _type = type(t)
    if _type == "userdata" then
        local metatable = getmetatable(t)
        if not metatable or not metatable.__index then
            t, _type = "userdata", "string"
        end
    end
    if _type == "userdata" or _type == "table" then
        local _tostring = t.tostring or t.toString or t.__tostring
        if type(_tostring)=="function" then
            local tstring = _tostring(t)
            t = _tostring(t)
        else
            local _ctype = ctype(t) or "Unknown"
            if _type == "table" then
                t = tostring(t):gsub(_type,_ctype) or tostring(t)
            else
                t = _ctype
            end
        end
    end
    return tostring(t)
end

function table.clear(t)
  for i, v in pairs(t) do
    t[i] = nil
  end
end

function table.copy(from, deepCopy)
  if type(from) == "table" then
    local to = {}
    for k, v in pairs(from) do
      if deepCopy and type(v) == "table" then to[k] = table.copy(v)
      else to[k] = v
      end
    end
    return to
  end
end

function table.contains(t, what, member) --member is optional
    assert(type(t) == "table", "table.contains: wrong argument types (<table> expected for t)")
    for i, v in pairs(t) do
        if member and v[member] == what or v == what then return i, v end
    end
end

function table.serialize(t, tab, functions)
  local s, len = {"{\n"}, 1
  for i, v in pairs(t) do
    local iType, vType = type(i), type(v)
    if vType~="userdata" and vType~="function" then
      if tab then 
        s[len+1] = tab 
        len = len + 1
      end
      s[len+1] = "\t"
      if iType == "number" then
        s[len+2], s[len+3], s[len+4] = "[", i, "]"
      elseif iType == "string" then
        s[len+2], s[len+3], s[len+4] = '["', i, '"]'
      end
      s[len+5] = " = "
      if vType == "number" then 
        s[len+6], s[len+7], len = v, ",\n", len + 7
      elseif vType == "string" then 
        s[len+6], s[len+7], s[len+8], len = '"', v, '",\n', len + 8
      elseif vType == "boolean" then 
        s[len+6], s[len+7], len = tostring(v), ",\n", len + 7
      end
    end
  end
  if tab then 
    s[len+1] = tab
    len = len + 1
  end
  s[len+1] = "}"
  return table.concat(s)
end

function table.merge(base, t, deepMerge)
  for i, v in pairs(t) do
    if deepMerge and type(v) == "table" and type(base[i]) == "table" then
      base[i] = table.merge(base[i], v)
    else base[i] = v
    end
  end
  return base
end

--from http://lua-users.org/wiki/SplitJoin
function string.split(str, delim, maxNb)
    -- Eliminate bad cases...
    if not delim or delim == "" or string.find(str, delim) == nil then
        return { str }
    end
    maxNb = (maxNb and maxNb >= 1) and maxNb or 0
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        if nb == maxNb then
            result[nb] = lastPos and string.sub(str, lastPos, #str) or str
            break
        end
        result[nb] = part
        lastPos = pos
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function string.join(arg, del)
    return table.concat(arg, del)
end

function string.trim(s)
    return s:match'^%s*(.*%S)' or ''
end

function string.unescape(s)
    return s:gsub(".",{
        ["\a"] = [[\a]],
        ["\b"] = [[\b]],
        ["\f"] = [[\f]],
        ["\n"] = [[\n]],
        ["\r"] = [[\r]],
        ["\t"] = [[\t]],
        ["\v"] = [[\v]],
        ["\\"] = [[\\]],
        ['"'] = [[\"]],
        ["'"] = [[\']],
        ["["] = "\\[",
        ["]"] = "\\]",
      })
end

function math.isNaN(num)
    return num ~= num
end

-- Round half away from zero
function math.round(num, idp)
    assert(type(num) == "number", "math.round: wrong argument types (<number> expected for num)")
    assert(type(idp) == "number" or idp == nil, "math.round: wrong argument types (<integer> expected for idp)")
    local mult = 10 ^ (idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult
    end
end

function math.close(a, b, eps)
    assert(type(a) == "number" and type(b) == "number", "math.close: wrong argument types (at least 2 <number> expected)")
    eps = eps or 1e-9
    return math.abs(a - b) <= eps
end

function math.limit(val, min, max)
    assert(type(val) == "number" and type(min) == "number" and type(max) == "number", "math.limit: wrong argument types (3 <number> expected)")
    return math.min(max, math.max(min, val))
end

function print(...)
    local t, len = {}, select("#",...)
    for i=1, len do
        local v = select(i,...)
        local _type = type(v)
        if _type == "string" then t[i] = v
        elseif _type == "number" then t[i] = tostring(v)
        elseif _type == "table" then t[i] = table.serialize(v)
        elseif _type == "boolean" then t[i] = v and "true" or "false"
        elseif _type == "userdata" then t[i] = ctostring(v)
        else t[i] = _type
        end
    end
    if len>0 then PrintChat(table.concat(t)) end
end

function Msg(msg, title)
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

local _SC = { menuKey = 16, width = 200, menuIndex = -1, instances = {}, keySwitch = nil, listSwitch = nil, sliderSwitch = nil, lastSwitch = 0 }
local _SCP = {x = 15, y = -5}

function __Menu__Draw()
  if KeyIsDown(_SC.menuKey) or _SC.keySwitch or _SC.listSwitch or _SC.sliderSwitch or GoS.Menu.s.Value() then
    __Menu__Browse()
    __Menu__WndTick()
    FillRect(_SCP.x-2,_SCP.y+18,_SC.width+4,4+20*#_SC.instances,ARGB(55, 255, 255, 255))
    for _=1, #_SC.instances do
      local instance = _SC.instances[_]
      FillRect(_SCP.x,_SCP.y+20*_,_SC.width,20,ARGB(255, 0, 0, 0))
      DrawText(" "..instance.__name.." ",15,_SCP.x,_SCP.y+1+20*_,0xffffffff)
      DrawText(">",15,_SCP.x+_SC.width-15,_SCP.y+1+20*_,0xffffffff)
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
  FillRect(_SCP.x-2+(_SC.width+5)*num,_SCP.y-2+20*_,_SC.width+4,4+20,ARGB(55, 255, 255, 255))
  FillRect(_SCP.x+(_SC.width+5)*num,_SCP.y+20*_,_SC.width,20,ARGB(255, 0, 0, 0))
  DrawText(" "..instance.__name.." ",15,_SCP.x+num*(_SC.width+5),_SCP.y+1+20*_,0xffffffff)
  DrawText(">",15,_SCP.x+_SC.width-15+_SC.width*num,_SCP.y+1+20*_,0xffffffff)
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
    FillRect(_SCP.x-2+(_SC.width+5)*xoff,_SCP.y-2+20*yoff,_SC.width+4,4+20,ARGB(55, 255, 255, 255))
    FillRect(_SCP.x+(_SC.width+5)*xoff,_SCP.y+20*yoff,_SC.width,20,ARGB(255, 0, 0, 0))
    if param.__type == "boolean" then
      DrawText(" "..param.__name.." ",15,_SCP.x+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
      FillRect(_SCP.x+_SC.width-20+(_SC.width+5)*xoff,_SCP.y+20*yoff+2,15,15, param.__val and GoS.Green or GoS.Red)
    elseif param.__type == "key" then
      DrawText(" "..param.__name.." ",15,_SCP.x+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
      FillRect(_SCP.x+_SC.width-21+(_SC.width+5)*xoff,_SCP.y+20*yoff+2,17,15, param.Value() and ARGB(150,0,255,0) or ARGB(150,255,0,0))
      DrawText("["..(param.__key == 32 and "  " or string.char(param.__key)).."]",15,_SCP.x+_SC.width-22+(_SC.width+5)*xoff,_SCP.y+20*yoff+1,0xffffffff)
    elseif param.__type == "slider" then
      DrawText(" "..param.__name.." ",15,_SCP.x+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
      DrawText("<|>",15,_SCP.x+_SC.width-25+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
    elseif param.__type == "list" then
      DrawText(" "..param.__name.." ",15,_SCP.x+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
      DrawText("v",15,_SCP.x+_SC.width-10+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
    elseif param.__type == "info" then
      DrawText(" "..param.__name.." ",15,_SCP.x+(_SC.width+5)*xoff,_SCP.y+1+20*yoff,0xffffffff)
    end
  end
end

function __Menu__DrawListSwitch(param, x, y)
  FillRect(x-2, y-2, _SC.width+4, 20*#param.__list+4, ARGB(55, 255, 255, 255))
  FillRect(x, y, _SC.width, 20*#param.__list,ARGB(255, 0, 0, 0))
  for i = 1, #param.__list do
    local entry = param.__list[i]
    if param.__val == i then
      DrawText("->",15,x+5,20*(i-1)+y,0xffffffff)
    end
    DrawText(tostring(entry),15,x+35,20*(i-1)+y,0xffffffff)
  end
end

function __Menu__DrawSliderSwitch(param, x, y)
  FillRect(x-2, y-2, _SC.width+4, 44, ARGB(55, 255, 255, 255))
  FillRect(x, y, _SC.width, 40,ARGB(255, 0, 0, 0))
  DrawText("Value: "..math.ceil(math.floor(param.__val*param.__inc*1000)/param.__inc)/1000,15,x+5,y,0xffffffff)
  DrawText("[X]",15,x+_SC.width-20,y,0xffffffff)
  DrawText(tostring(""..param.__min),15,x+5,y+20,0xffffffff)
  DrawText(tostring(""..param.__max),15,x+_SC.width-25,y+20,0xffffffff)
  FillRect(x+15,y+20, _SC.width-45, 18, ARGB(55, 255, 255, 255))
  local off = (_SC.width-45) / math.abs(param.__min-param.__max) / param.__inc
  local v = x+15+(param.__val-param.__min)*off
  if param.__max == 0 then
    v = x+15+param.__val*off+math.abs(param.__min-param.__max)*off
  elseif param.__min < 0 then
    v = x+15+param.__val*off+math.abs(param.__min-param.__max)/2*off
  end
  FillRect(v, y+20, 5, 18, GoS.Blue)
end

function __Menu__Browse()
  if _SC.listSwitch or _SC.sliderSwitch then return end
  local mmPos = GetCursorPos()
  for _=1, #_SC.instances do
    local instance = _SC.instances[_]
    local x = _SCP.x
    local y = _SCP.y+20*_
    local width = _SC.width
    local heigth = 20
    if mmPos.x >= x and mmPos.x <= x+_SC.width and mmPos.y >= y and mmPos.y <= y+heigth then
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
  local mmPos = GetCursorPos()
  local x = _SCP.x+(_SC.width+5)*num
  local y = _SCP.y+20*_
  local width = _SC.width
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

function __Menu__WndTick()
  local mmPos = GetCursorPos()
  if not KeyIsDown(1) then return end
  if _SC.listSwitch then
    local x = _SC.listSwitch.x
    local y = _SC.listSwitch.y
    if mmPos.x >= x and mmPos.x <= x+_SC.width then
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
    if mmPos.x >= x and mmPos.x <= x+_SC.width and mmPos.y >= y+20 and mmPos.y <= y+40 then
      if mmPos.x <= x+15 then
        _SC.sliderSwitch.__val = _SC.sliderSwitch.__min
      elseif mmPos.x >= x+_SC.width-30 then
        _SC.sliderSwitch.__val = _SC.sliderSwitch.__max
      else
        local off = (_SC.width-45) / math.abs(_SC.sliderSwitch.__min-_SC.sliderSwitch.__max) / _SC.sliderSwitch.__inc
        local v = (mmPos.x - x - 15) / off
        _SC.sliderSwitch.__val = math.floor(v+_SC.sliderSwitch.__min) * _SC.sliderSwitch.__inc
      end
    end
    if mmPos.x >= x+_SC.width-20 and mmPos.x <= x+_SC.width and mmPos.y >= y-5 and mmPos.y <= y+15 then
      GoS:DelayAction(function() _SC.sliderSwitch = nil end, 125)
      _SC.lastSwitch = GetTickCount() + 125
    end
  end
end

function __Menu__WndMsg()
  local mmPos = GetCursorPos()
  if not _SC.listSwitch and not _SC.sliderSwitch then
    if mmPos.x >= 15 and mmPos.x <= 15+_SC.width and mmPos.y >= 15 and mmPos.y <= 15+20*#_SC.instances then
      return;
    end
    for _=1, #_SC.instances do
      if _SC.instances[_].__active then
        local yoff = #_SC.instances[_].__subMenus
        for i=1, yoff do
          local sub = _SC.instances[_].__subMenus[i]
          if sub.__active and __Menu__SubMenuWndMsg(sub, i+_-1, 1) then
            return;
          end
        end
        for i=1, #_SC.instances[_].__params do
          local x = _SCP.x+_SC.width+5
          local y = _SCP.y+20*(yoff+i+_-1)
          local heigth = 20
          if mmPos.x >= x and mmPos.x <= x+_SC.width and mmPos.y >= y and mmPos.y <= y+heigth then
            __Menu__SwitchParam(_SC.instances[_].__params[i], x, y)
            return;
          end
        end
      end
    end
    __Menu__ResetActive()
  end
end

function __Menu__SubMenuWndMsg(instance, _, num)
  local mmPos = GetCursorPos()
  local yoff = #instance.__subMenus
  local xpos = _SCP.x+(_SC.width+5)*num+_SC.width+5
  local ypos = _SCP.y+_*20
  for i=1, #instance.__params do
    local x = xpos
    local y = ypos+(yoff+i-1)*20
    local heigth = 20
    if mmPos.x >= x and mmPos.x <= x+_SC.width and mmPos.y >= y and mmPos.y <= y+heigth then
      __Menu__SwitchParam(instance.__params[i], x, y)
      return true
    end
  end
  for i=1, #instance.__subMenus do
    local sub = instance.__subMenus[i] 
    if sub.__active and __Menu__SubMenuWndMsg(sub, i+_-1, num+1) then 
      return true
    end
  end
end

function __Menu__SwitchParam(param, x, y)
  if param.__type == "boolean" then
    param.__val = not param.__val
  elseif param.__type == "key" then
    _SC.keySwitch = param
  elseif param.__type == "slider" then
    _SC.sliderSwitch = param
    _SC.sliderSwitch.x = x+_SC.width+5
    _SC.sliderSwitch.y = y
  elseif param.__type == "list" then
    _SC.listSwitch = param
    _SC.listSwitch.x = x+_SC.width+5
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
  self.Menu:Boolean("s", "Show always", false)
  self.Menu:List("w", "Menu width", 2, {150, 200, 250, 300})
  self.Menu:List("l", "Language", 1, {"English", })
  OnLoop(function()
    __Menu__Draw()
    _SC.width = self.Menu.w:Value() * 50 + 100
  end)
  OnWndMsg(function(m,p)
    if (KeyIsDown(_SC.menuKey) or _SC.keySwitch or _SC.listSwitch or _SC.sliderSwitch or GoS.Menu.s.Value()) and m == WM_LBUTTONDOWN then
      __Menu__WndMsg()
    end
  end)
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
  _G.myHeroName = GetObjectName(myHero)
  _G.DAMAGE_MAGIC, _G.DAMAGE_PHYSICAL, _G.DAMAGE_MIXED = 1, 2, 3
  _G.MINION_ALLY, _G.MINION_ENEMY, _G.MINION_JUNGLE = GetTeam(myHero), 300-GetTeam(myHero), 300
  local summonerNameOne = GetCastName(myHero,SUMMONER_1)
  local summonerNameTwo = GetCastName(myHero,SUMMONER_2)
  mixed = Set {"Akali","Corki","Ekko","Evelynn","Ezreal","Kayle","Kennen","KogMaw","Malzahar","MissFortune","Mordekaiser","Pantheon","Poppy","Shaco","Skarner","Teemo","Tristana","TwistedFate","XinZhao","Yoric"}
  ad = Set {"Aatrox","Corki","Darius","Draven","Ezreal","Fiora","Gangplank","Garen","Gnar","Graves","Hecarim","Irelia","JarvanIV","Jax","Jayce","Jinx","Kalista","KhaZix","KogMaw","LeeSin","Lucian","MasterYi","MissFortune","Nasus","Nocturne","Olaf","Pantheon","Quinn","RekSai","Renekton","Rengar","Riven","Shaco","Shyvana","Sion","Sivir","Talon","Tristana","Trundle","Tryndamere","Twitch","Udyr","Urgot","Varus","Vayne","Vi","Warwick","Wukong","XinZhao","Yasuo","Yoric","Zed"}
  ap = Set {"Ahri","Akali","Alistar","Amumu","Anivia","Annie","Azir","Bard","Blitzcrank","Brand","Braum","Cassiopea","ChoGath","Diana","DrMundo","Ekko","Elise","Evelynn","Fiddlesticks","Fizz","Galio","Gragas","Heimerdinger","Janna","Karma","Karthus","Kassadin","Katarina","Kayle","Kennen","LeBlanc","Leona","Lissandra","Lulu","Lux","Malphite","Malzahar","Maokai","Mordekaiser","Morgana","Nami","Nautilus","Nidalee","Nunu","Orianna","Poppy","Rammus","Rumble","Ryze","Sejuani","Shen","Singed","Skarner","Sona","Soraka","Swain","Syndra","TahmKench","Taric","Teemo","Thresh","TwistedFate","Veigar","VelKoz","Viktor","Vladimir","Volibear","Xerath","Zac","Ziggz","Zilean","Zyra"}
  _G.Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))
  _G.Smite = (summonerNameOne:lower():find("summonersmite") and SUMMONER_1 or (summonerNameTwo:lower():find("summonersmite") and SUMMONER_2 or nil))
  _G.Exhaust = (summonerNameOne:lower():find("summonerexhaust") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerexhaust") and SUMMONER_2 or nil))
  self.projectilespeeds = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000, ["SRU_OrderMinionRanged"] = 650, ["SRU_ChaosMinionRanged"] = 650, ["SRU_OrderMinionSiege"] = 1200, ["SRU_ChaosMinionSiege"] = 1200, ["SRUAP_Turret_Chaos1"]  = 1200, ["SRUAP_Turret_Chaos2"]  = 1200, ["SRUAP_Turret_Chaos3"] = 1200, ["SRUAP_Turret_Order1"]  = 1200, ["SRUAP_Turret_Order2"]  = 1200, ["SRUAP_Turret_Order3"] = 1200, ["SRUAP_Turret_Chaos4"] = 1200, ["SRUAP_Turret_Chaos5"] = 500, ["SRUAP_Turret_Order4"] = 1200, ["SRUAP_Turret_Order5"] = 500, ["HA_ChaosMinionRanged"] = 650, ["HA_OrderMinionRanged"] = 650, ["HA_ChaosMinionSiege"] = 1200, ["HA_OrderMinionSiege"] = 1200 }
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
end

function goslib:ProcessSpell(unit, spell)
  local target = spell.target
  if target and IsObjectAlive(target) and GetOrigin(target) then
    if spell.name:lower():find("attack") then
      local timer = self:GetDistance(target,unit)/self:GetProjectileSpeed(unit)+spell.windUpTime
      if not self.tableForHPPrediction[GetNetworkID(target)] then self.tableForHPPrediction[GetNetworkID(target)] = {} end
      table.insert(self.tableForHPPrediction[GetNetworkID(target)], {source = unit, dmg = self:GetDmg(unit, target), time = GetTickCount() + 1000*timer, pos = Vector(unit)})
    end
  end
end
  
function goslib:GetProjectileSpeed(unit)
  return self.projectilespeeds[GetObjectName(unit)] and self.projectilespeeds[GetObjectName(unit)] or math.huge
end

function goslib:PredictHealth(unit, delta)
  if self.tableForHPPrediction[GetNetworkID(unit)] then
    local dmg = 0
    delta = delta + GetLatency()
    for _, attack in pairs(self.tableForHPPrediction[GetNetworkID(unit)]) do
      if IsObjectAlive(attack.source) and GetTickCount() < attack.time and attack.pos == Vector(attack.source) then
        if GetTickCount() + delta > attack.time then
          dmg = dmg + attack.dmg
        end
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
  objectManager.objects = {}
  objectManager.objectLCallbackId = 1
  objectManager.objectACallbackId = 1
  objectManager.tick = 0
  local done = false
  self.objectLoopEvents[objectManager.objectLCallbackId] = function(object)
    done = true
    objectManager.objects[object] = object
  end
  self.afterObjectLoopEvents[objectManager.objectACallbackId] = function()
    if done and self.objectLoopEvents[objectManager.objectLCallbackId] then
      self.objectLoopEvents[objectManager.objectLCallbackId] = nil
    end
    if not self.objectLoopEvents[objectManager.objectLCallbackId] then
      self:FindHeroes()
      self:MakeMinionManager()
      self.afterObjectLoopEvents[objectManager.objectACallbackId] = nil
    end
  end
  OnCreateObj(function(object)
    objectManager.objects[object] = object
  end)
  OnDeleteObj(function(object)
    objectManager.objects[object] = nil
  end)
  local function CleanUp()
    collectgarbage()
    self:DelayAction(CleanUp, 10)
  end
  CleanUp()
end

function goslib:FindHeroes()
  self.heroes = {myHero}
  for i, object in pairs(objectManager.objects) do
    if GetObjectType(object) == Obj_AI_Hero then
      self.heroes[#self.heroes+1] = object
    end
  end
end

function goslib:MakeMinionManager()
  _G.minionManager = {}
  minionManager.maxObjects = 0
  minionManager.objects = {}
  minionManager.unsorted = {}
  minionManager.tick = 0
  for i, object in pairs(objectManager.objects) do
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
      if not object or IsDead(object) then
        return i
      end
    end
  end
  OnLoop(function()
    if minionManager.tick > GetTickCount() then return end
    minionManager.tick = GetTickCount() + 125
    for i, object in pairs(minionManager.unsorted) do
      local object = minionManager.unsorted[i]
      local objName = GetObjectName(object)
      if objName == "Barrel" or (GetTeam(object) == 300 and GetCurrentHP(object) < 100000 or objName:find('_')) then
        local spot = findDeadPlace()
        if spot then
          minionManager.objects[spot] = object
          table.remove(minionManager.unsorted, i)
        else
          minionManager.maxObjects = minionManager.maxObjects + 1
          minionManager.objects[minionManager.maxObjects] = object
          table.remove(minionManager.unsorted, i)
        end
      end
    end
  end)
  OnCreateObj(function(object)
    if GetObjectType(object) == Obj_AI_Minion then
      table.insert(minionManager.unsorted, object)
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
    GapcloseConfig = Menu("Anti-Gapclose ("..self.str[spell]..")", "gapclose")
    self:DelayAction(function()
        for _,k in pairs(self:GetEnemyHeroes()) do
          if self.gapcloserTable[GetObjectName(k)] then
            GapcloseConfig:Boolean(GetObjectName(k).."agap", "On "..GetObjectName(k).." "..(type(self.gapcloserTable[GetObjectName(k)]) == 'number' and self.str[self.gapcloserTable[GetObjectName(k)]] or (GetObjectName(k) == "LeeSin" and "Q" or "E")), true)
          end
        end
    end, 1)
    OnProcessSpell(function(unit, spell)
      if not unit or not self.gapcloserTable[GetObjectName(unit)] or GapcloseConfig[GetObjectName(unit).."agap"] == nil or not GapcloseConfig[GetObjectName(unit).."agap"]:Value() then return end
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
    if unit == nil or GetOrigin(unit) == nil or not IsTargetable(unit) or IsImmune(unit,myHero) or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(myHero) or not self:IsInDistance(unit, range) then return false end
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
    local ArmorPen = GetObjectType(source) == Obj_AI_Minion and 0 or math.floor(GetArmorPenFlat(source))
    local ArmorPenPercent = GetObjectType(source) == Obj_AI_Minion and 1 or math.floor(GetArmorPenPercent(source)*100)/100
    local Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
    local ArmorPercent = (GetObjectType(source) == Obj_AI_Minion and Armor < 0) and 0 or Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
    local MagicPen = math.floor(GetMagicPenFlat(source))
    local MagicPenPercent = math.floor(GetMagicPenPercent(source)*100)/100
    local MagicArmor = GetMagicResist(target)*MagicPenPercent-MagicPen
    local MagicArmorPercent = MagicArmor > 0 and math.floor(MagicArmor*100/(100+MagicArmor))/100 or math.ceil(MagicArmor*100/(100-MagicArmor))/100
    return (GotBuff(source,"exhausted")  > 0 and 0.4 or 1) * math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
end

function goslib:GetTarget(range, damageType)
    damageType = damageType or ad[myHeroName] and 2 or ap[myHeroName] and 1 or mixed[myHeroName] and 3 or 0
    if damageType == 0 then print("Champion "..myHeroName.." not supported by the target selector. Please inform inspired.") end
    local target, steps = nil, 10000
    for _, k in pairs(self:GetEnemyHeroes()) do
        local step = GetCurrentHP(k) / self:CalcDamage(GetMyHero(), k, DAMAGE_MAGIC ~= damageType and 25 or 0, DAMAGE_PHYSICAL ~= damageType and 25 or 0)
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
  if self:ValidTarget(unit) then
    for _,k in pairs(u) do
      slot = GetItemSlot(myHero,k)
      if slot ~= nil and slot ~= 0 and CanUseSpell(myHero, slot) == READY then
        CastTargetSpell(unit, slot)
        return true
      end
    end
  end
  return false
end

function goslib:Circle(col)
  local circle = {}
  circle.object = nil
  circle.color = col or 0xffffffff
  circle.objectACallbackId = #self.afterObjectLoopEvents+1
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
        DrawCircle(circle.x, circle.y, circle.z, circle.r, 1, 128, circle.color)
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
    if v and self:ValidTarget(v) and self:GetDistanceSqr(pos,GetOrigin(v)) < range*range then
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
    if v and GetOrigin(v) ~= nil and not IsDead(v) and v ~= myHero and self:GetDistanceSqr(pos,GetOrigin(v)) < range*range then
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

Msg("Loaded.")
