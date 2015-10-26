_G.InspiredLoaded = true
_G.myHero = GetMyHero()

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

function math.round(num, idp)
  assert(type(num) == "number", "math.round: wrong argument types (<number> expected for num)")
  assert(type(idp) == "number" or idp == nil, "math.round: wrong argument types (<integer> expected for idp)")
  local mult = 10 ^ (idp or 0)
  if num >= 0 then return math.floor(num * mult + 0.5) / mult
  else return math.ceil(num * mult - 0.5) / mult
  end
end

function table.clear(t)
  for i, v in pairs(t) do
  t[i] = nil
  end
end

function table.serialize(t, tab, functions)
  assert(type(t) == "table", "table.serialize: Wrong Argument, table expected")
  local s, len = {"{\n"}, 1
  for i, v in pairs(t) do
    local iType, vType = type(i), type(v)
    if vType~="userdata" and (functions or vType~="function") then
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
        s[len+6], s[len+7], s[len+8], len = '"', v:unescape(), '",\n', len + 8
      elseif vType == "table" then 
        s[len+6], s[len+7], len = table.serialize(v, (tab or "") .. "\t", functions), ",\n", len + 7
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
    else 
      base[i] = v
    end
  end
  return base
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

local _saves, _initSave, lastSave = {}, true, GetTickCount()
function GetSave(name)
  local save
  if not _saves[name] then
    if FileExist(COMMON_PATH .. "\\" .. name .. ".save") then
      local f = loadfile(COMMON_PATH .. "\\" .. name .. ".save")
      if type(f) == "function" then
        _saves[name] = f()
      end
    else
      _saves[name] = {}
    end
  end
  save = _saves[name]
  if not save then
    print("SaveFile: " .. name .. " is broken. Reset.")
    _saves[name] = {}
    save = _saves[name]
  end
  function save:Save()
    local _save, _reload, _clear, _isempty, _remove = self.Save, self.Reload, self.Clear, self.IsEmpty, self.Remove
    self.Save, self.Reload, self.Clear, self.IsEmpty, self.Remove = nil, nil, nil, nil, nil
    WriteFile("return "..table.serialize(self, nil, true), COMMON_PATH .. "\\" .. name .. ".save")
    self.Save, self.Reload, self.Clear, self.IsEmpty, self.Remove = _save, _reload, _clear, _isempty, _remove
  end

  function save:Reload()
    _saves[name] = loadfile(COMMON_PATH .. "\\" .. name .. ".save")()
    save = _saves[name]
  end

  function save:Clear()
    for i, v in pairs(self) do
      if type(v) ~= "function" or (i ~= "Save" and i ~= "Reload" and i ~= "Clear" and i ~= "IsEmpty" and i ~= "Remove") then
        self[i] = nil
      end
    end
  end

  function save:IsEmpty()
    for i, v in pairs(self) do
      if type(v) ~= "function" or (i ~= "Save" and i ~= "Reload" and i ~= "Clear" and i ~= "IsEmpty" and i ~= "Remove") then
        return false
      end
    end
    return true
  end

  function save:Remove()
    for i, v in pairs(_saves) do
      if v == self then
        _saves[i] = nil
      end
      if FileExist(COMMON_PATH .. "\\" .. name .. ".save") then
        DeleteFile(COMMON_PATH .. "\\" .. name .. ".save")
      end
    end
  end

  if _initSave then
    _initSave = nil
    local function saveAll()
      for i, v in pairs(_saves) do
        if v and v.Save then
          if v:IsEmpty() then
            v:Remove()
          else 
            v:Save()
          end
        end
      end
    end
    OnTick(function() if lastSave < GetTickCount() then lastSave = GetTickCount()+10000 saveAll() end end)
  end
  return save
end

function FileExist(path)
  assert(type(path) == "string", "FileExist: wrong argument types (<string> expected for path)")
  local file = io.open(path, "r")
  if file then file:close() return true else return false end
end

function WriteFile(text, path, mode)
  assert(type(text) == "string" and type(path) == "string" and (not mode or type(mode) == "string"), "WriteFile: wrong argument types (<string> expected for text, path and mode)")
  local file = io.open(path, mode or "w+")
  if not file then
    file = io.open(path, mode or "w+")
    if not file then
      return false
    end
  end
  file:write(text)
  file:close()
  return true
end

function CursorIsUnder(x, y, sizeX, sizeY)
  assert(type(x) == "number" and type(y) == "number" and type(sizeX) == "number", "CursorIsUnder: wrong argument types (at least 3 <number> expected)")
  local posX, posY = GetCursorPos().x, GetCursorPos().y
  if sizeY == nil then sizeY = sizeX end
  if sizeX < 0 then
    x = x + sizeX
    sizeX = -sizeX
  end
  if sizeY < 0 then
    y = y + sizeY
    sizeY = -sizeY
  end
  return (posX >= x and posX <= x + sizeX and posY >= y and posY <= y + sizeY)
end

class "MenuConfig"
class "Boolean"
class "DropDown"
class "Slider"
class "ColorPick"
class "Info"
class "Empty"
class "Section"
class "TargetSelector"
class "KeyBinding"
class "PermaShow"

if not GetSave("MenuConfig").Menu_Base then 
  GetSave("MenuConfig").Menu_Base = {x = 15, y = -5, width = 200} 
end

local MC = GetSave("MenuConfig").Menu_Base
local MCadd = {instances = {}, lastChange = 0, startT = GetTickCount()}
local function __MC__remove(name)
  if not GetSave("MenuConfig")[name] then GetSave("MenuConfig")[name] = {} end
  table.clear(GetSave("MenuConfig")[name])
end

local function __MC__load(name)
  if not GetSave("MenuConfig")[name] then GetSave("MenuConfig")[name] = {} end
  return GetSave("MenuConfig")[name]
end

local function __MC__save(name, content)
  if not GetSave("MenuConfig")[name] then GetSave("MenuConfig")[name] = {} end
  table.clear(GetSave("MenuConfig")[name])
  table.merge(GetSave("MenuConfig")[name], content, true)
  GetSave("MenuConfig"):Save()
end

local function __MC_SaveInstance(ins)
  local toSave = {}
  for _, p in pairs(ins.__params) do
    if not toSave[p.id] then toSave[p.id] = {} end
    if p.type == "ColorPick" then
      toSave[p.id].color = p:Value()
    elseif p.type == "TargetSelector" then
      toSave[p.id].focus = p.settings[1]:Value()
      toSave[p.id].mode = p.settings[2]:Value()
    else
      if p.value ~= nil and (p.type ~= "KeyBinding" or p:Toggle()) then toSave[p.id].value = p.value end
      if p.key ~= nil then toSave[p.id].key = p.key end
      if p.isToggle ~= nil then toSave[p.id].isToggle = p:Toggle() end
    end
  end
  for _, i in pairs(ins.__subMenus) do
    toSave[i.__id] = __MC_SaveInstance(i)
  end
  return toSave
end

local function __MC_SaveAll()
  MCadd.lastChange = GetTickCount()
  if MCadd.startT + 1000 > GetTickCount() or (not mc_cfg_base.MenuKey:Value() and not mc_cfg_base.Show:Value()) then return end
  for i=1, #MCadd.instances do
    local ins = MCadd.instances[i]
    __MC__save(ins.__id, __MC_SaveInstance(ins))
  end
end

local function __MC_LoadInstance(ins, saved)
  if not saved then return end
  for _, p in pairs(ins.__params) do
    if p.forceDefault == false then
      if saved[p.id] then
        if p.type == "ColorPick" then
          p:Value({saved[p.id].color.a,saved[p.id].color.r,saved[p.id].color.g,saved[p.id].color.b})
        elseif p.type == "KeyBinding" then
          p:Toggle(saved[p.id].isToggle)
        elseif p.type == "TargetSelector" then
          p.settings[1].value = saved[p.id].focus
          p.settings[2].value = saved[p.id].mode
        else
          if p.value ~= nil then p.value = saved[p.id].value end
          if p.key ~= nil then p.key = saved[p.id].key end
        end
      end
    end
  end
  for _, i in pairs(ins.__subMenus) do
    __MC_LoadInstance(i, saved[i.__id])
  end
end

local function __MC_LoadAll()
  for i=1, #MCadd.instances do
    local ins = MCadd.instances[i]
    __MC_LoadInstance(ins, __MC__load(ins.__id))
  end
end

function GetTextArea(str, size)
  return str:len() * size
end

