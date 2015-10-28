do
	local Prediction = {}
	Prediction.User = {}
	Prediction.User.Interface = {}
	Prediction.User.State = {}
	Prediction.Callback = {}
	Prediction.Core = {}
	Prediction.Core.Math = {}
	Prediction.WayPointManager = {}

	Prediction.Vars = {
		Heroes = {},
		Slowed = {},
		Stunned = {},
		Dashing = {},
		Config = MenuConfig("nPrediction", "nPrediction"..myHeroName),
		DashCallbacks = {},
		StunCallbacks = {},
		LastBuffTick = 0,
		WayPoints = {},
		BUFF_NONE = 0,
		BUFF_GLOBAL = 1,
		BUFF_BASIC = 2,
		BUFF_DEBUFF = 3,
		BUFF_STUN = 5,
		BUFF_STEALTH = 6,
		BUFF_SILENCE = 7,
		BUFF_TAUNT = 8,
		BUFF_SLOW = 10,
		BUFF_ROOT = 11,
		BUFF_DOT = 12,
		BUFF_REGENERATION = 13,
		BUFF_SPEED = 14,
		BUFF_MAGIC_IMMUNE = 15,
		BUFF_PHYSICAL_IMMUNE = 16,
		BUFF_IMMUNE = 17,
		BUFF_Vision_Reduce = 19,
		BUFF_FEAR = 21,
		BUFF_CHARM = 22,
		BUFF_POISON = 23,
		BUFF_SUPPRESS = 24,
		BUFF_BLIND = 25,
		BUFF_STATS_INCREASE = 26,
		BUFF_STATS_DECREASE = 27,
		BUFF_FLEE = 28,
		BUFF_KNOCKUP = 29,
		BUFF_KNOCKBACK = 30,
		BUFF_DISARM = 31,
		spells = {
			{name = "katarinar", duration = 1},
			{name = "drain", duration = 1},
			{name = "crowstorm", duration = 1},
			{name = "consume", duration = 1.5},
			{name = "absolutezero", duration = 1},
			{name = "rocketgrab", duration = 0.5},
			{name = "staticfield", duration = 0.5},
			{name = "cassiopeiapetrifyinggaze", duration = 0.5},
			{name = "ezrealtrueshotbarrage", duration = 1},
			{name = "galioidolofdurand", duration = 1},
			{name = "luxmalicecannon", duration = 0.5},
			{name = "reapthewhirlwind", duration = 1},
			{name = "jinxw", duration = 0.5},
			{name = "jinxr", duration = 0.5},
			{name = "missfortunebullettime", duration = 1},
			{name = "shenstandunited", duration = 1},
			{name = "threshe", duration = 0.4},
			{name = "threshrpenta", duration = 0.75},
			{name = "infiniteduress", duration = 0.5},
			{name = "meditate", duration = 1},
			{name = "gate", duration = 1.5},
		},
		Spells = {},
		dashes = {
			{name = "ahritumble", duration = 0.25, range = 450},
			{name = "akalishadowdance", duration = 0.25, range = 700},
			{name = "headbutt", duration = 0.25, range = 650},
			{name = "caitlynentrapment", duration = 0.25, range = 0},
			{name = "carpetbomb", duration = 0.25, range = 800},
			{name = "dianateleport", duration = 0.25, range = 825},
			{name = "fizzpiercingstrike", duration = 0.25, range = 550, max = true},
			{name = "gragasbodyslam", duration = 0.25, range = 600},
			{name = "gravesmove", duration = 0.25, range = 425},
			{name = "ireliagatotsu", duration = 0.25, range = 650},
			{name = "jarvanivdragonstrike", duration = 0.25, range = 770},
			{name = "jaxleapstrike", duration = 0.25, range = 700},
			{name = "khazixe", duration = 0.25, range = 600},
			{name = "leblancslide", duration = 0.25, range = 600},
			{name = "leblancslidem", duration = 0.25, range = 600},
			{name = "blindmonkqtwo", duration = 0.25, endP = true},
			{name = "blindmonkwone", duration = 0.25, endP = true},
			{name = "luciane", duration = 0.25, range = 445, max = true},
			{name = "nocturneparanoia2", duration = 0.25, endP = true},
			{name = "pantheon_leapbash", duration = 0.25, endP = true},
			{name = "renektonsliceanddice", duration = 0.25, range = 450, max = true},
			{name = "riventricleave", duration = 0.25, range = 275, max = true},
			{name = "rivenfeint", duration = 0.25, range = 350, max = true},
			{name = "sejuaniarcticassault", duration = 0.25, range = 650, max = true},
			{name = "shenshadowdash", duration = 0.25, range = 600, max = true},
			{name = "shyvanatransformcast", duration = 0.25, range = 1000, max = true},
			{name = "rocketjump", duration = 0.25, range = 900},
			{name = "slashcast", duration = 0.25, range = 650},
			{name = "vaynetumble", duration = 0.25, range = 300},
			{name = "monkeykingnimbus", duration = 0.25, endP = true},
			{name = "xenzhaosweep", duration = 0.25, endP = true},
			{name = "yasuodashwrapper", duration = 0.25, range = 475, max = true},
		},
		blinks = {
			{name = "ezrealarcaneshift", range = 475, delay = 0.25, delay2=0.8},
			{name = "deceive", range = 400, delay = 0.25, delay2=0.8},
			{name = "riftwalk", range = 700, delay = 0.25, delay2=0.8},
			{name = "gate", range = 5500, delay = 1.5, delay2=1.5},
			{name = "katarinae", range = math.huge, delay = 0.25, delay2=0.8},
			{name = "elisespideredescent", range = math.huge, delay = 0.25, delay2=0.8},
			{name = "elisespidere", range = math.huge, delay = 0.25, delay2=0.8},
		}
	}

	function Prediction.Callback.ObjectLoad(hero)
		if GetObjectType(hero) == Obj_AI_Hero then
			Prediction.Vars.Heroes[GetNetworkID(hero)] = hero;
			Prediction.Vars.Slowed[GetNetworkID(hero)] = {};
			Prediction.Vars.Stunned[GetNetworkID(hero)] = {};
			Prediction.Vars.Dashing[GetNetworkID(hero)] = {};
			Prediction.Vars.WayPoints[GetNetworkID(hero)] = {};
		end
	end

	function Prediction.Callback.Tick()
		for i = 1, #heroes do
			local unit = heroes[i];
			if Prediction.Vars.LastBuffTick < GetGameTimer() then
				Prediction.Vars.LastBuffTick = GetGameTimer() + 0.05;
				local sccEndT = Prediction.Vars.Slowed[GetNetworkID(unit)].endT;
				local hccEndT = Prediction.Vars.Stunned[GetNetworkID(unit)].endT;
				for I = 0, 64 do
					local buff = { valid = GetBuffCount(unit,I) > 0, type = GetBuffType(unit, I), startT = GetBuffStartTime(unit, I), endT = GetBuffExpireTime(unit, I), name = GetBuffName(unit, I)}
					if buff and buff.valid and buff.endT > GetGameTimer() then
						if (buff.type == Prediction.Vars.BUFF_STUN or buff.type == Prediction.Vars.BUFF_ROOT or buff.type == Prediction.Vars.BUFF_KNOCKUP or buff.type == Prediction.Vars.BUFF_SUPPRESS) then
							if (not hccEndT or hccEndT < buff.endT) then
								Prediction.Vars.Stunned[GetNetworkID(unit)] = {endT = buff.endT, bType = buff.type, bName = buff.name}
							end
						elseif (buff.type == Prediction.Vars.BUFF_SLOW or buff.type == Prediction.Vars.BUFF_CHARM or buff.type == Prediction.Vars.BUFF_FEAR or buff.type == Prediction.Vars.BUFF_TAUNT) then
							if (not sccEndT or sccEndT < buff.endT) then
								Prediction.Vars.Slowed[GetNetworkID(unit)] = {endT = buff.endT, bType = buff.type, bName = buff.name}
							end
						end
					end
				end
			end
			Prediction.Core.RemoveOldWayPoints(unit)
			if GetTeam(unit) ~= GetTeam(myHero) then
				local I = #Prediction.Vars.DashCallbacks;
				for i = 1, I do
					dashCallback = Prediction.Vars.DashCallbacks[i]
					local x, y, z = Prediction.User.Interface.IsUnitDashing(unit, dashCallback.range, dashCallback.speed, dashCallback.delay, dashCallback.width, dashCallback.source)
					if x and z <= dashCallback.width + GetHitBox(unit) then
						dashCallback.callback(unit, y)
					end
				end
				local I = #Prediction.Vars.StunCallbacks;
				for i = 1, I do
					stunCallback = Prediction.Vars.StunCallbacks[i]
					local x, y = Prediction.User.Interface.IsUnitStunned(unit, stunCallback.range, stunCallback.speed, stunCallback.delay, stunCallback.width, stunCallback.source)
					if x and y <= stunCallback.width + GetHitBox(unit) then
						stunCallback.callback(unit, y)
					end
				end
			end
		end
	end

	function Prediction.Callback.ProcessWaypoint(unit, waypoint)
		if unit and IsObjectAlive(unit) and GetObjectType(unit) == GetObjectType(myHero) then
			if unit ~= myHero and waypoint.index == 1 then
				local current_way_point = Vector(waypoint.position)
				local my_current_position = Vector(myHero)
				local diff_coordinates = {x = current_way_point.x - my_current_position.x, y = current_way_point.y - my_current_position.y}
				local polar_coordinate = {theta = math.atan2(diff_coordinates.x, diff_coordinates.y), r = Prediction.Core.pythag(diff_coordinates.x, diff_coordinates.y)}
				Prediction.Vars.Stunned[GetNetworkID(unit)] = {}
				table.insert(Prediction.Vars.WayPoints[GetNetworkID(unit)], {waypoints = polar_coordinate, time = GetGameTimer()})
			end
		end
	end

	function Prediction.Callback.ProcessSpell(unit, spell)
		if unit and spell and spell.name then
			for _, thing in pairs(Prediction.Vars.spells) do
				if spell.name:lower() == thing.name then
					Prediction.Vars.Stunned[GetNetworkID(unit)] = {endT = GetGameTimer() + thing.duration + spell.windUpTime, bType = Prediction.Vars.BUFF_STUN, bName = spell.name}
					return
				end
			end
			for _, thing in pairs(Prediction.Vars.dashes) do
				if spell.name:lower():find(thing.name) then
					local endPos = Vector(spell.endPos)
					local realDist = GetDistance(unit, endPos)
					if not thing.endP then
						if thing.max then
							realDist = thing.range
							endPos = Vector(spell.startPos) + Vector(Vector(spell.endPos) - Vector(spell.startPos)):normalized() * thing.range
						elseif realDist > thing.range then
							realDist = thing.range
							endPos = Vector(spell.startPos) + Vector(Vector(spell.endPos) - Vector(spell.startPos)):normalized() * thing.range
						end
					end
					Prediction.Vars.Dashing[GetNetworkID(unit)] = {startT = GetGameTimer() + spell.windUpTime, endT = GetGameTimer() + spell.windUpTime + realDist/(thing.speed or 1800), startPos = Vector(spell.startPos), endPos = endPos, dashSpeed = thing.peed, dashDistance = realDist}
					return
				end
			end
			for _, thing in pairs(Prediction.Vars.blinks) do
				if spell.name:lower() == thing.name then
					Prediction.Vars.Stunned[GetNetworkID(unit)] = {endT = GetGameTimer() + thing.delay2, bType = Prediction.Vars.BUFF_STUN, bName = spell.name}
					return
				end
			end
		end
	end

	function Prediction.Core.RemoveOldWayPoints(unit)
		local waypoints = Prediction.Vars.WayPoints[GetNetworkID(unit)]
		local i = 1
		while i <= #waypoints do
			if (GetGameTimer() - waypoints[i].time) >= 10 then
				table.remove(waypoints, i)
			else
				i = i + 1
			end
		end
		Prediction.Vars.WayPoints[GetNetworkID(unit)] = waypoints
	end

	function Prediction.Core.GetLatestWaypoints(hero)
		local waypoints = Prediction.Vars.WayPoints[GetNetworkID(hero)]
		local last = nil
		for i, waypoint in ipairs(waypoints) do
			last = waypoint
		end
		return last
	end

	function Prediction.Core.GetSecondLatestWaypoints(hero)
		local waypoints = Prediction.Vars.WayPoints[GetNetworkID(hero)]
		local last = nil
		local slast = nil
		for i, waypoint in ipairs(waypoints) do
			slast = last and last or nil
			last = waypoint
		end
		return slast
	end

	function Prediction.WayPointManager.GetSimulatedWayPoints(object, fromT, toT)
		local wayPoints, fromT, toT = Prediction.WayPointManager.GetWayPoints(object), fromT or 0, toT or math.huge
		local invisDur = (not object.visible and WayPointVisibility[object.networkID]) and GetGameTimer() - WayPointVisibility[object.networkID] or ((not object.visible and not WayPointVisibility[object.networkID]) and math.huge or 0)
		fromT = fromT + invisDur
		local tTime, fTime, result = 0, 0, {}
		for i = 1, #wayPoints - 1 do
			local A, B = wayPoints[i], wayPoints[i + 1]
			local dist = GetDistance(A, B)
			local cTime = dist / object.ms
			if tTime + cTime >= fromT then
				if #result == 0 then
					fTime = fromT - tTime
					result[1] = { x = A.x + object.ms * fTime * ((B.x - A.x) / dist), y = A.y + object.ms * fTime * ((B.y - A.y) / dist) }
				end
				if tTime + cTime >= toT then
					result[#result + 1] = { x = A.x + object.ms * (toT - tTime) * ((B.x - A.x) / dist), y = A.y + object.ms * (toT - tTime) * ((B.y - A.y) / dist) }
					fTime = fTime + toT - tTime
					break
				else
					result[#result + 1] = B
					fTime = fTime + cTime
				end
			end
			tTime = tTime + cTime
		end
		if #result == 0 and (tTime >= toT or invisDur) then result[1] = wayPoints[#wayPoints] end
		return result, fTime
	end

	function Prediction.WayPointManager.GetWayPoints(object)
		local wayPoints, lineSegment, distanceSqr, fPoint = Prediction.WayPointManager.WayPoints[object.networkID], 0, math.huge, nil
		if not wayPoints then return { x = object.x, y = object.z } end
		for i = 1, #wayPoints - 1 do
			local p1, _, _ = VectorPointProjectionOnLineSegment(wayPoints[i], wayPoints[i + 1], object)
			local distanceSegmentSqr = GetDistanceSqr(p1, object)
			if distanceSegmentSqr < distanceSqr then
				fPoint = p1
				lineSegment = i
				distanceSqr = distanceSegmentSqr
			else break
			end
		end
		local result = { fPoint or { x = object.x, y = object.z } }
		for i = lineSegment + 1, #wayPoints do
			result[#result + 1] = wayPoints[i]
		end
		if #result == 2 and GetDistanceSqr(result[1], result[2]) < 400 then result[2] = nil end
		Prediction.WayPointManager.WayPoints[object.networkID] = result
		return result
	end

	function Prediction.Core.GetWaypointsSet(hero, mtime)
		local waypoints = Prediction.Vars.WayPoints[GetNetworkID(hero)]
		local set = {}
		for i, waypoint in ipairs(waypoints) do
			if (GetGameTimer() - waypoint.time) <= mtime then
				table.insert(set, waypoint)
			end
		end
		return set
	end

	function Prediction.Core.pythag(x,y)
		return math.sqrt(math.pow(x,2) + math.pow(y,2))
	end

	function Prediction.User.OnDash(callback, range, speed, delay, width, source)
		Prediction.Vars.DashCallbacks[#Prediction.Vars.DashCallbacks + 1] = {callback = callback, range = range, speed = speed, delay = delay, width = width, source = source or myHero}
	end

	function Prediction.User.OnImmobile(callback, range, speed, delay, width, source)
		Prediction.Vars.StunCallbacks[#Prediction.Vars.StunCallbacks + 1] = {callback = callback, range = range, speed = speed, delay = delay, width = width, source = source or myHero}
	end

	function Prediction.User.Interface.IsUnitStunned(unit, range, speed, delay, width, source)
		range = range or math.huge
		speed = speed or math.huge
		delay = delay or 0
		width = width or 0
		source = source or myHero
		if not unit or not IsObjectAlive(unit) then return false, math.huge end
		local dist = GetDistance(unit, source)
		if range ~= math.huge and speed ~= math.huge and dist < range+width/2 then
			delay = delay + (dist) / speed
		end
		local canHasStun = Prediction.Vars.Stunned[GetNetworkID(unit)];
		if canHasStun and canHasStun.endT and canHasStun.endT > GetGameTimer() then
			local remainingTime = canHasStun.endT - GetGameTimer()
			if remainingTime > delay then
				return true, 0
			else
				return true, GetMoveSpeed(unit) * (delay - remainingTime)
			end
		end
		return false, GetMoveSpeed(unit) * delay
	end

	function Prediction.User.Interface.IsUnitSlowed(unit, range, speed, delay, width, source)
		range = range or math.huge
		speed = speed or math.huge
		delay = delay or 0
		width = width or 0
		source = source or myHero
		if not unit or not IsObjectAlive(unit) then return false, math.huge end
		local dist = GetDistance(unit, source)
		if range ~= math.huge and speed ~= math.huge and dist < range+width/2 then
			delay = delay + (dist) / speed
		end
		local canHasSlow = Prediction.Vars.Slowed[GetNetworkID(unit)];
		if canHasSlow and canHasSlow.endT and canHasSlow.endT > GetGameTimer() then
			local remainingTime = canHasSlow.endT - GetGameTimer()
			if remainingTime > delay then
				return true, GetMoveSpeed(unit) * (delay)
			else
				return true, GetMoveSpeed(unit) * (delay - remainingTime)
			end
		end
		return false, GetMoveSpeed(unit) * delay
	end

	function Prediction.User.Interface.IsUnitDashing(unit, range, speed, delay, width, source)
		range = range or math.huge
		speed = speed or math.huge
		delay = delay or 0
		width = width or 0
		source = source or myHero
		if not unit or not IsObjectAlive(unit) then return false, nil, math.huge end
		local dist = GetDistance(unit, source)
		if range ~= math.huge and speed ~= math.huge and dist < range+width/2 then
			delay = delay + (dist) / speed
		end
		local canHasDash = Prediction.Vars.Dashing[GetNetworkID(unit)];
		if canHasDash.startT then
			local remainingTime = canHasDash.endT - GetGameTimer()
			if remainingTime > delay then
				local pos = Vector(canHasDash.startPos.x,0,canHasDash.startPos.z) + Vector(canHasDash.endPos.x-canHasDash.startPos.x,0,canHasDash.endPos.z-canHasDash.startPos.z):normalized() * canHasDash.dashSpeed * (GetGameTimer() - canHasDash.startT + delay)
				return true, pos, 0
			elseif remainingTime > 0 then
				return true, Vector(canHasDash.endPos), GetMoveSpeed(unit) * (delay - remainingTime)
			else
				Prediction.Vars.Dashing[GetNetworkID(unit)] = {};
				return false, nil, GetMoveSpeed(unit) * (delay - remainingTime)
			end
		end
		return false, nil, math.huge
	end

	do

		for name, callback in pairs(Prediction.Callback) do
			_G["On"..name](callback)
		end

		Prediction.Vars.Config:Info("i1", "Loaded!")
		Prediction.Vars.Config:Info("i2", "More menu options soon")

	end

	class "Spell"

	function Spell:__init(table)
		self.key = table.key
		self.range = table.range
		self.speed = table.speed
		self.delay = table.delay
		self.width = table.width
		self.type = table.type
		self.collision = table.collision
		self.callback = table.callback
		return self;
	end

	function Spell:Predict(unit, source)
		return nil--Prediction.Core.Predict(unit, self.range, self.speed, self.delay, self.width, self.collision, self.type, source or myHero)
	end

	_G.IPrediction = {
		IsUnitDashing = Prediction.User.Interface.IsUnitDashing,
		IsUnitSlowed = Prediction.User.Interface.IsUnitSlowed,
		IsUnitStunned = Prediction.User.Interface.IsUnitStunned,
		Prediction = function(data)
			if not (data.range and data.speed and data.delay and data.width) then print("Please specify spelldata!") end
			local spell = Spell({range = data.range, speed = data.speed, delay = data.delay, width = data.width, type = data.type, collision = type(data.collision) == "number" and data.collision or data.collision and 0 or math.huge, callback = callback})
			Prediction.Vars.Spells[#Prediction.Vars.Spells+1] = spell
			return spell
		end,
		OnDash = Prediction.User.OnDash,
		OnImmobile = Prediction.User.OnImmobile
	}
end
