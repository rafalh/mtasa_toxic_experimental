Player = {}

function Player:reloadMap()
	--outputChatBox("reloadMap")
	
	if(self.loading) then
		return true
	end
	
	if(not self.res) then
		self.res = PlayerRes.alloc()
		if(not self.res) then
			return false
		end
	end
	
	local status
	if(getResourceState(self.res) == "running") then
		status = restartResource(self.res)
	else
		status = startResource(self.res)
	end
	
	self.loading = status
	return status
end

function Player:setRoom(room)
	--outputChatBox("setRoom "..tostring(room))
	
	if(self.room == room) then
		return true
	end
	
	if(self.room) then
		self.room:removePlayer(self)
	end
	self.room = room
	if(self.room) then
		self.room:addPlayer(self)
	end
	return true
end

function Player:onMapReady()
	if(not self.room) then return end
	
	self.loading = false
	self.res_root = getResourceRootElement(self.res)
	self.room:sendMap(self)
end

function Player:destroy()
	if(self.res) then
		PlayerRes.free(self.res)
		self.res = false
	end
end

function Player:create(el)
	local player = setmetatable({}, Player.__mt)
	
	player.el = el
	player.res = false
	player.res_root = false
	player.loading = false
	
	return player
end

Player.__mt = {__index = Player}