function __MC_Draw()
  local function __MC_DrawParam(i, p, k)
    if p.type == "Boolean" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      FillRect(MC.x-1+4+MC.width*(k+1)-18, MC.y+2+23*i, 15, 15, p:Value() and ARGB(255,0,255,0) or ARGB(255,255,0,0))
      return 0
    elseif p.type == "KeyBinding" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      if p.key > 32 and p.key < 96 then
        FillRect(MC.x-1+4+MC.width*(k+1)-20, MC.y+2+23*i, 17, 15, p:Value() and ARGB(155,0,255,0) or ARGB(155,255,0,0))
        DrawText("["..(string.char(p.key)).."]",15,MC.x-1+4+MC.width*(k+1)-20, MC.y+1+23*i,0xffffffff)
      else
        FillRect(MC.x-1+4+MC.width*(k+1)-23, MC.y+2+23*i, 22, 15, p:Value() and ARGB(155,0,255,0) or ARGB(155,255,0,0))
        DrawText("["..(p.key).."]",15,MC.x-1+4+MC.width*(k+1)-25, MC.y+1+23*i,0xffffffff)
      end
      if p.active then
        for c,v in pairs(p.settings) do v.active = true end
        __MC_DrawParam(i, p.settings[1], k+1)
        __MC_DrawParam(i+1, p.settings[2], k+1)
      end
      return 0
    elseif p.type == "Slider" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 45, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 43, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      local psize = GetTextArea(""..p.value, 15)
      DrawText(" "..p.value.." ",15,MC.x-1+4+MC.width*(k+1)-psize/2-5, MC.y+2+23*i, 0xffffffff)
      DrawLine(MC.x+5+(4+MC.width)*k, MC.y+23*i+25,MC.x+(4+MC.width)*k+MC.width-5, MC.y+23*i+25,1,ARGB(255,255,255,255))
      DrawText(" "..p.min.." ",10,MC.x+(4+MC.width)*k, MC.y+23*i+30, ARGB(255,255,255,255))
      local psize = GetTextArea(""..p.max, 10)
      DrawText(" "..p.max.." ",10,MC.x+(4+MC.width)*k+MC.width-psize/2-8, MC.y+23*i+30, ARGB(255,255,255,255))
      local lineWidth = MC.width - 10
      local delta = (p.value - p.min) / (p.max - p.min)
      FillRect(MC.x+5+(4+MC.width)*k + lineWidth * delta - 1, MC.y+23*i+22, 3, 8, ARGB(255,255,255,255))
      if p.active then
        if KeyIsDown(1) and CursorIsUnder(MC.x+4+(4+MC.width)*k, MC.y+23*i+15, lineWidth+2, 20) then
          local cpos = GetCursorPos()
          local delta = (cpos.x - (MC.x+5+(4+MC.width)*k)) / lineWidth
          p:Value(math.round(delta * (p.max - p.min) + p.min), p.step)
        end
      end
      return 1
    elseif p.type == "DropDown" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      DrawText("->", 15, MC.x-1+4+MC.width*(k+1)-18, MC.y+2+23*i, 0xffffffff)
      if p.active then
        for m=1,#p.drop do
          local c = p.drop[m]
          FillRect(MC.x-1+(4+MC.width)*(k+1), MC.y-1+23*(i+m-1), MC.width+2, 22, ARGB(55,255,255,255))
          FillRect(MC.x+(4+MC.width)*(k+1), MC.y+23*(i+m-1), MC.width, 20, ARGB(255,0,0,0))
          if p.value == m then
            DrawText("->",15,MC.x+(4+MC.width)*(k+1)+5,MC.y+2+23*(i+m-1),0xffffffff)
          end
          DrawText(" "..c.." ",15,MC.x+(4+MC.width)*(k+1)+20,MC.y+1+23*(i+m-1),0xffffffff)
        end
      end
      return 0
    elseif p.type == "Empty" then
      return p.value
    elseif p.type == "Section" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawLine(MC.x+5+(4+MC.width)*k, MC.y+23*i+10,MC.x+(4+MC.width)*k+MC.width-5, MC.y+23*i+10,1,ARGB(255,255,255,255))
      return 0
    elseif p.type == "TargetSelector" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      DrawText(">", 15, MC.x-1+4+MC.width*(k+1)-17, MC.y+1+23*i, 0xffffffff)
      DrawText("|", 15, MC.x-1+4+MC.width*(k+1)-12, MC.y+1+23*i, 0xffffffff)
      DrawText("<", 15, MC.x-1+4+MC.width*(k+1)-11, MC.y+1+23*i, 0xffffffff)
      if p.active then
        if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i+23, MC.width, 20) then
          p.settings[2].active = true
        else
          if p.settings[2].active and CursorIsUnder(MC.x+(4+MC.width)*(k+2)-5, MC.y+23*i+23, MC.width+5, 23*9) then
          else 
            p.settings[2].active = false
          end
        end
        __MC_DrawParam(i, p.settings[1], k+1)
        __MC_DrawParam(i+1, p.settings[2], k+1)
      end
      return 0
    elseif p.type == "ColorPick" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      FillRect(MC.x-1+4+MC.width*(k+1)-18, MC.y+2+23*i, 5, 15, ARGB(255,255,0,0))
      FillRect(MC.x-1+4+MC.width*(k+1)-13, MC.y+2+23*i, 5, 15, ARGB(255,0,255,0))
      FillRect(MC.x-1+4+MC.width*(k+1)-8, MC.y+2+23*i, 5, 15, ARGB(255,0,0,255))
      if p.active then
        for c,v in pairs(p.color) do v.active = true end
        __MC_DrawParam(i, p.color[1], k+1)
        __MC_DrawParam(i, p.color[2], k+2)
        __MC_DrawParam(i+2, p.color[3], k+1)
        __MC_DrawParam(i+2, p.color[4], k+2)
      end
      return 0
    elseif p.type == "Info" then
      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
      return 0
    else
      return 0
    end
  end
  local function __MC_DrawInstance(k, v, madd)
    if v.__active then
      local sh = #v.__subMenus
      for i=1, sh do
        local s = v.__subMenus[i]
        __MC_DrawInstance(i+k-1, s, madd+1)
      end
      local add = sh
      local ph = #v.__params
      for i=1, ph do
        local p = v.__params[i]
        add = add + __MC_DrawParam(i+k+add-1, p, madd+1)
      end
    end
    FillRect(MC.x-1+(MC.width+4)*madd, MC.y-1+23*k, MC.width+2, 22, ARGB(55,255,255,255))
    FillRect(MC.x+(MC.width+4)*madd, MC.y+23*k, MC.width, 20, ARGB(255,0,0,0))
    DrawText(" "..v.__name.." ",15,MC.x+(MC.width+4)*madd,MC.y+1+23*k,0xffffffff)
    DrawText(">",15,MC.x+(MC.width+4)*madd+MC.width-15,MC.y+1+23*k,0xffffffff)
  end
  local function __MC_Draw()
    if mc_cfg_base.Show:Value() or mc_cfg_base.MenuKey:Value() then
      for k, v in pairs(MCadd.instances) do
        __MC_DrawInstance(k, v, 0)
      end
    end
  end
  OnDrawMinimap(function() if mc_cfg_base.ontop:Value() then __MC_Draw() end end)
  OnDraw(function() if not mc_cfg_base.ontop:Value() then __MC_Draw() end end)
end

