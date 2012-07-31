local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
g_Players = {}

addEvent("onPlayerMapLoaded", true)

local function init()
	PlayerRes.init()
	for i, player_el in ipairs(getElementsByType("player")) do
		g_Players[player_el] = Player:create(player_el)
	end
end

local function onPlayerJoin()
	g_Players[source] = Player:create(source)
end

local function onPlayerMapReady()
	--outputChatBox("onPlayerMapReady")
	local player = g_Players[client]
	if(player) then
		player:onMapReady()
	end
end

local function onElDestroy()
	local player = g_Players[source]
	if(player) then
		player:destroy()
		g_Players[source] = nil
	end
	
	local room = g_ElementToRoom[source]
	if(room) then
		room:destroy(true)
		g_ElementToRoom[source] = nil
	end
end

local function roomsCmd()
	local i = 1
	for id, room in pairs(g_Rooms) do
		outputChatBox(i..". "..id.." - "..#room.players.." players")
		i = i + 1
	end
end

addEvent("onPlayerMapReady", true)

addEventHandler("onResourceStart", g_ResRoot, init)
addEventHandler("onPlayerJoin", g_ResRoot, onPlayerJoin)
addEventHandler("onPlayerMapReady", g_Root, onPlayerMapReady)
addCommandHandler("rooms", roomsCmd)
addEventHandler("onElementDestroy", g_Root, onElDestroy)
