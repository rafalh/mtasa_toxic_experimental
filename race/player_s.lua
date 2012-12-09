Player = {elMap = {}}
Player.__mt = {__index = Player}
Player.readyMap = {}

-- States: active, training, finished, dead, waiting, joined

function Player:spawn(sp)
	local x, y, z = tonumber(sp.posX), tonumber(sp.posY), tonumber(sp.posZ)
	local rx, ry, rz = tonumber(sp.rotX) or 0, tonumber(sp.rotY) or 0, tonumber(sp.rotation or sp.rotZ) or 0
	local vehModel = tonumber(sp.vehicle)
	if(not x or not y or not z or not vehModel) then
		outputDebugString("Invalid spawnpoint", 1)
		return false
	end
	
	if(self.spawnPoint) then
		self.spawnPoint.busy = false
	end
	self.spawnPoint = sp
	sp.busy = true
	spawnPlayer(self.el, x, y, z, 0, 0, 0, self.game.dim)
	
	-- set spectate mode before making player alive
	self:setSpectateMode(false)
	
	local veh = createVehicle(vehModel, x, y, z, rx, ry, rz)
	self:setVehicle(veh)
	self.alive = true
	self.spawnTime = getTickCount()
	self.deathTime = false
	self.winner = false
	
	setCameraTarget(self.el, self.el)
	fadeCamera(self.el, true)
	setPedStat(self.el, 160, 1000)
	setPedStat(self.el, 229, 1000)
	setPedStat(self.el, 230, 1000)
	toggleAllControls(self.el, true)
	toggleControl(self.el, "enter_exit", false)
	
	self:setVisible(true)
end

function Player:kill()
	if(not self.alive) then return end
	
	killPed(self.el)
end

function Player:getVehicle()
	assert(self.alive)
	
	local veh = getPedOccupiedVehicle(self.el)
	if(not veh) then
		if(not isElement(self.veh)) then
			self:kill()
		else
			warpPedIntoVehicle(self.el, self.veh)
			toggleControl(self.el, "enter_exit", false)
		end
	end
	return self.veh
end

function Player:setVehicle(veh)
	if(isElement(self.veh)) then
		destroyElement(self.veh)
	end
	
	self.veh = veh
	if(veh) then
		setElementDimension(self.veh, self.game.dim)
		warpPedIntoVehicle(self.el, self.veh)
		toggleControl(self.el, "enter_exit", false)
	end
end

function Player:getPosition()
	local veh = self:getVehicle()
	local x, y, z = getElementPosition(veh)
	return {x, y, z}
end

function Player:setBlipEnabled(enabled)
	if(not enabled and self.blip) then
		destroyElement(self.blip)
		self.blip = false
	elseif(enabled and not self.blip) then
		local pos = self:getPosition()
		self.blip = createBlip(pos[1], pos[2], pos[3], 0, 1.5, 196, 196, 196, 255, 1)
		setElementDimension(self.blip, self.game.dim)
		attachElements(self.blip, self.el)
	end
end

function Player:setFrozen(frozen)
	if(not self.alive) then return end
	
	local veh = self:getVehicle()
	setElementFrozen(veh, frozen)
	if(not frozen and self.spawnPoint) then
		self.spawnPoint.busy = false
		self.spawnPoint = false
	end
end

function Player:triggerEvent(...)
	if(not self.ready) then
		table.insert(self.queuedEvents, {...})
		return false
	end
	
	return triggerClientEvent(self.el, ...)
end

function Player:setActive(active)
	if(self.active == active) then return end
	
	self.active = active
	if(self.active) then
		self.game.activeCount = self.game.activeCount + 1
		self:changeState("active")
	else
		self.game.activeCount = self.game.activeCount - 1
	end
end

function Player:setFinished(finished)
	if(self.finished == finished) then return end
	
	self.finished = finished
	if(self.finished) then
		self.game.finishedCount = self.game.finishedCount + 1
		self.finishedTime = getTickCount()
		self:changeState("finished")
	else
		self.game.finishedCount = self.game.finishedCount - 1
		self.finishedTime = false
	end
