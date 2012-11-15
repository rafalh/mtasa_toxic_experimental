local g_Root = getRootElement ()
local g_ResRoot = getResourceRootElement ()
local g_Players = {}
local g_Music = {}
local g_ServerAddress = get ( "server_address" )

addEvent("onClientStartMusicReq", true)
addEvent("onClientStopMusicReq", true)
addEvent("onPlayerReady", true)
addEvent("onRaceStateChanging")
addEvent("onPlayerChangeRoom")

local function getMapRes(room)
	local mapMgrRes = getResourceFromName("mapmanager")
	if(mapMgrRes and getResourceState(mapMgrRes) == "running") then
		return call(mapMgrRes, "getRunningGamemodeMap")
	end
	
	local roomMgrRes = getResourceFromName("roommgr")
	if(roomMgrRes and getResourceState(roomMgrRes) == "running" and room ~= g_Root) then
		return call(roomMgrRes, "getRoomMapResource", room)
	end
	return false
end

local function getRooms()
	local roomMgrRes = getResourceFromName("roommgr")
	if(roomMgrRes and getResourceState(roomMgrRes) == "running") then
		return call(roomMgrRes, "getRooms")
	end
	return {g_Root}
end

local function getPlayerRoom(player)
	local roomID = getElementData(player, "roomid")
	return (roomID and getElementByID(roomID)) or g_Root
end

local function startMusic(res, room)
	--outputDebugString ( "startMusic", 3 )
	local res_name = getResourceName ( res )
	local path = getResourceInfo ( res, "music" ) or get ( res_name..".music" )
	if ( path ) then
		g_Music[room] = {}
		g_Music[room].res = res
		g_Music[room].res_name = res_name
		g_Music[room].path = path
		g_Music[room].url = "http://"..g_ServerAddress.."/"..g_Music[room].res_name.."/"..g_Music[room].path
		
		for player, playerRoom in pairs ( g_Players ) do
			if(playerRoom == room) then
				triggerClientEvent ( player, "onClientStartMusicReq", g_ResRoot, g_Music[room].url )
			end
		end
	else
		--outputDebugString ( "No music!", 3 )
	end
end

local function stopMusic(room)
	if(not g_Music[room]) then return end
	
	g_Music[room] = false
	
	for player, playerRoom in pairs ( g_Players ) do
		if(playerRoom == room) then
			triggerClientEvent ( player, "onClientStopMusicReq", g_ResRoot )
		end
	end
end

local function onResStop(res)
	local roomID = getElementData(getResourceRootElement(res), "roomid")
	local room = roomID and getElementByID(roomID)
	if ( not g_Music[room] or g_Music[room].res ~= res ) then return end
	stopMusic(room)
end

local function onPlayerReady ()
	--outputDebugString ( "onPlayerReady", 3 )
	local room = getPlayerRoom(client)
	g_Players[client] = room
	if (g_Music[room]) then
		--outputDebugString ( "Start music", 3 )
		triggerClientEvent ( client, "onClientStartMusicReq", g_ResRoot, g_Music[room].url )
	end
end

local function onPlayerQuit ()
	g_Players[source] = nil
end

local function onPlayerChangeRoom(room)
	local oldRoom = g_Players[source]
	g_Players[source] = room
	
	if (room and g_Music[room]) then
		triggerClientEvent ( source, "onClientStartMusicReq", g_ResRoot, g_Music[room].url )
	elseif(oldRoom and g_Music[oldRoom]) then
		triggerClientEvent ( source, "onClientStopMusicReq", g_ResRoot )
	end
end

local function init ()
	--outputDebugString ( "init", 3 )
	local rooms = getRooms()
	for i, room in ipairs(rooms) do
		local mapRes = getMapRes(room)
		if(mapRes) then
			startMusic(mapRes, room)
		end
	end
end

local function onElDestroy()
	if(g_Music[source]) then
		stopMusic(source)
	end
end

local function onRaceStateChanging ( state, oldState, room )
	if ( state == "GridCountdown" ) then
		local map_res = getMapRes(room or g_Root)
		startMusic(map_res, room or g_Root)
	end
end

--addEventHandler ( "onGamemodeMapStart", g_Root, startMusic )
addEventHandler ( "onResourceStop", g_Root, onResStop )
addEventHandler ( "onPlayerReady", g_ResRoot, onPlayerReady )
addEventHandler ( "onPlayerQuit", g_Root, onPlayerQuit )
addEventHandler ( "onPlayerChangeRoom", g_Root, onPlayerChangeRoom )
addEventHandler ( "onResourceStart", g_ResRoot, init )
addEventHandler ( "onElementDestroy", g_Root, onElDestroy )
addEventHandler ( "onRaceStateChanging", g_Root, onRaceStateChanging )
