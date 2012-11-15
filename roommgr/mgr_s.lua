g_Root = getRootElement()
g_ResRoot = getResourceRootElement()

local function init()
	import("transfermgr")
	import("mapmgr")
	
	for i, player in ipairs(getElementsByType("player")) do
		Player:create(player)
	end
end

local function onPlayerJoin()
	Player:create(source)
end

local function onPlayerMapReady()
	local player = Player.elMap[client]
	local room = RoomRes.rootToRoom[source]
	if(player and room) then
		player:onMapReady(room)
	--[[else
		outputDebugString("Ignored map ready event ("..
			"room.root "..tostring(player.room and player.room.res.root).." "..
			"source "..tostring(source).." "..
			"resroot "..tostring(getResourceRootElement(player.room.res.res))..")", 2)]]
	end
end

local function onPlayerMapStarting()
	local player = Player.elMap[client]
	if(player and player.room and player.room.res.root == source) then
		player:onMapStart()
	else
		outputDebugString("Ignored map start event", 2)
	end
end

local function onElDestroy()
	local player = Player.elMap[source]
	if(player) then
		player:destroy()
	end
	
	local room = Room.elMap[source]
	if(room) then
		room:destroy(true)
	end
end

local function onChangeRoomReq(roomEl)
	local player = Player.elMap[client]
	local room = Room.elMap[roomEl]
	if(not player or not room) then return end
	
	player:setRoom(room)
end

addEvent("room_onMapReady", true)
addEvent("room_onMapStarting", true)
addEvent("roommgr_onChangeRoomReq", true)

addEventHandler("onResourceStart", g_ResRoot, init)
addEventHandler("onPlayerJoin", g_Root, onPlayerJoin)
addEventHandler("onElementDestroy", g_Root, onElDestroy)
addEventHandler("room_onMapReady", g_Root, onPlayerMapReady)
addEventHandler("room_onMapStarting", g_Root, onPlayerMapStarting)
addEventHandler("roommgr_onChangeRoomReq", g_Root, onChangeRoomReq)