local function __MC_WndMsg()
  local function __MC_IsBrowsing()
    local function __MC_IsBrowseParam(i, p, k)
      local isB, ladd = false, 0
      if p.type == "Slider" then ladd = 1 end
      if CursorIsUnder(MC.x+(4+MC.width)*k, MC.y+23*i-2, MC.width, 23+ladd*23) then
        isB = true
      end
      if p.active then 
        if p.type == "Boolean" then
          if CursorIsUnder(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 23) then
            isB = true
            p:Value(not p:Value())
          end
        elseif p.type == "DropDown" then 
          local padd = #p.drop
          for m=1, padd do
            if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i+23*(m-1), MC.width, 23) then
              isB = true
              p:Value(m)
            end
          end
        elseif p.type == "KeyBinding" then 
          if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i, MC.width*2+6, 23) then
            p:Toggle(not p:Toggle())
            isB = true
          elseif CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i+23, MC.width*2+6, 23) then
            MCadd.keyChange = p
            p.settings[2].name = "Press key to change now."
            isB = true
          end
        elseif p.type == "ColorPick" then 
          if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i, MC.width*2+6, 23*4) then
            isB = true
          end
        elseif p.type == "TargetSelector" then
          if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i, MC.width, 23*2) then
            p.settings[1]:Value(not p.settings[1]:Value())
            isB = true
          end
          for m=1, 9 do
            if CursorIsUnder(MC.x+(4+MC.width)*(k+2), MC.y+23*i+23+23*(m-1), MC.width, 23) then
              isB = true
              p.settings[2]:Value(m)
            end
          end
        end
      end
      return isB, ladd
    end
    local function __MC_IsBrowseInstance(k, v, madd)
      if CursorIsUnder(MC.x+(MC.width+4)*madd, MC.y+23*k-2, MC.width, 22) then
        return true
      end
      if v.__active then
        local sh = #v.__subMenus
        for _=1, sh do
          local s = v.__subMenus[_]
          if __MC_IsBrowseInstance(_+k-1, s, madd+1) then
            return true
          end
        end
        local add = sh
        for _, p in pairs(v.__params) do
          local isB, ladd = __MC_IsBrowseParam(_+k-1+add, p, madd+1)
          add = add + ladd
          if isB then
            return true
          end
        end
      end
    end
    if mc_cfg_base.Show:Value() or mc_cfg_base.MenuKey:Value() then
      for k, v in pairs(MCadd.instances) do
        if __MC_IsBrowseInstance(k, v, 0) then
          return true
        end
      end
    end
    return false
  end
  local function __MC_ResetInstance(v, skipID, onlyParams)
    for _, s in pairs(v.__subMenus) do
      if not skipID or skipID ~= v.__id then
        __MC_ResetInstance(s, skipID)
      end
    end
    for _, p in pairs(v.__params) do
      if not skipID or skipID ~= p.__id then
        p.active = false
      end
    end
    if not onlyParams then v.__active = false end
  end
  local function __MC_ResetActive(skipID, onlyParams)
    for k, v in pairs(MCadd.instances) do
      if not skipID or skipID ~= v.__id then
        __MC_ResetInstance(v, skipID, onlyParams)
        if not onlyParams then 
          v.__active = false 
        end
      end
    end
  end
  local function __MC_WndMsg(msg, key)
    if MCadd.keyChange ~= nil then
      if key >= 16 and key ~= 117 then
        MCadd.keyChange.key = key
        MCadd.keyChange.settings[2].name = "> Click to change key <"
        MCadd.keyChange = nil
      end
    end
    if msg == 514 then
      if moveNow then moveNow = nil end
      if not __MC_IsBrowsing() then 
        if MCadd.lastChange < GetTickCount() + 125 then
          __MC_ResetActive()
        end
      end
    end
    if msg == 513 and CursorIsUnder(MC.x, MC.y, MC.width, 23*#MCadd.instances+23) then
      local cpos = GetCursorPos()
      moveNow = {x = cpos.x - MC.x, y = cpos.y - MC.y}
    end
  end
  local function __MC_BrowseParam(i, p, k)
    local isB, ladd = false, 0
    if p.type == "Slider" then ladd = 1 end
    if CursorIsUnder(MC.x+(4+MC.width)*k, MC.y+23*i+ladd*23, MC.width, 20) then
      __MC_ResetInstance(p.head, nil, true)
      p.active = true
    end
    return ladd
  end
  local function __MC_BrowseInstance(k, v, madd)
    if CursorIsUnder(MC.x+(MC.width+4)*madd, MC.y+23*k, MC.width, 20) then
      if not v.__head then __MC_ResetActive(v.__id) end
      if v.__head then
        for _, s in pairs(v.__head.__subMenus) do
          __MC_ResetInstance(s)
        end
        __MC_ResetInstance(v.__head, nil, true)
      end
      v.__active = true
    end
    if v.__active then
      local sh = #v.__subMenus
      for _=1, sh do
        local s = v.__subMenus[_]
        __MC_BrowseInstance(_+k-1, s, madd+1)
      end
      local add = sh
      for _, p in pairs(v.__params) do
        add = add + __MC_BrowseParam(_+k-1+add, p, madd+1) 
      end
    end
  end
  local function __MC_Browse()
    if mc_cfg_base.Show:Value() or mc_cfg_base.MenuKey:Value() then
      for k, v in pairs(MCadd.instances) do
        __MC_BrowseInstance(k, v, 0)
      end
      if moveNow then
        local cpos = GetCursorPos()
        MC.x = math.min(math.max(cpos.x - moveNow.x, 15), 1920)
        MC.y = math.min(math.max(cpos.y - moveNow.y, -5), 1080)
        GetSave("MenuConfig"):Save()
      end
    end
  end
  OnWndMsg(__MC_WndMsg)
  OnTick(__MC_Browse)
end

do -- __MC_Init()
  __MC_Draw()
  __MC_WndMsg()
end

function Boolean:__init(head, id, name, value, callback, forceDefault)
  self.head = head
  self.id = id
  self.name = name
  self.type = "Boolean"
  self.value = value or false
  self.callback = callback
  self.forceDefault = forceDefault or false
end

function Boolean:Value(x)
  if x ~= nil then
    if self.value ~= x then
      self.value = x
      if self.callback then self.callback(self.value) end
      __MC_SaveAll()
    end
  else 
    return self.value
  end
end

function KeyBinding:__init(head, id, name, key, isToggle, callback, forceDefault)
  self.head = head
  self.id = id
  self.name = name
  self.type = "KeyBinding"
  self.key = key
  self.value = forceDefault or false
  self.isToggle = isToggle or false
  self.callback = callback
  self.forceDefault = forceDefault or false
  self.settings = {
          Boolean(head, "isToggle", "Is Toggle:", isToggle, nil, forceDefault),
          Info(head, "change", "> Click to change key <"),
        }
  OnWndMsg(function(msg, key)
    if key == self.key then
      if IsChatOpened() or not IsGameOnTop() then return end
      if self:Toggle() then
        if msg == 256 then
          self.value = not self.value
          if self.callback then self.callback(self.value) end
          __MC_SaveAll()
        end
      else
        if msg == 256 then
          self.value = true
          if self.callback then self.callback(self.value) end
        elseif msg == 257 then
          self.value = false
          if self.callback then self.callback(self.value) end
        end
      end
    end
  end)
end

function KeyBinding:Value(x)
  if x ~= nil then
    if self.value ~= x then
      self.value = x
      if self.callback then self.callback(self.value) end
      __MC_SaveAll()
    end
  else
    return self.value
  end
end

function KeyBinding:Key(x)
  if x ~= nil then
    self.key = x
  else
    return self.key
  end
end

function KeyBinding:Toggle(x)
  if x ~= nil then
    self.settings[1]:Value(x)
  else
    return self.settings[1]:Value()
  end
end

function ColorPick:__init(head, id, name, color, callback, forceDefault)
  self.head = head
  self.id = id
  self.name = name
  self.type = "ColorPick"
  self.color = {
          Slider(head, "c1", "Alpha", color[1], 0, 255, 1, callback, forceDefault),
          Slider(head, "c2", "Red", color[2], 0, 255, 1, callback, forceDefault),
          Slider(head, "c3", "Green", color[3], 0, 255, 1, callback, forceDefault),
          Slider(head, "c4", "Blue", color[4], 0, 255, 1, callback, forceDefault)
        }
end

function ColorPick:Value(x)
  if x ~= nil then
    for i=1,4 do
      self.color[i]:Value(x[i])
    end
    if self.callback then self.callback(self:Value()) end
    __MC_SaveAll()
  else
    return ARGB(self.color[1]:Value(),self.color[2]:Value(),self.color[3]:Value(),self.color[4]:Value())
  end
end

function Info:__init(head, id, name)
  self.head = head
  self.id = id
  self.name = name
  self.type = "Info"
end

function Empty:__init(head, id, value)
  self.head = head
  self.id = id
  self.type = "Empty"
  self.value = value or 0
end

TARGET_LESS_CAST = 1
TARGET_LESS_CAST_PRIORITY = 2
TARGET_PRIORITY = 3
TARGET_MOST_AP = 4
TARGET_MOST_AD = 5
TARGET_CLOSEST = 6
TARGET_NEAR_MOUSE = 7
TARGET_LOW_HP = 8
TARGET_LOW_HP_PRIORITY = 9
DAMAGE_MAGIC = 1
DAMAGE_PHYSICAL = 2

local function GetD(p1, p2)
  local dx = p1.x - p2.x
  local dz = p1.z - p2.z
  return dx*dx + dz*dz
end

function TargetSelector:__init(range, mode, type, focusselected, ownteam, priorityTable)
  self.head = head
  self.id = "id"
  self.name = "name"
  self.type = "TargetSelector"
  self.dtype = type
  self.mode = mode or 1
  self.range = range or 1000
  self.focusselected = focusselected or false
  self.forceDefault = false
  self.ownteam = ownteam
  self.priorityTable = priorityTable or {
    [5] = Set {"Alistar", "Amumu", "Blitzcrank", "Braum", "ChoGath", "DrMundo", "Garen", "Gnar", "Hecarim", "JarvanIV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac"},
    [4] = Set {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax","LeeSin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain","Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"},
    [3] = Set {"Akali", "Diana", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Janna", "Jayce", "Kassadin","Kayle", "KhaZix", "Lissandra", "Mordekaiser", "Nami", "Nidalee", "Riven", "Shaco", "Sona", "Soraka", "TahmKench", "Vladimir", "Yasuo", "Zilean", "Zyra"},
    [2] = Set {"Ahri", "Anivia", "Annie", "Brand",  "Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",  "Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",  "TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs" },
    [1] = Set {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne"},
  }
  self.settings = {
          Boolean(head, "sel", "Focus selected:", self.focusselected, function(var) self.focusselected = var end, false),
          DropDown(head, "mode", "TargetSelector Mode:", self.mode, {"Less Cast", "Less Cast Priority", "Priority", "Most AP", "Most AD", "Closest", "Near Mouse", "Lowest Health", "Lowest Health Priority"}, function(var) self.mode = var end, false)
        }
  OnWndMsg(function(msg, key)
    if msg == 513 then
      local t, d = nil, math.huge
      local mpos = GetMousePos()
      for _, h in pairs(heroes) do
        local p = GetD(GetOrigin(h), mpos)
        if p < d then
          t = h
          d = p
        end
      end
      if t and d < GetHitBox(t)^2.25 then
        self.selected = t
      else
        self.selected = nil
      end
    end
  end)
  self.IsValid = function(t,r)
    if t == nil or GetOrigin(t) == nil or not IsTargetable(t) or IsImmune(t,myHero) or IsDead(t) or not IsVisible(t) or (r and GetD(GetOrigin(t), GetOrigin(myHero)) > r^2) then
      return false
    end
    return true
  end
  OnDraw(function()
    if self.focusselected and self.IsValid(self.selected) then
      DrawCircle(GetOrigin(self.selected), GetHitBox(self.selected), 1, 1, ARGB(155,255,255,0))
    end
  end)
end

function TargetSelector:GetTarget()
  if self.focusselected then
    if self.IsValid(self.selected) then
      return self.selected
    else
      self.selected = nil
    end
  end
  if self.mode == TARGET_LESS_CAST then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = CalcDamage(myHero, hero, self.dtype == DAMAGE_PHYSICAL and 100 or 0, self.dtype == DAMAGE_MAGIC and 100 or 0)
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_LESS_CAST_PRIORITY then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = CalcDamage(myHero, hero, self.dtype == DAMAGE_PHYSICAL and 100 or 0, self.dtype == DAMAGE_MAGIC and 100 or 0)*(self.priorityTable[5][GetObjectName(hero)] and 5 or self.priorityTable[4][GetObjectName(hero)] and 4 or self.priorityTable[3][GetObjectName(hero)] and 3 or self.priorityTable[2][GetObjectName(hero)] and 2 or self.priorityTable[1][GetObjectName(hero)] and 1 or 10)
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_PRIORITY then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = self.priorityTable[5][GetObjectName(hero)] and 5 or self.priorityTable[4][GetObjectName(hero)] and 4 or self.priorityTable[3][GetObjectName(hero)] and 3 or self.priorityTable[2][GetObjectName(hero)] and 2 or self.priorityTable[1][GetObjectName(hero)] and 1 or 10
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_MOST_AP then
    local t, p = nil, -1
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = GetBonusAP(hero)
        if self.IsValid(hero, self.range) and prio > p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_MOST_AD then
    local t, p = nil, -1
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = GetBaseDamage(hero)+GetBonusDmg(hero)
        if self.IsValid(hero, self.range) and prio > p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_CLOSEST then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = GetD(GetOrigin(hero), GetOrigin(myHero))
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_NEAR_MOUSE then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = GetD(GetOrigin(hero), GetMousePos())
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_LOW_HP then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = GetCurrentHP(hero)
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  elseif self.mode == TARGET_LOW_HP_PRIORITY then
    local t, p = nil, math.huge
    for i=1, #heroes do
      local hero = heroes[i]
      if (self.ownteam and GetTeam(hero) == GetTeam(myHero)) or (not self.ownteam and GetTeam(hero) ~= GetTeam(myHero)) then
        local prio = GetCurrentHP(hero)*(self.priorityTable[5][GetObjectName(hero)] and 5 or self.priorityTable[4][GetObjectName(hero)] and 4 or self.priorityTable[3][GetObjectName(hero)] and 3 or self.priorityTable[2][GetObjectName(hero)] and 2 or self.priorityTable[1][GetObjectName(hero)] and 1 or 10)
        if self.IsValid(hero, self.range) and prio < p then
          t = hero
          p = prio
        end
      end
    end
    return t
  end
end

function Section:__init(head, id, name)
  self.head = head
  self.id = id
  self.name = name
  self.type = "Section"
end

function DropDown:__init(head, id, name, value, drop, callback, forceDefault)
  self.head = head
  self.id = id
  self.name = name
  self.type = "DropDown"
  self.value = value
  self.drop = drop
  self.callback = callback
  self.forceDefault = forceDefault or false
end

function DropDown:Value(x)
  if x ~= nil then
    if self.value ~= x then
      self.value = x
      if self.callback then self.callback(self.value) end
      __MC_SaveAll()
    end
  else
    return self.value
  end
end

function Slider:__init(head, id, name, value, min, max, step, callback, forceDefault)
  self.head = head
  self.id = id
  self.name = name
  self.type = "Slider"
  self.value = value
  self.min = min
  self.max = max
  self.step = step or 1
  self.callback = callback
  self.forceDefault = forceDefault or false
end

function Slider:Value(x)
  if x ~= nil then
    if self.value ~= x then
      if x < self.min then self.value = self.min
      elseif x > self.max then self.value = self.max
      else self.value = x
      end
      if self.callback then self.callback(self.value) end
      __MC_SaveAll()
    end
  else
    return self.value
  end
end

function Slider:Modify(min, max, step)
  self.min = min
  self.max = max
  self.step = step or 1
end

function Slider:Get()
  return self.min, self.max, self.step
end

if not GetSave("MenuConfig").Perma_Show then 
  GetSave("MenuConfig").Perma_Show = {x = 15, y = 400} 
end

local PS = GetSave("MenuConfig").Perma_Show
local PSadd = {instances = {}}

local function __PS__Draw()
  local ps = #PSadd.instances
  for k = 1, ps do
    local v = PSadd.instances[k]
    FillRect(PS.x-1, PS.y+17*k-1, 2+mc_cfg_base.Width:Value()*50+50+25, 16, ARGB(55,255,255,255))
    FillRect(PS.x, PS.y+17*k, mc_cfg_base.Width:Value()*50+50+25, 14, ARGB(155,0,0,0))
    DrawText(v.p.name, 12, PS.x+2, PS.y+17*k, ARGB(255,255,255,255))
    DrawText(v.p:Value() and " ON" or "OFF", 12, PS.x+2+mc_cfg_base.Width:Value()*50+50, PS.y+17*k, v.p:Value() and ARGB(255,0,255,0) or ARGB(255,255,0,0))
  end
  if PSadd.moveNow then
    local cpos = GetCursorPos()
    PS.x = math.min(math.max(cpos.x - PSadd.moveNow.x, 15), 1920)
    PS.y = math.min(math.max(cpos.y - PSadd.moveNow.y, -5), 1080)
    GetSave("MenuConfig"):Save()
  end
end
OnDrawMinimap(function() if mc_cfg_base.ontop:Value() and mc_cfg_base.ps:Value() then __PS__Draw() end end)
OnDraw(function() if not mc_cfg_base.ontop:Value() and mc_cfg_base.ps:Value() then __PS__Draw() end end)

local function __PS__WndMsg(msg, key)
  if msg == 514 then
    if PSadd.moveNow then PSadd.moveNow = nil end
  end
  if msg == 513 and CursorIsUnder(PS.x, PS.y, mc_cfg_base.Width:Value()*50+25, 17*#PSadd.instances+17) then
    local cpos = GetCursorPos()
    PSadd.moveNow = {x = cpos.x - PS.x, y = cpos.y - PS.y}
  end
end
--OnWndMsg(__PS__WndMsg)

function PermaShow:__init(p)
  assert(p.type == "Boolean" or p.type == "KeyBinding", "Parameter must be of type Boolean or KeyBinding!")
  self.p = p
  table.insert(PSadd.instances, self)
end;

function MenuConfig:__init(name, id, head)
  self.__name = name
  self.__id = id
  self.__subMenus = {}
  self.__params = {}
  self.__active = false
  self.__head = head
  if not head then
    table.insert(MCadd.instances, self)
    self = __MC__load(id)
  end
  return self
end

function MenuConfig:Menu(id, name)
  local m = MenuConfig(name, id, self)
  table.insert(self.__subMenus, m)
  self[id] = m
end

function MenuConfig:KeyBinding(id, name, key, isToggle, callback, forceDefault)
  local key = KeyBinding(self, id, name, key, isToggle, callback, forceDefault)
  table.insert(self.__params, key)
  self[id] = key
  __MC_LoadAll()
end

function MenuConfig:Boolean(id, name, value, callback, forceDefault)
  local bool = Boolean(self, id, name, value, callback, forceDefault)
  table.insert(self.__params, bool)
  self[id] = bool
  __MC_LoadAll()
end

function MenuConfig:Slider(id, name, value, min, max, step, callback, forceDefault)
  local slide = Slider(self, id, name, value, min, max, step, callback, forceDefault)
  table.insert(self.__params, slide)
  self[id] = slide
  __MC_LoadAll()
end

function MenuConfig:DropDown(id, name, value, drop, callback, forceDefault)
  local d = DropDown(self, id, name, value, drop, callback, forceDefault)
  table.insert(self.__params, d)
  self[id] = d
  __MC_LoadAll()
end

function MenuConfig:ColorPick(id, name, color, callback, forceDefault)
  local cp = ColorPick(self, id, name, color)
  table.insert(self.__params, cp)
  self[id] = cp
  __MC_LoadAll()
end

function MenuConfig:Info(id, name)
  local i = Info(self, id, name)
  table.insert(self.__params, i)
  self[id] = i
  __MC_LoadAll()
end

function MenuConfig:Empty(id, value)
  local e = Empty(self, id, value)
  table.insert(self.__params, e)
  self[id] = e
  __MC_LoadAll()
end

function MenuConfig:TargetSelector(id, name, ts, forceDefault)
  ts.head = self
  ts.id = id
  ts.name = name
  ts.forceDefault = forceDefault
  table.insert(self.__params, ts)
  self[id] = ts
  __MC_LoadAll()
end

function MenuConfig:Section(id, name)
  local s = Section(self, id, name)
  table.insert(self.__params, s)
  self[id] = s
  __MC_LoadAll()
end

-- backward compability
function MenuConfig:SubMenu(id, name)
  local m = MenuConfig(name, id, self)
  table.insert(self.__subMenus, m)
  self[id] = m
end

function MenuConfig:Key(id, name, key, isToggle, callback, forceDefault)
  local key = KeyBinding(self, id, name, key, isToggle, callback, forceDefault)
  table.insert(self.__params, key)
  self[id] = key
  __MC_LoadAll()
end

function MenuConfig:List(id, name, value, drop, callback, forceDefault)
  local d = DropDown(self, id, name, value, drop, callback, forceDefault)
  table.insert(self.__params, d)
  self[id] = d
  __MC_LoadAll()
end

_G.Menu = MenuConfig
-- backward compability end
  
function GetProjectileSpeed(unit)
  return GoS.projectilespeeds[GetObjectName(unit)] or math.huge
end

function AddGapcloseEvent(spell, range, targeted)
    GapcloseSpell = spell
    GapcloseTime = 0
    GapcloseUnit = nil
    GapcloseTargeted = targeted
    GapcloseRange = range
    GoS.str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
    GapcloseConfig = Menu("Anti-Gapclose ("..GoS.str[spell]..")", "gapclose")
    DelayAction(function()
        for _,k in pairs(GetEnemyHeroes()) do
          if GoS.gapcloserTable[GetObjectName(k)] then
            GapcloseConfig:Boolean(GetObjectName(k).."agap", "On "..GetObjectName(k).." "..(type(GoS.gapcloserTable[GetObjectName(k)]) == 'number' and GoS.str[GoS.gapcloserTable[GetObjectName(k)]] or (GetObjectName(k) == "LeeSin" and "Q" or "E")), true)
          end
        end
    end, 1)
    OnProcessSpell(function(unit, spell)
      if not unit or not GoS.gapcloserTable[GetObjectName(unit)] or GapcloseConfig[GetObjectName(unit).."agap"] == nil or not GapcloseConfig[GetObjectName(unit).."agap"]:Value() then return end
      local unitName = GetObjectName(unit)
      if spell.name == (type(GoS.gapcloserTable[unitName]) == 'number' and GetCastName(unit, GoS.gapcloserTable[unitName]) or GoS.gapcloserTable[unitName]) and (spell.target == myHero or GetDistanceSqr(spell.endPos) < GapcloseRange*GapcloseRange*4) then
        GapcloseTime = GetTickCount() + 2000
        GapcloseUnit = unit
      end
    end)
    OnTick(function(myHero)
      if CanUseSpell(myHero, GapcloseSpell) == READY and GapcloseTime and GapcloseUnit and GapcloseTime >GetTickCount() then
        local pos = GetOrigin(GapcloseUnit)
        if GapcloseTargeted then
          if GetDistanceSqr(pos,myHeroPos()) < GapcloseRange*GapcloseRange then
            CastTargetSpell(GapcloseUnit, GapcloseSpell)
          end
        else 
          if GetDistanceSqr(pos,myHeroPos()) < GapcloseRange*GapcloseRange*4 then
            CastSkillShot(GapcloseSpell, pos.x, pos.y, pos.z)
          end
        end
      else
        GapcloseTime = 0
        GapcloseUnit = nil
      end
    end)
end

function IsInDistance(p1,r)
    return GetDistanceSqr(GetOrigin(p1)) < r*r
end

function GetDistance(p1,p2)
  p1 = GetOrigin(p1) or p1
  p2 = GetOrigin(p2) or p2 or myHeroPos()
  return math.sqrt(GetDistanceSqr(p1,p2))
end

function GetDistanceSqr(p1,p2)
    p2 = p2 or myHeroPos()
    local dx = p1.x - p2.x
    local dz = (p1.z or p1.y) - (p2.z or p2.y)
    return dx*dx + dz*dz
end

function GetYDistance(p1, p2)
  p1 = GetOrigin(p1) or p1
  p2 = GetOrigin(p2) or p2 or myHeroPos()
  return math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2 + (p1.z - p2.z) ^ 2)
end

function ValidTarget(unit, range)
    range = range or 25000
    if unit == nil or GetOrigin(unit) == nil or not IsTargetable(unit) or IsImmune(unit,myHero) or IsDead(unit) or not IsVisible(unit) or GetTeam(unit) == GetTeam(myHero) or not IsInDistance(unit, range) then return false end
    return true
end

function myHeroPos()
    return GetOrigin(myHero) 
end

function GetMaladySlot(unit)
  for slot = 6, 13 do
    if GetCastName(unit, slot) and GetCastName(unit, slot):lower():find("malady") then
      return slot
    end
  end
  return nil
end

function GetEnemyHeroes()
  local result = {}
  for _=1, #(heroes or {}) do
    local obj = heroes[_]
    if GetTeam(obj) ~= GetTeam(GetMyHero()) then
      table.insert(result, obj)
    end
  end
  return result
end

function GetAllyHeroes()
  local result = {}
  for _=1, #(heroes or {}) do
    local obj = heroes[_]
    if GetTeam(obj) == GetTeam(GetMyHero()) then
      table.insert(result, obj)
    end
  end
  return result
end

function DelayAction(func, delay, args)
    if not GoS.delayedActionsExecuter then
        function GoS.delayedActionsExecuter()
            for t, funcs in pairs(GoS.delayedActions) do
                if t <= GetTickCount() then
                    for _, f in ipairs(funcs) do f.func(unpack(f.args or {})) end
                    GoS.delayedActions[t] = nil
                end
            end
        end
        OnTick(function() GoS.delayedActionsExecuter() end)
    end
    local t = GetTickCount() + (delay or 0)
    if GoS.delayedActions[t] then 
      table.insert(GoS.delayedActions[t], { func = func, args = args })
    else 
      GoS.delayedActions[t] = { { func = func, args = args } }
    end
end

function CalcDamage(source, target, addmg, apdmg)
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
    return (GotBuff(source,"exhausted")  > 0 and 0.6 or 1) * math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
end

function CastOffensiveItems(unit)
  i = {3074, 3077, 3142, 3184}
  u = {3153, 3146, 3144}
  for _,k in pairs(i) do
    slot = GetItemSlot(myHero,k)
    if slot ~= nil and slot ~= 0 and CanUseSpell(myHero, slot) == READY then
      CastTargetSpell(GetMyHero(), slot)
      return true
    end
  end
  if ValidTarget(unit) then
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

function EnemiesAround(pos, range)
  local c = 0
  if pos == nil then return 0 end
  for k,v in pairs(GetEnemyHeroes()) do 
    if v and ValidTarget(v) and GetDistanceSqr(pos,GetOrigin(v)) < range*range then
      c = c + 1
    end
  end
  return c
end

function ClosestEnemy(pos)
  local enemy = nil
  for k,v in pairs(GetEnemyHeroes()) do 
    if not enemy and v then enemy = v end
    if enemy and v and GetDistanceSqr(GetOrigin(enemy),pos) > GetDistanceSqr(GetOrigin(v),pos) then
      enemy = v
    end
  end
  return enemy
end

function AlliesAround(pos, range)
  local c = 0
  if pos == nil then return 0 end
  for k,v in pairs(GetAllyHeroes()) do 
    if v and GetOrigin(v) ~= nil and not IsDead(v) and v ~= myHero and GetDistanceSqr(pos,GetOrigin(v)) < range*range then
      c = c + 1
    end
  end
  return c
end

function ClosestAlly(pos)
  local ally = nil
  for k,v in pairs(GetAllyHeroes()) do 
    if not ally and v then ally = v end
    if ally and v and GetDistanceSqr(GetOrigin(ally),pos) > GetDistanceSqr(GetOrigin(v),pos) then
      ally = v
    end
  end
  return ally
end

function MinionsAround(pos, range, team)
  local c = 0
  if pos == nil then return 0 end
  for k,v in pairs(minionManager.objects) do 
    if v and GetOrigin(v) ~= nil and not IsDead(v) and GetDistanceSqr(pos,GetOrigin(v)) < range*range and (not team or team == GetTeam(v)) then
      c = c + 1
    end
  end
  return c
end

function ClosestMinion(pos, team)
  local m = nil
  for k,v in pairs(minionManager.objects) do 
    if not m and v then m = v end
    if m and v and GetDistanceSqr(GetOrigin(m),pos) > GetDistanceSqr(GetOrigin(v),pos) and (not team or team == GetTeam(v)) then
      m = v
    end
  end
  return m
end

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

class "MinionManager"

function MinionManager:__init()
  self.objects = {}
  self.maxObjects = 0
  OnObjectLoad(function(o) self:CreateObj(o) end)
  OnCreateObj(function(o) self:CreateObj(o) end)
end

function MinionManager:CreateObj(o)
  if o and GetObjectType(o) == Obj_AI_Minion then
    if GetObjectBaseName(o):find('_') or GetObjectName(o):find('_') then
      self:insert(o)
    end
  end
end

function MinionManager:insert(o)
  local function FindSpot()
    for i=1, self.maxObjects do
      local o = self.objects[i]
      if not o or not IsObjectAlive(o) then
        return i
      end
    end
    self.maxObjects = self.maxObjects + 1
    return self.maxObjects
  end
  self.objects[FindSpot()] = o
end

function Ready(slot)
  return CanUseSpell(myHero, slot) == 0
end IsReady = Ready

function GetLineFarmPosition(range, width)
    local BestPos 
    local BestHit = 0
    local objects = minionManager.objects
    for i, object in pairs(objects) do
      if GetOrigin(object) ~= nil and IsObjectAlive(object) and GetTeam(object) ~= GetTeam(myHero) then
        local EndPos = Vector(myHero) + range * (Vector(object) - Vector(myHero)):normalized()
        local hit = CountObjectsOnLineSegment(GetOrigin(myHero), EndPos, width, objects)
        if hit > BestHit and GetDistanceSqr(GetOrigin(object)) < range^2 then
          BestHit = hit
          BestPos = Vector(object)
          if BestHit == #objects then
          break
          end
        end
      end
    end
    return BestPos, BestHit
end

function GetFarmPosition(range, width)
  local BestPos 
  local BestHit = 0
  local objects = minionManager.objects
  for i, object in pairs(objects) do
    if GetOrigin(object) ~= nil and IsObjectAlive(object) and GetTeam(object) ~= GetTeam(myHero) then
      local hit = CountObjectsNearPos(Vector(object), range, width, objects)
      if hit > BestHit and GetDistanceSqr(Vector(object)) < range * range then
        BestHit = hit
        BestPos = Vector(object)
        if BestHit == #objects then
          break
        end
      end
    end
  end
  return BestPos, BestHit
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
  local n = 0
  for i, object in pairs(objects) do
    if GetOrigin(object) ~= nil and IsObjectAlive(object) and GetTeam(object) ~= GetTeam(myHero) then
      local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, GetOrigin(object))
      local w = width
      if isOnSegment and GetDistanceSqr(pointSegment, GetOrigin(object)) < w^2 and GetDistanceSqr(StartPos, EndPos) > GetDistanceSqr(StartPos, GetOrigin(object)) then
        n = n + 1
      end
    end
  end
  return n
end

function CountObjectsNearPos(pos, range, radius, objects)
  local n = 0
  for i, object in pairs(objects) do
    if IsObjectAlive(object) and GetTeam(object) ~= GetTeam(myHero) and GetDistanceSqr(pos, Vector(object)) <= radius^2 then
      n = n + 1
    end
  end
  return n
end

function GetPercentHP(unit)
  return 100 * GetCurrentHP(unit) / GetMaxHP(unit)
end

function GetPercentMP(unit)
  return 100 * GetCurrentMana(unit) / GetMaxMana(unit)
end

-- }

class "InspiredsOrbWalker"

function InspiredsOrbWalker:__init()
  _G.IOWversion = 2
  self.attacksEnabled = true
  self.movementEnabled = true
  self.altAttacks = Set { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3" }
  self.resetAttacks = Set { "dariusnoxiantacticsonh", "fiorae", "garenq", "hecarimrapidslash", "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak", "luciane", "lucianq", "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq", "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow", "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw", "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie", "volibearq", "xenzhaocombotarget", "yorickspectral", "reksaiq", "riventricleave", "itemtitanichydracleave", "itemtiamatcleave" }
  self.autoAttackT = 0
  self.lastBoundingChange = 0
  self.lastStickChange = 0
  self.callbacks = {[1] = {}, [2] = {}, [3] = {}}
  self.bonusDamageTable = { -- TODO: Lulu, Rumble, Nautilus, TwistedFate, Ziggs
    ["Aatrox"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg+(GotBuff(source, "aatroxwpower")>0 and 35*GetCastLevel(source, _W)+25 or 0), APDmg, TRUEDmg
      end,
    ["Ashe"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg*(GotBuff(source, "asheqattack")>0 and 5*(0.01*GetCastLevel(source, _Q)+0.22) or GotBuff(target, "ashepassiveslow")>0 and (1.1+GetCritChance(source)*(1)) or 1), APDmg, TRUEDmg
      end,
    ["Bard"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg+(GotBuff(source, "bardpspiritammocount")>0 and 30+GetLevel(source)*15+0.3*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Blitzcrank"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg*(GotBuff(source, "powerfist")+1), APDmg, TRUEDmg
      end,
    ["Caitlyn"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "caitlynheadshot") > 0 and 1.5*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Chogath"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "vorpalspikes") > 0 and 15*GetCastLevel(source, _E)+5+.3*GetBonusAP(source) or 0), APDmg, TRUEDmg
      end,
    ["Corki"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, 0, TRUEDmg + (GotBuff(source, "rapidreload") > 0 and .1*(ADDmg) or 0)
      end,
    ["Darius"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "dariusnoxiantacticsonh") > 0 and .4*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Diana"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "dianaarcready") > 0 and math.max(5*GetLevel(source)+15,10*GetLevel(source)-10,15*GetLevel(source)-60,20*GetLevel(source)-125,25*GetLevel(source)-200)+.8*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Draven"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "dravenspinning") > 0 and (.1*GetCastLevel(source, _Q)+.35)*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Ekko"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "ekkoeattackbuff") > 0 and 30*GetCastLevel(source, _E)+20+.2*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Fizz"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "fizzseastonepassive") > 0 and 5*GetCastLevel(source, _W)+5+.3*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Garen"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "garenq") > 0 and 25*GetCastLevel(source, _Q)+5+.4*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Gragas"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "gragaswattackbuff") > 0 and 30*GetCastLevel(source, _W)-10+.3*GetBonusAP(source)+(.01*GetCastLevel(source, _W)+.07)*GetMaxHP(minion) or 0), TRUEDmg
      end,
    ["Irelia"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, 0, TRUEDmg + (GotBuff(source, "ireliahitenstylecharged") > 0 and 25*GetCastLevel(source, _Q)+5+.4*(ADDmg) or 0)
      end,
    ["Jax"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "jaxempowertwo") > 0 and 35*GetCastLevel(source, _W)+5+.6*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Jayce"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "jaycepassivemeleeatack") > 0 and 40*GetCastLevel(source, _R)-20+.4*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Jinx"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "jinxq") > 0 and .1*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Kalista"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg * 0.9, APDmg, TRUEDmg
      end,
    ["Kassadin"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "netherbladebuff") > 0 and 20+.1*GetBonusAP(source) or 0) + (GotBuff(source, "netherblade") > 0 and 25*GetCastLevel(source, _W)+15+.6*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Kayle"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "kaylerighteousfurybuff") > 0 and 5*GetCastLevel(source, _E)+5+.15*GetBonusAP(source) or 0) + (GotBuff(source, "judicatorrighteousfury") > 0 and 5*GetCastLevel(source, _E)+5+.15*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Leona"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "leonashieldofdaybreak") > 0 and 30*GetCastLevel(source, _Q)+10+.3*GetBonusAP(source) or 0), TRUEDmg
      end,
    ["Lux"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "luxilluminatingfraulein") > 0 and 10+(GetLevel(source)*8)+(GetBonusAP(source)*0.2) or 0), TRUEDmg
      end,
    ["MasterYi"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "doublestrike") > 0 and .5*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Nocturne"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "nocturneumrablades") > 0 and .2*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Orianna"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + 2 + 8 * math.ceil(GetLevel(source)/3) + 0.15*GetBonusAP(source), TRUEDmg
      end,
    ["RekSai"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "reksaiq") > 0 and 10*GetCastLevel(source, _Q)+5+.2*(ADDmg) or 0), TRUEDmg
      end,
    ["Rengar"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "rengarqbase") > 0 and math.max(30*GetCastLevel(source, _Q)+(.05*GetCastLevel(source, _Q)-.05)*(ADDmg)) or 0) + (GotBuff(source, "rengarqemp") > 0 and math.min(15*GetLevel(source)+15,10*GetLevel(source)+60)+.5*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Shyvana"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "shyvanadoubleattack") > 0 and (.05*GetCastLevel(source, _Q)+.75)*(ADDmg) or 0), APDmg, TRUEDmg
      end,
    ["Talon"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "talonnoxiandiplomacybuff") > 0 and 30*GetCastLevel(source, _Q)+.3*(GetBonusDmg(source)) or 0), APDmg, TRUEDmg
      end,
    ["Teemo"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + 10*GetCastLevel(source, _E)+0.3*GetBonusAP(source), TRUEDmg
      end,
    ["Trundle"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "trundletrollsmash") > 0 and 20*GetCastLevel(source, _Q)+((0.05*GetCastLevel(source, _Q)+0.095)*(ADDmg)) or 0), APDmg, TRUEDmg
      end,
    ["Varus"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg, APDmg + (GotBuff(source, "varusw") > 0 and (4*GetCastLevel(source, _W)+6+.25*GetBonusAP(source)) or 0) , TRUEDmg
      end,
    ["Vayne"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "vaynetumblebonus") > 0 and (.05*GetCastLevel(source, _Q)+.25)*(ADDmg) or 0), 0, TRUEDmg + (GotBuff(target, "vaynesilvereddebuff") > 1 and 10*GetCastLevel(source, _W)+10+((1*GetCastLevel(source, _W)+3)*GetMaxHP(target)/100) or 0)
      end,
    ["Vi"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "vie") > 0 and 15*GetCastLevel(source, _E)-10+.15*(ADDmg)+.7*GetBonusAP(source) or 0) , APDmg, TRUEDmg
      end,
    ["Volibear"] = function(source, target, ADDmg, APDmg, TRUEDmg)
        return ADDmg + (GotBuff(source, "volibearq") > 0 and 30*GetCastLevel(source, _Q) or 0), APDmg, TRUEDmg
      end
  }
  self.tableForHPPrediction = {}
  self:MakeMenu()
  self.mobs = minionManager
  OnTick(function() self:Tick() end)
  OnDraw(function() self:Draw() end)
  OnProcessSpell(function(x,y) self:ProcessSpell(x,y) end)
  OnProcessSpellComplete(function(x,y) self:ProcessSpellComplete(x,y) end)
  OnProcessWaypoint(function(x,y) self:ProcessWaypoint(x,y) end)
  return self
