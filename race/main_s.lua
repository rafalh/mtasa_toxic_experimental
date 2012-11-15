g_Root = getRootElement()
g_ResRoot = getResourceRootElement()
local g_Game = false

local function init()
	import("mapmgr")
	import("roommgr")
end

local function cleanup()
	for room, game in pairs(Game.roomToGame) do
		game:destroy(true)
	end
end

function startGamemodeInRoom(room)
	if(not Game.roomToGame[room]) then
		Game.create(room)
	end
end

function stopGamemodeInRoom(room)
	local game = Game.roomToGame[room]
	if(game) then
		game:destroy()
	end
end

function isGhostModeEnabled(room)
	local game = Game.roomToGame[room]
	if(not game) then return false end
	return game.ghostMode
end

function setGhostModeEnabled(room, enabled)
	local game = Game.roomToGame[room]
	if(not game) then return false end
	game:setGhostMode(enabled)
	return true
end

addEventHandler("onResourceStart", g_ResRoot, init)
addEventHandler("onResourceStop", g_ResRoot, cleanup)
