local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()

g_MapsList = {}

local function init()
	import("roommanager")
	refreshMapsList()
end

local function mapCmd(player, cmd, str)
	local map_name = findMap(str)
	if(not map_name) then
		outputChatBox("Map not found")
		return
	end
	
	local room = getPlayerRoom(player)
	if(room) then
		startRoomMap(room, map_name)
	end
end

local function mapsCmd()
	for i, map_name in ipairs(g_MapsList) do
		outputChatBox(i..". "..map_name)
	end
end

addEventHandler("onResourceStart", g_ResRoot, init)
addCommandHandler("map", mapCmd)
addCommandHandler("maps", mapsCmd)