end

function msg(x)
  PrintChat("<font color=\"#00FFFF\">[InspiredsOrbWalker]:</font> <font color=\"#FFFFFF\">"..tostring(x).."</font>")
end

function InspiredsOrbWalker:MakeMenu()
  self.Config = MenuConfig("Inspired'sOrbWalker", "IOW"..myHeroName)
  self.Config:Menu("h", "Hotkeys")
  self.Config.h:KeyBinding("Combo", "Combo", 32)
  self.Config.h:KeyBinding("Harass", "Harass", string.byte("C"))
  self.Config.h:KeyBinding("LastHit", "LastHit", string.byte("X"))
  self.Config.h:KeyBinding("LaneClear", "LaneClear", string.byte("V"))
  self.Config:Slider("stop", "Stickyradius (mouse)", GetHitBox(myHero), 0, 250, 1, function() self.lastBoundingChange = GetTickCount() + 375 end)
  self.Config:Slider("stick", "Stickyradius (target)", GetRange(myHero)*2, 0, 550, 1, function() self.lastStickChange = GetTickCount() + 375 end)
  self.Config:DropDown("lcm", "Lane Clear method", myHeroName == "Vayne" and 2 or 1, {"Focus Highest", "Stick to 1"})
  self.Config:Boolean("sticky", "Stick to one Target", true)
  self.Config:Boolean("wtt", "Walk to Target", true)
  self.Config:Boolean("drawcircle", "Autoattack Circle", true)
  self.Config:ColorPick("circlecol", "Circle color", {255,255,255,255})
  self.Config:Slider("circlequal", "Circle quality", 4, 0, 8, 1)
  self.Config:Info("space", "")
  self.ts = TargetSelector(GetRange(myHero), TARGET_LESS_CAST, DAMAGE_PHYSICAL)
  self.Config:TargetSelector("ts", "TargetSelector", self.ts)
  self.Config:Info("space", "")
  self.Config:Info("version", "Version: v"..IOWversion)
  self.Config:Boolean("OrbWalking", "OrbWalking", false)
  self.permaShow = PermaShow(self.Config.OrbWalking)
  for _,p in pairs(self.Config.__params) do
    if p.id == "OrbWalking" then
      table.remove(self.Config.__params, _)
    end
  end
  self.toLoad = true
  msg("Loaded!")
