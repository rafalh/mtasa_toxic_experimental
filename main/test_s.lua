local function roomsCmd(source)
	local rooms = getRooms()
	for i, room in ipairs(rooms) do
		local id = getElementID(room)
		local roomPlayers = getRoomPlayers(room)
		outputChatBox(i..". "..id.." - "..#roomPlayers.." players", source)
	end
end

local function roomCmd(source, cmd, roomId)
	if(not roomId) then
		local room = getPlayerRoom(source)
		local roomId = room and getElementID(room)
		outputChatBox("Your room: "..tostring(roomId), source)
	else
		local rooms = getRooms()
		for i, room in ipairs(rooms) do
			local id = getElementID(room)
			if(id:find(roomId, 1, true)) then
				setPlayerRoom(source, room)
				break
			end
		end
	end
end

local function refreshMapsCmd()
	refreshMapsList()
end

local function ghostmode(source)
	local room = getPlayerRoom(source)
	if(room and getElementData(room, "race.state") == "running") then
		local gm = isGhostModeEnabled(room)
		if(not setGhostModeEnabled(room, not gm)) then
			outputChatBox("Failed to set ghostmode", g_Root, 255, 0, 0)
		elseif(gm) then
			outputChatBox("Ghostmode has been disabled", g_Root, 255, 0, 0)
		else
			outputChatBox("Ghostmode has been enabled", g_Root, 0, 255, 0)
		end
	end
end

local function voteMap(player)
	local room = getPlayerRoom(player)
	if(room) then
		startVote(room)
	end
end

addCommandHandler("rooms", roomsCmd)
addCommandHandler("room", roomCmd)
addCommandHandler("votemap", voteMap)
addCommandHandler("refreshmaps", refreshMapsCmd)
addCommandHandler("gm", ghostmode)
