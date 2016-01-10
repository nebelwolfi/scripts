-- { local vars and funcs
	local Object = {}
	local heroes = {}
	local usingOldCallbacks = false
	local cooldowns = {}
	local remBuffsForCd = {
		["AhriFoxFire"] = "AhriFoxFire", 
		["AhriTumble"] = "AhriTumble", 
		["Takedown"] = "Takedown", 
		["vaynetumblebonus"] = "VayneTumble"
	}
	local sameSpells = { ["ryzerq"] = "RyzeQ", ["ryzerw"] = "RyzeW", ["ryzere"] = "RyzeE", }
	local spells = {}
	local spells2 = {}
	local Object = {}
	local heroes = {}
	local function GDS(p1,p2) p2 = p2 or myHero.pos local dx = p1.x - p2.x local dz = (p1.z or p1.y) - (p2.z or p2.y) return dx*dx + dz*dz end
	local function AutoUpdate()
		local lskt = require("socket")
		local skt = lskt.tcp()
		local start = false
		local file = ""
		local tick = -1
		skt:settimeout(0, 'b')
		skt:settimeout(99999999, 't')
		skt:connect('nebelwolfi.xyz', 80)
		tick = Callback.Add("Tick", function()
			rcv, stat, snip = skt:receive(1024)
			if stat == 'timeout' and not go then
				skt:send("GET /get.php?script=inspired_new HTTP/1.1\r\nHost: nebelwolfi.xyz\r\n\r\n")
				start = true
			end
			file = file .. (rcv or snip)
			if file:find('</'..'g'..'o'..'s'..'>') then
				file = file:sub(file:find('<'..'g'..'o'..'s'..'>')+5,file:find('</'..'g'..'o'..'s'..'>')-1)
				Callback.Del("Tick", tick)
				WriteFile(file, COMMON_PATH.."Inspired.lua")
				print("Synced Inspired.lua!")
			end
		end)
	end
-- }
do -- helpers
	os = {}
	os.clock = function()
		return GetTickCount()/1000
	end
	Timer = os.clock
	function Set(list)
		local set = {}
		for _, l in ipairs(list) do 
			set[l] = true 
		end
		return set
	end
	function VecIsUnder(a, b, c, d, e, f)
		if type(a) == "table" then
			f,e,d,c,b=e,d,c,b
			a,b = a.x,a.y
		end
		return a>=c and a<=c+e and b>=d and b<= d+f
	end
end
do -- vector class
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
end
do -- overwrite gos pointer structure to classes
	local old_IsImmune = IsImmune
	IsImmune = function(x, y)
		while type(x) == "table" and x.object do x = x.object end
		if y then while type(y) == "table" and y.object do y = y.object end else y = myHero end
		return old_IsImmune(x, y)
	end
	local old_IsDead = IsDead
	IsDead = function(x)
		while type(x) == "table" and x.object do x = x.object end
		return old_IsDead(x)
	end
	local old_IsTargetable = IsTargetable
	IsTargetable = function(x)
		while type(x) == "table" and x.object do x = x.object end
		return old_IsTargetable(x)
	end
	local old_IsVisible = IsVisible
	IsVisible = function(x)
		while type(x) == "table" and x.object do x = x.object end
		return old_IsVisible(x)
	end
	local old_IsRecalling = IsRecalling
	IsRecalling = function(x)
		while type(x) == "table" and x.object do x = x.object end
		return old_IsRecalling(x)
	end
	local old_AttackUnit = AttackUnit
	AttackUnit = function(x)
		while type(x) == "table" and x.object do x = x.object end
		return old_AttackUnit(x)
	end
	local old_CastTargetSpell = CastTargetSpell
	CastTargetSpell = function(x, ...)
		while type(x) == "table" and x.object do x = x.object end
		return old_CastTargetSpell(x, ...)
	end
	local old_stuff = {} -- wrap old functions into new ones
	local other_stuff_0 = Set { "GetBuffTypeList", "GetCurrentTarget", "GetTickCount", "GetMyHero", "GetLatency", "GetMapID", "GetResolution", "GetMousePos", "GetCursorPos", "GetGameTimer" }
	local other_stuff_2 = Set { "GetDamagePrediction", "GetCastName", "GetCastRange", "GetItemAmmo", "GetItemID", "GetItemSlot", "GetItemStack", "GetCastLevel" }
	local other_stuff_3 = Set { "GetCastCooldown", "GetCastMana", }
	local pred, skinC, modelC, drawD, canU, isA, gbNID = GetPredictionForPlayer, HeroSkinChanger, ModelChanger, DrawDmgOverHpBar, CanUseSpell, IsObjectAlive, GetObjByNetID
	for _, f in pairs(_G) do
		if _ == "HeroSkinChanger" then
			_G[_] = function(x, ...)
				if x then while type(x) == "table" and x.object do x = x.object end end
				skinC(x,...)
			end
		elseif _ == "ModelChanger" then
			_G[_] = function(x, ...)
				if x then while type(x) == "table" and x.object do x = x.object end end
				modelC(x,...)
			end
		elseif _ == "DrawDmgOverHpBar" then
			_G[_] = function(x, ...)
				if x then while type(x) == "table" and x.object do x = x.object end end
				drawD(x,...)
			end
		elseif _ == "CanUseSpell" then
			_G[_] = function(x, ...)
				if x then while type(x) == "table" and x.object do x = x.object end end
				return canU(x,...)
			end
		elseif _ == "GetObjByNetID" then
			_G[_] = function(x)
				return gbNID(x)
			end
		elseif _ == "IsObjectAlive" then
			_G[_] = function(x, ...)
				if x then while type(x) == "table" and x.object do x = x.object end end
				return isA(x,...)
			end
		elseif _ == "GetPredictionForPlayer" then
			_G[_] = function(x, y, ...)
				if y then while type(y) == "table" do y = y.object end end
				return pred(x, y, ...)
			end
		elseif _:find("Get") or _:find("Got") then
			old_stuff[_] = f
			if other_stuff_0[_] then
				_G[_] = function()
					return old_stuff[_]()
				end
			elseif other_stuff_3[_] then
				_G[_] = function(x, y, z)
					if x then while type(x) == "table" and x.object do x = x.object end end
					if y then while type(y) == "table" and y.object do y = y.object end end
					if z then while type(z) == "table" and z.object do z = z.object end end
					return old_stuff[_](x, y, z)
				end
			elseif _:find("Buff") or other_stuff_2[_] then
				_G[_] = function(x, y)
					if x then while type(x) == "table" and x.object do x = x.object end end
					if y then while type(y) == "table" and y.object do y = y.object end end
					return old_stuff[_](x, y)
				end
			else
				_G[_] = function(x)
					if x then while type(x) == "table" and x.object do x = x.object end end
					local x, y = pcall(function() return old_stuff[_](x) end)
					if not x then PrintChat("Report this function to Inspired: ".._) end
					return y
				end
			end
		end
	end
	local FunctionToIndexTable = { -- make Objects indexable
		__type = function(t) return "Object_Class" end,
		name = function(t) return GetObjectBaseName(t) end,
		charName = function(t) return GetObjectName(t) end,
		modelName = function(t) return GetObjectModelName(t) end,
		levelPoints = function(t) return GetLevelPoints(t) end,
		alive = function(t) return IsObjectAlive(t) end,
		dead = function(t) return IsDead(t) end,
		team = function(t) return GetTeam(t) end,
		valid = function(t) return IsObjectAlive(t) and IsVisible(t) and not IsDead(t) end,
		visible = function(t) return IsVisible(t) end,
		level = function(t) return GetLevel(t) end,
		type = function(t) return GetObjectType(t) end,
		isAi = function(t) return GetObjectBaseName(t):find(" Bot") end,
		pos = function(t) return Vector(t) end,
		pos2D = function(t) return WorldToScreen(1, t) end,
		x = function(t) return GetOrigin(t).x end,
		y = function(t) return GetOrigin(t).y end,
		z = function(t) return GetOrigin(t).z end,
		buffCount = function(t) return 63 end,
		networkID = function(t) return GetNetworkID(t) end,
		isInvulnerable = function(t) return IsImmune(t,GetMyHero()) end,
		isMelee = function(t) return GetRange(t)<425 end,
		isRanged = function(t) return GetRange(t)>=425 end,
		isMe = function(t) return (t.networkID == GetMyHero().networkID) end,
		isStealthed = function(t) return (t:HasBuffType(6)) end,
		isTaunted = function(t) return (t:HasBuffType(8)) end,
		isCharmed = function(t) return (t:HasBuffType(22)) end,
		isFeared = function(t) return (t:HasBuffType(21)) end,
		isAsleep = function(t) return (t:HasBuffType(18)) end,
		isNearSight = function(t) return (t:HasBuffType(19)) end,
		isGhosted = function(t) return (t:HasBuffType(14)) end,
		isFleeing = function(t) return (t:HasBuffType(21)) end,
		isPoisoned = function(t) return (t:HasBuffType(23)) end,
		isSpellShielded = function(t) return (t:HasBuffType(4)) end,
		isTargetable = function(t) return IsTargetable(t) end,
		range = function(t) return GetRange(t) end,
		boundingRadius = function(t) return GetHitBox(t) end,
		cdr = function(t) return GetCDR(t) end,
		health = function(t) return GetCurrentHP(t) end,
		maxHealth = function(t) return GetMaxHP(t) end,
		mana = function(t) return GetCurrentMana(t) end,
		maxMana = function(t) return GetMaxMana(t) end,
		hpRegen = function(t) return GetHPRegen(t) end,
		mpRegen = function(t) return GetMPRegen(t) end,
		critChance = function(t) return GetCritChance(t) end,
		baseAttackSpeed = function(t) return GetBaseAttackSpeed(t) end,
		attackSpeed = function(t) return GetAttackSpeed(t) end,
		exp = function(t) return GetExperience(t) end,
		lifeSteal = function(t) return GetLifeSteal(t) end,
		spellVamp = function(t) return GetSpellVamp(t) end,
		physReduction = function(t) local armor = GetArmor(t) return 1-(armor >= 0 and (100/(100+armor)) or (2-(100/(100-armor)))) end,
		magicReduction = function(t) local armor = GetMagicResist(t) return 1-(armor >= 0 and (100/(100+armor)) or (2-(100/(100-armor)))) end,
		armorPen = function(t) return GetArmorPenFlat(t) end,
		magicPen = function(t) return GetMagicPenFlat(t) end,
		armorPenPercent = function(t) return GetArmorPenPercent(t) end,
		bonusArmorPenPercent = function(t) return GetBonusArmorPenPercent(t) end,
		magicPenPercent = function(t) return GetMagicPenPercent(t) end,
		totalDamage = function(t) return (GetBonusDmg(t)+GetBaseDamage(t)) end,
		addDamage = function(t) return GetBonusDmg(t) end,
		ap = function(t) return GetBonusAP(t) end,
		damage = function(t) return GetBaseDamage(t) end,
		armor = function(t) return GetArmor(t) end,
		baseArmor = function(t) return GetBaseArmor(t) end,
		magicArmor = function(t) return GetMagicResist(t) end,
		ms = function(t) return GetMoveSpeed(t) end,
		gold = function(t) return GetCurrentGold(t) end,
		shieldAD = function(t) return GetDmgShield(t) end,
		shieldAP = function(t) return GetMagicShield(t) end,
		isUnit = function(t) local t = GetObjectType(t) return (t == Obj_AI_Hero or t == Obj_AI_Minion or Obj_AI_Turret) end,
		isHero = function(t) local t = GetObjectType(t) return (t == Obj_AI_Hero) end,
		isMinion = function(t) local t = GetObjectType(t) return (t == Obj_AI_Minion) end,
		isTurret = function(t) local t = GetObjectType(t) return (t == Obj_AI_Turret) end,
		isSpell = function(t) return GetObjectBaseName(t)=="missile" end,
		spellName = function(t) return Object(GetObjectSpellName(t)) end,
		spellOwner = function(t) return Object(GetObjectSpellOwner(t)) end,
		startPos = function(t) return GetObjectSpellStartPos(t) end,
		endPos = function(t) return GetObjectSpellEndPos(t) end,
		placePos = function(t) return GetObjectSpellPlacementPos(t) end,
		target = function(t) return GetObjectSpellTarget(t) end,
		totalGold = function(t) return GetTotalEarnedGold(t) end,
		owner = function(t) return GetObjectOwner(t) end,
		hpBarPos = function(t) return GetHPBarPos(t) end,
		spell = function(t) return (spells[t.networkID] or nil) end,
		isRecalling = function(t) return IsRecalling(t) end,
		ongoing = function(t) local x = (t.lastX or 0) t.lastX = t.x return (x ~= t.lastX and GDS(t.endPos,t.startPos) > GDS(t.endPos,t.pos)) end
	}
	local FunctionToExecuteTable = { -- give objects some functions
		HasBuffType = function(self, t) local unit = self for index = 0, 63 do if GetBuffCount(unit, index) > 0 then local buffData = GetBuffData(unit, GetBuffName(unit, index)) if buffData.Type == t then return true end end end return false end,
		Stop = function(self) HoldPosition() end,
		Move = function(self, x, z) MoveToXYZ(x, self.y, z) end,
		Attack = function(self, t) AttackUnit(type(t) == "table" and t.object or t) end,
		DistanceTo = function(self, a, b, c) if a and b and c then local p1 = GetOrigin(self.object) local dx = p1.x - a local dz = p1.z - c return math.sqrt(dx*dx + dz*dz) elseif a and b then local p1 = GetOrigin(self.object) local dx = p1.x - a local dz = p1.z - b return math.sqrt(dx*dx + dz*dz) else local p1 = GetOrigin(self.object) local p2 = type(a)=="table" and a or GetOrigin(a) local dx = p1.x - p2.x local dz = p1.z - (p2.z or p2.y) return math.sqrt(dx*dx + dz*dz) end end,
		CalcDamage = function(self, t, dmg) if not dmg then dmg = self.totalDamage end local enemy = type(t) == "table" and t.object or t local armor = GetArmor(enemy) local baseArmor = GetBaseArmor(enemy) local bonusArmor = armor-baseArmor local apenPerc = GetArmorPenPercent(self.object) local apenFlat = GetArmorPenFlat(self.object) armor = (baseArmor*(apenPerc)+bonusArmor*(apenPerc*GetBonusArmorPenPercent(self.object)))-apenFlat return (dmg*(armor >= 0 and (100/(100+armor)) or (2-(100/(100-armor))))) end,
		CalcMagicDamage = function(self, t, dmg) if not dmg then dmg = self.totalDamage end local enemy = type(t) == "table" and t.object or t local armor = GetMagicResist(enemy) local perc = GetMagicPenPercent(self) local flat = GetMagicPenFlat(self) armor = (armor*(perc))-flat return (dmg*(armor >= 0 and (100/(100+armor)) or (2-(100/(100-armor))))) end,
		GetSpellData = function(self, slot) local unit = self return { name = GetCastName(unit, slot), mana = GetCastMana(unit, slot, GetCastLevel(unit, slot)), cd = GetCastCooldown(unit, slot, GetCastLevel(unit, slot))*(1+self.cdr), range = GetCastRange(unit, slot), level = GetCastLevel(unit, slot), currentCd = math.max(0, (cooldowns[unit.networkID][sameSpells[GetCastName(unit, slot)] or GetCastName(unit, slot)] or 0)-Timer()+GetCastCooldown(unit, slot, GetCastLevel(unit, slot))*(1+self.cdr)) } end,
		CanUseSpell = function(self, index) return CanUseSpell(self, index) end,
		GetBuff = function(self, index) local unit = self return { valid = GetBuffCount(unit, index) > 0, type = GetBuffType(unit, index), startT = GetBuffStartTime(unit, index), endT = GetBuffExpireTime(unit, index), name = GetBuffName(unit, index)} end,
		getBuff = function(self, index) local unit = self return { valid = GetBuffCount(unit, index) > 0, type = GetBuffType(unit, index), startT = GetBuffStartTime(unit, index), endT = GetBuffExpireTime(unit, index), name = GetBuffName(unit, index)} end,
		CastSpell = function(self, a, b, c) if not b then CastSpell(a) elseif not c then if type(b) == "table" then if b.object then CastTargetSpell(b.object, a) else CastSkillShot(a, b.x, b.z and b.y or self.y, b.z or b.y) end else CastTargetSpell(b, a) end else CastSkillShot(a, b, self.y, c) end end,
		Cast = function(self, a, b, c) if not b then CastSpell(a) elseif not c then if type(b) == "table" then if b.object then CastTargetSpell(b.object, a) else CastSkillShot(a, b.x, b.z and b.y or self.y, b.z or b.y) end else CastTargetSpell(b, a) end else CastSkillShot(a, b, self.y, c) end end,
		Draw = function(self, r, c) local r = r or self.boundingRadius == 1 and 75 or self.boundingRadius DrawCircle(self.pos, r, 1, 0, c or ARGB(255, 255, 255, 255)) if self.isSpell then DrawCircle(self.startPos, r, 1, 0, c or ARGB(255, 255, 255, 255)) DrawCircle(self.endPos, r, 1, 0, c or ARGB(255, 255, 255, 255)) end end,
		DrawDmg = function(self, dmg, col, chp) DrawDmgOverHpBar(self, chp or self.health,dmg,0,col or ARGB(255, 255, 255, 255)) end,
		Skin = function(self, id) HeroSkinChanger(self, id) end,
		Model = function(self, id, model) HeroSkinChanger(self, id, model) end,
		GetItem = function(self, slot) local unit = self return { id = GetItemID(unit, slot), stack = GetItemStack(unit, slot), ammo = GetItemAmmo(unit, slot) } end
	} 
	ObjectMetaTable = { -- define object metatable
		__index = function(t, k)
			if FunctionToIndexTable[k] then return FunctionToIndexTable[k](t) end
			if FunctionToExecuteTable[k] then return FunctionToExecuteTable[k] end
		end,
		__eq = function(o1, o2)
			return o1.networkID == o2.networkID
		end
	}
	setmetatable(Object, { -- set object metatable
			__index = Object,
			__call = function(self, o)
				if not o then return nil end
				if type(o) == "table" then return o end
				local x = objManager:getByNetworkID(GetNetworkID(o))
				if x then return x end
				local t = {}
				t.object = o
				setmetatable(t, ObjectMetaTable)
				return t
			end
		}
	)
	local curT, gamT = GetCurrentTarget, GetGameTarget
	_G["GetCurrentTarget"] = function()
		return Object(curT())
	end
	_G["GetGameTarget"] = function()
		return Object(gamT())
	end
