local res = GetResolution()
local blockPos = {x = res.x/2-250, y = res.y - 250}
local blocks, balls = { }, { }
local lifes, score = 3, 0
ARROW_LEFT, ARROW_RIGHT = 37, 39

for i=70,res.x-160,160 do
	for I=150,res.y-450,35 do
		table.insert(blocks, {x = i, y = I})
	end
end

OnDrawMinimap(function()
    if not doPlay then return end
	FillRect(0, 0, 1920, 1080, 0xFF000000)
	DrawText("Lifes: "..lifes, 25, 25, 25, 0xFFFFFFFF)
	if startT then DrawText("Time: "..math.floor((GetGameTimer() - startT)), 25, 120, 25, 0xFFFFFFFF) end
	DrawText("Score: "..score, 25, 25, 55, 0xFFFFFFFF)
	if lifes < 1 then
		DrawText("GAME OVER", 55, res.x/2-175, res.y/2, 0xFFFFFFFF)
		DrawText("Continue?", 25, res.x/2-110, res.y/2+125, 0xFFFFFFFF)
	else
		FillRect(blockPos.x, blockPos.y, 250, 50, 0xFFFFFFFF)
		for _, block in pairs(blocks) do
			FillRect(block.x, block.y, 150, 25, 0xFFFFFFFF)
		end
		for _, ball in pairs(balls) do
			DrawBall(ball.x, ball.y, 10, 0xFFFF0000)
		end
	end
end)

OnTick(function()
    if not doPlay then return end
	if KeyIsDown(ARROW_LEFT) then
		blockPos.x = math.max(0, blockPos.x - 15)
	end
	if KeyIsDown(ARROW_RIGHT) then
		blockPos.x = math.max(0, blockPos.x + 15)
	end
	for _=1, #balls do
		local ball = balls[_]
		balls[_] = { x = ball.x + ball.dir.x, y = ball.y + ball.dir.y, dir = ball.dir}
		local x, y = balls[_].x, balls[_].y
		if InBlock(x, y) then
			local tV = {x = balls[_].dir.x+(x-blockPos.x > 125 and 5 or -5), y = -balls[_].dir.y}
			local len = math.sqrt(tV.x * tV.x + tV.y * tV.y)
			balls[_] = { x = x, y = y, dir = {x = 12 * tV.x / len, y = 12 * tV.y / len}}
		elseif InBlocks(x, y) then
			balls[_] = { x = x, y = y, dir = {x = balls[_].dir.x, y = -balls[_].dir.y}}
		elseif y < 10 then
			balls[_] = { x = x, y = y, dir = {x = balls[_].dir.x, y = -balls[_].dir.y}}
		elseif x < 10 or x > res.x then
			balls[_] = { x = x, y = y, dir = {x = -balls[_].dir.x, y = balls[_].dir.y}}
		elseif y > res.y then
			lifes = lifes - 1
			table.remove(balls, _)
		end
	end
end)

OnWndMsg(function(msg, key)
	if msg == 256 and key==122 then
        doPlay=not doPlay
    end
    if not doPlay then return end
	if key == 32 and msg==256 and #balls < 1 then
		if not startT then startT = GetGameTimer() end
		local tV = {x = math.random(10)-5, y = -10}
		local len = math.sqrt(tV.x * tV.x + tV.y * tV.y)
		table.insert(balls, {x = blockPos.x+125, y = blockPos.y-10, dir = {x = 12 * tV.x / len, y = 12 * tV.y / len} })
	end
end)

function DrawBall(x, y, size, color, quality)
	local quality = quality or 1;
	local lastPos = {}
	for theta=0,360,quality do
		DrawLine(x + size * math.cos(theta), y + size * math.sin(theta), x + size * math.cos(theta+1), y + size * math.sin(theta+1), 10, color)
	end
end

function InBlocks(x, y)
	for _, block in pairs(blocks) do
		if x >= block.x and x <= block.x+150 and y >= block.y and y <= block.y+25 then
			table.remove(blocks, _)
			score = score + math.max(750, 1000 - math.ceil(GetGameTimer() - startT))
            if #blocks == 0 then
                for i=70,res.x-160,160 do
	                for I=150,res.y-450,35 do
		                table.insert(blocks, {x = i, y = I})
	                end
                end
            end
			return true
		end
	end
	return false
end

function InBlock(x, y)
	return x >= blockPos.x and x <= blockPos.x+250 and y >= blockPos.y and y <= blockPos.y+50
end
