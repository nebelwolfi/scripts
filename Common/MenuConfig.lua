myHero = GetMyHero()

local function FillRect(a,b,c,d,e)
	DrawLine(a, b, a+c, b, d, e)
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

_G.heroes = {}
do
	local doSkip = false
	local shouldSkip = GetTickCount()
	OnObjectLoop(function(o)
		if doSkip then return end
		if GetObjectType(o) == Obj_AI_Hero then
			heroes[1+#heroes] = o
		end
	end)
	OnTick(function() 
		if doSkip then return end
		if shouldSkip+250 < GetTickCount() then
			doSkip = true
		end
	end)
end
if not GetSave("MenuConfig").Menu_Base then 
	GetSave("MenuConfig").Menu_Base = {x = 15, y = -5, width = 200} 
end
local mc = nil
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
	if MCadd.startT + 1000 > GetTickCount() or (not mc.MenuKey:Value() and not mc.Show:Value()) then return end
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
		if mc.Show:Value() or mc.MenuKey:Value() then
			for k, v in pairs(MCadd.instances) do
				__MC_DrawInstance(k, v, 0)
			end
		end
	end
	OnDrawMinimap(function() if mc.ontop:Value() then __MC_Draw() end end)
	OnDraw(function() if not mc.ontop:Value() then __MC_Draw() end end)
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
		if mc.Show:Value() or mc.MenuKey:Value() then
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
		if mc.Show:Value() or mc.MenuKey:Value() then
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
local function CalcDamage(source, target, addmg, apdmg)
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
	return math.floor(ADDmg*(1-ArmorPercent))+math.floor(APDmg*(1-MagicArmorPercent))
end

function TargetSelector:__init(head, id, name, mode, range, type, focusselected, ownteam, priorityTable)
	self.head = head
	self.id = id
	self.name = name
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
		[2] = Set {"Ahri", "Anivia", "Annie",	"Brand",	"Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",	"Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",	"TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs" },
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
		FillRect(PS.x-1, PS.y+17*k-1, 2+mc.Width:Value()*50+50+25, 16, ARGB(55,255,255,255))
		FillRect(PS.x, PS.y+17*k, mc.Width:Value()*50+50+25, 14, ARGB(155,0,0,0))
		DrawText(v.p.name, 12, PS.x+2, PS.y+17*k, ARGB(255,255,255,255))
		DrawText(v.p:Value() and " ON" or "OFF", 12, PS.x+2+mc.Width:Value()*50+50, PS.y+17*k, v.p:Value() and ARGB(255,0,255,0) or ARGB(255,255,0,0))
	end
	if PSadd.moveNow then
		local cpos = GetCursorPos()
		PS.x = math.min(math.max(cpos.x - PSadd.moveNow.x, 15), 1920)
		PS.y = math.min(math.max(cpos.y - PSadd.moveNow.y, -5), 1080)
		GetSave("MenuConfig"):Save()
	end
end
OnDrawMinimap(function() if mc.ontop:Value() and mc.ps:Value() then __PS__Draw() end end)
OnDraw(function() if not mc.ontop:Value() and mc.ps:Value() then __PS__Draw() end end)

local function __PS__WndMsg(msg, key)
	if msg == 514 then
		if PSadd.moveNow then PSadd.moveNow = nil end
	end
	if msg == 513 and CursorIsUnder(PS.x, PS.y, mc.Width:Value()*50+25, 17*#PSadd.instances+17) then
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

function MenuConfig:TargetSelector(id, name, mode, range, type, focusselected, ownteam)
	local ts = TargetSelector(self, id, name, mode, range, type, focusselected, ownteam)
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

mc = MenuConfig("MenuConfig", "MenuConfig")
mc:Info("Inf", "MenuConfig Settings")
mc:Boolean("Show", "Show always", true)
mc:Boolean("ontop", "Stay OnTop", false)
mc:Boolean("ps", "PermaShow", true)
mc:DropDown("Width", "Menu Width", 2, {150, 200, 250, 300}, function(value) MC.width = value*50+100 end)
mc:KeyBinding("MenuKey", "Key to open Menu", 16)
PermaShow(mc.MenuKey)
PermaShow(mc.Show)
PermaShow(mc.ontop)

print("MenuConfig loaded.")

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
