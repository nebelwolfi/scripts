require("Inspired")

class "IAIO"

str = {[0]="Q",[1]="W",[2]="E",[3]="R"}
spellData = {{}, {}, {}, [0]={}}

local function DrawLine3D(x,y,z,a,b,c,width,col)
	local p1 = WorldToScreen(0, Vector(x,y,z))
	local p2 = WorldToScreen(0, Vector(a,b,c))
	DrawLine(p1.x, p1.y, p2.x, p2.y, width, col)
end

local function DrawRectangleOutline(startPos, endPos, width, alpha)
	local c1 = startPos+Vector(Vector(endPos)-startPos):perpendicular():normalized()*width/2
	local c2 = startPos+Vector(Vector(endPos)-startPos):perpendicular2():normalized()*width/2
	local c3 = endPos+Vector(Vector(startPos)-endPos):perpendicular():normalized()*width/2
	local c4 = endPos+Vector(Vector(startPos)-endPos):perpendicular2():normalized()*width/2
	DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,math.ceil(width/100),ARGB(alpha, 255, 255, 255))
	DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,math.ceil(width/100),ARGB(alpha, 255, 255, 255))
	DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(alpha, 255, 255, 255))
	DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,math.ceil(width/100),ARGB(alpha, 255, 255, 255))
end

function IAIO:__init()
	self.toDraw = {{0, 0, 0},{0, 0, 0},{0, 0, 0},[0]={0, 0, 0}}
	self.ts = {}
	self.Config = MenuConfig("IAIO", "IAIO"..myHeroName)
	for i=0,3 do
		self.Config:Menu("Skill"..str[i], "Skill "..str[i])
		self.Config["Skill"..str[i]]:Info("Name", GetCastName(myHero, i))
		self.Config["Skill"..str[i]]:Boolean("UseCombo", "Use Combo", true)
		self.Config["Skill"..str[i]]:Boolean("UseHarass", "Use Harass", true)
		self.Config["Skill"..str[i]]:Boolean("UseLastHit", "Use LastHit", true)
		self.Config["Skill"..str[i]]:Slider("ManaLastHit", "Mana LastHit", 50, 0, 100, 1)
		self.Config["Skill"..str[i]]:Boolean("UseLaneClear", "Use LaneClear", true)
		self.Config["Skill"..str[i]]:Slider("ManaLaneClear", "Mana LastClear", 50, 0, 100, 1)
		self.Config["Skill"..str[i]]:Boolean("Draw", "Draw Range", false)
		self.Config["Skill"..str[i]]:ColorPick("Color", "Color", {255, 255, 255, 255}, function(var) self.toDraw[i][1] = GetTickCount() end)
		self.Config["Skill"..str[i]]:Slider("Range", "Range", GetCastRange(myHero, i), 0, 3500, 1, function(var) self.toDraw[i][1] = GetTickCount() end)
		self.Config["Skill"..str[i]]:Slider("Speed", "Speed", 1000, 0, 2500, 1, function(var) self.toDraw[i][2] = GetTickCount() end)
		self.Config["Skill"..str[i]]:Slider("Delay", "Delay", 250, 0, 1250, 1, function(var) self.toDraw[i][2] = GetTickCount() end)
		self.Config["Skill"..str[i]]:Slider("Width", "Width", 125, 0, 500, 1, function(var) self.toDraw[i][3] = GetTickCount() end)
		self.Config["Skill"..str[i]]:DropDown("Type", "Type", 1, {"Linear", "Circular", "Cone", "Arc", "Pentagon"})
		self.Config["Skill"..str[i]]:DropDown("TType", "TravelType", 1, {"Travel", "Instant"}, function(var) self:Switch(i, var) end, false)
		self.Config["Skill"..str[i]]:Boolean("Collision", "Collision", true)
		self.Config["Skill"..str[i]]:Boolean("AOE", "AOE", false)
		self.Config["Skill"..str[i]]:DropDown("Logic", "Cast as ", 1, {"Skillshot", "Targeted", "Heal/Shield (self)", "Heal/Shield (ally)", "Heal/Shield (skillshot)", "AA Reset", "AA Reset(Emote)"})
		self.Config["Skill"..str[i]]:DropDown("Damage", "Damage Tye ", 1, {"Magic", "Physical"})
		self.ts[i] = TargetSelector(0, TARGET_LESS_CAST_PRIORITY, DAMAGE_MAGIC)
		self.Config["Skill"..str[i]]:TargetSelector("ts", "TargetSelector", self.ts[i])
		DelayAction(function()self:Switch(i, self.Config["Skill"..str[i]].TType:Value())  end, 1000)
	end
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpellComplete(function(unit, spell) self:ProcessSpellComplete(unit, spell) end)
	IOW:AddCallback(AFTER_ATTACK, function(t, m) self:WindUp(t, m) end)
end

function IAIO:Switch(x, y)
	if y == 2 then
		self.lastSpeed = self.Config["Skill"..str[x]].Speed:Value()
		self.Config["Skill"..str[x]].Speed:Modify(0, 0, 1)
		self.Config["Skill"..str[x]].Speed:Value(0)
	else
		self.Config["Skill"..str[x]].Speed:Modify(0, 2500, 1)
		self.Config["Skill"..str[x]].Speed:Value(self.lastSpeed)
	end
end

