package.path = package.path .. ';C:/GOS/?.lua;'

local reloading = 0

function AfterObjectLoopEvent(myHero)
	if KeyIsDown(0x78) then
		reloading = 1
	else
		if reloading == 1 then
			package.loaded[ 'Inspired' ] = nil
			package.loaded[ GetObjectName(myHero) ] = nil
			require('Inspired')
			require(GetObjectName(myHero))
			reloading = 0
		end
	end
end
