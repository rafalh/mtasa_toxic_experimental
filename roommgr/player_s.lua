Player = {}
Player.elMap = {}
Player.__mt = {__index = Player}

addEvent("onPlayerChangeRoom")
addEvent("roommgr_onPlayerReady")

function Player:setRoom(room)
	--outputChatBox("setRoom "..tostring(room))
	
	if(self.room == room) then
		return true
	end
	
	if(self.room) then
		if(self.mapStarted) then
			assert(self.room.res.root)
			triggerClientEvent(self.el, "onMapStopReq", self.room.res.root)
		end
		
		self.room:removePlayer(self)
	end
	
	self.room = room
	self.mapReady = self.readyRooms[room]
	
	if(room) then
		room:addPlayer(self)
		setElementData(self.el, "roomid", room.id)
		if(room.mapInfo and self.mapReady) then
			room:sendMap(self)
		end
		setElementParent(self.el, room.el)
	else
		removeElementData(self.el, "roomid")
		setElementParent(self.el, g_Root)
	end
	
	triggerEvent("onPlayerChangeRoom", self.el, room and room.el)
	for playerEl, player in pairs(Player.elMap) do
		if(player.ready) then
			triggerClientEvent(playerEl, "roommgr_onPlayerChangeRoom", self.el, room and room.el)
		end
	end
	
	return true
end

function Player:onMapReady(room)
	self.readyRooms[room] = true
	if(room == self.room) then
		self.mapReady = true
		if(room.mapInfo) then
			room:sendMap(self)
		end
	end
end

function Player:onMapStart()
	self.mapStarted = true
	setElementData(self.el, "room.mapStarted", true)
	triggerEvent("onPlayerMapStarting", self.el, self.room.el)
end

function Player:onMapStop()
	self.mapReady = false
	self.readyRooms[self.room] = nil
	self.mapStarted = false
	removeElementData(self.el, "room.mapStarted")
end

function Player:getName(colorCodes)
	local name = getPlayerName(self.el)
	if(colorCodes) then
		return name
	end
	return name:gsub ( "#%x%x%x%x%x%x", "" )
end

function Player:destroy()
	self:setRoom(false)
	self.readyRooms = {}
	
	Player.elMap[self.el] = nil
end

function Player:create(el)
	local self = setmetatable({}, Player.__mt)
	
	self.el = el
	self.readyRooms = {}
	self.ready = false
	self:setRoom(false)
	
	Player.elMap[el] = self
	return self
end

addEventHandler("roommgr_onPlayerReady", g_ResRoot, function()
	local player = Player.elMap[client]
	if(not player) then return end
	player.ready = true
end)