function IAIO:Tick()
	for i=0, 3 do
		spellData[i] = { 
							name = self.Config["Skill"..str[i]].Name.name, 
							range = self.Config["Skill"..str[i]].Range:Value(), 
							width = self.Config["Skill"..str[i]].Width:Value(), 
							speed = self.Config["Skill"..str[i]].Speed:Value(), 
							delay = self.Config["Skill"..str[i]].Delay:Value(), 
							type = self.Config["Skill"..str[i]].Type:Value(), 
							ttype = self.Config["Skill"..str[i]].TType:Value(), 
							logic = self.Config["Skill"..str[i]].Logic:Value(), 
							draw = self.Config["Skill"..str[i]].Draw:Value(), 
							collision = self.Config["Skill"..str[i]].Collision:Value(), 
							color = { 
										self.Config["Skill"..str[i]].Color.color[1]:Value(), 
										self.Config["Skill"..str[i]].Color.color[2]:Value(), 
										self.Config["Skill"..str[i]].Color.color[3]:Value(),
										self.Config["Skill"..str[i]].Color.color[4]:Value()
									}
						}
		self.ts[i].range = spellData[i].range
		self.ts[i].dtype = self.Config["Skill"..str[i]].Damage:Value()
		self.ts[i].ownteam = (spellData[i].logic == 4 or spellData[i].logic == 5)
		local mode = IOW:Mode()
		if mode ~= "" and GetCastName(myHero, i) == spellData[i].name then
			local target = IOW.target or self.ts[i]:GetTarget()
			if (target ~= nil or spellData[i].logic == 4) and self.Config["Skill"..str[i]]["Use"..mode]:Value() and (not self.Config["Skill"..str[i]]["Mana"..mode] or self.Config["Skill"..str[i]]["Mana"..mode]:Value() <= 100*GetCurrentMana(myHero)/GetMaxMana(myHero)) and CanUseSpell(myHero, i) == 0 then
				if spellData[i].logic == 1 then
					self:PredCast(i, target, spellData[i])
				elseif spellData[i].logic == 2 then
					CastTargetSpell(target, i)
				elseif spellData[i].logic == 3 and GetCurrentHP(myHero)/GetMaxHP(myHero) < 0.65 then
					CastSpell(i)
				elseif spellData[i].logic == 4 and GetCurrentHP(target)/GetMaxHP(target) < 0.65 then
					CastTargetSpell(target, i)
				elseif spellData[i].logic == 5 and GetCurrentHP(target)/GetMaxHP(target) < 0.65 then
					self:PredCast(i, target, spellData[i])
				end
			end
		end
	end
end

function IAIO:WindUp(t, m)
	if t ~= nil and m ~= "" then
		for i=3, 0, -1 do
			if spellData[i].logic == 6 and CanUseSpell(myHero, i) == 0 then
				CastTargetSpell(t, i)
				CastSpell(i)
				IOW:ResetAA()
				break;
			elseif spellData[i].logic == 7 and CanUseSpell(myHero, i) == 0 then
				DelayAction(function() CastSkillShot(i, GetOrigin(t)) end, GetLatency() + 30)
				IOW:ResetAA()
				break;
			end
		end
	end
end

function IAIO:ProcessSpellComplete(unit, spell)
	if unit and unit == myHero and spell and spell.name and IOW:Mode() ~= "" then
		-- that moment when riven needs an extra line..
		if myHeroName == "Riven" then if spell.name == spellData[_W].name then CastSkillShot(_Q, GetOrigin(self.ts[0]:GetTarget()) or GetMousePos()) return; end end
		for i=0, 3 do
			if spellData[i].logic == 7 and spellData[i].name == spell.name then
				DelayAction(function() 
					CastEmote(EMOTE_DANCE) 
				end, GetLatency() + 375)
				IOW:ResetAA()
				break;
			end
		end
	end
end

function IAIO:Draw()
	for i=0, 3 do
		if spellData[i].draw then
			DrawCircle(myHeroPos(), spellData[i].range, 3, 100, ARGB(spellData[i].color[1], spellData[i].color[2], spellData[i].color[3], spellData[i].color[4]))
		elseif self.toDraw[i][1] + 5000 > GetTickCount() then
			DrawCircle(myHeroPos(), spellData[i].range, 3, 100, ARGB(255-255 * (GetTickCount()-self.toDraw[i][1]) / 5000, spellData[i].color[2], spellData[i].color[3], spellData[i].color[4]))
		end
		if self.toDraw[i][3] + 5000 > GetTickCount() then
			if spellData[i].type == 1 then
				DrawRectangleOutline(myHeroPos(), GetMousePos(), spellData[i].width, 255-255 * (GetTickCount()-self.toDraw[i][3]) / 5000)
			elseif spellData[i].type == 2 then
				DrawCircle(GetMousePos(), spellData[i].width, 3, 100, ARGB(255-255 * (GetTickCount()-self.toDraw[i][3]) / 5000, spellData[i].color[2], spellData[i].color[3], spellData[i].color[4]))
			end
		end
	end
end

function IAIO:PredCast(spell, target, t)
	if target == nil or GetOrigin(target) == nil or not IsTargetable(target) or IsImmune(target, myHero) or IsDead(target) or not IsVisible(target) then return false end
	local Pred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target), t.ttype == 2 and math.huge or t.speed, t.delay, t.range, t.width, t.collision, true)
	if Pred.HitChance >= 1 then
		CastSkillShot(spell, Pred.PredPos.x, Pred.PredPos.y, Pred.PredPos.z)
		return true
	end
end

IAIO()