end

function Player:setRank(rank)
	self.rank = rank
	if(rank) then
		setElementData(self.el, "race.rank", rank)
	else
		removeElementData(self.el, "race.rank")
	end
end

function Player:setAlpha(alpha)
	if(self.veh) then
		setElementAlpha(self.veh, alpha)
	end
	setElementAlpha(self.el, alpha)
end

function Player:setVisible(visible)
	local alpha = self.ghost and 196 or 255
	if(not visible) then
		alpha = 0
	end
	self:setAlpha(alpha)
	self:setBlipEnabled(visible)
end

function Player:setGhost(isGhost)
	self.ghost = isGhost
	setElementData(self.el, "race.ghost", isGhost)
	
	if(self.alive) then
		self:setAlpha(isGhost and 196 or 255)
	end
end

function Player:changeState(newState)
	if(newState == self.state) then return end
	
	if(self.stateObj) then
		TimerMgr.destroyTimerFor(self.stateObj)
	end
	
	self.state = newState
	self.stateObj = {}
end

function Player:getName(colorCodes)
	local name = getPlayerName(self.el)
	if(colorCodes) then
		return name
	end
	return name:gsub ( "#%x%x%x%x%x%x", "" )
end

function Player:savePos()
	local veh = self:getVehicle()
	if(not veh or not self.alive) then return false end
	
	self.traceSize = self.traceSize + 1
	triggerClientEvent(self.el, "race_saveVehicleData", veh)
	return true
end

function Player:removeLastPos()
	if(self.traceSize <= 0) then return end
	self.traceSize = self.traceSize - 1
	triggerClientEvent(self.el, "race_removeVehicleData", self.el)
end

function Player:loadPos(remove)
	local veh = self:getVehicle()
	if(not veh or not self.alive) then
		return false
	end
	
	if(remove) then
		self.traceSize = self.traceSize - 1
	end
	
	respawnVehicle(veh)
	triggerClientEvent(self.el, "race_loadVehicleData", veh, remove)
	return true
end

function Player:setCp(cp)
	self.cp = cp
	if(cp) then
		setElementData(self.el, "race.cp", cp)
	else
		removeElementData(self.el, "race.cp")
	end
end

function Player:unfreezeAfterRespawn()
	if(not self.alive) then return end
	toggleAllControls (self.el,true, true, false )
	self:setFrozen(false)
	--setTimer(function() self:loadPos() end,50,1)
	self:loadPos()
end

function Player:onMapStart()
end

function Player:onMapStop()
	self.alive = false
	self.mapReady = false
	self.traceSize = 0
	self.cp = false
	self.spawnPoint = false
	
	self:setActive(false)
	self:setFinished(false)
	self:setRank(false)
	self:setVehicle(false)
	self:setCp(false)
	self:setBlipEnabled(false)
	self:setSpectateMode(false)
	
	fadeCamera(self.el, false)
end

function Player:onMapReady()
	self.mapReady = true
	self.game:onPlayerReady(self)
	fadeCamera(self.el, true)
end

function Player:onGameStart()
	if(self.mapReady) then
		self:setFrozen(false)
	else
		outputDebugString("Map is not ready!", 2)
	end
end

function Player:onGameStop()
	toggleAllControls(self.el, false, true, false)
	self:changeState("idle")
end

function Player:changeGame(game)
	if(self.game) then
		self.game:removePlayer(self)
		self:onMapStop()
	end
	
	TimerMgr.destroyTimerFor(self)
	
	self.game = game
	if(self.game) then
		self.game:addPlayer(self)
	end
end

function Player:setTrainingMode(enabled)
	self.training = enabled
	if(enabled) then
		self:changeState("training")
	end
end

