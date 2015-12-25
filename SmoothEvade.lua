require("Inspired")
_G.EVADEloaded = true
_G.EVADEversion = 8
AutoUpdate("/Inspired-gos/scripts/master/SmoothEvade.lua","/Inspired-gos/scripts/master/SmoothEvade.version","SmoothEvade.lua",EVADEversion)
local myHero = GetMyHero()
local myHeroName = GetObjectName(myHero)
_G.Evade = false

local function Set(list)
	local set = {}
	for _, l in ipairs(list) do 
		set[l] = true 
	end
	return set
end

local function GetD(p1, p2)
	p1 = GetOrigin(p1) or p1
	p2 = GetOrigin(p2) or p2
	local dx = p1.x - p2.x
	local dz = p1.z - p2.z
	return dx*dx + dz*dz
end

local function GetDi(p1, p2)
	return math.sqrt(GetD(p1, p2))
end

local function DrawLine3D(x,y,z,a,b,c,width,col)
	local p1 = WorldToScreen(0, Vector(x,y,z))
	local p2 = WorldToScreen(0, Vector(a,b,c))
	DrawLine(p1.x, p1.y, p2.x, p2.y, width, col)
end

local function DrawRectangleOutline(startPos, endPos, pos, width)
	local c1 = startPos+Vector(Vector(endPos)-startPos):perpendicular():normalized()*width/2
	local c2 = startPos+Vector(Vector(endPos)-startPos):perpendicular2():normalized()*width/2
	local c3 = endPos+Vector(Vector(startPos)-endPos):perpendicular():normalized()*width/2
	local c4 = endPos+Vector(Vector(startPos)-endPos):perpendicular2():normalized()*width/2
	DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,math.ceil(width/100),ARGB(55, 255, 255, 255))
	DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,math.ceil(width/100),ARGB(55, 255, 255, 255))
	DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(55, 255, 255, 255))
	DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(55, 255, 255, 255))
	local c1 = startPos+Vector(Vector(endPos)-startPos):perpendicular():normalized()*width
	local c2 = startPos+Vector(Vector(endPos)-startPos):perpendicular2():normalized()*width
	local c3 = endPos+Vector(Vector(startPos)-endPos):perpendicular():normalized()*width
	local c4 = endPos+Vector(Vector(startPos)-endPos):perpendicular2():normalized()*width
	DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,math.ceil(width/100),ARGB(25, 255, 255, 255))
	DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,math.ceil(width/100),ARGB(25, 255, 255, 255))
	DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(25, 255, 255, 255))
	DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(25, 255, 255, 255))
	if pos then
		DrawCircle(pos, width/2, 1, 32, ARGB(155, 255, 255, 255))
	end
end

class "SmoothEvade"

