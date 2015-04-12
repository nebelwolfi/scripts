local version = 1.0

--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()

-- called once when the script is loaded
function OnLoad()
    PrintChat(" >> Lulu script")
    ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,950)
    menu = scriptConfig("Lulu script", "Lulu")
    menu:addSubMenu("AutoCombo Settings", "combosettings")
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