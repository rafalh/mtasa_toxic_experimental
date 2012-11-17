local g_Rooms = {
	{id = "room-dm", title = "Deathmatch", mapPatterns = "[dm]"},
	{id = "room-dd", title = "Destruction derby", mapPatterns = "[dd]"},
	{id = "room-race", title = "Race", mapPatterns = "[race]"},
}

function initRooms()
	local raceRes = getResourceFromName("race")
	
	for i, info in ipairs(g_Rooms) do
		local room = createRoom(info.id)
		if(not room) then
			outputDebugString("Failed to create room "..info.title, 1)
		else
			setElementData(room, "title", info.title)
			setElementData(room, "mapPatterns", info.mapPatterns)
			startRoomGamemode(room, raceRes)
		end
	end
end
