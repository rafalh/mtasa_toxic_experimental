Game = {}

addEvent("onPlayerMapStarting", true)

function Game:addPlayer(player)
	table.insert(self.players, player)
	
	setPlayerRoom(player, self.room)
	addEventHandler("onPlayerMapStarting", player, function()
		self:spawnPlayer(source)
	end)
end

function Game:destroy()
end

function Game:spawnPlayer(player)
	local spawnpoints = getRoomMapElements(self.room, "spawnpoint")
	if(not spawnpoints or #spawnpoints == 0) then
		outputChatBox("No spawnpoints")
		return false
	end
	
	local sp = spawnpoints[math.random(1, #spawnpoints)]
	local x, y, z = tonumber(sp.posX), tonumber(sp.posY), tonumber(sp.posZ)
	local veh_id = tonumber(sp.vehicle)
	if(not x or not y or not z or not veh_id) then
		outputChatBox("Invalid spawnpoint")
		return false
	end
	
	spawnPlayer(player, x, y, z, 0, 0, 0, self.dim)
	local veh = createVehicle(veh_id, x, y, z)
	setElementDimension(veh, self.dim)
	setElementFrozen(veh, true)
	warpPedIntoVehicle(player, veh)
	setTimer(setElementFrozen, 3000, 1, veh, false)
	
	setCameraTarget(player, player)
	fadeCamera(player, true)
	return true
end

function Game:create(room)
	local game = setmetatable({}, Game.__mt)
	game.room = room
	game.dim = getElementDimension(room)
	game.players = {}
	
	local map = findMap("Hust")
	startRoomMap(room, map)
	
	return game
end

Game.__mt = {__index = Game}
