local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Game = false

local function init()
	import("mapmanager")
	import("roommanager")
	
	outputChatBox("Started gamemode")
	
	local room = createRoom("race")
	g_Game = Game:create(room)
	
	local players = getElementsByType("player")
	for i, player in ipairs(players) do
		g_Game:addPlayer(player)
	end
end

local function cleanup()
	g_Game:destroy()
	destroyElement(g_Game.room)
end

local function onPlayerJoin()
	g_Game:addPlayer(source)
	outputChatBox(getPlayerName(source).." joined")
end

addEventHandler("onResourceStart", g_ResRoot, init)
addEventHandler("onResourceStop", g_ResRoot, cleanup)
addEventHandler("onPlayerJoin", g_Root, onPlayerJoin)
