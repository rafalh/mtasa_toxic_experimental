local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()

g_PlayerToRoom = {}

function createRoom(id)
	local room = Room:create(id)
	if(not room) then
		return false
	end
	
	return room.el
end

function getRooms()
	local ret = {}
	for id, room in ipairs(g_Rooms) do
		table.insert(ret, room.el)
	end
	return ret
end

function setPlayerRoom(player_el, room_el)
	local room = g_ElementToRoom[room_el]
	if(room_el and not room) then
		return false
	end
	
	local player = g_Players[player_el]
	if(not player) then
		return false
	end
	
	player:setRoom(room)
	return true
end

function startRoomMap(room_el, map_name)
	local room = g_ElementToRoom[room_el]
	if(not room) then
		return false
	end
	
	local path = ":mapmanager/"..get("mapmanager.maps_dir").."/"..map_name
	return room:startMap(path)
end

function stopRoomMap(room_el)
	local room = g_ElementToRoom[room_el]
	if(not room) then
		return false
	end
	
	return room:stopMap()
end

function getPlayerRoom(player_el)
	local player = g_Players[player_el]
	if(not player) then
		return false
	end
	
	local room = player.room
	return room and room.el
end

function getRoomMapElements(room_el, type)
	local room = g_ElementToRoom[room_el]
	if(not room) then
		return false
	end
	
	return room:getMapElements(type)
end