function Player:onFinish()
	self:setActive(false)
	self:setFinished(true)
	
	-- destroy vehicle after 1 second
	TimerMgr.createTimerFor(self, self.game):set(self.setSpectateMode, 1000, 1, self, true)
	toggleAllControls(self.el, false, true, false)
	
	self.game:onPlayerFinish(self)
end

function Player:onWasted()
	if(not self.alive) then return end
	
	self.alive = false
	self.deathTime = getTickCount()
	if(not self.game.respawn) then
		self:setActive(false)
	end
	
	self:changeState("dead")
	TimerMgr.createTimerFor(self.stateObj):set(self.setVisible, 3000, 1, self, false)
	TimerMgr.createTimerFor(self.stateObj):set(self.setSpectateMode, 3000, 1, self, true)
	
	if(self.spawnPoint) then
		self.spawnPoint.busy = false
		self.spawnPoint = false
	end
	
	if(getTickCount() - self.spawnTime < 3000) then
		outputDebugString("Removing vehicle data", 3)
		self:removeLastPos()
	end
	
	self.game:onPlayerWasted(self)
end

function Player:onRespawnReq()
	if(self.alive or self.game.state ~= "running" or not self.game.isDM or type(self.game.respawn) == "number") then return end
	self.game:spawnPlayer(self, true)
end

function Player:destroy()
	Player.elMap[self.el] = nil
	
	self:changeState("destroying")
	
	if(self.spawnPoint) then
		self.spawnPoint.busy = false
		self.spawnPoint = false
	end
	
	self:setActive(false)
	self:setFinished(false)
	self:setVehicle(false)
	self:setBlipEnabled(false)
	
	TimerMgr.destroyTimerFor(self)
	
	if(self.game) then
		self.game:removePlayer(self)
		self.game = false
	end
end

function Player.create(el, game)
	assert(not Player.elMap[el])
	assert(el and game)
	
	local self = setmetatable({}, Player.__mt)
	self.el = el
	self.game = game
	self.ready = Player.readyMap[el]
	self.alive = false
	self.active = false
	self.finished = false
	self.mapReady = getElementData(self.el, "room.mapStarted")
	self.queuedEvents = {}
	self.traceSize = 0
	self.state = "unknown"
	
	if(Player.readyMap[el]) then
		self:changeState("joined")
	else
		self:changeState("joining")
	end
	
	self:setSpectateMode(false)
	self:setCp(game.isRace and 0)
	
	self.game:addPlayer(self)
	
	Player.elMap[el] = self
	return self
end

function Player.__mt:__lt(player)
	if(self.game.isRace) then
		if(self.finished and player.finished) then
			return self.finishedTime < player.finishedTime
		else
			return self.cp > player.cp -- TODO: improve check when cp is equal
		end
	elseif(not self.game.respawn) then
		if(self.deathTime and player.deathTime) then
			return self.deathTime > player.deathTime
		elseif(self.alive and not player.alive) then
			return true -- alive is better
		end
	end
	return false
end

addEvent("race_onPlayerReady", true)
addEventHandler("race_onPlayerReady", g_Root, function()
	Player.readyMap[client] = true
	
	local player = Player.elMap[client]
	if(player) then
		player.ready = true
		
		for i, event in ipairs(player.queuedEvents) do
			triggerClientEvent(player.el, unpack(event))
		end
		player.queuedEvents = {}
	end
end)

addEvent("race_onRespawnReq", true)
addEventHandler("race_onRespawnReq", g_ResRoot, function()
	local player = Player.elMap[client]
	if(not player) then return end
	player:onRespawnReq()
end)

addEvent("onPlayerMapStarting")
addEventHandler("onPlayerMapStarting", g_Root, function()
	local player = Player.elMap[source]
	if(not player) then return end
	player:onMapReady()
end)

addEventHandler("onPlayerQuit", g_Root, function()
	Player.readyMap[source] = nil
end)

addEventHandler("onPlayerWasted", g_Root, function()
	local player = Player.elMap[source]
	if(not player) then return end
	player:onWasted()
end)