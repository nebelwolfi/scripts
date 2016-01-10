function AutoUpdate()
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
	end
end
AutoUpdate()
-- this is just a download of real inspired lua.