end

function InspiredsOrbWalker:Mode()
  if self.Config.h.Combo:Value() then
    self:SwitchPermaShow("Combo")
    return "Combo"
  elseif self.Config.h.Harass:Value() then
    self:SwitchPermaShow("Harass")
    return "Harass"
  elseif self.Config.h.LastHit:Value() then
    self:SwitchPermaShow("LastHit")
    return "LastHit"
  elseif self.Config.h.LaneClear:Value() then
    self:SwitchPermaShow("LaneClear")
    return "LaneClear"
  else
    self:SwitchPermaShow("OrbWalking")
    return ""
  end
end

function InspiredsOrbWalker:SwitchPermaShow(mode)
  self.permaShow.p.name = mode
  self.Config["OrbWalking"]:Value(mode ~= "OrbWalking")
end

function InspiredsOrbWalker:Draw()
  if self.Config.drawcircle:Value() then
    DrawCircle(GetOrigin(myHero), GetRange(myHero)+GetHitBox(myHero), 1, (512/self.Config.circlequal:Value()), self.Config.circlecol:Value())
  end
  if self.lastBoundingChange > GetTickCount() then
    DrawCircle(GetOrigin(myHero), self.Config.stop:Value(), 2, 32, ARGB(255,255,255,255))
  end
  if self.lastStickChange > GetTickCount() and self.Config.stick then
    DrawCircle(GetOrigin(myHero), self.Config.stick:Value(), 2, 32, ARGB(255,255,255,255))
  end