end
do -- overwrite gos callback structure
	local didFirstTick = false
	if not Callback then
		Callback = { name = "Callback",
			callbacks = { -- known Callback.callbacks
				Load = {},
				AfterLoad = {},
				Tick = {},
				Draw = {},
				CreateObj = {},
				DeleteObj = {},
				ProcessSpell = {},
				ProcessSpellAttack = {},
				ProcessSpellCast = {},
				ProcessSpellComplete = {},
				AttackCancel = {},
				ProcessWaypoint = {},
				RemoveBuff = {},
				UpdateBuff = {},
				ProcessRecall = {},
				ObjectLoad = {},
				DrawMinimap = {},
				WndMsg = {},
				UnLoad = {},
				BugSplat = {},
				Animation = {}
			} 
		}
		function Callback.Add(cb, f)
			if not Callback.callbacks[cb] then PrintChat("Callback: "..cb.." not supported!") return 0 end
			if didFirstTick and (cb == "Load" or cb == "AfterLoad") then f() return 0 end
			local c, toA, i = #Callback.callbacks[cb], nil, 0
			for i=1, c do
				local cb = Callback.callbacks[cb][i]
				if not cb then 
					toA = i
				end
			end
			i = toA or 1 + #Callback.callbacks[cb]
			Callback.callbacks[cb][i] = f
			return i
		end
		function Callback.Del(cb, i)
			Callback.callbacks[cb][i] = nil
		end
		function GoSNeverCalledOnCreateObjEvent(o)
			local o = Object(o)
			objManager:addObject(o)
			if o.isSpell then
				table.insert(spells2, o)
			end
			for c, cb in pairs(Callback.callbacks["CreateObj"]) do
				cb(o)
			end
			if not usingOldCallbacks and OnCreateObj then OnCreateObj(o) end
		end
		function GoSNeverCalledOnProcessSpell(o, proc)
			local o = Object(o)
			if o.type == myHero.type and cooldowns[o.networkID] then
				cooldowns[o.networkID][sameSpells[proc.name] or proc.name] = Timer()+proc.windUpTime
			end
			spells[o.networkID] = {}
			for k, v in pairs(proc) do
				spells[o.networkID][k] = v
			end
			spells[o.networkID].time = Timer()
			for c, cb in pairs(Callback.callbacks["ProcessSpell"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnProcessSpell then OnProcessSpell(o, proc) end
		end
		function GoSNeverCalledOnProcessSpellCast(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["ProcessSpellCast"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnProcessSpellCast then OnProcessSpellCast(o, proc) end
		end
		function GoSNeverCalledOnProcessSpellAttack(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["ProcessSpellAttack"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnProcessSpellAttack then OnProcessSpellAttack(o, proc) end
		end
		function GoSNeverCalledOnUnLoadEvent()
			for c, cb in pairs(Callback.callbacks["UnLoad"]) do
				cb()
			end
			if not usingOldCallbacks and OnUnLoad then OnUnLoad() end
		end
		function GoSNeverCalledOnBugSplatEvent(proc)
			for c, cb in pairs(Callback.callbacks["BugSplat"]) do
				cb(proc)
			end
			if not usingOldCallbacks and OnBugSplat then OnBugSplat(proc) end
		end
		function GoSNeverCalledOnAnimationEvent(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["Animation"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnAnimation then OnAnimation(o, proc) end
		end
		function GoSNeverCalledOnProcessSpellComplete(o, proc)
			local o = Object(o)
			if o.type == myHero.type then
				if o.charName == "Ryze" and GotBuff(o.object, "ryzepassivecharged") > 0 then
					for _, c in pairs(cooldowns[o.networkID]) do
						if (sameSpells[_] or _) ~= (sameSpells[proc.name] or proc.name) then
							cooldowns[o.networkID][sameSpells[_] or _] = c - o:GetSpellData(_Q).cd
						end
					end
				end
			end
			for c, cb in pairs(Callback.callbacks["ProcessSpellComplete"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnProcessSpellComplete then OnProcessSpellComplete(o, proc) end
		end
		function GoSNeverCalledOnAttackCancel(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["AttackCancel"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnAttackCancel then OnAttackCancel(o, proc) end
		end
		function GoSNeverCalledOnProcessWaypoint(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["ProcessWaypoint"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnProcessWaypoint then OnProcessWaypoint(o, proc) end
		end
		function GoSNeverCalledOnDeleteObjEvent(o)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["DeleteObj"]) do
				cb(o)
			end
			if not usingOldCallbacks and OnDeleteObj then OnDeleteObj(o) end
		end
		function GoSNeverCalledOnRemoveBuffEvent(o, proc)
			local o = Object(o)
			if remBuffsForCd[proc.Name] then
				cooldowns[o.networkID][remBuffsForCd[proc.Name]] = Timer()+GetLatency()/1000
			end
			for c, cb in pairs(Callback.callbacks["RemoveBuff"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnRemoveBuff then OnRemoveBuff(o, proc) end
		end
		function GoSNeverCalledOnUpdateBuffEvent(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["UpdateBuff"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnUpdateBuff then OnUpdateBuff(o, proc) end
		end
		function GoSNeverCalledOnProcessRecall(o, proc)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["ProcessRecall"]) do
				cb(o, proc)
			end
			if not usingOldCallbacks and OnProcessRecall then OnProcessRecall(o, proc) end
		end
		function GoSNeverCalledObjectLoadEvent(o)
			local o = Object(o)
			objManager:addObject(o)
			if o.type == Obj_AI_Hero then
				cooldowns[o.networkID] = {}
				heroes[1+heroManager.iCount] = o
				heroManager.iCount = #heroes
			end
			for c, cb in pairs(Callback.callbacks["ObjectLoad"]) do
				cb(o)
			end
			if not usingOldCallbacks and OnObjectLoad then OnObjectLoad(o) end
		end
		function GoSNeverCalledOnDrawMinimapEvent(o)
			for c, cb in pairs(Callback.callbacks["DrawMinimap"]) do
				cb()
			end
			if not usingOldCallbacks and OnDrawMinimap then OnDrawMinimap() end
		end
		old_GoSNeverCalledOnTickEvent = GoSNeverCalledOnTickEvent
		function GoSNeverCalledOnTickEvent(o)
			local o = Object(o)
			for c, cb in pairs(Callback.callbacks["Tick"]) do
				cb(o)
			end
			if not usingOldCallbacks and OnTick then OnTick(o) end
		end
		GoSNeverCalledObjectLoopEvent = function() end
		function GoSNeverCalledAfterObjectLoopEvent()
			if not didFirstTick then
				didFirstTick = true
				for c, cb in pairs(Callback.callbacks["Load"]) do
					cb()
					Callback.callbacks["Load"][c] = nil
				end
				if not usingOldCallbacks and OnLoad ~= nil then OnLoad() end
				for c, cb in pairs(Callback.callbacks["AfterLoad"]) do
					cb()
					Callback.callbacks["AfterLoad"][c] = nil
				end
				if not usingOldCallbacks and OnAfterLoad ~= nil then OnAfterLoad() end
			end
			for c, cb in pairs(Callback.callbacks["Draw"]) do
				cb()
			end
			if not usingOldCallbacks and OnDraw then OnDraw() end
		end
		function GoSNeverCalledOnWndMsg(...)
			for c, cb in pairs(Callback.callbacks["WndMsg"]) do
				cb(...)
			end
			if not usingOldCallbacks and OnWndMsg then OnWndMsg(...) end
		end
		Callback.Add("Tick", function() -- first time we use new defined struct
			for a, b in pairs(spells2) do
				for c, d in pairs(spells) do
					if b.spellOwner.networkID == c then
						spells[c].object = b
						spells[c].projectileID = b.networkID
						spells2[a] = nil
					end
				end
			end
			for k, v in pairs(spells) do
				if (not v.object or not v.object.ongoing) and v.time+GetLatency()/500+v.windUpTime-Timer() < 0 then
					spells[k] = nil
				end
			end
			local k, v = myHero.networkID, myHero.spell
			if v then
				if v.time+v.windUpTime-Timer() < 0 then
					spells[myHero.networkID][k] = nil
				end
			end
		end)
		function OldCallbacks()
			usingOldCallbacks = true
			for _, c in pairs(Callback.callbacks) do
				_G["On".._..""] = function(cb)
					Callback.Add(_, cb)
				end
			end
		end
	end
end
do -- object managers
	_G.objManager = _G.objManager or { -- object manager
		iCount = 0,
		objects = {},
		objectsNID = {},
		getByNetworkID = function(id)
			return objManager.objectsNID[id]
		end,
		getObject = function(id)
			return objManager.objects[id]
		end,
		addObject = function(o)
			objManager.iCount = objManager.iCount +1
			objManager.objects[objManager.iCount] = o
			local nID = o.networkID
			if nID and nID > 0 then
				objManager.objectsNID[nID] = o
			end
		end
	}

	_G.heroManager = _G.heroManager or { -- hero manager
		iCount = #heroes,
		GetHero = function(self, index)
			return heroes[type(self) == "number" and self or index]
		end,
		getHero = function(self, index)
			return heroes[type(self) == "number" and self or index]
		end,
	}

	class "MinionManager"

	function MinionManager:__init()
		self.objects = {}
		self.maxObjects = 0
		Callback.Add("ObjectLoad", function(o) self:CreateObj(o) end)
		Callback.Add("CreateObj", function(o) self:CreateObj(o) end)
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
	_G.minionManager = _G.minionManager or MinionManager()

	function GetMinions(_)
		return GetObjects(_,minionManager.objects,minionManager.maxObjects)
	end

	function GetHeroes(_)
		return GetObjects(_,heroes,#heroes)
	end

	function GetObjects(_,__,___)
		local i,o,c=0,__,___ or#__
		local function cpairs(_)
			local function IsOk(m,_)if m and m.valid then for k,v in pairs(_)do if (type(v)=="function"and not v(m)) or not m[k] or m[k]~=v then return false end end return true else return false end end
			i=1+i if i>c then return end local m=o[i]
			while not IsOk(m,_)do i=1+i if i>c then return end m=o[i]end
			return m
		end
		return cpairs,_ or{}
	end
end
do -- sprite class
	class "Sprite"

	function Sprite:__init(path, width, height, x, y, scale)
		scale = math.max(0, scale or 1)
		self.scale = scale
		self.id = CreateSpriteFromFile("\\"..path, self.scale)
		self.path = path
		self.x, self.y, self.sx, self.sy, self.w, self.h = 0, 0, x or 0, y or 0, w or 1, h or 1
		self.pos = { x = self.x, y = self.y }
		self.callbacks = {}
		self.Callback = {
			Add = function(which, what, posFunc)
				self.callbacks[which] = Callback.Add(which, function(...)
					if VecIsUnder(posFunc and posFunc() or GetCursorPos(), self.x, self.y, (self.w-self.sx)*self.scale, (self.h-self.sy)*self.scale) then
						what(...)
					end
				end)
			end,
			Del = function(which, what)
				Callback.Del(which, self.callbacks[which])
			end
		}
		self.width, self.heigth = self.w*self.scale, self.h*self.scale
	end

	function Sprite:Scale(scale)
		ReleaseSprite(self.id)
		scale = math.max(0, scale or 1)
		self.scale = scale
		self.id = CreateSpriteFromFile("\\"..self.path, scale or 1)
		self.width, self.heigth = self.w*self.scale, self.h*self.scale
	end

	function Sprite:Release()
		ReleaseSprite(self.id)
	end

	function Sprite:Draw(x, y, color, w, h, sx, sy)
		self.x, self.y, self.sx, self.sy, self.w, self.h = x or self.pos.x or 0, y or self.pos.y or 0, sx or self.sx, sy or self.sy, w or self.w, h or self.h
		self.pos = { x = self.x, y = self.y }
		DrawSprite(self.id, self.x, self.y, self.sx*self.scale, self.sy*self.scale, self.w*self.scale, self.h*self.scale, color or ARGB(255,255,255,255))
	end
end
do -- notify class
	Notify = { notifications = {}, time = 10, speed = 8.3 }

	function Notify.Add(header, text, time)
		table.insert(Notify.notifications, {header=header,text=text or"",time=time or Notify.time,t=os.clock(),x=250})
	end

	function Notify.Tick()
		for i=1, #Notify.notifications do
			local n = Notify.notifications[i]
			if n then
				if n.t+n.time<os.clock() then
					table.remove(Notify.notifications, i)
				elseif n.t+n.time-1<os.clock() then
					Notify.notifications[i].x = n.x + Notify.speed
				else
					Notify.notifications[i].x = math.max(0, n.x - Notify.speed)
				end
			end
		end
	end

	function Notify.Draw()
		for i=1, #Notify.notifications do
			local n = Notify.notifications[i]
			if n then
				FillRect(WINDOW_W-260+n.x,85*i+190,270,95,CursorIsUnder(WINDOW_W-260+n.x,85*i+190,270,95) and 0x17ffffff or 0x07ffffff)
				FillRect(WINDOW_W-250+n.x,85*i+200,250,75,0xaf000000)
				DrawTextOutline(n.header,25,WINDOW_W-245+n.x,85*i+200)
				DrawTextOutline(n.text,20,WINDOW_W-245+n.x,85*i+235)
			end
		end
	end

	function Notify.WndMsg(msg, key)
		if key == 0 and msg == 513 then
			for i=1, #Notify.notifications do
				if CursorIsUnder(WINDOW_W-260+Notify.notifications[i].x,85*i+190,270,95) then
					Notify.notifications[i].t = os.clock()-Notify.notifications[i].time+1
				end
			end
		end
	end

	Callback.Add("Draw", Notify.Draw)
	Callback.Add("Tick", Notify.Tick)
	Callback.Add("WndMsg", Notify.WndMsg)
end
do -- waypoint manager
end
do -- other functions
	function GetDistanceSqr(p1, p2)
		p2 = p2 or myHero.pos
		local dx = p1.x - p2.x
		local dz = (p1.z or p1.y) - (p2.z or p2.y)
		return dx*dx + dz*dz
	end

	function GetDistance(p1, p2)
		return math.sqrt(GetDistanceSqr(p1, p2))
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
			local _getType = t.__type or t.type or t.Type
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

	function print(...)
		local t, len = {}, select("#",...)
		for i=1, len do
			local v = select(i,...)
			local _type = ctype(v)
			if _type == "string" then t[i] = v
			elseif _type == "number" then t[i] = tostring(v)
			elseif _type == "table" then t[i] = table.serialize(v)
			elseif _type == "boolean" then t[i] = ({[true]="True",[false]="False"})[v]
			elseif _type == "userdata" then t[i] = ctostring(v)
			else t[i] = _type
			end
		end
		if len>0 then PrintChat(table.concat(t)) end
	end


	function ValidTarget(object, distance, enemyTeam)
		local enemyTeam = (enemyTeam ~= false)
		return object ~= nil and object.valid and (object.team ~= myHero.team) == enemyTeam and object.visible and not object.dead and object.isTargetable and (enemyTeam == false or object.isInvulnerable == false) and (distance == nil or GetDistanceSqr(object) <= distance * distance)
	end

	function ValidTargetNear(object, distance, target)
		return object ~= nil and object.valid and object.team == target.team and object.networkID ~= target.networkID and object.visible and not object.dead and object.bTargetable and GetDistanceSqr(target, object) <= distance * distance
	end

	function GetDistanceFromMouse(object)
		if object ~= nil and VectorType(object) then return GetDistance(object, mousePos) end
		return math.huge
	end

	local _enemyHeroes
	function GetEnemyHeroes()
		if _enemyHeroes then return _enemyHeroes end
		_enemyHeroes = {}
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team ~= myHero.team then
				table.insert(_enemyHeroes, hero)
			end
		end
		return setmetatable(_enemyHeroes,{
			__newindex = function(self, key, value)
				error("Adding to EnemyHeroes is not granted. Use table.copy.")
			end,
		})
	end

	local _allyHeroes
	function GetAllyHeroes()
		if _allyHeroes then return _allyHeroes end
		_allyHeroes = {}
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team and hero.networkID ~= myHero.networkID then
				table.insert(_allyHeroes, hero)
			end
		end
		return setmetatable(_allyHeroes,{
			__newindex = function(self, key, value)
				error("Adding to AllyHeroes is not granted. Use table.copy.")
			end,
		})
	end

	function GetDrawClock(time, offset)
		time, offset = time or 1, offset or 0
		return (os.clock() + offset) % time / time
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
				elseif vType == "function" and functions then
					local dump = string.dump(v)
					s[len+6], s[len+7], s[len+8], len = "load(Base64Decode(\"", Base64Encode(dump, #dump), "\")),\n", len + 8
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

	error = function(...)
		print("<font color=\"#FF0000\">[ERROR] ", ..., "</font>")
	end
	alert = function(...)
		print("<font color=\"#FFB700\">[ALERT] ", ..., "</font>")
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

	local fps, avgFps, frameCount, fFrame, lastFrame, updateFPS = 0, 0, 0, -math.huge, -math.huge, nil
	local function startFPSCounter()
		if not updateFPS then
			function updateFPS()
				fps = 1 / (os.clock() - lastFrame)
				lastFrame, frameCount = os.clock(), frameCount + 1
				if os.clock() < 0.5 + fFrame then return end
				avgFps = math.floor(frameCount / (os.clock() - fFrame))
				fFrame, frameCount = os.clock(), 0
			end

			Callback.Add("Draw", updateFPS)
		end
	end

	function GetExactFPS()
		startFPSCounter()
		return fps
	end

	function GetFPS()
		startFPSCounter()
		return avgFps
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
			Callback.Add("UnLoad", saveAll)
			Callback.Add("BugSplat", saveAll)
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

	function ReadFile(path)
		assert(type(path) == "string", "ReadFile: wrong argument types (<string> expected for path)")
		local file = io.open(path, "r")
		if not file then
			file = io.open(SCRIPT_PATH .. path, "r")
			if not file then
				file = io.open(LIB_PATH .. path, "r")
				if not file then return end
			end
		end
		local text = file:read("*all")
		file:close()
		return text
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

	function GetFileSize(path)
		assert(type(path) == "string", "GetFileSize: wrong argument types (<string> expected for path)")
		local file = io.open(path, "r")
		if not file then
			file = io.open(SCRIPT_PATH .. path, "r")
			if not file then
				file = io.open(LIB_PATH .. path, "r")
				if not file then return end
			end
		end
		local size = file:seek("end")
		file:close()
		return size
	end

	function IsInDistance(p1,r)
		return GetDistanceSqr(GetOrigin(p1)) < r*r
	end

	local _turrets, __turrets__OnTick
	local function __Turrets__init()
		if _turrets == nil then
			_turrets = {}
			local turretRange = 950
			local fountainRange = 1050
			local visibilityRange = 1300
			Callback.Add("ObjectLoad", function(object)
				if object ~= nil and object.type == Obj_AI_Turret then
					local turretName = object.name
					_turrets[turretName] = {
						object = object,
						team = object.team,
						range = turretRange,
						visibilityRange = visibilityRange,
						x = object.x,
						y = object.y,
						z = object.z,
					}
					if turretName == "Turret_OrderTurretShrine_A" or turretName == "Turret_ChaosTurretShrine_A" then
						_turrets[turretName].range = fountainRange
						Callback.Add("ObjectLoad", function(object2)
							if object2 ~= nil and object2.type == Obj_AI_SpawnPoint and GetDistanceSqr(object, object2) < 1000000 then
								_turrets[turretName].x = object2.x
								_turrets[turretName].z = object2.z
							elseif object2 ~= nil and object2.type == Obj_AI_Shop and GetTeam(object2) == GetTeam(object) then
								_turrets[turretName].y = object2.y
							end
						end)
					end
				end
			end)
			function __turrets__OnTick()
				for name, turret in pairs(_turrets) do
					if not turret.object.valid or turret.object.dead or turret.object.health == 0 then
						_turrets[name] = nil
					end
				end
			end
			Callback.Add("Tick", __turrets__OnTick)
		end
	end;__Turrets__init()

	function GetTurrets()
		return _turrets
	end

	function GetUnderTurret(pos, enemyTurret)
		local enemyTurret = (enemyTurret ~= false)
		for _, turret in pairs(_turrets) do
			if turret ~= nil and (turret.team ~= myHero.team) == enemyTurret and GetDistanceSqr(turret, pos) <= (turret.range) ^ 2 then
				return turret
			end
		end
	end

	function UnderTurret(pos, enemyTurret)
		return (GetUnderTurret(pos, enemyTurret) ~= nil)
	end

	local delayedActions, delayedActionsExecuter = {}, nil
	function DelayAction(func, delay, args) --delay in seconds
		if not delayedActionsExecuter then
			function delayedActionsExecuter()
				for t, funcs in pairs(delayedActions) do
					if t <= os.clock() then
						for _, f in ipairs(funcs) do f.func(unpack(f.args or {})) end
						delayedActions[t] = nil
					end
				end
			end
			Callback.Add("Tick", delayedActionsExecuter)
		end
		local t = os.clock() + (delay or 0)
		if delayedActions[t] then table.insert(delayedActions[t], { func = func, args = args })
		else delayedActions[t] = { { func = func, args = args } }
		end
	end

	local _intervalFunction
	function SetInterval(userFunction, timeout, count, params)
		if not _intervalFunction then
			function _intervalFunction(userFunction, startTime, timeout, count, params)
				if userFunction(table.unpack(params or {})) ~= false and (not count or count > 1) then
					DelayAction(_intervalFunction, (timeout - (os.clock() - startTime - timeout)), { userFunction, startTime + timeout, timeout, count and (count - 1), params })
				end
			end
		end
		DelayAction(_intervalFunction, timeout, { userFunction, os.clock(), timeout or 0, count, params })
	end

	local _DrawText, _PrintChat, _DrawLine, _DrawCircle, _FillRect2 = DrawText, PrintChat, DrawLine, DrawCircle, FillRect
	function EnableOverlay()
		_G.DrawText, _G.PrintChat, _G.DrawLine, _G.DrawCircle, _G.FillRect = _DrawText, _PrintChat, _DrawLine, _DrawCircle, _FillRect
	end

	function DisableOverlay()
		_DrawText, _PrintChat, _DrawLine, _DrawCircle, _FillRect2 = DrawText, PrintChat, DrawLine, DrawCircle, FillRect
		_G.DrawText, _G.PrintChat, _G.DrawLine, _G.DrawCircle, _G.FillRect = function() end, function() end, function() end, function() end, function() end
	end

	function BuffIsValid(buff)
		return buff and buff.name and buff.startT <= GetGameTimer() and buff.startT+buff.endT >= GetGameTimer()
	end

	function UnitHaveBuff(target, buffName)
		assert(type(buffName) == "string" or type(buffName) == "table", "TargetHaveBuff: wrong argument types (<string> or <table of string> expected for buffName)")
		for i = 1, target.buffCount do
			local tBuff = target:getBuff(i)
			if BuffIsValid(tBuff) then
				if type(buffName) == "string" then
					if tBuff.name:lower() == buffName:lower() then return true end
				else
					for _, sBuff in ipairs(buffName) do
						if tBuff.name:lower() == sBuff:lower() then return true end
					end
				end
			end
		end
		return false
	end

	function CountEnemyHeroInRange(range, object)
		object = object or myHero
		range = range and range * range or myHero.range * myHero.range
		local enemyInRange = 0
		for i = 1, heroManager.iCount, 1 do
			local hero = heroManager:getHero(i)
			if ValidTarget(hero) and GetDistanceSqr(object, hero) <= range then
				enemyInRange = enemyInRange + 1
			end
		end
		return enemyInRange
	end

	function DrawLine3D(x,y,z,a,b,c,width,col)
		local p1 = WorldToScreen(0, Vector(x,y,z))
		local p2 = WorldToScreen(0, Vector(a,b,c))
		DrawLine(p1.x, p1.y, p2.x, p2.y, width, col)
	end

	function DrawRectangleOutline(startPos, endPos, width, t, color)
		local c1 = startPos+Vector(Vector(endPos)-startPos):perpendicular():normalized()*width
		local c2 = startPos+Vector(Vector(endPos)-startPos):perpendicular2():normalized()*width
		local c3 = endPos+Vector(Vector(startPos)-endPos):perpendicular():normalized()*width
		local c4 = endPos+Vector(Vector(startPos)-endPos):perpendicular2():normalized()*width
		DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,t,color)
		DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,t,color)
		DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,t,color)
		DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,t,color)
	end

	function GetMaladySlot(unit)
		for slot = 6, 13 do
		if GetCastName(unit, slot) and GetCastName(unit, slot):lower():find("malady") then
			return slot
		end
		end
		return nil
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

	function Ready(slot)
		return CanUseSpell(myHero, slot) == 0
	end IsReady = Ready

	function GetLineFarmPosition(range, width, team)
		local BestPos 
		local BestHit = 0
		local objects = minionManager.objects
		for i, object in pairs(objects) do
			if GetOrigin(object) ~= nil and IsObjectAlive(object) and (not team or GetTeam(object) == team) then
				local EndPos = Vector(myHero) + range * (Vector(object) - Vector(myHero)):normalized()
				local hit = CountObjectsOnLineSegment(GetOrigin(myHero), EndPos, width, objects, team)
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

	function GetFarmPosition(range, width, team)
		local BestPos 
		local BestHit = 0
		local objects = minionManager.objects
		for i, object in pairs(objects) do
			if GetOrigin(object) ~= nil and IsObjectAlive(object) and (not team or GetTeam(object) == team) then
				local hit = CountObjectsNearPos(Vector(object), range, width, objects, team)
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

	function CountObjectsOnLineSegment(StartPos, EndPos, width, objects, team)
		local n = 0
		for i, object in pairs(objects) do
			if object ~= nil and object.valid and (not team or object.team == team) then
				local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, GetOrigin(object))
				local w = width
				if isOnSegment and GetDistanceSqr(pointSegment, GetOrigin(object)) < w^2 and GetDistanceSqr(StartPos, EndPos) > GetDistanceSqr(StartPos, GetOrigin(object)) then
					n = n + 1
				end
			end
		end
		return n
	end

	function CountObjectsNearPos(pos, range, radius, objects, team)
		local n = 0
		for i, object in pairs(objects) do
			if IsObjectAlive(object) and (not team or GetTeam(object) == team) and GetDistanceSqr(pos, Vector(object)) <= radius^2 then
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

	function DrawScreenCircle(x, y, size, color, quality, elliptic)
		local quality = quality or 1;
		local elliptic = elliptic or 1;
		for theta=0,360,quality do
			DrawLine(x + size * math.cos(2*math.pi/360*theta), y - elliptic * size * math.sin(2*math.pi/360*theta), x + size * math.cos(2*math.pi/360*(theta-1)), y - elliptic * size * math.sin(2*math.pi/360*(theta-1)), 1, color)
		end
	end

	function DrawFilledScreenCircle(x, y, size, color, quality, elliptic)
		local quality = quality or 1;
		local elliptic = elliptic or 1;
		for theta=0,360,quality do
			DrawLine(x + size * math.cos(2*math.pi/360*theta), y - elliptic * size * math.sin(2*math.pi/360*theta), x + size * math.cos(2*math.pi/360*(theta-180)), y - elliptic * size * math.sin(2*math.pi/360*(theta-180)), 1, color)
		end
	end

	function DrawCircle2(o, radius, width, quality, color)
		local p = GetOrigin(o) or o
		local quality = quality and 2 * math.pi / quality or 2 * math.pi / (radius / 5);
		local points = {}
		for theta=0,2*math.pi+quality,quality do
			local a = WorldToScreen(0, Vector(p.x+radius*math.cos(theta), p.y, p.z-radius*math.sin(theta)))
			points[1+#points] = a
		end
		for I=1, #points-1 do
			local a = points[I]
			local b = points[I+1]
			DrawLine(a.x, a.y, b.x, b.y, width, color)
		end
	end

	function DrawLines2(t,w,c)
		for i=1, #t-1 do
			if t[i].x > 0 and t[i].y > 0 and t[i+1].x > 0 and t[i+1].y > 0 then
				DrawLine(t[i].x, t[i].y, t[i+1].x, t[i+1].y, w, c)
			end
		end
	end

	function DrawRectangle(x, y, width, height, color, thickness)
		local thickness = thickness or 1
		if thickness == 0 then return end
		x = x - 1
		y = y - 1
		width = width + 2
		height = height + 2
		local halfThick = math.floor(thickness/2)
		DrawLine(x - halfThick, y, x + width + halfThick, y, thickness, color)
		DrawLine(x, y + halfThick, x, y + height - halfThick, thickness, color)
		DrawLine(x + width, y + halfThick, x + width, y + height - halfThick, thickness, color)
		DrawLine(x - halfThick, y + height, x + width + halfThick, y + height, thickness, color)
	end

	function OnScreen(x, y) 
		local typex = type(x)
		if typex == "number" then 
			return x <= WINDOW_W and x >= 0 and y >= 0 and y <= WINDOW_H
		elseif typex == "userdata" or typex == "table" then
			local p1, p2, p3, p4 = {x = 0,y = 0}, {x = WINDOW_W,y = 0}, {x = 0,y = WINDOW_H}, {x = WINDOW_W,y = WINDOW_H}
			return OnScreen(x.x, x.z or x.y) or (y and OnScreen(y.x, y.z or y.y) or IsLineSegmentIntersection(x,y,p1,p2) or IsLineSegmentIntersection(x,y,p3,p4) or IsLineSegmentIntersection(x,y,p1,p3) or IsLineSegmentIntersection(x,y,p2,p4))
		end
	end

	function DrawLineBorder3D(x1, y1, z1, x2, y2, z2, size, color, width)
		local o = { x = -(z2 - z1), z = x2 - x1 }
		local len = math.sqrt(o.x ^ 2 + o.z ^ 2)
		o.x, o.z = o.x / len * size / 2, o.z / len * size / 2
		local points = {
			WorldToScreen(1,Vector(x1 + o.x, y1, z1 + o.z)),
			WorldToScreen(1,Vector(x1 - o.x, y1, z1 - o.z)),
			WorldToScreen(1,Vector(x2 - o.x, y2, z2 - o.z)),
			WorldToScreen(1,Vector(x2 + o.x, y2, z2 + o.z)),
			WorldToScreen(1,Vector(x1 + o.x, y1, z1 + o.z)),
		}
		for i, c in ipairs(points) do points[i] = Vector(c.x, c.y) end
		DrawLines2(points, width or 1, color or 4294967295)
	end

	function DrawLineBorder(x1, y1, x2, y2, size, color, width)
		local o = { x = -(y2 - y1), y = x2 - x1 }
		local len = math.sqrt(o.x ^ 2 + o.y ^ 2)
		o.x, o.y = o.x / len * size / 2, o.y / len * size / 2
		local points = {
			Vector(x1 + o.x, y1 + o.y),
			Vector(x1 - o.x, y1 - o.y),
			Vector(x2 - o.x, y2 - o.y),
			Vector(x2 + o.x, y2 + o.y),
			Vector(x1 + o.x, y1 + o.y),
		}
		DrawLines2(points, width or 1, color or 4294967295)
	end

	function DrawCircle2D(x, y, radius, width, color, quality)
		quality, radius = quality and 2 * math.pi / quality or 2 * math.pi / 20, radius or 50
		local points = {}
		for theta = 0, 2 * math.pi + quality, quality do
			points[#points + 1] = Vector(x + radius * math.cos(theta), y - radius * math.sin(theta))
		end
		DrawLines2(points, width or 1, color or 4294967295)
	end

	function DrawCircle3D(x, y, z, radius, width, color, quality)
		radius = radius or 300
		quality = quality and 2 * math.pi / quality or 2 * math.pi / (radius / 5)
		local points = {}
		for theta = 0, 2 * math.pi + quality, quality do
			local c = WorldToScreen(1,Vector(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
			points[#points + 1] = Vector(c.x, c.y)
		end
		DrawLines2(points, width or 1, color or 4294967295)
	end

	function DrawLine3D(x1, y1, z1, x2, y2, z2, width, color)
		local p = WorldToScreen(1,Vector(x1, y1, z1))
		local px, py = p.x, p.y
		local c = WorldToScreen(1,Vector(x2, y2, z2))
		local cx, cy = c.x, c.y
		if OnScreen({ x = px, y = py }, { x = px, y = py }) then
			DrawLine(cx, cy, px, py, width or 1, color or 4294967295)
		end
	end

	function DrawLines3D(points, width, color)
		local l
		for _, point in ipairs(points) do
			local p = { x = point.x, y = point.y, z = point.z }
			if not p.z then p.z = p.y; p.y = nil end
			p.y = p.y or player.y
			local c = WorldToScreen(1,Vector(p.x, p.y, p.z))
			if l and OnScreen({ x = l.x, y = l.y }, { x = c.x, y = c.y }) then
				DrawLine(l.x, l.y, c.x, c.y, width or 1, color or 4294967295)
			end
			l = c
		end
	end

	local old_DrawText = DrawText
	function DrawText(str, s, x, y, col)
		old_DrawText(tostring(str), s, x, y, col or ARGB(255,255,255,255))
	end

	function DrawTextA(text, size, x, y, color, halign, valign)
		local textArea = GetTextArea(tostring(text) or "", size or 12)
		halign, valign = halign and halign:lower() or "left", valign and valign:lower() or "top"
		x = (halign == "right"	and x - textArea.x) or (halign == "center" and x - textArea.x/2) or x or 0
		y = (valign == "bottom" and y - textArea.y) or (valign == "center" and y - textArea.y/2) or y or 0
		DrawText(tostring(text) or "", size or 12, math.floor(x), math.floor(y), color or 4294967295)
	end

	function DrawText3D(text, x, y, z, size, color, center)
		local p = WorldToScreen(1,Vector(x, y, z))
		local textArea = GetTextArea(text, size or 12)
		if center then
			if OnScreen(p.x + textArea.x / 2, p.y + textArea.y / 2) then
				DrawText(text, size or 12, p.x - textArea.x / 2, p.y, color or 4294967295)
			end
		else
			if OnScreen({ x = p.x, y = p.y }, { x = p.x + textArea.x, y = p.y + textArea.y }) then
				DrawText(text, size or 12, p.x, p.y, color or 4294967295)
			end
		end
	end

	class'MEC'
	function MEC:__init(points)
		self.circle = Circle()
		self.points = {}
		if points then
			self:SetPoints(points)
		end
	end

	function MEC:SetPoints(points)
		-- Set the points
		self.points = {}
		for _, p in ipairs(points) do
			table.insert(self.points, Vector(p))
		end
	end

	function MEC:HalfHull(left, right, pointTable, factor)
		-- Computes the half hull of a set of points
		local input = pointTable
		table.insert(input, right)
		local half = {}
		table.insert(half, left)
		for _, p in ipairs(input) do
			table.insert(half, p)
			while #half >= 3 do
				local dir = factor * VectorDirection(half[(#half + 1) - 3], half[(#half + 1) - 1], half[(#half + 1) - 2])
				if dir <= 0 then
					table.remove(half, #half - 1)
				else
					break
				end
			end
		end
		return half
	end

	function MEC:ConvexHull()
		-- Computes the set of points that represent the convex hull of the set of points
		local left, right = self.points[1], self.points[#self.points]
		local upper, lower, ret = {}, {}, {}
		-- Partition remaining points into upper and lower buckets.
		for i = 2, #self.points - 1 do
			if VectorType(self.points[i]) == false then PrintChat("self.points[i]") end
			table.insert((VectorDirection(left, right, self.points[i]) < 0 and upper or lower), self.points[i])
		end
		local upperHull = self:HalfHull(left, right, upper, -1)
		local lowerHull = self:HalfHull(left, right, lower, 1)
		local unique = {}
		for _, p in ipairs(upperHull) do
			unique["x" .. p.x .. "z" .. p.z] = p
		end
		for _, p in ipairs(lowerHull) do
			unique["x" .. p.x .. "z" .. p.z] = p
		end
		for _, p in pairs(unique) do
			table.insert(ret, p)
		end
		return ret
	end

	function MEC:Compute()
		-- Compute the MEC.
		-- Make sure there are some points.
		if #self.points == 0 then return nil end
		-- Handle degenerate cases first
		if #self.points == 1 then
			self.circle.center = self.points[1]
			self.circle.radius = 0
			self.circle.radiusPoint = self.points[1]
		elseif #self.points == 2 then
			local a = self.points
			self.circle.center = a[1]:center(a[2])
			self.circle.radius = a[1]:dist(self.circle.center)
			self.circle.radiusPoint = a[1]
		else
			local a = self:ConvexHull()
			local point_a = a[1]
			local point_b
			local point_c = a[2]
			if not point_c then
				self.circle.center = point_a
				self.circle.radius = 0
				self.circle.radiusPoint = point_a
				return self.circle
			end
			-- Loop until we get appropriate values for point_a and point_c
			while true do
				point_b = nil
				local best_theta = 180.0
				-- Search for the point "b" which subtends the smallest angle a-b-c.
				for _, point in ipairs(self.points) do
					if (not point == point_a) and (not point == point_c) then
						local theta_abc = point:angleBetween(point_a, point_c)
						if theta_abc < best_theta then
							point_b = point
							best_theta = theta_abc
						end
					end
				end
				-- If the angle is obtuse, then line a-c is the diameter of the circle,
				-- so we can return.
				if best_theta >= 90.0 or (not point_b) then
					self.circle.center = point_a:center(point_c)
					self.circle.radius = point_a:dist(self.circle.center)
					self.circle.radiusPoint = point_a
					return self.circle
				end
				local ang_bca = point_c:angleBetween(point_b, point_a)
				local ang_cab = point_a:angleBetween(point_c, point_b)
				if ang_bca > 90.0 then
					point_c = point_b
				elseif ang_cab <= 90.0 then
					break
				else
					point_a = point_b
				end
			end
			local ch1 = (point_b - point_a) * 0.5
			local ch2 = (point_c - point_a) * 0.5
			local n1 = ch1:perpendicular2()
			local n2 = ch2:perpendicular2()
			ch1 = point_a + ch1
			ch2 = point_a + ch2
			self.circle.center = VectorIntersection(ch1, n1, ch2, n2)
			self.circle.radius = self.circle.center:dist(point_a)
			self.circle.radiusPoint = point_a
		end
		return self.circle
	end

	function GetMEC(radius, range, target)
		assert(type(radius) == "number" and type(range) == "number" and (target == nil or target.team ~= nil), "GetMEC: wrong argument types (expected <number>, <number>, <object> or nil)")
		local points = {}
		for i = 1, heroManager.iCount do
			local object = heroManager:GetHero(i)
			if (target == nil and ValidTarget(object, (range + radius))) or (target and ValidTarget(object, (range + radius), (target.team ~= player.team)) and (ValidTargetNear(object, radius * 2, target) or object.networkID == target.networkID)) then
				table.insert(points, Vector(object))
			end
		end
		return _CalcSpellPosForGroup(radius, range, points)
	end

	function _CalcSpellPosForGroup(radius, range, points)
		if #points == 0 then
			return nil
		elseif #points == 1 then
			return Circle(Vector(points[1]))
		end
		local mec = MEC()
		local combos = {}
		for j = #points, 2, -1 do
			local spellPos
			combos[j] = {}
			_CalcCombos(j, points, combos[j])
			for _, v in ipairs(combos[j]) do
				mec:SetPoints(v)
				local c = mec:Compute()
				if c ~= nil and c.radius <= radius and c.center:dist(player) <= range and (spellPos == nil or c.radius < spellPos.radius) then
					spellPos = Circle(c.center, c.radius)
				end
			end
			if spellPos ~= nil then return spellPos end
		end
	end

	function _CalcCombos(comboSize, targetsTable, comboTableToFill, comboString, index_number)
		local comboString = comboString or ""
		local index_number = index_number or 1
		if string.len(comboString) == comboSize then
			local b = {}
			for i = 1, string.len(comboString), 1 do
				local ai = tonumber(string.sub(comboString, i, i))
				table.insert(b, targetsTable[ai])
			end
			return table.insert(comboTableToFill, b)
		end
		for i = index_number, #targetsTable, 1 do
			_CalcCombos(comboSize, targetsTable, comboTableToFill, comboString .. i, i + 1)
		end
	end

	-- for combat
	FindGroupCenterFromNearestEnemies = GetMEC
	function FindGroupCenterNearTarget(target, radius, range)
		return GetMEC(radius, range, target)
	end

	function DrawTextOutline(t, s, x, y, c, l)
		for i=-1, 1, 1 do
			for j=-1, 1, 1 do
				DrawText(t, s, x+i, y+j, l or ARGB(255, 0, 0, 0))
			end
		end
		DrawText(t, s, x, y, c or ARGB(255, 255, 255, 255))
	end

	function DrawTextOutlineA(t, s, x, y, h, v, c, l)
		for i=-1, 1, 1 do
			for j=-1, 1, 1 do
				DrawTextA(t, s, x+i, y+j, l or ARGB(255, 0, 0, 0), h, v)
			end
		end
		DrawTextA(t, s, x, y, c or ARGB(255, 255, 255, 255), h, v)
	end

	function GetTextArea(str, size)
		local ret=0
		for c in str:gmatch"." do
			if c==" " then 
				ret=ret+4
			elseif tonumber(c)~=nil then 
				ret=ret+6
			elseif c==string.upper(c) then 
				ret=ret+8
			elseif c==string.lower(c) then 
				ret=ret+7
			else 
				ret=ret+5 
			end
		end
		return {x = ret * size * 0.035, y = size }
	end
end
do -- orbwalker
	class "InspiredsOrbWalker"
	function InspiredsOrbWalker:__init()
	  _G.IOWversion = 2
	  myHeroName = myHero.charName
	  self.attacksEnabled = true
	  self.movementEnabled = true
	  self.altAttacks = Set { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3" }
	  self.resetAttacks = Set { "dariusnoxiantacticsonh", "fiorae", "garenq", "hecarimrapidslash", "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak", "luciane", "lucianq", "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq", "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow", "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw", "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie", "volibearq", "xenzhaocombotarget", "yorickspectral", "reksaiq", "riventricleave", "itemtitanichydracleave", "itemtiamatcleave" }
	  self.autoAttackT = 0
	  self.lastBoundingChange = 0
	  self.lastStickChange = 0
	  self.callbacks = {[1] = {}, [2] = {}, [3] = {}}
	  self.bonusDamageTable = {
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
	        return ADDmg, APDmg + (GotBuff(source, "netherbladebuff") > 0 and 20+.1*GetBonusAP(source) or (GotBuff(source, "netherblade") > 0 and 25*GetCastLevel(source, _W)+15+.6*GetBonusAP(source) or 0)), TRUEDmg
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
	        return ADDmg + (GotBuff(source, "reksaiq") > 0 and 10*GetCastLevel(source, _Q)+5+.2*(ADDmg) or 0), APDmg, TRUEDmg
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
	  self.projspeed = {
	    ["Velkoz"]= 2000,
	    ["TahmKench"]= math.huge,
	    ["Kindred"]= 2000,
	    ["Kalista"]= 2600,
	    ["TeemoMushroom"] = math.huge,
	    ["TestCubeRender"] = math.huge,
	    ["Xerath"] = 2000.0000,
	    ["Kassadin"] = math.huge,
	    ["Rengar"] = math.huge,
	    ["Thresh"] = 1000.0000,
	    ["Ziggs"] = 1500.0000,
	    ["ZyraPassive"] = 1500.0000,
	    ["ZyraThornPlant"] = 1500.0000,
	    ["KogMaw"] = 1800.0000,
	    ["HeimerTBlue"] = 1599.3999,
	    ["EliseSpider"] = 500.0000,
	    ["Skarner"] = 500.0000,
	    ["ChaosNexus"] = 500.0000,
	    ["Katarina"] = math.huge,
	    ["Riven"] = math.huge,
	    ["SightWard"] = math.huge,
	    ["HeimerTYellow"] = 1599.3999,
	    ["Ashe"] = 2000.0000,
	    ["VisionWard"] = 2000.0000,
	    ["TT_NGolem2"] = math.huge,
	    ["ThreshLantern"] = math.huge,
	    ["TT_Spiderboss"] = math.huge,
	    ["OrderNexus"] = math.huge,
	    ["Soraka"] = 1000.0000,
	    ["Jinx"] = 2750.0000,
	    ["TestCubeRenderwCollision"] = 2750.0000,
	    ["Red_Minion_Wizard"] = 650.0000,
	    ["JarvanIV"] = math.huge,
	    ["Blue_Minion_Wizard"] = 650.0000,
	    ["TT_ChaosTurret2"] = 1200.0000,
	    ["TT_ChaosTurret3"] = 1200.0000,
	    ["TT_ChaosTurret1"] = 1200.0000,
	    ["ChaosTurretGiant"] = 1200.0000,
	    ["Dragon"] = 1200.0000,
	    ["LuluSnowman"] = 1200.0000,
	    ["Worm"] = 1200.0000,
	    ["ChaosTurretWorm"] = 1200.0000,
	    ["TT_ChaosInhibitor"] = 1200.0000,
	    ["ChaosTurretNormal"] = 1200.0000,
	    ["AncientGolem"] = 500.0000,
	    ["ZyraGraspingPlant"] = 500.0000,
	    ["HA_AP_OrderTurret3"] = 1200.0000,
	    ["HA_AP_OrderTurret2"] = 1200.0000,
	    ["Tryndamere"] = math.huge,
	    ["OrderTurretNormal2"] = 1200.0000,
	    ["Singed"] = 700.0000,
	    ["OrderInhibitor"] = 700.0000,
	    ["Diana"] = math.huge,
	    ["HA_FB_HealthRelic"] = math.huge,
	    ["TT_OrderInhibitor"] = math.huge,
	    ["GreatWraith"] = 750.0000,
	    ["Yasuo"] = math.huge,
	    ["OrderTurretDragon"] = 1200.0000,
	    ["OrderTurretNormal"] = 1200.0000,
	    ["LizardElder"] = 500.0000,
	    ["HA_AP_ChaosTurret"] = 1200.0000,
	    ["Ahri"] = 1750.0000,
	    ["Lulu"] = 1450.0000,
	    ["ChaosInhibitor"] = 1450.0000,
	    ["HA_AP_ChaosTurret3"] = 1200.0000,
	    ["HA_AP_ChaosTurret2"] = 1200.0000,
	    ["ChaosTurretWorm2"] = 1200.0000,
	    ["TT_OrderTurret1"] = 1200.0000,
	    ["TT_OrderTurret2"] = 1200.0000,
	    ["TT_OrderTurret3"] = 1200.0000,
	    ["LuluFaerie"] = 1200.0000,
	    ["HA_AP_OrderTurret"] = 1200.0000,
	    ["OrderTurretAngel"] = 1200.0000,
	    ["YellowTrinketUpgrade"] = 1200.0000,
	    ["MasterYi"] = math.huge,
	    ["Lissandra"] = 2000.0000,
	    ["ARAMOrderTurretNexus"] = 1200.0000,
	    ["Draven"] = 1700.0000,
	    ["FiddleSticks"] = 1750.0000,
	    ["SmallGolem"] = math.huge,
	    ["ARAMOrderTurretFront"] = 1200.0000,
	    ["ChaosTurretTutorial"] = 1200.0000,
	    ["NasusUlt"] = 1200.0000,
	    ["Maokai"] = math.huge,
	    ["Wraith"] = 750.0000,
	    ["Wolf"] = math.huge,
	    ["Sivir"] = 1750.0000,
	    ["Corki"] = 2000.0000,
	    ["Janna"] = 1200.0000,
	    ["Nasus"] = math.huge,
	    ["Golem"] = math.huge,
	    ["ARAMChaosTurretFront"] = 1200.0000,
	    ["ARAMOrderTurretInhib"] = 1200.0000,
	    ["LeeSin"] = math.huge,
	    ["HA_AP_ChaosTurretTutorial"] = 1200.0000,
	    ["GiantWolf"] = math.huge,
	    ["HA_AP_OrderTurretTutorial"] = 1200.0000,
	    ["YoungLizard"] = 750.0000,
	    ["Jax"] = math.huge,
	    ["LesserWraith"] = math.huge,
	    ["Blitzcrank"] = math.huge,
	    ["ARAMChaosTurretInhib"] = 1200.0000,
	    ["Shen"] = math.huge,
	    ["Nocturne"] = math.huge,
	    ["Sona"] = 1500.0000,
	    ["ARAMChaosTurretNexus"] = 1200.0000,
	    ["YellowTrinket"] = 1200.0000,
	    ["OrderTurretTutorial"] = 1200.0000,
	    ["Caitlyn"] = 2500.0000,
	    ["Trundle"] = math.huge,
	    ["Malphite"] = 1000.0000,
	    ["Mordekaiser"] = math.huge,
	    ["ZyraSeed"] = math.huge,
	    ["Vi"] = 1000.0000,
	    ["Tutorial_Red_Minion_Wizard"] = 650.0000,
	    ["Renekton"] = math.huge,
	    ["Anivia"] = 1400.0000,
	    ["Fizz"] = math.huge,
	    ["Heimerdinger"] = 1500.0000,
	    ["Evelynn"] = math.huge,
	    ["Rumble"] = math.huge,
	    ["Leblanc"] = 1700.0000,
	    ["Darius"] = math.huge,
	    ["OlafAxe"] = math.huge,
	    ["Viktor"] = 2300.0000,
	    ["XinZhao"] = math.huge,
	    ["Orianna"] = 1450.0000,
	    ["Vladimir"] = 1400.0000,
	    ["Nidalee"] = 1750.0000,
	    ["Tutorial_Red_Minion_Basic"] = math.huge,
	    ["ZedShadow"] = math.huge,
	    ["Syndra"] = 1800.0000,
	    ["Zac"] = 1000.0000,
	    ["Olaf"] = math.huge,
	    ["Veigar"] = 1100.0000,
	    ["Twitch"] = 2500.0000,
	    ["Alistar"] = math.huge,
	    ["Akali"] = math.huge,
	    ["Urgot"] = 1300.0000,
	    ["Leona"] = math.huge,
	    ["Talon"] = math.huge,
	    ["Karma"] = 1500.0000,
	    ["Jayce"] = math.huge,
	    ["Galio"] = 1000.0000,
	    ["Shaco"] = math.huge,
	    ["Taric"] = math.huge,
	    ["TwistedFate"] = 1500.0000,
	    ["Varus"] = 2000.0000,
	    ["Garen"] = math.huge,
	    ["Swain"] = 1600.0000,
	    ["Vayne"] = 2000.0000,
	    ["Fiora"] = math.huge,
	    ["Quinn"] = 2000.0000,
	    ["Kayle"] = math.huge,
	    ["Blue_Minion_Basic"] = math.huge,
	    ["Brand"] = 2000.0000,
	    ["Teemo"] = 1300.0000,
	    ["Amumu"] = math.huge,
	    ["Annie"] = 1200.0000,
	    ["Odin_Blue_Minion_caster"] = 1200.0000,
	    ["Elise"] = 1600.0000,
	    ["Nami"] = 1500.0000,
	    ["Poppy"] = math.huge,
	    ["AniviaEgg"] = 500.0000,
	    ["Tristana"] = 2250.0000,
	    ["Graves"] = 3000.0000,
	    ["Morgana"] = 1600.0000,
	    ["Gragas"] = math.huge,
	    ["MissFortune"] = 2000.0000,
	    ["Warwick"] = math.huge,
	    ["Cassiopeia"] = 1200.0000,
	    ["Tutorial_Blue_Minion_Wizard"] = 650.0000,
	    ["DrMundo"] = math.huge,
	    ["Volibear"] = 467.0000,
	    ["Irelia"] = 467.0000,
	    ["Odin_Red_Minion_Caster"] = 650.0000,
	    ["Lucian"] = 2800.0000,
	    ["Yorick"] = math.huge,
	    ["RammusPB"] = math.huge,
	    ["Red_Minion_Basic"] = math.huge,
	    ["Udyr"] = math.huge,
	    ["MonkeyKing"] = math.huge,
	    ["Tutorial_Blue_Minion_Basic"] = math.huge,
	    ["Kennen"] = 1600.0000,
	    ["Nunu"] = math.huge,
	    ["Ryze"] = 2400.0000,
	    ["Zed"] = math.huge,
	    ["Nautilus"] = 1000.0000,
	    ["Gangplank"] = 1000.0000,
	    ["Lux"] = 1600.0000,
	    ["Sejuani"] = math.huge,
	    ["Ezreal"] = 2000.0000,
	    ["OdinNeutralGuardian"] = 1800.0000,
	    ["Khazix"] = math.huge,
	    ["Sion"] = math.huge,
	    ["Aatrox"] = math.huge,
	    ["Hecarim"] = math.huge,
	    ["Pantheon"] = math.huge,
	    ["Shyvana"] = math.huge,
	    ["Zyra"] = 1700.0000,
	    ["Karthus"] = 1200.0000,
	    ["Rammus"] = math.huge,
	    ["Zilean"] = 1200.0000,
	    ["Chogath"] = math.huge,
	    ["Malzahar"] = 2000.0000,
	    ["YorickRavenousGhoul"] = math.huge,
	    ["YorickSpectralGhoul"] = math.huge,
	    ["JinxMine"] = 347.79999,
	    ["YorickDecayedGhoul"] = math.huge,
	    ["XerathArcaneBarrageLauncher"] = 347.79999,
	    ["Odin_SOG_Order_Crystal"] = 347.79999,
	    ["TestCube"] = 347.79999,
	    ["ShyvanaDragon"] = math.huge,
	    ["FizzBait"] = math.huge,
	    ["Blue_Minion_MechMelee"] = math.huge,
	    ["OdinQuestBuff"] = math.huge,
	    ["TT_Buffplat_L"] = math.huge,
	    ["TT_Buffplat_R"] = math.huge,
	    ["KogMawDead"] = math.huge,
	    ["TempMovableChar"] = math.huge,
	    ["Lizard"] = 500.0000,
	    ["GolemOdin"] = math.huge,
	    ["OdinOpeningBarrier"] = math.huge,
	    ["TT_ChaosTurret4"] = 500.0000,
	    ["TT_Flytrap_A"] = 500.0000,
	    ["TT_NWolf"] = math.huge,
	    ["OdinShieldRelic"] = math.huge,
	    ["LuluSquill"] = math.huge,
	    ["redDragon"] = math.huge,
	    ["MonkeyKingClone"] = math.huge,
	    ["Odin_skeleton"] = math.huge,
	    ["OdinChaosTurretShrine"] = 500.0000,
	    ["Cassiopeia_Death"] = 500.0000,
	    ["OdinCenterRelic"] = 500.0000,
	    ["OdinRedSuperminion"] = math.huge,
	    ["JarvanIVWall"] = math.huge,
	    ["ARAMOrderNexus"] = math.huge,
	    ["Red_Minion_MechCannon"] = 1200.0000,
	    ["OdinBlueSuperminion"] = math.huge,
	    ["SyndraOrbs"] = math.huge,
	    ["LuluKitty"] = math.huge,
	    ["SwainNoBird"] = math.huge,
	    ["LuluLadybug"] = math.huge,
	    ["CaitlynTrap"] = math.huge,
	    ["TT_Shroom_A"] = math.huge,
	    ["ARAMChaosTurretShrine"] = 500.0000,
	    ["Odin_Windmill_Propellers"] = 500.0000,
	    ["TT_NWolf2"] = math.huge,
	    ["OdinMinionGraveyardPortal"] = math.huge,
	    ["SwainBeam"] = math.huge,
	    ["Summoner_Rider_Order"] = math.huge,
	    ["TT_Relic"] = math.huge,
	    ["odin_lifts_crystal"] = math.huge,
	    ["OdinOrderTurretShrine"] = 500.0000,
	    ["SpellBook1"] = 500.0000,
	    ["Blue_Minion_MechCannon"] = 1200.0000,
	    ["TT_ChaosInhibitor_D"] = 1200.0000,
	    ["Odin_SoG_Chaos"] = 1200.0000,
	    ["TrundleWall"] = 1200.0000,
	    ["HA_AP_HealthRelic"] = 1200.0000,
	    ["OrderTurretShrine"] = 500.0000,
	    ["OriannaBall"] = 500.0000,
	    ["ChaosTurretShrine"] = 500.0000,
	    ["LuluCupcake"] = 500.0000,
	    ["HA_AP_ChaosTurretShrine"] = 500.0000,
	    ["TT_NWraith2"] = 750.0000,
	    ["TT_Tree_A"] = 750.0000,
	    ["SummonerBeacon"] = 750.0000,
	    ["Odin_Drill"] = 750.0000,
	    ["TT_NGolem"] = math.huge,
	    ["AramSpeedShrine"] = math.huge,
	    ["OriannaNoBall"] = math.huge,
	    ["Odin_Minecart"] = math.huge,
	    ["Summoner_Rider_Chaos"] = math.huge,
	    ["OdinSpeedShrine"] = math.huge,
	    ["TT_SpeedShrine"] = math.huge,
	    ["odin_lifts_buckets"] = math.huge,
	    ["OdinRockSaw"] = math.huge,
	    ["OdinMinionSpawnPortal"] = math.huge,
	    ["SyndraSphere"] = math.huge,
	    ["Red_Minion_MechMelee"] = math.huge,
	    ["SwainRaven"] = math.huge,
	    ["crystal_platform"] = math.huge,
	    ["MaokaiSproutling"] = math.huge,
	    ["Urf"] = math.huge,
	    ["TestCubeRender10Vision"] = math.huge,
	    ["MalzaharVoidling"] = 500.0000,
	    ["GhostWard"] = 500.0000,
	    ["MonkeyKingFlying"] = 500.0000,
	    ["LuluPig"] = 500.0000,
	    ["AniviaIceBlock"] = 500.0000,
	    ["TT_OrderInhibitor_D"] = 500.0000,
	    ["Odin_SoG_Order"] = 500.0000,
	    ["RammusDBC"] = 500.0000,
	    ["FizzShark"] = 500.0000,
	    ["LuluDragon"] = 500.0000,
	    ["OdinTestCubeRender"] = 500.0000,
	    ["TT_Tree1"] = 500.0000,
	    ["ARAMOrderTurretShrine"] = 500.0000,
	    ["Odin_Windmill_Gears"] = 500.0000,
	    ["ARAMChaosNexus"] = 500.0000,
	    ["TT_NWraith"] = 750.0000,
	    ["TT_OrderTurret4"] = 500.0000,
	    ["Odin_SOG_Chaos_Crystal"] = 500.0000,
	    ["OdinQuestIndicator"] = 500.0000,
	    ["JarvanIVStandard"] = math.huge,
	    ["TT_DummyPusher"] = 500.0000,
	    ["OdinClaw"] = 500.0000,
	    ["EliseSpiderling"] = math.huge,
	    ["QuinnValor"] = math.huge,
	    ["UdyrTigerUlt"] = math.huge,
	    ["UdyrTurtleUlt"] = math.huge,
	    ["UdyrUlt"] = math.huge,
	    ["UdyrPhoenixUlt"] = math.huge,
	    ["ShacoBox"] = 1500.0000,
	    ["HA_AP_Poro"] = 1500.0000,
	    ["AnnieTibbers"] = math.huge,
	    ["UdyrPhoenix"] = math.huge,
	    ["UdyrTurtle"] = math.huge,
	    ["UdyrTiger"] = math.huge,
	    ["HA_AP_OrderShrineTurret"] = 500.0000,
	    ["HA_AP_Chains_Long"] = 500.0000,
	    ["HA_AP_BridgeLaneStatue"] = 500.0000,
	    ["HA_AP_ChaosTurretRubble"] = 500.0000,
	    ["HA_AP_PoroSpawner"] = 500.0000,
	    ["HA_AP_Cutaway"] = 500.0000,
	    ["HA_AP_Chains"] = 500.0000,
	    ["ChaosInhibitor_D"] = 500.0000,
	    ["ZacRebirthBloblet"] = 500.0000,
	    ["OrderInhibitor_D"] = 500.0000,
	    ["Nidalee_Spear"] = 500.0000,
	    ["Nidalee_Cougar"] = 500.0000,
	    ["TT_Buffplat_Chain"] = 500.0000,
	    ["WriggleLantern"] = 500.0000,
	    ["TwistedLizardElder"] = 500.0000,
	    ["RabidWolf"] = math.huge,
	    ["HeimerTGreen"] = 1599.3999,
	    ["HeimerTRed"] = 1599.3999,
	    ["ViktorFF"] = 1599.3999,
	    ["TwistedGolem"] = math.huge,
	    ["TwistedSmallWolf"] = math.huge,
	    ["TwistedGiantWolf"] = math.huge,
	    ["TwistedTinyWraith"] = 750.0000,
	    ["TwistedBlueWraith"] = 750.0000,
	    ["TwistedYoungLizard"] = 750.0000,
	    ["Red_Minion_Melee"] = math.huge,
	    ["Blue_Minion_Melee"] = math.huge,
	    ["Blue_Minion_Healer"] = 1000.0000,
	    ["Ghast"] = 750.0000,
	    ["blueDragon"] = 800.0000,
	    ["Red_Minion_MechRange"] = 3000,
	    ["SRU_OrderMinionRanged"] = 650,
	    ["SRU_ChaosMinionRanged"] = 650,
	    ["SRU_OrderMinionSiege"] = 1200,
	    ["SRU_ChaosMinionSiege"] = 1200,
	    ["SRUAP_Turret_Chaos1"]  = 1200,
	    ["SRUAP_Turret_Chaos2"]  = 1200,
	    ["SRUAP_Turret_Chaos3"] = 1200,
	    ["SRUAP_Turret_Order1"]  = 1200,
	    ["SRUAP_Turret_Order2"]  = 1200,
	    ["SRUAP_Turret_Order3"] = 1200,
	    ["SRUAP_Turret_Chaos4"] = 1200,
	    ["SRUAP_Turret_Chaos5"] = 500,
	    ["SRUAP_Turret_Order4"] = 1200,
	    ["SRUAP_Turret_Order5"] = 500,
	    ["HA_ChaosMinionRanged"] = 650,
	    ["HA_OrderMinionRanged"] = 650,
	    ["HA_ChaosMinionSiege"] = 1200,
	    ["HA_OrderMinionSiege"] = 1200
	  }
	  self.tableForHPPrediction = {}
	  self:MakeMenu()
	  self.mobs = minionManager
	  Callback.Add("Tick", function() self:Tick() end)
	  Callback.Add("Draw", function() self:Draw() end)
	  Callback.Add("ProcessSpell", function(x,y) self:ProcessSpell(x,y) end)
	  Callback.Add("ProcessSpellComplete", function(x,y) self:ProcessSpellComplete(x,y) end)
	  Callback.Add("ProcessWaypoint", function(x,y) self:ProcessWaypoint(x,y) end)
	  return self
	end

	function msg(x)
	  PrintChat("<font color=\"#00FFFF\">[InspiredsOrbWalker]:</font> <font color=\"#FFFFFF\">"..tostring(x).."</font>")
	end

	function InspiredsOrbWalker:MakeMenu()
	  self.Config = MenuConfig("IOW", "IOW"..myHeroName)
	  self.Config:Menu("config", "Configuration")
	  self.Config = self.Config.config
	  self.Config:Menu("h", "Hotkeys")
	  self.Config.h:KeyBinding("Combo", "Combo", 32)
	  self.Config.h:KeyBinding("Harass", "Harass", string.byte("C"))
	  self.Config.h:KeyBinding("LastHit", "LastHit", string.byte("X"))
	  self.Config.h:KeyBinding("LaneClear", "LaneClear", string.byte("V"))
	  self.Config:Menu("s", "Sticky Settings")
	  self.Config.s:Slider("stop", "Stickyradius (mouse)", GetHitBox(myHero), 0, 250, "", false, function() self.lastBoundingChange = GetTickCount() + 375 end)
	  if myHero.isMelee then
	  	self.Config.s:Slider("stick", "Stickyradius (target)", GetRange(myHero)*2, 0, 550, "", false, function() self.lastStickChange = GetTickCount() + 375 end)
	  end
	  self.Config:Menu("c", "Combo Settings")
	  self.Config:Menu("d", "Draw Settings")
	  self.Config:Menu("f", "Farm Settings")
	  self.Config.f:DropDown("dmgpred", "Damage Prediction", 1, {"Inspired", "GoS"})
	  self.Config.d:Info("s", "Self")
	  self.Config.d:Boolean("sdrawcircle", "Autoattack Circle", true)
	  self.Config.d:ColorPick("scirclecol", "Circle color", {255,255,255,255})
	  self.Config.d:Slider("scirclequal", "Circle quality", 4, 0, 8, 1)
	  self.Config.d:Empty("e", 20)
	  self.Config.d:Info("e", "Enemy")
	  self.Config.d:Boolean("edrawcircle", "Autoattack Circle", true)
	  self.Config.d:ColorPick("ecirclecol", "Circle color", {155,255,0,0})
	  self.Config.d:Slider("ecirclequal", "Circle quality", 4, 0, 8, 1)
	  self.Config.d:Empty("e", 20)
	  self.Config.d:Info("m", "Minions")
	  self.Config.d:Boolean("lh", "Last Hit Marker", true)
	  self.Config.c:Boolean("sticky", "Stick to one Target", false, true)
	  if myHero.isMelee then
	    self.Config.c:Boolean("wtt", "Walk to Target", true)
	  end
	  self.Config.c:Boolean("Humanizer", "Humanizer", IsGoSHumanizerActive() or true)
	  self.ts = TargetSelector(GetRange(myHero), TARGET_LESS_CAST, DAMAGE_PHYSICAL)
	  self.Config.c:TargetSelector("ts", "TargetSelector", self.ts)
	  msg("Loaded!")
	end

	function InspiredsOrbWalker:Mode()
	  if self.Config.h.Combo:Value() then
	    return "Combo"
	  elseif self.Config.h.Harass:Value() then
	    return "Harass"
	  elseif self.Config.h.LastHit:Value() then
	    return "LastHit"
	  elseif self.Config.h.LaneClear:Value() then
	    return "LaneClear"
	  else
	    return ""
	  end
	end

	function InspiredsOrbWalker:SwitchPermaShow(mode)
	  self.permaShow.p.name = mode
	  self.Config["OrbWalking"]:Value(mode ~= "OrbWalking")
	end

	function InspiredsOrbWalker:Draw()
	  local myRange = GetRange(myHero)+GetHitBox(myHero)+(self.target and self.target.boundingRadius or myHero.boundingRadius)
	  if self.Config.d.sdrawcircle:Value() then
	  	local pos = myHero.pos
	    DrawCircle3D(pos.x, pos.y, pos.z, myRange, 1, self.Config.d.scirclecol:Value(), (4*self.Config.d.scirclequal:Value()))
	  end
	  if self.Config.d.edrawcircle:Value() then
	  for i, hero in pairs(GetEnemyHeroes()) do
	    local r = GetRange(hero)+GetHitBox(hero)
	    if ValidTarget(hero, myRange*1.5+r*1.5) then
	    	local pos = hero.pos 
	      DrawCircle3D(pos.x, pos.y, pos.z, r, 1, self.Config.d.ecirclecol:Value(), (4*self.Config.d.ecirclequal:Value()))
	    end
	  end
	  end
	  if self.lastBoundingChange > GetTickCount() then
	  	local pos = myHero.pos
	    DrawCircle3D(pos.x, pos.y, pos.z, self.Config.s.stop:Value(), 2, ARGB(255,255,255,255), 32)
	  end
	  if self.lastStickChange > GetTickCount() and self.Config.s.stick then
	  	local pos = myHero.pos
	    DrawCircle3D(pos.x, pos.y, pos.z, self.Config.s.stick:Value(), 2, ARGB(255,255,255,255), 32)
	  end
	end

	function InspiredsOrbWalker:Tick()
	  self.ts.range = GetRange(myHero)+GetHitBox(myHero)+(self.target and self.target.boundingRadius or myHero.boundingRadius)
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
	    return self:CanOrb(self.forceTarget) and self.forceTarget or (self.Config.c.sticky:Value() and self:CanOrb(self.target) and GetObjectType(self.target) == GetObjectType(myHero)) and self.target or self.ts:GetTarget()
	  elseif self.Config.h.Harass:Value() then
	    return self:GetLastHit() or self:CanOrb(self.forceTarget) and self.forceTarget or (self.Config.c.sticky:Value() and self:CanOrb(self.target) and GetObjectType(self.target) == GetObjectType(myHero)) and self.target or self.ts:GetTarget()
	  elseif self.Config.h.LastHit:Value() then
	    return self:GetLastHit()
	  elseif self.Config.h.LaneClear:Value() then
	    return self:GetLastHit() or self:GetLaneClear() or self:GetJungleClear()
	  else
	    return nil
	  end
	end

	function InspiredsOrbWalker:GetLastHit()
	  local dmg = 0
	  local armor = 0
	  for i=1, self.mobs.maxObjects do
	    local o = self.mobs.objects[i]
	    if o and IsObjectAlive(o) and GetTeam(o) == 300-GetTeam(myHero) then
	      if self:CanOrb(o) then
	        local ar = GetArmor(o)
	        if dmg == 0 or armor ~= ar or GetObjectName(myHero) == "Vayne" then
	          dmg = self:GetDmg(myHero, o)
	          armor = ar
	        end
	        if self:PredictHealth(o, 1000*GetWindUp(myHero) + 1000*math.sqrt(GetDistanceSqr(GetOrigin(o), GetOrigin(myHero))) / self:GetProjectileSpeed(myHero)) < dmg then
	          return o
	        end
	      end
	    end
	  end
	end

	function InspiredsOrbWalker:GetLaneClear()
	  local m = nil
	  local dmg = 0
	  local armor = 0
	  for i=1, self.mobs.maxObjects do
	    local o = self.mobs.objects[i]
	    if o and IsObjectAlive(o) and GetTeam(o) == 300-GetTeam(myHero) then
	      if self:CanOrb(o) then
	        local ar = GetArmor(o)
	        if dmg == 0 or armor ~= ar or GetObjectName(myHero) == "Vayne" then
	          dmg = self:GetDmg(myHero, o)
	          armor = ar
	        end
	        if self:PredictHealth(o, 2000/(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero)) + 2000 * GetDistance(GetOrigin(o), GetOrigin(myHero)) / self:GetProjectileSpeed(myHero)) < dmg then
	          return nil
	        else
	          m = o
	        end
	      end
	    end
	  end
	  return m
	end

	function InspiredsOrbWalker:GetJungleClear()
	  local m = nil
	  for i=1, self.mobs.maxObjects do
	    local o = self.mobs.objects[i]
	    if o and IsObjectAlive(o) and GetTeam(o) == MINION_JUNGLE then
	      if self:CanOrb(o) then
	        if not m or GetMaxHP(o) > GetMaxHP(m) then
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
	  if self.Config.f.dmgpred:Value() == 1 then
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
	  else
	    dmg = GetDamagePrediction(unit, delta)
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
	    elseif targetType == Obj_AI_Minion then
	      damageMultiplier = 0.95 * damageMultiplier
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
	  return self.projspeed[GetObjectName(o)] or math.huge
	end

	function InspiredsOrbWalker:Orb()
	  if self.Config.c.wtt and self.Config.c.wtt:Value() then
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
	      if GetDistanceSqr(GetOrigin(myHero), GetMousePos()) > self.Config.s.stop:Value()^2 and self.movementEnabled then
	        if self.targetPos and self.Config.s.stick and (not self.target or not GetObjectType(self.target) == GetObjectType(myHero)) and GetDistanceSqr(self.targetPos, GetOrigin(myHero)) < (self.Config.s.stick:Value())^2 then
	          if GetDistanceSqr(GetOrigin(myHero), self.targetPos) > GetRange(myHero)^2 then
	            self:Move(self:MakePos(self.targetPos))
	          end
	        else
	          self:Move(self:MakePos(self.forcePos or GetMousePos()))
	        end
	      else
	        HoldPosition()
	      end
	    else
	      if myHeroName ~= "Graves" or GotBuff(myHero, "gravesbasicattackammo1") > 0 then
	        self:Execute(1, self.target)
	        self.autoAttackT = GetTickCount()
	        AttackUnit(self.target)
	      end
	    end
	  end
	end

	function InspiredsOrbWalker:Move(pos)
	  if not self.Config.c.Humanizer:Value() then
	    MoveToXYZ(pos)
	  elseif not self.lastPos then
	    self.lastPos = { pos, GetTickCount() }
	    MoveToXYZ(pos)
	  else
	    if self.lastPos[2] + 375 < GetTickCount() or (GetDistance(pos, self.lastPos[1]) > 225 and self.lastPos[2] + 225 < GetTickCount()) then
	      self.lastPos = { pos, GetTickCount() }
	      MoveToXYZ(pos)
	    end
	  end
	end

	function InspiredsOrbWalker:MakePos(p)
	  local mPos = p
	  local hPos = GetOrigin(myHero)
	  local tV = {x = (mPos.x-hPos.x), y = (mPos.z-hPos.z), z = (mPos.z-hPos.z)}
	  local len = math.sqrt(tV.x * tV.x + tV.y * tV.y + tV.z * tV.z)
	  local ran = math.min(GetDistance(p), math.random(150)+math.random(150)+math.random(150)+math.random(150)+math.random(150)+math.random(150)+math.random(150)+math.random(150)+math.random(150)+math.random(150))
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
	  if unit and spell and unit.isMe and spell.name then
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
	  if unit and spell and unit.isMe and spell.name then
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
	      local timer = math.sqrt(GetDistanceSqr(GetOrigin(target),GetOrigin(unit)))/self:GetProjectileSpeed(unit) + GetLatency() / 2000
	      if not self.tableForHPPrediction[nID] then self.tableForHPPrediction[nID] = {} end
	      table.insert(self.tableForHPPrediction[nID], {source = unit, dmg = self:GetDmg(unit, target), time = GetTickCount() + 1000*timer, reattacktime = 1000*(spell.animationTime+spell.windUpTime) + 1000*timer  + GetLatency() / 2})
	    end
	  end
	end

	function InspiredsOrbWalker:ProcessWaypoint(unit, waypoint)
	  if unit and waypoint and unit.isMe and waypoint.index > 1 then
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

	function LoadIOW()
		if not _G.IOW then _G.IOW = InspiredsOrbWalker() end
		return IOW
	end
end
do -- menu
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
	class "MenuSprite"

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
	      toSave[p.id].color = { a = p.color[1]:Value(), r = p.color[2]:Value(), g = p.color[3]:Value(), b = p.color[4]:Value(), }
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
	    if p.forceDefault == false or not p.forceDefault then
	      if saved[p.id] then
	        if p.type == "ColorPick" then
	          p:Value({saved[p.id].color.a,saved[p.id].color.r,saved[p.id].color.g,saved[p.id].color.b})
	        elseif p.type == "KeyBinding" then
	          p:Toggle(saved[p.id].isToggle)
	          p:Key(saved[p.id].key)
	          if saved[p.id].isToggle then p:Value(saved[p.id].value) end
	        elseif p.type == "TargetSelector" then
	          p.settings[1]:Value(saved[p.id].focus)
	          p.settings[2]:Value(saved[p.id].mode)
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

	function __MC_Draw()
	  local function __MC_DrawParam(i, p, k)
	    if p.type == "Boolean" then
	      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
	      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
	      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
	    DrawScreenCircle(MC.x-1+4+MC.width*(k+1)-12, MC.y+10+23*i, 8, p:Value() and ARGB(255,0,255,0) or ARGB(255,255,0,0), 8)
	      if p:Value() then
	          DrawText("ON",8,MC.x+MC.width*(k+1)-14,MC.y+6+23*i,0xffffffff)
	      else
	          DrawText("OFF",8,MC.x+MC.width*(k+1)-15,MC.y+6+23*i,0xffffffff)
	      end
	      return 0
	    elseif p.type == "KeyBinding" then
	      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
	      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
	      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
	      if p.key > 32 and p.key < 96 then
	        FillRect(MC.x-1+4+MC.width*(k+1)-18, MC.y+4+23*i, 15, 13, p:Value() and ARGB(155,0,255,0) or ARGB(155,255,0,0))
	        DrawText("["..(string.char(p.key)).."]",15,MC.x-1+4+MC.width*(k+1)-20, MC.y+1+23*i,0xffffffff)
	      else
	        FillRect(MC.x-1+4+MC.width*(k+1)-23, MC.y+4+23*i, 22, 13, p:Value() and ARGB(155,0,255,0) or ARGB(155,255,0,0))
	        DrawText("["..(p.key).."]",15,MC.x-1+4+MC.width*(k+1)-25, MC.y+1+23*i,0xffffffff)
	      end
	      if p.active then
	        for c,v in pairs(p.settings) do v.active = true end
	        __MC_DrawParam(i, p.settings[1], k+1)
	        __MC_DrawParam(i+1, p.settings[2], k+1)
	      end
	      return 0
	    elseif p.type == "Slider" then
	      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 30, ARGB(55,255,255,255))
	      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 28, ARGB(255,0,0,0))
	      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
	      local psize = GetTextArea(tostring(p.value), 15).x * 3
	      DrawText(" "..p.value.." ",15,MC.x-1+4+MC.width*(k+1)-psize/2-5, MC.y+23*i, 0xffffffff)
	      DrawLine(MC.x+5+(4+MC.width)*k, MC.y+23*i+20,MC.x+(4+MC.width)*k+MC.width-5, MC.y+23*i+20,1,ARGB(255,255,255,255))
	      --DrawText(" "..p.min.." ",10,MC.x+(4+MC.width)*k, MC.y+23*i+15, ARGB(255,255,255,255))
	      local psize = GetTextArea(tostring(p.max), 10).x * 3
	      --DrawText(" "..p.max.." ",10,MC.x+(4+MC.width)*k+MC.width-psize/2-8, MC.y+23*i+15, ARGB(255,255,255,255))
	      local lineWidth = MC.width - 10
	      local delta = (p.value - p.min) / (p.max - p.min)
	      FillRect(MC.x+5+(4+MC.width)*k + lineWidth * delta - 2, MC.y+23*i+16, 5, 10, ARGB(155,0,0,0))
	      FillRect(MC.x+5+(4+MC.width)*k + lineWidth * delta - 1, MC.y+23*i+17, 3, 8, ARGB(255,255,255,255))
	      if p.active then
	        if KeyIsDown(1) and CursorIsUnder(MC.x+4+(4+MC.width)*k, MC.y+23*i, lineWidth+2, 30) then
	          local cpos = GetCursorPos()
	          local delta = (cpos.x - (MC.x+5+(4+MC.width)*k)) / lineWidth
	          p:Value(math.round(delta * (p.max - p.min) + p.min), p.step)
	        end
	      end
	      return 0.35
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
	      for I = -1, 1 do
	        for j = -1, 1 do
	          DrawText("x", 25, MC.x+4+MC.width*(k+1)-15+I, MC.y-6+23*i+j, 0xffffffff)
	        end
	      end
	      DrawText("x", 25, MC.x+4+MC.width*(k+1)-15, MC.y-6+23*i, 0xff000000)
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
	        local mode = p.settings[2]:Value()
	        if mode == 2 or mode == 3 or mode == 9 then
	          for I=3,#p.settings do
	            p.settings[I].active = true
	            __MC_DrawParam(i+(I*1.35-2), p.settings[I], k+1)
	          end
	        end
	      end
	      return 0
	    elseif p.type == "ColorPick" then
	      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
	      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
	      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
	      DrawFilledScreenCircle(MC.x-1+4+MC.width*(k+1)-12, MC.y+10+23*i, 6, p:Value())
	      if p.active then
	        for c,v in pairs(p.color) do v.active = true end
	        __MC_DrawParam(i, p.color[1], k+1)
	        __MC_DrawParam(i, p.color[2], k+2.35)
	        FillRect(MC.x+(4+MC.width)*(k+2), MC.y+23*i, MC.width*0.35-3, 60, p:Value())
	        __MC_DrawParam(i+1.35, p.color[3], k+1)
	        __MC_DrawParam(i+1.35, p.color[4], k+2.35)
	      end
	      return 0
	    elseif p.type == "Info" then
	      FillRect(MC.x-1+(4+MC.width)*k, MC.y-1+23*i, MC.width+2, 22, ARGB(55,255,255,255))
	      FillRect(MC.x+(4+MC.width)*k, MC.y+23*i, MC.width, 20, ARGB(255,0,0,0))
	      DrawText(" "..p.name.." ",15,MC.x+(4+MC.width)*k,MC.y+1+23*i,0xffffffff)
	      return 0
	    elseif p.type == "MenuSprite" then
	      FillRect(MC.x-1+(4+MC.width)*k, MC.y-2+23*i, MC.width+3, p.height+2, ARGB(55,255,255,255))
	      DrawSprite(p.ID, MC.x+(4+MC.width)*k, MC.y+23*i, p.x, p.y, MC.width+p.x, p.height+p.y, p.color)
	      return p.height/23-0.9
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
	  Callback.Add("DrawMinimap", function() if mc_cfg_base.ontop:Value() then __MC_Draw() end end)
	  Callback.Add("Draw", function() if not mc_cfg_base.ontop:Value() then __MC_Draw() end end)
	end

	local function __MC_WndMsg()
	  local function __MC_IsBrowsing()
	    local function __MC_IsBrowseParam(i, p, k)
	      local isB, ladd = false, 0
	      if p.type == "Slider" then ladd = 0.35 end
	      if p.type == "MenuSprite" then ladd = p.height/23-0.9 end
	      if p.type == "Empty" then ladd = p.value end
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
	          if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i, MC.width*3+6, 23*4) then
	            isB = true
	          end
	        elseif p.type == "TargetSelector" then
	          if CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i, MC.width, 23) then
	            p.settings[1]:Value(not p.settings[1]:Value())
	            isB = true
	      elseif CursorIsUnder(MC.x+(4+MC.width)*(k+1), MC.y+23*i, MC.width, 23*#p.settings*1.35) then
	      isB = true
	          end
	        if p.settings[2].active then
	      for m=1, 9 do
	        if CursorIsUnder(MC.x+(4+MC.width)*(k+2), MC.y+23*i+23+23*(m-1), MC.width, 23) then
	        isB = true
	        p.settings[2]:Value(m)
	        end
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
	  if MCadd.lastChange + 375 > GetTickCount() then return end
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
	    if not IsGameOnTop() or IsChatOpened() then return end
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
	    if p.type == "Slider" then ladd = 0.35 end
	    if p.type == "MenuSprite" then ladd = p.height/23-0.9 end
	    if p.type == "Empty" then ladd = p.value
	    elseif CursorIsUnder(MC.x+(4+MC.width)*k, MC.y+23*i+ladd*23, MC.width, 20) then
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
	  Callback.Add("WndMsg", __MC_WndMsg)
	  Callback.Add("Tick", __MC_Browse)
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
	  Callback.Add("WndMsg", function(msg, key)
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
	  self.ownteam = ownteam or false
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
	  local I = 0;
	  Callback.Add("ObjectLoad", function(hero)
	    if GetObjectType(hero) == GetObjectType(myHero) then
	    if self.ownteam and GetTeam(hero) == GetTeam(myHero) or GetTeam(hero) ~= GetTeam(myHero) then
	      I = I + 1
	      table.insert(self.settings, Slider(head, GetObjectName(hero), "Priority: "..GetObjectName(hero), (self.priorityTable[5][GetObjectName(hero)] and 5 or self.priorityTable[4][GetObjectName(hero)] and 4 or self.priorityTable[3][GetObjectName(hero)] and 3 or self.priorityTable[2][GetObjectName(hero)] and 2 or self.priorityTable[1][GetObjectName(hero)] and 1 or 1), 1, 5, 0))
	    end
	    end
	  end)
	  Callback.Add("WndMsg", function(msg, key)
	    if msg == 513 and self.focusselected then
	      local t, d = nil, math.huge
	      local mpos = GetMousePos()
	      for _, h in pairs(heroes) do
	        local p = GetD(GetOrigin(h), mpos)
	        if p < d then
	          t = h
	          d = p
	        end
	      end
	      if t and d < GetHitBox(t)^2.25 and (self.ownteam and GetTeam(t) == GetTeam(myHero) or GetTeam(t) ~= GetTeam(myHero)) then
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
	  Callback.Add("Draw", function()
	    if self.focusselected and self.IsValid(self.selected) then
	      DrawCircle(GetOrigin(self.selected), GetHitBox(self.selected), 1, 1, ARGB(155,255,255,0))
	    end
	  end)
	end

	function TargetSelector:GetPriority(hero)
	  for I=2, #self.settings do
	    local s = self.settings[I]
	    if s.id == GetObjectName(hero) then
	      return s:Value()
	    end
	  end
	  return 1
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
	        local prio = CalcDamage(myHero, hero, self.dtype == DAMAGE_PHYSICAL and 100 or 0, self.dtype == DAMAGE_MAGIC and 100 or 0)*(self:GetPriority(hero))
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
	        local prio = self:GetPriority(hero)
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
	        local prio = GetCurrentHP(hero)*(self:GetPriority(hero))
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

	function MenuSprite:__init(head, id, ID, x, y, height, color)
	  self.head = head
	  self.id = id
	  self.type = "MenuSprite"
	  self.ID = ID
	  self.x = x or 0
	  self.y = y or 0
	  self.height = height or 0
	  self.color = color or ARGB(255,255,255,255)
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
	  local cp = ColorPick(self, id, name, color, callback, forceDefault)
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
	  ts.forceDefault = forceDefault or false
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

	function MenuConfig:Sprite(id, name, x, y, height, color)
	  local sID = CreateSpriteFromFile(name)
	  if sID == 0 then print("Sprite "..name.." not found!") end
	  local s = Sprite(self, id, sID, x, y, height, color)
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
	if not _G.mc_cfg_base then
		_G.mc_cfg_base = MenuConfig("MenuConfig", "MenuConfig")
		mc_cfg_base:Info("Inf", "MenuConfig Settings")
		mc_cfg_base:Boolean("Show", "Show always", true)
		mc_cfg_base:Boolean("ontop", "Stay OnTop", false)
		MC.width = 200
		mc_cfg_base:KeyBinding("MenuKey", "Key to open Menu", 16)
	end
end
do -- misc load
	myHero = Object(GetMyHero())
	_G.GetMyHero = function() return myHero end
	cooldowns[myHero.networkID] = {}
	Callback.Add("ObjectLoad", function(o)
		if GetObjectType(o) == Obj_AI_Hero then
			heroes[1+#heroes] = o
		end
	end)
	mapID = GetMapID()
	DAMAGE_MAGIC, DAMAGE_PHYSICAL, DAMAGE_MIXED = 1, 2, 3
	MINION_ALLY, MINION_ENEMY, MINION_JUNGLE = myHero.team, 300-myHero.team, 300
	mixed = Set {"Akali","Corki","Ekko","Evelynn","Ezreal","Kayle","Kennen","KogMaw","Malzahar","MissFortune","Mordekaiser","Pantheon","Poppy","Shaco","Skarner","Teemo","Tristana","TwistedFate","XinZhao","Yoric"}
	ad = Set {"Aatrox","Corki","Darius","Draven","Ezreal","Fiora","Gangplank","Garen","Gnar","Graves","Hecarim","Illaoi","Irelia","JarvanIV","Jax","Jayce","Jinx","Kalista","KhaZix","KogMaw","LeeSin","Lucian","MasterYi","MissFortune","Nasus","Nocturne","Olaf","Pantheon","Quinn","RekSai","Renekton","Rengar","Riven","Shaco","Shyvana","Sion","Sivir","Talon","Tristana","Trundle","Tryndamere","Twitch","Udyr","Urgot","Varus","Vayne","Vi","Warwick","Wukong","XinZhao","Yasuo","Yoric","Zed"}
	ap = Set {"Ahri","Akali","Alistar","Amumu","Anivia","Annie","Azir","Bard","Blitzcrank","Brand","Braum","Cassiopea","ChoGath","Diana","DrMundo","Ekko","Elise","Evelynn","Fiddlesticks","Fizz","Galio","Gragas","Heimerdinger","Janna","Karma","Karthus","Kassadin","Katarina","Kayle","Kennen","LeBlanc","Leona","Lissandra","Lulu","Lux","Malphite","Malzahar","Maokai","Mordekaiser","Morgana","Nami","Nautilus","Nidalee","Nunu","Orianna","Poppy","Rammus","Rumble","Ryze","Sejuani","Shen","Singed","Skarner","Sona","Soraka","Swain","Syndra","TahmKench","Taric","Teemo","Thresh","TwistedFate","Veigar","VelKoz","Viktor","Vladimir","Volibear","Xerath","Zac","Ziggz","Zilean","Zyra"}
	GoS = {}
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
	Dashes = {
		["Vayne"]			= {Spellslot = _Q, Range = 300},
		["Kindred"]			= {Spellslot = _Q, Range = 300},
		["Riven"]			= {Spellslot = _E, Range = 325},
		["Ezreal"]		 	= {Spellslot = _E, Range = 450},
		["Caitlyn"]			= {Spellslot = _E, Range = 400},
		["Kassadin"]	 	= {Spellslot = _R, Range = 700},
		["Graves"]		 	= {Spellslot = _E, Range = 425},
		["Renekton"]	 	= {Spellslot = _E, Range = 450},
		["Aatrox"]		 	= {Spellslot = _Q, Range = 650},
		["Gragas"]		 	= {Spellslot = _E, Range = 600},
		["Khazix"]		 	= {Spellslot = _E, Range = 600},
		["Lucian"]		 	= {Spellslot = _E, Range = 425},
		["Sejuani"]			= {Spellslot = _Q, Range = 650},
		["Shen"]			= {Spellslot = _E, Range = 575},
		["Tryndamere"] 		= {Spellslot = _E, Range = 660},
		["Tristana"]	 	= {Spellslot = _W, Range = 900},
		["Corki"]			= {Spellslot = _W, Range = 800},
	}
	PrintChat("Loaded, Press F9 to sync Inspired.lua...")
	_G.InspiredLoaded = true
	local syncCallback = -1
	syncCallback = Callback.Add("WndMsg", function(msg, key) if msg==256 and key==120 then print("Syncing, please wait...") AutoUpdate() Callback.Del("WndMsg", syncCallback) end end)
end