function SmoothEvade:__init()
	self.Config = MenuConfig("SmoothEvade", "SmoothEvade")
	OnTick(function() self:Dodge() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpell(function(u,s) self:ProcessSpell(u,s) end)
	OnProcessWaypoint(function(x,y) self:ProcessWaypoint(x,y) end)
	OnDeleteObj(function(o) self:DeleteObj(o) end)
	self:Data()
	DelayAction(function()
		for _,k in pairs(heroes) do
		  self.Config:Menu(GetObjectName(k), GetObjectName(k))
		  for i=-8,4 do
			if self.data and self.data[GetObjectName(k)] and self.data[GetObjectName(k)][i] and self.data[GetObjectName(k)][i].name ~= "" and self.data[GetObjectName(k)][i].type then
			  self.Config[GetObjectName(k)]:Boolean(self.str[i], "Evade "..self.str[i], true)
			end
		  end
		end
	end, 1)
	self.Config:Boolean("d", "Draw", true)
	self.Config:Boolean("e", "Evade", true)
	if Dashes[GetObjectName(myHero)] then
		self.Config:Boolean("dd", "Use Dash", true)
		self.Config:Boolean("od", "Use Dash only", false)
		self.dashKey = Dashes[GetObjectName(myHero)].Spellslot
	end
	self.Config:KeyBinding("se", "Stop Evade", string.byte("N"), true)
	self.Config:Slider("ew", "Extrawidth", 20, 0, 100, 0)
	self.Config:Slider("er", "Extrarange", 20, 0, 100, 0)
	self.Config:DropDown("p", "Pathfinding", 1, {"Basic", "Advanced"})
	self.activeSpells = {}
	self.str = { [-8] = "P", [-7] = "E3", [-6] = "E2", [-5] = "W3", [-4] = "W2", [-3] = "Q4", [-2] = "Q3", [-1] = "Q2", [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R", [4] = "R2"}
end

function SmoothEvade:Pos()
	if not self.moveVec then return myHeroPos() end
	return Vector(myHero) + Vector(Vector(self.moveVec) - myHeroPos()):normalized() * GetMoveSpeed(myHero) * 0.25
end

function SmoothEvade:ProcessWaypoint(unit, wp)
  if unit and wp and unit == myHero and wp.index == 1 then
	self.moveVec = wp.position
	if _G.Evade and GetDi(myHeroPos(), wp.position) < 25 then
		self.m = nil
		_G.Evade = false
	end
  end
end

function SmoothEvade:Dodge()
	if not self.Config.e:Value() then _G.Evade = false end
	if _G.Evade and self.m ~= nil then
		if GetD(self.m,myHeroPos()) > GetHitBox(myHero)*GetHitBox(myHero) and GetD(self.m,myHero) < GetMoveSpeed(myHero)^2 and self.m.time > GetGameTimer() and not self.Config.se:Value() then
			if self.dashKey and self.Config.dd:Value() and (CanUseSpell(myHero, self.dashKey) == 0 or self.Config.od:Value()) then
				CastSkillShot(self.dashKey, self.m)
			else
				MoveToXYZ(self.m)
			end
			IOW.forcePos = self.m
			return
		else
			IOW.forcePos = nil
			_G.Evade = false
		end
	end
	for _,spell in pairs(self.activeSpells) do
		local width = self.data[GetObjectName(spell.source)][spell.slot].width
		local range = self.data[GetObjectName(spell.source)][spell.slot].range
		local speed = self.data[GetObjectName(spell.source)][spell.slot].speed
		local delay = self.data[GetObjectName(spell.source)][spell.slot].delay
		local type	= self.data[GetObjectName(spell.source)][spell.slot].type
		local b		= GetHitBox(myHero)
		if speed and speed ~= math.huge and type then
			if type == "linear" then
				if spell.startTime+range/speed+delay+self:GetGroundTime(spell.source, spell.slot) > GetGameTimer() then
					if GetD(spell.startPos,spell.endPos) < range * range + width * width + self.Config.er:Value() * self.Config.er:Value() then
						spell.endPos = Vector(spell.startPos)+Vector(Vector(spell.endPos)-spell.startPos):normalized()*(range+width)
					end
					local p = Vector(spell.startPos)+Vector(Vector(spell.endPos)-spell.startPos):normalized()*(speed*(GetGameTimer()+delay-spell.startTime)-width+self.Config.ew:Value())
					local s = (width+self.Config.ew:Value()+b)^2
					if GetD(myHero,p) <= s or GetD(self:Pos(),p) <= s then
						_G.Evade = true
						self.m = self:FindSafeSpot(spell.startPos,p,width,b,type)
						self.m.speed = speed
						self.m.startPos = Vector(spell.startPos)
						self.m.source = spell.source
						self.m.slot = spell.slot
						self.m.time = spell.startTime+range/speed+delay+self:GetGroundTime(spell.source, spell.slot)
					end
				else
					table.remove(self.activeSpells, _)
				end
			end
			if type == "circular" then
				if spell.startTime+range/speed+delay+self:GetGroundTime(spell.source, spell.slot) > GetGameTimer() then
					local s = (width/2+self.Config.ew:Value()+b)^2
					if GetD(myHero,spell.endPos) <= s or GetD(self:Pos(),spell.endPos) <= s then
						_G.Evade = true
						self.m = self:FindSafeSpot(spell.startPos,spell.endPos,width/2,b,type)
						self.m.speed = speed
						self.m.startPos = Vector(spell.startPos)
						self.m.source = spell.source
						self.m.slot = spell.slot
						self.m.time = spell.startTime+range/speed+delay+self:GetGroundTime(spell.source, spell.slot)
					end
				else
					table.remove(self.activeSpells, _)
				end
			end
		elseif speed and speed == math.huge and type then
			if type == "circular" then
				if spell.startTime+delay+self:GetGroundTime(spell.source, spell.slot) > GetGameTimer() then
					local s = (width/2+self.Config.ew:Value()+b)^2
					if GetD(myHero,spell.endPos) <= s or GetD(self:Pos(),spell.endPos) <= 2 then
						_G.Evade = true
						self.m = self:FindSafeSpot(spell.startPos,spell.endPos,width/2,b,type)
						self.m.speed = speed
						self.m.startPos = Vector(spell.startPos)
						self.m.source = spell.source
						self.m.slot = spell.slot
						self.m.time = spell.startTime+delay+self:GetGroundTime(spell.source, spell.slot)
					end
				else
					table.remove(self.activeSpells, _)
				end
			end
			if type == "linear" then
				if spell.startTime+delay+self:GetGroundTime(spell.source, spell.slot) > GetGameTimer() then
					if GetD(spell.startPos,spell.endPos) < range * range + self.Config.er:Value() * self.Config.er:Value() then
						spell.endPos = spell.startPos+Vector(Vector(spell.endPos)-spell.startPos):normalized()*GetDi(spell.startPos,myHero)
					end
					local s = (width+self.Config.ew:Value()+b)^2
					if GetD(myHero,spell.endPos) < s or GetD(self:Pos(),spell.endPos) < s then
						_G.Evade = true
						self.m = self:FindSafeSpot(spell.startPos,spell.endPos,width,b,"lh")
						self.m.speed = speed
						self.m.startPos = Vector(spell.startPos)
						self.m.source = spell.source
						self.m.slot = spell.slot
						self.m.time = spell.startTime+delay+self:GetGroundTime(spell.source, spell.slot)
					end
				else
					table.remove(self.activeSpells, _)
				end
			end
		end
	end
end

function SmoothEvade:FindSafeSpot(s,p,w,b,t)
	if self.Config.p:Value() == 1 then
		if t == "circular" then
			return Vector(myHero)+Vector(Vector(myHero)-p):normalized()*(w+b)
		elseif t == "lh" then
			local pos1 = Vector(myHero)+Vector(Vector(myHero)-p):normalized()*(w+b+self.Config.ew:Value())
			local pos2 = Vector(myHero)+Vector(Vector(myHero)-p):normalized()*(w+b+self.Config.ew:Value())
			if GetD(pos1,s) < GetD(pos2,s) then
				return pos1
			else
				return pos2
			end
		else
			local pos1 = Vector(myHero)+Vector(Vector(myHero)-p):normalized():perpendicular()*(w+b+self.Config.ew:Value())
			local pos2 = Vector(myHero)+Vector(Vector(myHero)-p):normalized():perpendicular2()*(w+b+self.Config.ew:Value())
			if GetD(pos1,s) < GetD(pos2,s) then
				return pos1
			else
				return pos2
			end
		end
	else
		print("Please use Basic Pathfinding for now.")
		return myHeroPos()
	end
end

function SmoothEvade:Draw()
	if not self.Config.d:Value() then return end
	if _G.Evade and self.m then
		DrawCircle(self.m, GetHitBox(myHero), 2, 32, ARGB(255, 255, 255, 255))
	end
	if self.Config.se:Value() then
		DrawText("Evading Disabled", 35, GetResolution().x/2.5, GetResolution().y/4, ARGB(255, 255, 0, 0))
	end
	for _,spell in pairs(self.activeSpells) do
		local range = self.data[GetObjectName(spell.source)][spell.slot].range
		local width = self.data[GetObjectName(spell.source)][spell.slot].width
		local speed = self.data[GetObjectName(spell.source)][spell.slot].speed
		local delay = self.data[GetObjectName(spell.source)][spell.slot].delay
		local type	= self.data[GetObjectName(spell.source)][spell.slot].type
		if type == "special" then
		elseif speed ~= math.huge then
			if type == "linear" then
				if spell.startTime+range/speed+delay+self:GetGroundTime(spell.source, spell.slot) > GetGameTimer() then
					if GetD(spell.startPos,spell.endPos) ~= range * range then
						spell.endPos = spell.startPos+Vector(Vector(spell.endPos)-spell.startPos):normalized()*(range + width)
					end
					if spell.startTime+delay > GetGameTimer() then
						DrawRectangleOutline(spell.startPos, spell.endPos, nil, width)
					else
						DrawRectangleOutline(spell.startPos, spell.endPos, spell.startPos+Vector(Vector(spell.endPos)-spell.startPos):normalized()*(speed*(GetGameTimer()-delay-spell.startTime) + width/2), width)
					end
				else
					table.remove(self.activeSpells, _)
				end
			elseif type == "circular" then
				if spell.startTime+range/speed+delay+self:GetGroundTime(spell.source, spell.slot) > GetGameTimer() then
					DrawCircle(spell.endPos, width, 2, 32, ARGB(255, 255, 255, 255))
					DrawCircle(spell.endPos, width+50, 2, 32, ARGB(55, 255, 255, 255))
				else
					table.remove(self.activeSpells, _)
				end
			end
		elseif speed == math.huge then
			if type == "circular" then
				if spell.startTime+delay > GetGameTimer() then
					DrawCircle(spell.endPos, width, 2, 32, ARGB(255, 255, 255, 255))
					DrawCircle(spell.endPos, width+50, 2, 32, ARGB(55, 255, 255, 255))
				else
					table.remove(self.activeSpells, _)
				end
			elseif type == "linear" then
				if spell.startTime+delay > GetGameTimer() then
					if GetD(spell.startPos,spell.endPos) < range * range then
						spell.endPos = spell.startPos+Vector(Vector(spell.endPos)-spell.startPos):normalized()*range
					end
					DrawRectangleOutline(spell.startPos, spell.endPos, nil, width)
				else
					table.remove(self.activeSpells, _)
				end
			end
		end
	end
end

function SmoothEvade:GetGroundTime(unit, spell)
	if GetObjectName(unit) == "Lux" and spell == 2 then return 5 end
	if GetObjectName(unit) == "Ziggs" and spell == 1 then return 1 end
	if GetObjectName(unit) == "Ziggs" and spell == 2 then return 1 end
	return 0
end

function SmoothEvade:DeleteObj(o)
	if GetObjectBaseName(o) == "Lux_Base_E_tar_aoe_red.troy" then
		for _,spell in pairs(self.activeSpells) do
			if spell.name == "LuxLightStrikeKugel" then
				table.remove(self.activeSpells, _)
			end
		end
	end
end

function SmoothEvade:ProcessSpell(unit, spell)
	if self.Config and unit and spell and spell.name and GetTeam(unit) ~= GetTeam(myHero) then
		if spell.name:lower():find("attack") or not GetObjectName(spell.target) then return end
		if self.data and self.data[GetObjectName(unit)] then
			for i = -8,4 do
				if self.Config[GetObjectName(unit)][self.str[i]] and spell.name:find(self.data[GetObjectName(unit)][i].name) then
					s = {slot = i, source = unit, startTime = GetGameTimer(), startPos = Vector(unit), endPos = Vector(spell.endPos), name = spell.name}
					table.insert(self.activeSpells, s)
				end
			end
		end
	end
end

function SmoothEvade:Data()
	self.data = {
		["Aatrox"] = {
			[_Q] = { name = "AatroxQ", speed = 450, delay = 0.25, range = 650, width = 285, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "AatroxE", objname = "AatroxEConeMissile", speed = 1250, delay = 0.25, range = 1075, width = 35, collision = false, aoe = false, type = "linear"}
		},
		["Ahri"] = {
			[_Q] = { name = "AhriOrbofDeception", objname = "AhriOrbMissile", speed = 2500, delay = 0.25, range = 1000, width = 100, collision = false, aoe = false, type = "linear"},
			[-1] = { name = "AhriOrbReturn", objname = "AhriOrbReturn", speed = 1900, delay = 0.25, range = 1000, width = 100, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "AhriFoxFire", range = 700},
			[_E] = { name = "AhriSeduce", objname = "AhriSeduceMissile", speed = 1550, delay = 0.25, range = 1000, width = 60, collision = true, aoe = false, type = "linear"},
			[_R] = { name = "AhriTumble", range = 450}
		},
		["Akali"] = {
			[_E] = { name = "CrescentSlash", speed = math.huge, delay = 0.125, range = 0, width = 325, collision = false, aoe = true, type = "circular"}
		},
		["Alistar"] = {
			[_Q] = { name = "Pulverize", speed = math.huge, delay = 0.25, range = 0, width = 365, collision = false, aoe = true, type = "circular"}
		},
		["Amumu"] = {
			[_Q] = { name = "BandageToss", objname = "SadMummyBandageToss", speed = 725, delay = 0.25, range = 1000, width = 100, collision = true, aoe = false, type = "linear"}
		},
		["Anivia"] = {
			--[_Q] = { name = "FlashFrostSpell", objname = "FlashFrostSpell", speed = 850, delay = 0.250, range = 1200, width = 110, collision = false, aoe = false, type = "linear"},
			--[_R] = { name = "GlacialStorm", speed = math.huge, delay = math.huge, range = 615, width = 350, collision = false, aoe = true, type = "circular"}
		},
		["Annie"] = {
			[_Q] = { name = "Disintegrate" },
			--[_W] = { name = "Incinerate", speed = math.huge, delay = 0.25, range = 625, width = 250, collision = false, aoe = true, type = "cone"},
			[_E] = { name = "MoltenShield" },
			[_R] = { name = "InfernalGuardian", speed = math.huge, delay = 0.25, range = 600, width = 300, collision = false, aoe = true, type = "circular"}
		},
		["Ashe"] = {
			[_Q] = { name = "FrostShot", range = 700},
			--[_W] = { name = "Volley", objname = "VolleyAttack", speed = 902, delay = 0.25, range = 1200, width = 100, collision = true, aoe = false, type = "cone"},
			[_E] = { speed = 1500, delay = 0.5, range = 25000, width = 1400, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "EnchantedCrystalArrow", objname = "EnchantedCrystalArrow", speed = 1600, delay = 0.5, range = 25000, width = 100, collision = true, aoe = false, type = "linear"}
		},
		["Azir"] = {
			[_Q] = { name = "AzirQ", speed = 2500, delay = 0.250, range = 880, width = 100, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "AzirW", range = 520},
			--[_E] = { name = "AzirE", range = 1100, delay = 0.25, speed = 1200, width = 60, collision = true, aoe = false, type = "linear"},
			[_R] = { name = "AzirR", speed = 1300, delay = 0.2, range = 520, width = 600, collision = false, aoe = true, type = "linear"}
		},
		["Bard"] = {
			[_Q] = { name = "BardQ", objname = "BardQMissile", speed = 1100, delay = 0.25, range = 850, width = 108, collision = true, aoe = false, type = "linear"},
		        [_R] = { name = "BardR", objname = "BardR", speed = 2100, delay = 0.5, range = 3400, width = 350, collision = false, aoe = false, type = "circular"}
		},
		["Blitzcrank"] = {
			[_Q] = { name = "RocketGrab", objname = "RocketGrabMissile", speed = 1800, delay = 0.250, range = 900, width = 70, collision = true, type = "linear"},
			[_W] = { name = "OverDrive", range = 2500},
			[_E] = { name = "PowerFist", range = 225},
			[_R] = { name = "StaticField", speed = math.huge, delay = 0.25, range = 0, width = 500, collision = false, aoe = false, type = "circular"}
		},
		["Brand"] = {
			[_Q] = { name = "BrandBlaze", objname = "BrandBlazeMissile", speed = 1200, delay = 0.25, range = 1050, width = 80, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "BrandFissure", speed = math.huge, delay = 0.625, range = 1050, width = 275, collision = false, aoe = false, type = "circular"},
			[_E] = { name = "", range = 625},
			[_R] = { name = "BrandWildfire", range = 750}
		},
		["Braum"] = {
			[_Q] = { name = "BraumQ", objname = "BraumQMissile", speed = 1600, delay = 0.25, range = 1000, width = 100, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "BraumR", objname = "braumrmissile", speed = 1250, delay = 0.5, range = 1250, width = 0, collision = false, aoe = false, type = "linear"}
		},
		["Caitlyn"] = {
			[_Q] = { name = "CaitlynPiltoverPeacemaker", objname = "CaitlynPiltoverPeacemaker", speed = 2200, delay = 0.625, range = 1300, width = 0, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "CaitlynEntrapment", objname = "CaitlynEntrapmentMissile",speed = 2000, delay = 0.400, range = 1000, width = 80, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "CaitlynAceintheHole" }
		},
		["Cassiopeia"] = {
			[_Q] = { name = "CassiopeiaNoxiousBlast", objname = "CassiopeiaNoxiousBlast", speed = math.huge, delay = 0.75, range = 850, width = 100, collision = false, aoe = true, type = "circular"},
			--[_W] = { name = "CassiopeiaMiasma", speed = 2500, delay = 0.5, range = 925, width = 90, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "CassiopeiaTwinFang", range = 700},
			--[_R] = { name = "CassiopeiaPetrifyingGaze", objname = "CassiopeiaPetrifyingGaze", speed = math.huge, delay = 0.5, range = 825, width = 410, collision = false, aoe = true, type = "cone"}
		},
		["Chogath"] = {
			[_Q] = { name = "Rupture", objname = "Rupture", speed = math.huge, delay = 0.25, range = 950, width = 300, collision = false, aoe = true, type = "circular"},
			[_W] = { name = "FeralScream", speed = math.huge, delay = 0.5, range = 650, width = 275, collision = false, aoe = false, type = "linear"},
		},
		["Corki"] = {
			[_Q] = { name = "PhosphorusBomb", objname = "PhosphorusBombMissile", speed = 700, delay = 0.4, range = 825, width = 250, collision = false, aoe = false, type = "circular"},
			[_R] = { name = "MissileBarrage", objname = "MissileBarrageMissile", speed = 2000, delay = 0.200, range = 1300, width = 60, collision = false, aoe = false, type = "linear"},
			[4]  = { name = "MissileBarrageBig", objname = "MissileBarrageMissile2", speed = 2000, delay = 0.200, range = 1500, width = 80, collision = false, aoe = false, type = "linear"},
		},
		["Darius"] = {
			--[_Q] = { name = "DariusCleave", objname = "DariusCleave", speed = math.huge, delay = 0.75, range = 450, width = 450, type = "circular"},
			[_W] = { name = "DariusNoxianTacticsONH", range = 275},
			[_E] = { name = "DariusAxeGrabCone", objname = "DariusAxeGrabCone", speed = math.huge, delay = 0.32, range = 570, width = 125},
			[_R] = { name = "DariusExecute", range = 460}
		},
		["Diana"] = {
			[_Q] = { name = "DianaArc", objname = "DianaArcArc", speed = 1500, delay = 0.250, range = 835, width = 130, collision = false, aoe = false, type = "circular"},
			[_W] = { name = "PaleCascade", range = 250},
			[_E] = { name = "DianaVortex", speed = math.huge, delay = 0.33, range = 0, width = 395, collision = false, aoe = false, type = "circular" },
			[_R] = { name = "LunarRush", range = 825}
		},
		["DrMundo"] = {
			[_Q] = { name = "InfectedCleaverMissile", objname = "InfectedCleaverMissile", speed = 2000, delay = 0.250, range = 1050, width = 75, collision = true, aoe = false, type = "linear"}
		},
		["Draven"] = {
			[_E] = { name = "DravenDoubleShot", objname = "DravenDoubleShotMissile", speed = 1400, delay = 0.250, range = 1100, width = 130, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "DravenRCast", objname = "DravenR", speed = 2000, delay = 0.5, range = 25000, width = 160, collision = false, aoe = false, type = "linear"}
		},
		["Ekko"] = {
			[_Q] = { name = "EkkoQ", objname = "ekkoqmis", speed = 1050, delay = 0.25, range = 925, width = 140, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "EkkoW", objname = "EkkoW", speed = math.huge, delay = 2.5, range = 1600, width = 450, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "EkkoE", delay = 0.50, range = 350},
			[_R] = { name = "EkkoR", objname = "EkkoR", speed = math.huge, delay = 0.5, range = 0, width = 400, collision = false, aoe = true, type = "circular"}
		},
		["Elise"] = {
			[_E] = { name = "EliseHumanE", objname = "EliseHumanE", speed = 1450, delay = 0.250, range = 975, width = 70, collision = true, aoe = false, type = "linear"}
		},
		["Evelynn"] = {
			[_R] = { name = "EvelynnR", objname = "EvelynnR", speed = 1300, delay = 0.250, range = 650, width = 350, collision = false, aoe = true, type = "circular" }
		},
		["Ezreal"] = {
			[_Q] = { name = "EzrealMysticShot", objname = "EzrealMysticShotMissile", speed = 2000, delay = 0.25, range = 1200, width = 65, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "EzrealEssenceFlux", objname = "EzrealEssenceFluxMissile", speed = 1200, delay = 0.25, range = 900, width = 90, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "", range = 450},
			[_R] = { name = "EzrealTrueshotBarrage", objname = "EzrealTrueshotBarrage", speed = 2000, delay = 1, range = 25000, width = 180, collision = false, aoe = false, type = "linear"}
		},
		["Fiddlesticks"] = {
		},
		["Fiora"] = {
		},
		["Fizz"] = {
			[_R] = { name = "FizzMarinerDoom", objname = "FizzMarinerDoomMissile", speed = 1350, delay = 0.250, range = 1150, width = 100, collision = false, aoe = false, type = "linear"}
		},
		["Galio"] = {
			[_Q] = { name = "GalioResoluteSmite", objname = "GalioResoluteSmite", speed = 1300, delay = 0.25, range = 900, width = 250, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "GalioRighteousGust", speed = 1200, delay = 0.25, range = 1000, width = 200, collision = false, aoe = false, type = "linear"}
		},
		["Gangplank"] = {
			[_Q] = { name = "GangplankQWrapper", range = 900},
			--[_E] = { name = "GangplankE", speed = math.huge, delay = 0.25, range = 900, width = 250, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "GangplankR", speed = math.huge, delay = 0.25, range = 25000, width = 575, collision = false, aoe = true, type = "circular"}
		},
		["Garen"] = {
		},
		["Gnar"] = {
			[_Q] = { name = "GnarQ", objname = "gnarqmissile", speed = 1225, delay = 0.125, range = 1200, width = 80, collision = false, aoe = false, type = "linear"},
			[-1] = { name = "GnarQReturn", objname = "GnarQMissileReturn", speed = 1225, delay = 0, range = 2500, width = 75, collision = false, aoe = false, type = "linear"},
			[-2] = { name = "GnarBigQ", speed = 2100, delay = 0,5, range = 2500, width = 90, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "GnarBigW", objname = "GnarBigW", speed = math.huge, delay = 0.6, range = 600, width = 80, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "GnarE", objname = "GnarE", speed = 903, delay = 0, range = 473, width = 150, collision = false, aoe = false, type = "circular"}
		},
		["Gragas"] = {
			--[_Q] = { name = "GragasQ", objname = "GragasQMissile", speed = 1000, delay = 0.250, range = 1000, width = 300, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "GragasE", objname = "GragasE", speed = math.huge, delay = 0.250, range = 600, width = 50, collision = true, aoe = true, type = "circular"},
			[_R] = { name = "GragasR", objname = "GragasRBoom", speed = 1000, delay = 0.250, range = 1050, width = 400, collision = false, aoe = true, type = "circular"}
		},
		["Graves"] = {
			[_Q] = { name = "GravesQLineSpell", objname = "GravesQLineMis", speed = 1950, delay = 0.265, range = 750, width = 85, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "GravesSmokeGrenade", speed = 1650, delay = 0.300, range = 700, width = 250, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "GravesChargeShot", objname = "GravesChargeShotShot", speed = 2100, delay = 0.219, range = 1000, width = 100, collision = false, aoe = false, type = "linear"}
		},
		["Hecarim"] = {
			[_Q] = { name = "HecarimRapidSlash", speed = math.huge, delay = 0.250, range = 0, width = 350, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "HecarimUlt", speed = 1900, delay = 0.219, range = 1000, width = 200, collision = false, aoe = false, type = "linear"}
		},
		["Heimerdinger"] = {
			[_W] = { name = "Heimerdingerwm", objname = "HeimerdingerWAttack2", speed = 1800, delay = 0.25, range = 1500, width = 70, collision = true, aoe = false, type = "linear"},
			[_E] = { name = "HeimerdingerE", objname = "heimerdingerespell", speed = 1200, delay = 0.25, range = 925, width = 100, collision = false, aoe = true, type = "circular"}
		},
		["Irelia"] = {
			[_R] = { name = "IreliaTranscendentBlades", objname = "IreliaTranscendentBlades", speed = 1700, delay = 0.250, range = 1200, width = 25, collision = false, aoe = false, type = "linear"}
		},
		["Janna"] = {
			[_Q] = { name = "HowlingGale", objname = "HowlingGaleSpell", speed = 1500, delay = 0.250, range = 1700, width = 150, collision = false, aoe = false, type = "linear"}
		},
		["JarvanIV"] = {
			[_Q] = { name = "JarvanIVDemacianStandard", objname = "JarvanIVDemacianStandard", speed = 1400, delay = 0.25, range = 770, width = 70, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "", speed = 1450, delay = 0.25, range = 850, width = 175, collision = false, aoe = false, type = "linear"}
		},
		["Jax"] = {
			--[_E] = { name = "", speed = math.huge, delay = 0.250, range = 0, width = 375, collision = false, aoe = true, type = "circular"}
		},
		["Jayce"] = {
			[_Q] = { name = "jayceshockblast", objname = "JayceShockBlastMis", speed = 1450, delay = 0.15, range = 1750, width = 70, collision = true, aoe = false, type = "linear"},
			[-1] = { name = "JayceQAccel", objname = "JayceShockBlastWallMis", speed = 2350, delay = 0.15, range = 1300, width = 70, collision = true, aoe = false, type = "linear"}
		},
		["Jinx"] = {
			[_W] = { name = "JinxW", objname = "JinxWMissile", speed = 3000, delay = 0.600, range = 1400, width = 60, collision = true, aoe = false, type = "linear"},
			--[_E] = { name = "JinxE", speed = 887, delay = 0.500, range = 830, width = 0, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "JinxR", objname = "JinxR", speed = 1700, delay = 0.600, range = 20000, width = 140, collision = false, aoe = true, type = "linear"}
		},
		["Kalista"] = {
			[_Q] = { name = "KalistaMysticShot", objname = "kalistamysticshotmis", speed = 1700, delay = 0.25, range = 1150, width = 40, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "", delay = 1.5, range = 5000},
			[_E] = { name = "", range = 1000},
			[_R] = { name = "", range = 2000}
		},
		["Karma"] = {
			[_Q] = { name = "KarmaQ", objname = "KarmaQMissile", speed = 1700, delay = 0.25, range = 1050, width = 60, collision = true, aoe = false, type = "linear"},
		        [-1] = { name = "KarmaQMantra", objname = "KarmaQMissileMantra", speed = 1700, delay = 0.25, range = 950, width = 80, collision = true, aoe = false, type = "linear"}
		},
		["Karthus"] = {
			[_Q] = { name = "KarthusLayWaste", speed = math.huge, delay = 0.775, range = 875, width = 160, collision = false, aoe = true, type = "circular"},
			[_W] = { name = "KarthusWallOfPain", speed = math.huge, delay = 0.25, range = 1000, width = 160, collision = false, aoe = true, type = "circular"},
			--[_E] = { name = "KarthusDefile", speed = math.huge, delay = 0.25, range = 550, width = 550, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "KarthusFallenOne", range = math.huge}
		},
		["Kassadin"] = {
			--[_E] = { name = "", speed = 2200, delay = 0.25, range = 650, width = 80, collision = false, aoe = false, type = "cone"},
			[_R] = { name = "RiftWalk", objname = "RiftWalk", speed = math.huge, delay = 0.5, range = 500, width = 150, collision = false, aoe = true, type = "circular"}
		},
		["Katarina"] = {
			[_Q] = { name = "KatarinaQ", range = 675},
			[_W] = { name = "KatarinaW", range = 375},
			[_E] = { name = "KatarinaE", range = 700},
			[_R] = { name = "KatarinaR", range = 550}
		},
		["Kayle"] = {
			[_Q] = { name = "JudicatorReckoning" },
			[_W] = { name = "JudicatorDivineBlessing" },
			[_E] = { name = "JudicatorRighteosFury" },
			[_R] = { name = "JudicatorIntervention" }
		},
		["Kennen"] = {
			[_Q] = { name = "KennenShurikenHurlMissile1", speed = 1700, delay = 0.180, range = 1050, width = 70, collision = true, aoe = false, type = "linear"}
		},
		["KhaZix"] = {
			[_W] = { name = "KhazixW", objname = "KhazixWMissile", speed = 1700, delay = 0.25, range = 1025, width = 70, collision = true, aoe = false, type = "linear"},
			[_E] = { name = "KhazixE", objname = "KhazixE", speed = 400, delay = 0.25, range = 600, width = 325, collision = false, aoe = true, type = "circular"}
		},
		["KogMaw"] = {
			[_Q] = { name = "KogMawQ", objname = "KogMawQ", speed = 1600, delay = 0.25, range = 975, width = 80, type = "linear"},
			[_E] = { name = "KogMawVoidOoze", objname = "KogMawVoidOozeMissile", speed = 1200, delay = 0.25, range = 1200, width = 120, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "KogMawLivingArtillery", objname = "KogMawLivingArtillery", speed = math.huge, delay = 1.1, range = 2200, width = 250, collision = false, aoe = true, type = "circular"}
		},
		["LeBlanc"] = {
			[_Q] = { range = 700},
			[_W] = { name = "LeblancSlide", objname = "LeblancSlide", speed = 1300, delay = 0.250, range = 600, width = 250, collision = false, aoe = false, type = "circular"},
			[_E] = { name = "LeblancSoulShackle", objname = "LeblancSoulShackle", speed = 1300, delay = 0.250, range = 950, width = 55, collision = true, aoe = false, type = "linear"},
			[_R] = { range = 0}
		},
		["LeeSin"] = {
			[_Q] = { name = "BlindMonkQOne", objname = "BlindMonkQOne", speed = 1750, delay = 0.25, range = 1000, width = 70, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "", range = 600},
			[_E] = { name = "BlindMonkEOne", speed = math.huge, delay = 0.25, range = 0, width = 450, collision = false, aoe = false, type = "circular"},
			[_R] = { name = "BlindMonkR", speed = 2000, delay = 0.25, range = 2000, width = 150, collision = false, aoe = false, type = "linear"}
		},
		["Leona"] = {
			[_E] = { name = "LeonaZenithBlade", objname = "LeonaZenithBladeMissile", speed = 2000, delay = 0.250, range = 875, width = 80, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "LeonaSolarFlare", objname = "LeonaSolarFlare", speed = 2000, delay = 0.250, range = 1200, width = 300, collision = false, aoe = true, type = "circular"}
		},
		["Lissandra"] = {
			[_Q] = { name = "LissandraQ", objname = "LissandraQMissile", speed = 2200, delay = 0.25, range = 700, width = 75, collision = false, aoe = false, type = "linear"},
			[-1] = { name = "LissandraQShards", objname = "lissandraqshards", speed = 2200, delay = 0.25, range = 700, width = 90, collision = false, aoe = false, type = "linear"},
	                [_E] = { name = "LissandraE", objname = "LissandraEMissile", speed = 850, delay = 0.25, range = 1025, width = 125, collision = false, aoe = false, type = "linear"},
		},
		["Lucian"] = {
			[_Q] = { name = "LucianQ", objname = "LucianQ", speed = math.huge, delay = 0.5, range = 1300, width = 65, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "LucianW", objname = "lucianwmissile", speed = 800, delay = 0.3, range = 1000, width = 80, collision = true, aoe = false, type = "linear"},
			[_R] = { name = "LucianRMis", objname = "lucianrmissileoffhand", speed = 2800, delay = 0.5, range = 1400, width = 110, collision = true, aoe = false, type = "linear"}
		},
		["Lulu"] = {
			[_Q] = { name = "LuluQ", objname = "LuluQMissile", speed = 1500, delay = 0.25, range = 950, width = 60, collision = false, aoe = false, type = "linear"},
			[-1] = { name = "LuluQPix", objname = "LuluQMissileTwo", speed = 1450, delay = 0.25, range = 950, width = 60, collision = false, aoe = false, type = "linear"}
		},
		["Lux"] = {
			[_Q] = { name = "LuxLightBinding", objname = "LuxLightBindingMis", speed = 1200, delay = 0.25, range = 1300, width = 130, collision = true, type = "linear"},
			--[_W] = { name = "LuxPrismaticWave", speed = 1630, delay = 0.25, range = 1250, width = 210, collision = false, type = "linear"},
			[_E] = { name = "LuxLightStrikeKugel", objname = "LuxLightStrikeKugel", speed = 1300, delay = 0.25, range = 1100, width = 345, collision = false, type = "circular"},
			[_R] = { name = "LuxMaliceCannon", objname = "LuxMaliceCannon", speed = math.huge, delay = 1, range = 3340, width = 250, collision = false, type = "linear"}
		},
		["Malphite"] = {
			[_R] = { name = "UFSlash", objname = "UFSlash", speed = 1600, delay = 0.5, range = 900, width = 500, collision = false, aoe = true, type = "circular"}
		},
		["Malzahar"] = {
			[_Q] = { name = "AlZaharCalloftheVoid", objname = "AlZaharCalloftheVoid", speed = math.huge, delay = 1, range = 900, width = 100, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "", speed = math.huge, delay = 0.5, range = 800, width = 250, collision = false, aoe = false, type = "circular"},
			[_E] = { name = "", range = 650},
			[_R] = { name = "", range = 700}
		},
		["Maokai"] = {
			[_Q] = { name = "", speed = math.huge, delay = 0.25, range = 600, width = 100, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "", speed = 1500, delay = 0.25, range = 1100, width = 175, collision = false, aoe = false, type = "circular"}
		},
		["MasterYi"] = {
		},
		["MissFortune"] = {
			[_E] = { name = "MissFortuneScattershot", speed = math.huge, delay = 3.25, range = 800, width = 400, collision = false, aoe = true, type = "circular"},
			--[_R] = { name = "MissFortuneBulletTime", speed = math.huge, delay = 0.25, range = 1400, width = 700, collision = false, aoe = true, type = "cone"}
		},
		["Mordekaiser"] = {
			--[_E] = { name = "", speed = math.huge, delay = 0.25, range = 700, width = 0, collision = false, aoe = true, type = "cone"}
		},
		["Morgana"] = {
			[_Q] = { name = "DarkBindingMissile", objname = "DarkBindingMissile", speed = 1200, delay = 0.250, range = 1300, width = 80, collision = true, aoe = false, type = "linear"}
		},
		["Nami"] = {
			[_Q] = { name = "NamiQ", objname = "namiqmissile", speed = math.huge, delay = 0.95, range = 1625, width = 150, collision = false, aoe = true, type = "circular"},
			[_Q] = { name = "NamiR", objname = "NamiRMissile", speed = 850, delay = 0.5, range = 2750, width = 260, collision = false, aoe = true, type = "linear"}
		},
		["Nasus"] = {
			[_E] = { name = "", speed = math.huge, delay = 0.25, range = 450, width = 250, collision = false, aoe = true, type = "circular"}
		},
		["Nautilus"] = {
			[_Q] = { name = "NautilusAnchorDrag", objname = "NautilusAnchorDragMissile", speed = 2000, delay = 0.250, range = 1080, width = 80, collision = true, aoe = false, type = "linear"}
		},
		["Nidalee"] = {
			[_Q] = { name = "JavelinToss", objname = "JavelinToss", speed = 1300, delay = 0.25, range = 1500, width = 40, collision = true, type = "linear"}
		},
		["Nocturne"] = {
			[_Q] = { name = "NocturneDuskbringer", objname = "NocturneDuskbringer", speed = 1400, delay = 0.250, range = 1125, width = 60, collision = false, aoe = false, type = "linear"}
		},
		["Nunu"] = {
		},
		["Olaf"] = {
			[_Q] = { name = "OlafAxeThrowCast", objname = "olafaxethrow", speed = 1600, delay = 0.25, range = 1000, width = 90, collision = false, aoe = false, type = "linear"}
		},
		["Orianna"] = {
			[_Q] = { name = "OriannasQ", objname = "orianaizuna", speed = 1200, delay = 0, range = 1500, width = 80, collision = false, aoe = false, type = "linear"},
		        [-1] = { name = "OriannaQend", speed = 1200, delay = 0, range = 1500, width = 80, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "OrianaDissonanceCommand-", objname = "OrianaDissonanceCommand-", speed = math.huge, delay = 0.25, range = 0, width = 255, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "OriannasE", objname = "orianaredact", speed = 1800, delay = 0.250, range = 825, width = 80, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "OrianaDetonateCommand-", objname = "OrianaDetonateCommand-", speed = math.huge, delay = 0.250, range = 0, width = 410, collision = false, aoe = true, type = "circular"}
		},
		["Pantheon"] = {
			--[_E] = { name = "", speed = math.huge, delay = 0.250, range = 400, width = 100, collision = false, aoe = true, type = "cone"},
			[_R] = { name = "", speed = 3000, delay = 1, range = 5500, width = 1000, collision = false, aoe = true, type = "circular"}
		},
		["Poppy"] = {
		},
		["Quinn"] = {
			[_Q] = { name = "QuinnQ", objname = "QuinnQ", speed = 1550, delay = 0.25, range = 1050, width = 80, collision = true, aoe = false, type = "linear"}
		},
		["Rammus"] = {
		},
		["RekSai"] = {
			[_Q] = { name = "reksaiqburrowed", objname = "RekSaiQBurrowedMis", speed = 1550, delay = 0.25, range = 1050, width = 180, collision = true, aoe = false, type = "linear"}
		},
		["Renekton"] = {
			[_Q] = { name = "", speed = math.huge, delay = 0.25, range = 0, width = 450, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "", speed = 1225, delay = 0.25, range = 450, width = 150, collision = false, aoe = false, type = "linear"}
		},
		["Rengar"] = {
			[_W] = { name = "RengarW", speed = math.huge, delay = 0.25, range = 0, width = 490, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "RengarE", objname = "RengarEFinal", speed = 1225, delay = 0.25, range = 1000, width = 80, collision = true, aoe = false, type = "linear"},
			[_R] = { range = 4000}
		},
		["Riven"] = {
			[_Q] = { name = "RivenTriCleave", speed = math.huge, delay = 0.250, range = 310, width = 225, collision = false, aoe = true, type = "circular"},
			[_W] = { name = "RivenMartyr", speed = math.huge, delay = 0.250, range = 0, width = 265, collision = false, aoe = true, type = "circular"},
			[_E] = { range = 390},
			--[_R] = { name = "rivenizunablade", objname = "RivenLightsaberMissile", speed = 2200, delay = 0.5, range = 1100, width = 200, collision = false, aoe = false, type = "cone"}
		},
		["Rumble"] = {
			--[_Q] = { name = "RumbleFlameThrower", speed = math.huge, delay = 0.250, range = 600, width = 500, collision = false, aoe = false, type = "cone"},
			[_W] = { range = GetHitBox(myHero)},
			[_E] = { name = "RumbleGrenade", objname = "RumbleGrenade", speed = 1200, delay = 0.250, range = 850, width = 90, collision = true, aoe = false, type = "linear"},
			[_R] = { name = "RumbleCarpetBombM", objname = "RumbleCarpetBombMissile", speed = 1200, delay = 0.250, range = 1700, width = 90, collision = false, aoe = false, type = "linear"}
		},
		["Ryze"] = {
			[_Q] = { name = "RyzeQ", objname = "RyzeQ", speed = 1700, delay = 0.25, range = 900, width = 50, collision = true, aoe = false, type = "linear"},
	                [-1] = { name = "ryzerq", objname = "ryzerq", speed = 1700, delay = 0.25, range = 900, width = 50, collision = true, aoe = false, type = "linear"}
		},
		["Sejuani"] = {
			[_Q] = { name = "SejuaniArcticAssault", speed = 1600, delay = 0, range = 900, width = 70, collision = true, aoe = false, type = "linear"},
			[_R] = { name = "SejuaniGlacialPrisonStart", objname = "sejuaniglacialprison", speed = 1600, delay = 0.25, range = 1200, width = 110, collision = false, aoe = false, type = "linear"}
		},
		["Shaco"] = {
		},
		["Shen"] = {
			[_E] = { name = "ShenShadowDash", objname = "ShenShadowDash", speed = 1200, delay = 0.25, range = 600, width = 40, collision = false, aoe = false, type = "linear"}
		},
		["Shyvana"] = {
			[_E] = { name = "ShyvanaFireball", objname = "ShyvanaFireballMissile", speed = 1500, delay = 0.250, range = 925, width = 60, collision = false, aoe = false, type = "linear"}
		},
		["Singed"] = {
		},
		["Sion"] = {
		},
		["Sivir"] = {
			[_Q] = { name = "SivirQ", objname = "SivirQMissile", speed = 1330, delay = 0.250, range = 1075, width = 0, collision = false, aoe = false, type = "linear"},
			[-1] = { name = "SivirQReturn", objname = "SivirQMissileReturn", speed = 1330, delay = 0.250, range = 1075, width = 0, collision = false, aoe = false, type = "linear"}
		},
		["Skarner"] = {
			[_E] = { name = "SkarnerFracture", objname = "SkarnerFractureMissile", speed = 1200, delay = 0.600, range = 350, width = 60, collision = false, aoe = false, type = "linear"}
		},
		["Sona"] = {
			[_R] = { name = "SonaR", objname = "SonaR", speed = 2400, delay = 0.5, range = 900, width = 160, collision = false, aoe = false, type = "linear"}
		},
		["Soraka"] = {
			[_Q] = { name = "SorakaQ", speed = 1000, delay = 0.25, range = 900, width = 260, collision = false, aoe = true, type = "circular"},
			--[_E] = { name = "SorakaE", speed = math.huge, delay = 1.75, range = 900, width = 310, collision = false, aoe = true, type = "circular"}
		},
		["Swain"] = {
			[_W] = { name = "SwainShadowGrasp", objname = "SwainShadowGrasp", speed = math.huge, delay = 0.850, range = 900, width = 125, collision = false, aoe = true, type = "circular"}
		},
		["Syndra"] = {
			[_Q] = { name = "SyndraQ", objname = "SyndraQ", speed = math.huge, delay = 0.67, range = 790, width = 125, collision = false, aoe = true, type = "circular"},
			[_W] = { name = "syndrawcast", objname = "syndrawcast" ,speed = math.huge, delay = 0.8, range = 925, width = 190, collision = false, aoe = true, type = "circular"},
			--[_E] = { name = "SyndraE", objname = "SyndraE", speed = 2500, delay = 0.25, range = 730, width = 45, collision = false, aoe = true, type = "cone"}
		},
		["Talon"] = {
			--[_W] = { name = "TalonRake", objname = "talonrakemissileone", speed = 900, delay = 0.25, range = 600, width = 200, collision = false, aoe = false, type = "cone"},
			[_E] = { name = "", range = 700},
			[_R] = { name = "", speed = math.huge, delay = 0.25, range = 0, width = 650, collision = false, aoe = false, type = "circular"}
		},
		["Taric"] = {
			[_R] = { name = "TaricHammerSmash", speed = math.huge, delay = 0.25, range = 0, width = 175, collision = false, aoe = false, type = "circular"}
		},
		["Teemo"] = {
			[_Q] = { name = "BlindingDart", range = GetRange(myHero)+GetHitBox(myHero)*3},
			[_W] = { name = "MoveQuick", range = 25000},
			[_E] = { name = "ToxicShot", range = GetRange(myHero)+GetHitBox(myHero)},
			[_R] = { name = "TeemoRCast", speed = 1200, delay = 1.25, range = 900, width = 250, type = "circular"}
		},
		["Thresh"] = {
			[_Q] = { name = "ThreshQ", objname = "ThreshQMissile", speed = 1825, delay = 0.25, range = 1050, width = 70, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "ThreshW", range = 25000},
			[_E] = { name = "ThreshE", objname = "ThreshEMissile1", speed = 2000, delay = 0.25, range = 450, width = 110, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "ThreshRPenta", range = 450, width = 250}
		},
		["Tristana"] = {
			[_Q] = { name = "TristanaQ", range = 543 },
			[_W] = { name = "RocketJump", objname = "RocketJump", speed = 2100, delay = 0.25, range = 900, width = 125, collision = false, aoe = false, type = "circular"}
		},
		["Trundle"] = {
			[_E] = { name = "TrundleCircle", speed = math.huge, delay = 0.25, range = 1000, width = 125, collision = false, aoe = false, type = "circular"}
		},
		["Tryndamere"] = {
			[_E] = { name = "slashCast", objname = "slashCast", speed = 1500, delay = 0.250, range = 650, width = 160, collision = false, aoe = false, type = "linear"}
		},
		["TwistedFate"] = {
			[_Q] = { name = "WildCards", objname = "SealFateMissile", speed = 1500, delay = 0.250, range = 1200, width = 80, collision = false, aoe = false, type = "linear"}
		},
		["Twitch"] = {
			[_W] = { name = "TwitchVenomCask", objname = "TwitchVenomCaskMissile", speed = 1750, delay = 0.250, range = 950, width = 275, collision = false, aoe = true, type = "circular"}
		},
		["Udyr"] = {
		},
		["Urgot"] = {
			[_Q] = { name = "UrgotHeatseekingLineMissile", objname = "UrgotHeatseekingLineMissile", speed = 1575, delay = 0.175, range = 1000, width = 80, collision = true, aoe = false, type = "linear"},
			[_E] = { name = "UrgotPlasmaGrenade", objname = "UrgotPlasmaGrenadeBoom", speed = 1750, delay = 0.25, range = 890, width = 200, collision = false, aoe = true, type = "circular"}
		},
		["Varus"] = {
			[_Q] = { name = "VarusQMissilee", objname = "VarusQMissile", speed = 1500, delay = 0.5, range = 1475, width = 100, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "VarusE", objname = "VarusE", speed = 1750, delay = 0.25, range = 925, width = 235, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "VarusR", objname = "VarusRMissile", speed = 1200, delay = 0.5, range = 800, width = 100, collision = false, aoe = false, type = "linear"}
		},
		["Vayne"] = {
			[_Q] = { name = "VayneTumble", range = 450},
			[_W] = { name = "", range = GetRange(myHero)+GetHitBox(myHero)*2},
			[_E] = { name = "VayneCondemn", speed = 2000, delay = 0.25, range = 650, width = 0, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "", range = 1000}
		},
		["Veigar"] = {
			[_Q] = { name = "VeigarBalefulStrike", objname = "VeigarBalefulStrikeMis", speed = 1200, delay = 0.25, range = 900, width = 70, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "VeigarDarkMatter", speed = math.huge, delay = 1.2, range = 900, width = 225, collision = false, aoe = false, type = "circular"},
			[_E] = { name = "VeigarEvenHorizon", speed = math.huge, delay = 0.75, range = 725, width = 275, collision = false, aoe = false, type = "circular"},
			[_R] = { name = "VeigarPrimordialBurst", range = 650}
		},
		["VelKoz"] = {
			[_Q] = { name = "VelKozQ", objname = "VelkozQMissile", speed = 1300, delay = 0.25, range = 1100, width = 50, collision = true, aoe = false, type = "linear"},
			[-1] = { name = "VelkozQSplit", objname = "VelkozQMissileSplit", speed = 2100, delay = 0.25, range = 1100, width = 55, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "VelKozW", objname = "VelkozWMissile", speed = 1700, delay = 0.064, range = 1050, width = 80, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "VelKozE", objname = "VelkozEMissile", speed = 1500, delay = 0.333, range = 850, width = 225, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "VelKozR", speed = math.huge, delay = 0.333, range = 1550, width = 50, collision = false, aoe = false, type = "linear"}
		},
		["Vi"] = {
			[_Q] = { name = "Vi-q", objname = "ViQMissile", speed = 1500, delay = 0.25, range = 715, width = 55, collision = false, aoe = false, type = "linear"}
		},
		["Viktor"] = {
			[_Q] = { name = "ViktorPowerTransfer", range = 0},
			[_W] = { name = "ViktorGravitonField", speed = 750, delay = 0.6, range = 700, width = 125, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "Laser", objname = "ViktorDeathRayMissile", speed = 1200, delay = 0.25, range = 1200, width = 0, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "ViktorChaosStorm", speed = 1000, delay = 0.25, range = 700, width = 0, collision = false, aoe = true, type = "circular"}
		},
		["Vladimir"] = {
			[_R] = { name = "VladimirHemoplague", speed = math.huge, delay = 0.25, range = 700, width = 175, collision = false, aoe = true, type = "circular"}
		},
		["Volibear"] = {
		},
		["Warwick"] = {
		},
		["Wukong"] = {
		},
		["Xerath"] = {
			[_Q] = { name = "xeratharcanopulse2", objname = "xeratharcanopulse2", speed = math.huge, delay = 1.75, range = 750, width = 100, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "XerathArcaneBarrage2", objname = "XerathArcaneBarrage2", speed = math.huge, delay = 0.25, range = 1100, width = 100, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "XerathMageSpear", objname = "XerathMageSpearMissile", speed = 1600, delay = 0.25, range = 1050, width = 70, collision = true, aoe = false, type = "linear"},
			[_R] = { name = "xerathrmissilewrapper", objname = "xerathrmissilewrapper", speed = math.huge, delay = 0.75, range = 3200, width = 245, collision = false, aoe = true, type = "circular"}
		},
		["XinZhao"] = {
			[_R] = { name = "XenZhaoParry", speed = math.huge, delay = 0.25, range = 0, width = 375, collision = false, aoe = true, type = "circular"}
		},
		["Yasuo"] = {
			[_Q] = { name = "yasuoq", objname = "yasuoq", speed = math.huge, delay = 0.25, range = 475, width = 40, collision = false, aoe = false, type = "linear"},
			[_W] = { name = "YasuoWMovingWall", range = 350},
			[_E] = { name = "YasuoDashWrapper", range = 475},
			[_R] = { name = "YasuoRKnockUpWCombo", range = 1200},
			[-1] = { name = "yasuoq2", objname = "yasuoq2", speed = math.huge, delay = 0.25, range = 475, width = 40, collision = false, aoe = false, type = "linear"},
			[-2] = { name = "yasuoq3w", objname = "yasuoq3w", range = 1200, speed = 1200, delay = 0.125, width = 65, collision = false, aoe = false, type = "linear" }
		},
		["Yorick"] = {
			[_Q] = { range = 0},
			[_W] = { name = "YorickDecayed", speed = math.huge, delay = 0.25, range = 600, width = 175, collision = false, aoe = true, type = "circular"},
			[_E] = { range = 0},
		},
		["Zac"] = {
			[_Q] = { name = "ZacQ", objname = "ZacQ", speed = 2500, delay = 0.110, range = 500, width = 110, collision = false, aoe = false, type = "linear"}
		},
		["Zed"] = {
			[_Q] = { name = "ZedQ", objname = "ZedQMissile", speed = 1700, delay = 0.25, range = 900, width = 50, collision = false, aoe = false, type = "linear"},
			[_E] = { name = "ZedE", speed = math.huge, delay = 0.25, range = 0, width = 300, collision = false, aoe = true, type = "circular"}
		},
		["Ziggs"] = {
			[_Q] = { name = "ZiggsQ", objname = "ZiggsQSpell", speed = 1750, delay = 0.25, range = 1400, width = 155, collision = true, aoe = false, type = "linear"},
			[_W] = { name = "ZiggsW", objname = "ZiggsW", speed = 1800, delay = 0.25, range = 970, width = 275, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "ZiggsE", objname = "ZiggsE", speed = 1750, delay = 0.12, range = 900, width = 350, collision = false, aoe = true, type = "circular"},
			[_R] = { name = "ZiggsR", objname = "ZiggsR", speed = 1750, delay = 0.14, range = 5300, width = 525, collision = false, aoe = true, type = "circular"}
		},
		["Zilean"] = {
			[_Q] = { name = "ZileanQ", objname = "ZileanQMissile", speed = math.huge, delay = 0.5, range = 900, width = 150, collision = false, aoe = true, type = "circular"}
		},
		["Zyra"] = {
			[-8] = { name = "zyrapassivedeathmanager", objname = "zyrapassivedeathmanager", speed = 1900, delay = 0.5, range = 1475, width = 70, collision = false, aoe = false, type = "linear"},
			[_Q] = { name = "ZyraQFissure", objname = "ZyraQFissure", speed = math.huge, delay = 0.7, range = 800, width = 85, collision = false, aoe = true, type = "circular"},
			[_E] = { name = "ZyraGraspingRoots", objname = "ZyraGraspingRoots", speed = 1150, delay = 0.25, range = 1100, width = 70, collision = false, aoe = false, type = "linear"},
			[_R] = { name = "ZyraBrambleZone", speed = math.huge, delay = 1, range = 1100, width = 500, collision=false, aoe = true, type = "circular"}
		}
	}
end

_G.SmoothEvade = SmoothEvade()