end

function InspiredsOrbWalker:Tick()
  if self.toLoad then
    if GetRange(myHero) > 0 then
      if self.Config.stick then
        if self.Config.stick:Value() == 0 then
          self.Config.stick:Value(GetRange(myHero))
        end
      end
      if GetRange(myHero) >= 450 then
        for _,p in pairs(self.Config.__params) do
          if p.id == "wtt" then
            table.remove(self.Config.__params, _)
          end
        end
        self.Config["wtt"] = nil
        for _,p in pairs(self.Config.__params) do
          if p.id == "stick" then
            table.remove(self.Config.__params, _)
          end
        end
        self.Config["stick"] = nil
      end
      self.toLoad = false
    end
  end
  self.Config.ts.range = GetRange(myHero)+GetHitBox(myHero)
  if self:ShouldOrb() then
    self:Orb()
  end
  if self.isWindingDown then
    self.isWindingDown = (GetTickCount()-(self.autoAttackT+1000/(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero))-GetLatency()-70) < 0)
  end
end

function InspiredsOrbWalker:ShouldOrb()
  return self:Mode() ~= ""
end

_G.BEFORE_ATTACK, _G.ON_ATTACK, _G.AFTER_ATTACK = 1, 2, 3
function InspiredsOrbWalker:AddCallback(type, func)
  table.insert(self.callbacks[type], func)
end

function InspiredsOrbWalker:Execute(k, target)
  for _=1, #self.callbacks[k] do
    local func = self.callbacks[k][_]
    if func then
      func(target, self:Mode())
    end
  end
end

function InspiredsOrbWalker:GetTarget()
  if self.Config.h.Combo:Value() then
    return self:CanOrb(self.forceTarget) and self.forceTarget or (self.Config.sticky:Value() and self:CanOrb(self.target) and GetObjectType(self.target) == GetObjectType(myHero)) and self.target or self.Config.ts:GetTarget()
  elseif self.Config.h.Harass:Value() then
    return self:GetLastHit() or self:CanOrb(self.forceTarget) and self.forceTarget or (self.Config.sticky:Value() and self:CanOrb(self.target)) and self.target or self.Config.ts:GetTarget()
  elseif self.Config.h.LastHit:Value() then
    return self:GetLastHit()
  elseif self.Config.h.LaneClear:Value() then
    return self:GetLastHit() or self:GetLaneClear()
  else
    return nil
  end
