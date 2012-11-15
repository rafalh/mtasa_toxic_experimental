local g_Me = getLocalPlayer()
local g_ResRoot = getResourceRootElement()

function getCurrentRoom()
	local id = getElementData(g_Me, "roomid")
	local room = id and getElementByID(id)
	return room
end

function setCurrentRoom(room)
	triggerServerEvent("roommgr_onChangeRoomReq", g_ResRoot, room)
end

function getRooms()
	return getElementsByType("game-room")
end

function getPlayerRoom(player)
	local roomID = getElementData(player, "roomid")
	return roomID and getElementByID(roomID)
end

function getRoomPlayers(room)
	local currentRoom = getCurrentRoom()
	local players = getElementsByType("player")
	local ret = {}
	for i, player in ipairs(players) do
		if(getPlayerRoom(player) == currentRoom) then
			table.insert(ret, player)
		end
	end
	return ret
end
