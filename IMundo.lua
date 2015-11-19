require("Inspired")
require("IPrediction")
AutoUpdate("/Inspired-gos/scripts/master/IMundo.lua","/Inspired-gos/scripts/master/IMundo.version","IMundo.lua",2)
local myQ = { name = "InfectedCleaverMissile", speed = 2000, delay = 0.250, range = 1000, width = 75, collision = true, aoe = false, type = "linear"}
myQ.pred = IPrediction.Prediction(myQ)
local menu = MenuConfig("IMundo", "IMundo")
if FileExist(SPRITE_PATH.."\\mundo.png") then
	menu:Sprite("mundo", "mundo.png", 250, 220, 130, ARGB(255,255,255,255))
end
menu:KeyBinding("throw", "THROW", string.byte("T"), true, function() end, false);
menu:KeyBinding("farm", "FARM", string.byte("Z"), true, function() end, false);
menu:Boolean("kill", "KILLSTEAL", true);
menu:Boolean("draw", "DRAW", true);
menu:ColorPick("color", "COLOR", {255, 140, 0, 255});
menu:Slider("quality", "QUALITY", 4, 0, 8, 1);
OnTick(function()
	if menu.throw:Value() then
		for _, target in pairs(GetEnemyHeroes()) do
			if ValidTarget(target, 1050) then
				local hitchance, pos = myQ.pred:Predict(target)
				if hitchance > 2 then
					CastSkillShot(_Q, pos)
				end
			end
		end
	end
	if menu.farm:Value() then
		for i=1, minionManager.maxObjects do
			local minion = minionManager.objects[i]
			if ValidTarget(minion, 1050) and IOW:PredictHealth(minion, GetDistance(minion)/2) < CalcDamage(myHero, minion, 0, 30+50*GetCastLevel(myHero, _Q)) then
				local coll, num, tab = IPrediction.CollisionM(myHero, minion, myQ.pred)
				if not coll then
					CastSkillShot(_Q, GetOrigin(minion))
				end
			end
		end
	end
	if menu.kill:Value() then
		for _, target in pairs(GetEnemyHeroes()) do
			if ValidTarget(target, 1050) and GetCurrentHP(target) < CalcDamage(myHero, target, 0, 30+50*GetCastLevel(myHero, _Q)) then
				local hitchance, pos = myQ.pred:Predict(target)
				if hitchance > 2 then
					CastSkillShot(_Q, pos)
				end
			end
		end
	end
end)
OnDraw(function()
	if menu.draw:Value() then
		DrawCircle(GetOrigin(myHero), 1075, 1, 512/menu.quality:Value(), menu.color:Value())
	end
end)
