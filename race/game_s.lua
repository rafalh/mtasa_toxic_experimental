local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()

-- Game CLASS
Game = {}
Game.roomToGame = {}

addEvent("onPlayerFinish")
addEvent("onPlayerWin")
addEvent("onPlayerChangeRoom")
addEvent("onPlayerMapStarting")

function Game:addPlayer(player)
	table.insert(self.players, player)
	
	if(self.state ~= "idle") then
		local timePassed = self:getTimePassed()
		player:triggerEvent("onClientInitGame", self.room, self.mapInfo, timePassed, self.timeLimit)
	end
	
	if(self.state == "countdown" or self.state == "waiting" or (self.state == "running" and self.respawn)) then
		self:spawnPlayer(player)
	elseif(self.state == "running") then
		player:setSpectateMode(true)
	end
end

function Game:removePlayer(player)
	table.removeValue(self.players, player)
end

function Game:getActivePlayers()
	local ret = {}
	
	for i, player in ipairs(self.players) do
		if(player.active) then
			table.insert(ret, player)
		end
	end
	
	return ret
end

function Game:triggerClientEvent(...)
	for i, player in ipairs(self.players) do
		player:triggerEvent(...)
	end
end

function Game:spawnPlayer(player, training)
	local makeBusy = not self.ghostMode and not training
	local sp = self.spawnpoints:getRandom(#self.players, makeBusy)
	if(not sp) then
		outputChatBox("No spawnpoint available for "..player:getName(), player.el, 255, 0, 0)
		return false
	end
	
	player:spawn(sp)
	player:setActive(not training)
	player:setTrainingMode(training)
	player:setFrozen(true)
	player:setGhost(training or self.ghostMode)
	player.training = training
	
	if(self.state == "running") then
		if(not player:loadPos()) then
			player.cp = 0
		end
		TimerMgr.createTimerFor(player, self, player:getVehicle()):set(player.unfreezeAfterRespawn, 2000, 1, player)
	end
	
	return true
end

function Game:spawnAllPlayers()
	for i, player in ipairs(self.players) do
		self:spawnPlayer(player)
	end
end

function Game:changeState(newState)
	local oldState = self.state
	
	self.state = newState
	setElementData(self.room, "race.state", newState)
	
	-- old race compatible states
	local stateConv = {
		countdown = "GridCountdown", loading = "LoadingMap", idle = "NoMap",
		running = "Running", waiting = "PreGridCountdown"}
	triggerEvent("onRaceStateChanging", g_Root, stateConv[newState] or newState, stateConv[oldState] or oldState, self.room)
end

function Game:setGhostMode(enabled)
	if(self.ghostMode == enabled) then return end
	
	self.ghostMode = enabled
	for i, player in ipairs(self.players) do
		if(player.alive) then
			player:setGhost(self.ghostMode or player.training)
		end
	end
end

function Game:setRespawn(seconds, trainingMode)
	self.respawn = seconds
	setElementData(self.room, "race.respawn", self.respawn or trainingMode)
end

function Game:setTimeLimit(limit)
	self.timeLimit = limit
end

function Game:onMapStart()
	self:changeState("loading")
	self.mapStartTime = getTickCount()
	self.mapSettings = getRoomMapSettings(self.room)
	self.mapInfo = getElementData(self.room, "mapinfo")
	
	self.checkpoints:onMapStart()
	self.pickups:onMapStart()
	self.spawnpoints:onMapStart()
	
	self.isDM = self.mapInfo.name and self.mapInfo.name:match("%[DM%]") and true
	self.minActivePlayers = (self.isDM and 1) or 2
	
	local respawn = false
	if((self.mapSettings.respawn or "timelimit") == "timelimit") then
		respawn = tonumber(self.mapSettings.respawntime) or 10
	end
	self:setRespawn(respawn, self.isDM)
	
	local gm = tobool(self.mapSettings.ghostmode)
	self:setGhostMode(gm)
	
	local duration = tonumber(self.mapSettings.duration) or 5*60
	self:setTimeLimit(duration*1000)
	
	self.readyPlayers = 0
	for i, player in ipairs(self.players) do
		player:onMapStart()
		player:triggerEvent("onClientInitGame", self.room, self.mapInfo, false, self.timeLimit)
	end
	
	-- Creating vehcile and warping player in this event results in Network Trouble...
	TimerMgr.createTimerFor(self):set(self.spawnAllPlayers, 50, 1, self)
	
	self:changeState("waiting")
	self.waitTimer = TimerMgr.createTimerFor(self):set(self.startCountDown, 8000, 1, self)
end

function Game:onMapStop()
	TimerMgr.destroyTimerFor(self.mapInfo)
	
	self:stopGame("mapchange")
	self:changeState("idle")
	
	self.checkpoints:onMapStop()
	self.pickups:onMapStop()
	self.spawnpoints:onMapStop()
	
	for i, player in ipairs(self.players) do
		player:onMapStop()
	end
	
	assert(self.activeCount == 0)
	assert(self.finishedCount == 0)
end

function Game:onPlayerReady(player)
	self.readyPlayers = (self.readyPlayers or 0) + 1
	if(self.state == "waiting" and self.readyPlayers == #self.players) then
		self.waitTimer:destroy()
		self:startCountDown()
	elseif(self.state == "running") then
		TimerMgr.createTimerFor(self, player):set(player.setFrozen, 1000, 1, player, false)
	end
end

function Game:startCountDown()
	self:changeState("countdown")
	self.counter = 3
	TimerMgr.createTimerFor(self):set(self.countDown, 1000, 4, self)
end

function Game:countDown()
	triggerEvent("onGameCountdown", self.room, self.counter)
	self:triggerClientEvent("onClientGameCountdown", self.room, self.counter)
	
	if(self.counter == 0) then
		self:startGame()
	else
		self.counter = self.counter - 1
	end
end

function Game:startGame()
	if(self.state == "running") then return end
	
	self:changeState("running")
	self.startTime = getTickCount()
	
	for i, player in ipairs(self.players) do
		player:onGameStart()
	end
	
	triggerEvent("onGameStart", self.room)
	self:triggerClientEvent("onClientGameStart", self.room)
	
	self:updateRanks()
	if(self.isRace) then
		TimerMgr.createTimerFor(self):set(self.updateRanks, 1000, 0, self)
	end
	
	if(self.timeLimit) then
		TimerMgr.createTimerFor(self):set(self.stopGame, self.timeLimit, 1, self, "timesup")
	end
end

function Game:stopGame(reason, resStop)
	if(self.state == "stopped") then return end
	
	TimerMgr.destroyTimerFor(self)
	
	if(self.state == "running") then
		for i, player in ipairs(self.players) do
			player:onGameStop()
		end
		
		triggerEvent("onGameStop", self.room, reason)
		if(not resStop) then
			self:triggerClientEvent("onClientGameStop", self.room, reason)
		end
	end
	
	self:changeState("stopped")
end

function Game:getTimePassed()
	if(self.state ~= "running") then
		--outputDebugString("getTimePassed - state="..self.state, 2)
		return false
	end
	
	return getTickCount() - self.startTime
end

function Game:updateRanks()
	table.sort(self.players)
	
	for i, player in ipairs(self.players) do
		if(self.isRace or (not self.respawn and not player.alive)) then
			player:setRank(i)
		else
			player:setRank(false)
		end
	end
end

function Game:onPlayerWin(player)
	local timePassed = self:getTimePassed()
	triggerEvent("onPlayerWin", player.el, player.rank, timePassed)
	self:triggerClientEvent("onClientPlayerWin", player.el, player.rank, timePassed)
end

-- called for Race and DM
function Game:onPlayerFinish(player)
	triggerEvent("onPlayerFinish", player.el)
	
	if(self.finishedCount == 1) then
		self:onPlayerWin(player)
		
		if(self.activeCount == 0) then
			self:stopGame("noplayers")
		elseif(self.isRace) then
			TimerMgr.createTimerFor(self):set(self.stopGame, 30000, 1, self, "playerwon")
		elseif(self.activePlayers == 1) then -- winner of DM
			self:stopGame("playerwon")
		end
	else
		local timePassed = self:getTimePassed()
		local secPassed = timePassed/1000
		outputChatBox(player:getName().." has finished! Time: "..("%u:%02u"):format(secPassed/60, secPassed%60))
	end
end

function Game:onPlayerWasted(player)
	--outputDebugString("active "..self.activeCount, 3)
	
	if(self.respawn) then
		TimerMgr.createTimerFor(self, player.el):set(self.spawnPlayer, self.respawn*1000, 1, self, player)
	elseif(self.activeCount == 1 and not self.isRace) then
		local activePlayers = self:getActivePlayers()
		assert(#activePlayers == 1)
		local winner = activePlayers[1]
		self:onPlayerWin(winner)
		
		if(not self.isDM) then
			self:stopGame("playerwon")
		end
	elseif(self.activeCount == 0) then
		self:stopGame("noplayers")
	end
end

function Game:destroy(resStop)
	if(self.state == "running") then
		self:stopGame("destroy", resStop)
	end
	
	for i, player in ipairs(self.players) do
		self:removePlayer(player)
		player:destroy()
	end
	
	self.checkpoints:destroy()
	self.pickups:destroy()
	self.spawnpoints:destroy()
	TimerMgr.destroyTimerFor(self)
	
	Game.roomToGame[self.room] = nil
end

function Game.create(room)
	local self = setmetatable({}, Game.__mt)
	self.room = room
	self.dim = getElementDimension(room)
	self.players = {}
	self.activeCount = 0
	self.finishedCount = 0
	self.state = "unknown"
	self.checkpoints = Checkpoints.create(self)
	self.pickups = Pickups.create(self)
	self.spawnpoints = SpawnPoints.create(self)
	
	Game.roomToGame[room] = self
	self:changeState("idle")
	--outputChatBox("WTF: "..getElementID(room))
	for i, playerEl in ipairs(getRoomPlayers(room)) do
		local player = Player.elMap[playerEl]
		assert(not player)
		--outputChatBox(getPlayerName(playerEl).." - adding")
		Player.create(playerEl, self)
	end
	
	return self
end

Game.__mt = {__index = Game}

addEventHandler("onPlayerChangeRoom", g_Root, function(room)
	local game = Game.roomToGame[room]
	local player = Player.elMap[source]
	if(not player and not game) then return end
	
	if(not player) then
		player = Player.create(source, game)
	elseif(not game) then
		player:destroy()
	else
		player:changeGame(game)
	end
end)

addEventHandler("onRoomMapStart", g_Root, function()
	local game = Game.roomToGame[source]
	if(not game) then return end
	
	game:onMapStart()
end)

addEventHandler("onRoomMapStop", g_Root, function()
	local game = Game.roomToGame[source]
	if(not game) then return end
	
	game:onMapStop()
end)

addEventHandler("onElementDestroy", g_Root, function()
	local game = Game.roomToGame[source]
	if(not game) then return end
	game:destroy()
end)
