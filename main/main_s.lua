g_Root = getRootElement()
g_ResRoot = getResourceRootElement()

local function init()
	setGameType("DM/DD/Race")
	
	import("roommgr")
	import("mapmgr")
	import("votemgr")
	import("race")
	
	initRooms()
	initPlayers()
	initVoteBetweenMaps()
end

addEventHandler("onResourceStart", resourceRoot, init)