end

function InspiredsOrbWalker:GetLastHit()
  for i=1, self.mobs.maxObjects do
    local o = self.mobs.objects[i]
    if o and IsObjectAlive(o) and GetTeam(o) == 300-GetTeam(myHero) then
      if self:CanOrb(o) then
        if self:PredictHealth(o, 1000*GetWindUp(myHero) + 1000*math.sqrt(GetDistanceSqr(GetOrigin(o), GetOrigin(myHero))) / self:GetProjectileSpeed(myHero)) < self:GetDmg(myHero, o) then
          return o
        end
      end
    end
  end
end

function InspiredsOrbWalker:GetLaneClear()
  local m = nil
  for i=1, self.mobs.maxObjects do
    local o = self.mobs.objects[i]
    if o and IsObjectAlive(o) and GetTeam(o) ~= MINION_ALLY then
      if self:CanOrb(o) then
        if GetTeam(o) <= 200 and self:PredictHealth(o, 2000/(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero)) + 2000 * math.sqrt(GetDistanceSqr(GetOrigin(o), GetOrigin(myHero))) / self:GetProjectileSpeed(myHero)) < self:GetDmg(myHero, o) then
          return nil
        else
          m = o
        end
      end
    end
  end
  return m
end

function InspiredsOrbWalker:PredictHealth(unit, delta)
  local nID = GetNetworkID(unit)
  if self.tableForHPPrediction[nID] then
    local dmg = 0
    delta = delta + GetLatency()
    for _, k in pairs(self.tableForHPPrediction[nID]) do
      if k.time < GetTickCount() then
        if (k.time + k.reattacktime) - delta < GetTickCount() then
          dmg = dmg + k.dmg
        end
        self.tableForHPPrediction[nID][_] = nil
      else
        if k.time - delta < GetTickCount() then
          dmg = dmg + k.dmg
        end
      end
    end
    return GetCurrentHP(unit) - dmg
  else
    return GetCurrentHP(unit)
  end
end

function InspiredsOrbWalker:GetDmg(source, target)
  if target == nil or source == nil or not IsObjectAlive(source) or not IsObjectAlive(target) then
    return 0
  end
  local ADDmg            = 0
  local APDmg            = 0
  local TRUEDmg          = 0
  local AP               = 0
  local Level            = 0
  local TotalDmg         = GetBonusDmg(source)+GetBaseDamage(source)
  local crit             = 0
  local damageMultiplier = 1
  local sourceType       = GetObjectType(source)
  local targetType       = GetObjectType(target)
  local myHeroType     = GetObjectType(myHero)
  local ArmorPen         = 0
  local ArmorPenPercent  = 0
  local MagicPen         = 0
  local MagicPenPercent  = 0
  local Armor             = GetArmor(target)
  local MagicArmor        = GetMagicResist(target)
  local ArmorPercent      = 0
  local MagicArmorPercent = 0
  if targetType == Obj_AI_Turret then
    ArmorPenPercent = 1
    ArmorPen = 0
  end
  if sourceType == Obj_AI_Minion then
    ArmorPenPercent = 1
    if targetType == myHeroType and GetTeam(source) <= 200 then
      damageMultiplier = 0.60 * damageMultiplier
    elseif targetType == Obj_AI_Turret then
      damageMultiplier = 0.475 * damageMultiplier
    end
    Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
    ArmorPercent = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
  elseif sourceType == Obj_AI_Turret then
    ArmorPenPercent = 0.7
    if GetObjectBaseName(target) == "Red_Minion_MechCannon" or GetObjectBaseName(target) == "Blue_Minion_MechCannon" then
      damageMultiplier = 0.8 * damageMultiplier
    elseif GetObjectBaseName(target) == "Red_Minion_Wizard" or GetObjectBaseName(target) == "Blue_Minion_Wizard" or GetObjectBaseName(target) == "Red_Minion_Basic" or GetObjectBaseName(target) == "Blue_Minion_Basic" then
      damageMultiplier = (1 / 0.875) * damageMultiplier
    end
    damageMultiplier = 1.05 * damageMultiplier
    Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
    if targetType == Obj_AI_Minion then
      ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or 0
    else
      ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
    end
  elseif sourceType == myHeroType then
    if targetType == Obj_AI_Turret then
      TotalDmg = math.max(TotalDmg, GetBaseDamage(source) + 0.4 * GetBonusAP(source))
      damageMultiplier = 0.95 * damageMultiplier
    else
      --damageMultiplier = damageMultiplier * 0.95
      AP = GetBonusAP(source)
      crit = GetCritChance(source)
      ArmorPen         = math.floor(GetArmorPenFlat(source))
      ArmorPenPercent  = math.floor(GetArmorPenPercent(source)*100)/100
      MagicPen         = math.floor(GetMagicPenFlat(source))
      MagicPenPercent  = math.floor(GetMagicPenPercent(source)*100)/100
      Armor = GetArmor(target)*ArmorPenPercent-ArmorPen
      if targetType == Obj_AI_Minion then
        ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or 0
      else
        ArmorPercent      = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
      end
    end
  end
  MagicArmor = GetMagicResist(target)*MagicPenPercent-MagicPen
  local MagicArmorPercent = MagicArmor > 0 and math.floor(MagicArmor*100/(100+MagicArmor))/100 or math.ceil(MagicArmor*100/(100-MagicArmor))/100
  ADDmg = TotalDmg
  if source == myHero and targetType ~= Obj_AI_Turret then
    if GetMaladySlot(source) then
      APDmg = 15 + 0.15*AP
    end
    if GotBuff(source, "itemstatikshankcharge") == 100 then
      APDmg = APDmg + 100
    end
    if source == myHero and not freeze then
      if self.bonusDamageTable[GetObjectName(source)] then
        ADDmg, APDmg, TRUEDmg = self.bonusDamageTable[GetObjectName(source)](source, target, ADDmg, APDmg, TRUEDmg)
      end
      if GotBuff(source, "sheen") > 0 then
        ADDmg = ADDmg + TotalDmg
      end
      if GotBuff(source, "lichbane") > 0 then
        ADDmg = ADDmg + TotalDmg*0.75
        APDmg = APDmg + 0.5*GetBonusAP(source)
      end
      if GotBuff(source, "itemfrozenfist") > 0 then
        ADDmg = ADDmg + TotalDmg*1.25
      end
    end
  end
  dmg = math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
  dmg = math.floor(dmg*damageMultiplier)+TRUEDmg
  return dmg
end

function InspiredsOrbWalker:GetProjectileSpeed(o)
  local s = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000, ["SRU_OrderMinionRanged"] = 650, ["SRU_ChaosMinionRanged"] = 650, ["SRU_OrderMinionSiege"] = 1200, ["SRU_ChaosMinionSiege"] = 1200, ["SRUAP_Turret_Chaos1"]  = 1200, ["SRUAP_Turret_Chaos2"]  = 1200, ["SRUAP_Turret_Chaos3"] = 1200, ["SRUAP_Turret_Order1"]  = 1200, ["SRUAP_Turret_Order2"]  = 1200, ["SRUAP_Turret_Order3"] = 1200, ["SRUAP_Turret_Chaos4"] = 1200, ["SRUAP_Turret_Chaos5"] = 500, ["SRUAP_Turret_Order4"] = 1200, ["SRUAP_Turret_Order5"] = 500, ["HA_ChaosMinionRanged"] = 650, ["HA_OrderMinionRanged"] = 650, ["HA_ChaosMinionSiege"] = 1200, ["HA_OrderMinionSiege"] = 1200 }
  return s[GetObjectName(o)] or math.huge
end

function InspiredsOrbWalker:Orb()
  if self.Config.wtt and self.Config.wtt:Value() then
    self.targetPos = self.forcePos or GetOrigin(self.target)
  else
    self.targetPos = nil
  end
  if self.isWindingUp then
    if self.target and IsDead(self.target) then
      self:ResetAA()
    end
    if self.autoAttackT + 1000*GetWindUp(myHero) + GetLatency() + 70 < GetTickCount() then
      self.isWindingUp = false
    end
  else
    self.target = self:GetTarget()
    if self.isWindingDown or not self.target or not self.attacksEnabled then
      if GetDistanceSqr(GetOrigin(myHero), GetMousePos()) > self.Config.stop:Value()^2 and self.movementEnabled then
        if self.targetPos and (not self.target or not GetObjectType(self.target) == GetObjectType(myHero)) and GetDistanceSqr(self.targetPos, GetOrigin(myHero)) < (self.Config.stick:Value())^2 then
          if GetDistanceSqr(GetOrigin(myHero), self.targetPos) > GetRange(myHero)^2 then
            MoveToXYZ(self:MakePos(self.targetPos))
          end
        else
          MoveToXYZ(self:MakePos(self.forcePos or GetMousePos()))
        end
      else
        HoldPosition()
      end
    else
      self:Execute(1, self.target)
      self.autoAttackT = GetTickCount()
      AttackUnit(self.target)
    end
  end
end

function InspiredsOrbWalker:MakePos(p)
  local mPos = p
  local hPos = GetOrigin(myHero)
  local tV = {x = (mPos.x-hPos.x), y = (mPos.z-hPos.z), z = (mPos.z-hPos.z)}
  local len = math.sqrt(tV.x * tV.x + tV.y * tV.y + tV.z * tV.z)
  local ran = math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)+math.random(50)
  return {x = hPos.x + (250+ran) * tV.x / len, y = hPos.y, z = hPos.z + (250+ran) * tV.z / len}
end

function InspiredsOrbWalker:CanOrb(t)
  local r = GetRange(myHero)+GetHitBox(myHero)
  if t == nil or GetOrigin(t) == nil or not IsTargetable(t) or IsImmune(t,myHero) or IsDead(t) or not IsVisible(t) or (r and GetDistanceSqr(GetOrigin(t), GetOrigin(myHero)) > r^2) then
    return false
  end
  return true
end

