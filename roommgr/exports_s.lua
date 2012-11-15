local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()

function createRoom(id)
	local room = Room.create(id)
	if(not room) then
		return false
	end
	
	return room.el
end

function getRooms()
	local ret = {}
	for id, room in pairs(Room.list) do
		table.insert(ret, room.el)
	end
	return ret
end

function getRoomPlayers(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		outputDebugString("Invalid room", 1)
		return false
	end
	
	local ret = {}
	for i, player in ipairs(room.players) do
		table.insert(ret, player.el)
		assert(isElement(player.el))
	end
	return ret
end

function getRoomPlayersCount(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		outputDebugString("Invalid room", 1)
		return false
	end
	
	local ret = 0
	for i, player in ipairs(room.players) do
		ret = ret + 1
	end
	return ret
end

function setPlayerRoom(playerEl, roomEl)
	local room = Room.elMap[roomEl]
	if(roomEl and not room) then
		outputDebugString("Invalid room", 1)
		return false
	end
	
	local player = Player.elMap[playerEl]
	if(not player) then
		outputDebugString("Invalid player", 1)
		return false
	end
	
	player:setRoom(room)
	return true
end

function getPlayerRoom(playerEl)
	local player = Player.elMap[playerEl]
	if(not player) then
		return false
	end
	
	local room = player.room
	return room and room.el
end

function startRoomMap(roomEl, mapPath)
	local room = Room.elMap[roomEl]
	if(not room) then
		outputDebugString("Invalid room", 1)
		return false
	end
	
	return room:startMap(mapPath)
end

function stopRoomMap(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room:stopMap()
end

function getRoomMap(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		outputDebugString("Invalid room", 1)
		return false
	end
	
	return room.mapPath
end

function startRoomGamemode(roomEl, res)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room:startGamemode(res)
end

function stopRoomGamemode(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room:stopGamemode()
end

function getRoomMapElements(roomEl, type)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room:getMapElements(type)
end

function getRoomMapSettings(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room.mapSettings
end

function getRoomMapInfo(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room.mapInfo
end

function getRoomMapResource(roomEl)
	local room = Room.elMap[roomEl]
	if(not room) then
		return false
	end
	
	return room.res.res
end
