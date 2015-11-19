require("AutoUpdater")
local VERSION = 2
AutoUpdater(
		VERSION,  -- local version!
		true, -- https?true:false
		"raw.githubusercontent.com", -- host
		"/Inspired-gos/scripts/master/AutoUpdate.version?no-cache="..(math.random(100000)), -- version url
		"/Inspired-gos/scripts/master/AutoUpdate.lua?no-cache="..(math.random(100000)), -- lua url
		SCRIPT_PATH.."//AutoUpdate.lua", -- local path + file name
		function(nv, ov) print("Updated from v"..ov.." to v"..nv.."!") end, -- callback after update
		function(v) print("You already have latest version! (v"..v..")") end, -- callback no update
		function(nv, ov) print("New version found! Going to update.. (v"..ov.."->v"..nv..")") end, -- callback new version
		function() print("An unexpected error occured.") end -- callback error
	)
