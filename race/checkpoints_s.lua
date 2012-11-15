local g_Root = getRootElement()

-- Checkpoints CLASS
Checkpoints = {}

addEvent("race_onPlayerReachCp", true)

function Checkpoints:load()
	local room = self.game.room
	local list = getRoomMapElements(room, "checkpoint")
	self.list = {}
	if(not list or #list == 0) then return end
	
	local idToCp = {}
	for i, cp in ipairs(list) do
		if(cp.id) then
			idToCp[cp.id] = cp
		end
	end
	
	local cp = list[1]
	repeat
		table.insert(self.list, cp)
		cp = idToCp[cp.nextid or false]
	until(not cp)
	
	--outputChatBox("Loaded "..#self.list.." checkpoints (server-side)")
end

function Checkpoints:onPlayerReachCp(player, idx)
	if(not player.alive) then return end
	
	local cp = self.list[idx]
	if(not cp) then return end
	
	local vehModel = tonumber(cp.vehicle)
	if(vehModel) then
		local veh = player:getVehicle()
		setElementModel(veh, vehModel)
	end
	
	player:setCp(idx)
	player:savePos()
	self.game:updateRanks()
	
	triggerEvent("onPlayerReachCheckpoint", player.el, idx, player.game:getTimePassed())
	
	if(idx == #self.list) then
		triggerEvent("onPlayerFinish", player.el, player.rank)
		player:onFinish()
	end
end

function Checkpoints:onMapStart()
	self:load()
	
	self.game.isRace = (#self.list > 0)
	
	if(not self.game.isRace) then return end
	
	for i, player in ipairs(self.game.players) do
		player:setCp(0)
	end
end

function Checkpoints:onMapStop()
	for i, player in ipairs(self.game.players) do
		player:setCp(false)
	end
end

function Checkpoints:destroy()
	self.list = {}
	self.game = false
end

function Checkpoints.create(game)
	local self = setmetatable({}, Checkpoints.__mt)
	self.list = {}
	self.game = game
	return self
end

Checkpoints.__mt = {__index = Checkpoints}

addEventHandler("race_onPlayerReachCp", g_Root, function(idx)
	local player = Player.elMap[source]
	local game = player and player.game
	if(not game) then return end
	
	game.checkpoints:onPlayerReachCp(player, idx)
end)
