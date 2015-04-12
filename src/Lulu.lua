local version = 1.0

--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()
allie = GetAllyHeros()

-- called once when the script is loaded
function OnLoad()
    PrintChat(" >> Lulu script")
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,950)
    menu = scriptConfig("Lulu script", "Lulu")
    menu:addSubMenu("AutoCombo Settings", "combosettings")
    menu:addSubMenu("AutoGrowth Settings", "growthsettings")
    menu.growthsettings:addParam("user","Use R", SCRIPT_PARAM_ONOFF, true)
    menu.growthsettings:addSubMenu("Custom Priority","custompriority")
    menu.growthsettings.custompriority: addParam(allie[1].name, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.growthsettings.custompriority: addParam(allie[2].name, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.growthsettings.custompriority: addParam(allie[3].name, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    menu.growthsettings.custompriority: addParam(allie[4].name, SCRIPT_PARAM_SLICE, 3, 1, 9, 0)
    
    menu.combosettings:addParam("useflashr","Use Flash+R", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
    menu:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    menu:addParam("harass", "Toogle Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
    PrintChat ("<font color='#4ECB65'>Lulu script - loaded successful!</font>")
end
    
-- handles script logic, a pure high speed loop
function OnTick()

end

--handles overlay drawing (processing is not recommended here,use onTick() for that)
function OnDraw()

end

--handles input
function OnWndMsg(msg,key)

end

-- listens to chat input
function OnSendChat(txt)

end

-- listens to spell
function OnProcessSpell(owner,spell)

end