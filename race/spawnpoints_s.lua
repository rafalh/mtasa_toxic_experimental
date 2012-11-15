-- SpawnPoints CLASS
SpawnPoints = {}

function SpawnPoints:onMapStart()
	local room = self.game.room
	self.list = getRoomMapElements(room, "spawnpoint")
	assert(self.list)
	self.freeCount = #self.list
end

function SpawnPoints:onMapStop()
	self.list = {}
end

function SpawnPoints:getRandom(maxIndex, remove)
	maxIndex = math.min(maxIndex or math.huge, #self.list)
	local listCopy = table.copy(self.list, maxIndex)
	
	local sp = false
	while(#listCopy > 0) do
		local i = math.random(1, #listCopy)
		sp = table.remove(listCopy, i)
		
		if(not sp.busy) then break end
	end
	
	if(not sp or sp.busy) then
		return false
	end
	
	if(remove) then
		sp.busy = true
	end
	return sp
end

function SpawnPoints:destroy()
	self.list = false
	self.game = false
end

function SpawnPoints.create(game)
	local self = setmetatable({}, SpawnPoints.__mt)
	self.game = game
	self.list = false
	return self
end

SpawnPoints.__mt = {__index = SpawnPoints}