function InspiredsOrbWalker:ProcessSpell(unit, spell)
  if unit and spell and unit == myHero and spell.name then
    local spellName = spell.name:lower()
    if spellName:find("attack") or self.altAttacks[spellName] then
      self.isWindingDown = false
      self.isWindingUp = true
      self:Execute(2, spell.target)
      self.autoAttackT = GetTickCount()
    end
    if self.resetAttacks[spellName] then
      self:ResetAA()
    end
  end
end

function InspiredsOrbWalker:ProcessSpellComplete(unit, spell)
  if unit and spell and unit == myHero and spell.name then
    local spellName = spell.name:lower()
    if spellName:find("attack") or self.altAttacks[spellName] then
      self.isWindingUp = false
      self.isWindingDown = true
      self.windUpT = GetTickCount()-self.autoAttackT
      self:Execute(3, spell.target)
    end
  end
  local target = spell.target
  if target and IsObjectAlive(target) and GetOrigin(target) then
    if spell.name:lower():find("attack") then
      local nID = GetNetworkID(target)
      local timer = math.sqrt(GetDistanceSqr(GetOrigin(target),GetOrigin(unit)))/self:GetProjectileSpeed(unit)
      if not self.tableForHPPrediction[nID] then self.tableForHPPrediction[nID] = {} end
      table.insert(self.tableForHPPrediction[nID], {source = unit, dmg = self:GetDmg(unit, target), time = GetTickCount() + 1000*timer, reattacktime = spell.animationTime})
    end
  end
end

function InspiredsOrbWalker:ProcessWaypoint(unit, waypoint)
  if unit and waypoint and unit == myHero and waypoint.index > 1 then
    if self.isWindingUp then
      self.isWindingUp = false
    end
  end
end

function InspiredsOrbWalker:ResetAA()
  self.isWindingUp = false
  self.isWindingDown = false
  self.autoAttackT = 0
end

do
  _G.myHeroName = GetObjectName(myHero)
  _G.mapID = GetMapID()
  _G.DAMAGE_MAGIC, _G.DAMAGE_PHYSICAL, _G.DAMAGE_MIXED = 1, 2, 3
  _G.MINION_ALLY, _G.MINION_ENEMY, _G.MINION_JUNGLE = GetTeam(myHero), 300-GetTeam(myHero), 300
  _G.heroes = {}
  if not _G.minionManager then
    OnObjectLoad(function(o)
      if GetObjectType(o) == Obj_AI_Hero then
        heroes[1+#heroes] = o
      end
    end)
    _G.minionManager = MinionManager()
  end
  local summonerNameOne = GetCastName(myHero, SUMMONER_1)
  local summonerNameTwo = GetCastName(myHero, SUMMONER_2)
  _G.Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))
  _G.Exhaust = (summonerNameOne:lower():find("summonerexhaust") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerexhaust") and SUMMONER_2 or nil))
  _G.Barrier = (summonerNameOne:lower():find("summonerbarrier") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerbarrier") and SUMMONER_2 or nil))
  _G.ClairVoyance = (summonerNameOne:lower():find("summonerclairvoyance") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerclairvoyance") and SUMMONER_2 or nil)) 
  _G.Clarity = (summonerNameOne:lower():find("summonermana") and SUMMONER_1 or (summonerNameTwo:lower():find("summonermana") and SUMMONER_2 or nil)) 
  _G.Cleanse = (summonerNameOne:lower():find("summonerboost") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerboost") and SUMMONER_2 or nil)) 
  _G.Flash = (summonerNameOne:lower():find("summonerflash") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerflash") and SUMMONER_2 or nil)) 
  _G.Garrison = (summonerNameOne:lower():find("summonerodingarrison") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerodingarrison") and SUMMONER_2 or nil))
  _G.Ghost = (summonerNameOne:lower():find("summonerhaste") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerhaste") and SUMMONER_2 or nil))
  _G.Heal = (summonerNameOne:lower():find("summonerheal") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerheal") and SUMMONER_2 or nil))
  _G.Smite = (summonerNameOne:lower():find("smite") and SUMMONER_1 or (summonerNameTwo:lower():find("smite") and SUMMONER_2 or nil))
  _G.Snowball = (summonerNameOne:lower():find("summonersnowball") and SUMMONER_1 or (summonerNameTwo:lower():find("summonersnowball") and SUMMONER_2 or nil))
  _G.Teleport = (summonerNameOne:lower():find("summonerteleport") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerteleport") and SUMMONER_2 or nil))


  mixed = Set {"Akali","Corki","Ekko","Evelynn","Ezreal","Kayle","Kennen","KogMaw","Malzahar","MissFortune","Mordekaiser","Pantheon","Poppy","Shaco","Skarner","Teemo","Tristana","TwistedFate","XinZhao","Yoric"}
  ad = Set {"Aatrox","Corki","Darius","Draven","Ezreal","Fiora","Gangplank","Garen","Gnar","Graves","Hecarim","Irelia","JarvanIV","Jax","Jayce","Jinx","Kalista","KhaZix","KogMaw","LeeSin","Lucian","MasterYi","MissFortune","Nasus","Nocturne","Olaf","Pantheon","Quinn","RekSai","Renekton","Rengar","Riven","Shaco","Shyvana","Sion","Sivir","Talon","Tristana","Trundle","Tryndamere","Twitch","Udyr","Urgot","Varus","Vayne","Vi","Warwick","Wukong","XinZhao","Yasuo","Yoric","Zed"}
  ap = Set {"Ahri","Akali","Alistar","Amumu","Anivia","Annie","Azir","Bard","Blitzcrank","Brand","Braum","Cassiopea","ChoGath","Diana","DrMundo","Ekko","Elise","Evelynn","Fiddlesticks","Fizz","Galio","Gragas","Heimerdinger","Janna","Karma","Karthus","Kassadin","Katarina","Kayle","Kennen","LeBlanc","Leona","Lissandra","Lulu","Lux","Malphite","Malzahar","Maokai","Mordekaiser","Morgana","Nami","Nautilus","Nidalee","Nunu","Orianna","Poppy","Rammus","Rumble","Ryze","Sejuani","Shen","Singed","Skarner","Sona","Soraka","Swain","Syndra","TahmKench","Taric","Teemo","Thresh","TwistedFate","Veigar","VelKoz","Viktor","Vladimir","Volibear","Xerath","Zac","Ziggz","Zilean","Zyra"}
  projectilespeeds = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000, ["SRU_OrderMinionRanged"] = 650, ["SRU_ChaosMinionRanged"] = 650, ["SRU_OrderMinionSiege"] = 1200, ["SRU_ChaosMinionSiege"] = 1200, ["SRUAP_Turret_Chaos1"]  = 1200, ["SRUAP_Turret_Chaos2"]  = 1200, ["SRUAP_Turret_Chaos3"] = 1200, ["SRUAP_Turret_Order1"]  = 1200, ["SRUAP_Turret_Order2"]  = 1200, ["SRUAP_Turret_Order3"] = 1200, ["SRUAP_Turret_Chaos4"] = 1200, ["SRUAP_Turret_Chaos5"] = 500, ["SRUAP_Turret_Order4"] = 1200, ["SRUAP_Turret_Order5"] = 500, ["HA_ChaosMinionRanged"] = 650, ["HA_OrderMinionRanged"] = 650, ["HA_ChaosMinionSiege"] = 1200, ["HA_OrderMinionSiege"] = 1200 }
  _G.GoS = {}
  GoS.White = ARGB(255,255,255,255)
  GoS.Red = ARGB(255,255,0,0)
  GoS.Blue = ARGB(255,0,0,255)
  GoS.Green = ARGB(255,0,255,0)
  GoS.Pink = ARGB(255,255,0,255)
  GoS.Black = ARGB(255,0,0,0)
  GoS.Yellow = ARGB(255,255,255,0)
  GoS.Cyan = ARGB(255,0,255,255)
  GoS.objectLoopEvents = {}
  GoS.delayedActions = {}
  GoS.delayedActionsExecuter = nil
  GoS.gapcloserTable = {
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
  _G.Dashes = {
    ["Vayne"]      = {Spellslot = _Q, Range = 300},
    ["Riven"]      = {Spellslot = _E, Range = 325},
    ["Ezreal"]     = {Spellslot = _E, Range = 450},
    ["Caitlyn"]    = {Spellslot = _E, Range = 400},
    ["Kassadin"]   = {Spellslot = _R, Range = 700},
    ["Graves"]     = {Spellslot = _E, Range = 425},
    ["Renekton"]   = {Spellslot = _E, Range = 450},
    ["Aatrox"]     = {Spellslot = _Q, Range = 650},
    ["Gragas"]     = {Spellslot = _E, Range = 600},
    ["Khazix"]     = {Spellslot = _E, Range = 600},
    ["Lucian"]     = {Spellslot = _E, Range = 425},
    ["Sejuani"]    = {Spellslot = _Q, Range = 650},
    ["Shen"]       = {Spellslot = _E, Range = 575},
    ["Tryndamere"] = {Spellslot = _E, Range = 660},
    ["Tristana"]   = {Spellslot = _W, Range = 900},
    ["Corki"]      = {Spellslot = _W, Range = 800},
  }
  GapcloseSpell, GapcloseTime, GapcloseUnit, GapcloseTargeted, GapcloseRange = 2, 0, nil, true, 450
  if not _G.mc_cfg_base then
    _G.mc_cfg_base = MenuConfig("MenuConfig", "MenuConfig")
    mc_cfg_base:Info("Inf", "MenuConfig Settings")
    mc_cfg_base:Boolean("Show", "Show always", true)
    mc_cfg_base:Boolean("ontop", "Stay OnTop", false)
    mc_cfg_base:Boolean("ps", "PermaShow", true)
    mc_cfg_base:DropDown("Width", "Menu Width", 2, {150, 200, 250, 300}, function(value) MC.width = value*50+100 end)
    mc_cfg_base:KeyBinding("MenuKey", "Key to open Menu", 16)
    PermaShow(mc_cfg_base.MenuKey)
    PermaShow(mc_cfg_base.Show)
    PermaShow(mc_cfg_base.ontop)
  end
  if not _G.IOW and not _G.IACloaded then _G.IOW = InspiredsOrbWalker() end
end

Msg("Loaded.")

return true
