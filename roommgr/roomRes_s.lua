RoomRes = {}
RoomRes.__mt = {__index = RoomRes}
RoomRes.rootToRoom = {}

function RoomRes:start()
	if(not self.res or self.stopping) then
		-- delay starting
		--outputDebugString("Resource start has been delayed", 3)
		self.startQueued = true
		return true
	end
	
	self.startQueued = false
	
	local resState = getResourceState(self.res)
	if(resState == "loaded" or resState == "stopping") then
		self.room:onMapResReady()
		
		if(not startResource(self.res)) then
			outputDebugString("startResource failed", 2)
			return false
		end
	else
		assert(false, "Wrong resource state "..tostring(resState))
	end
	
	local resState = getResourceState(self.res)
	self.root = getResourceRootElement(self.res)
	assert(isElement(self.root))
	RoomRes.rootToRoom[self.root] = self.room
	setElementData(self.root, "roomid", self.room.id)
	self.room:onMapResStart()
	--outputDebugString("Room resource started "..self.room.id..": "..tostring(self.root).." state "..resState, 3)
	
	return true
end

function RoomRes:stop()
	if(not self.res or self.stopping) then return false end
	
	local resState = getResourceState(self.res)
	if(resState ~= "running" and resState ~= "starting") then return end
	
	if(not stopResource(self.res)) then
		outputDebugString("stopResource failed", 2)
		return false
	end
	
	-- Stop happens after the scripts are done executing for this server frame
	RoomRes.rootToRoom[self.root] = nil
	self.root = false
	self.stopping = true
	self.timer = setTimer(function()
		assert(self.stopping)
		self.stopping = false
		self.timer = false
		local resState = getResourceState(self.res)
		if(resState ~= "loaded") then
			outputDebugString("Wrong resource state "..resState, 2)
			self:stop()
		else
			--self.res:onMapResStop()
			
			if(self.startQueued) then
				self:start()
			end
		end
	end, 300, 1)
	return true
end

function RoomRes:destroy()
	if(self.res and getResourceState(self.res) == "running") then
		stopResource(self.res)
		-- MTA doesn't allow resource removal here
		--setTimer(deleteResource, 50, 1, self.name)
	elseif(self.res) then
		deleteResource(self.name)
		self.res = false
	end
	
	if(self.root) then
		RoomRes.rootToRoom[self.root] = nil
	end
	
	self.stopping = false
	if(self.timer) then
		killTimer(self.timer)
		self.timer = false
	end
end

function RoomRes.create(room)
	local self = setmetatable({}, RoomRes.__mt)
	self.room = room
	
	local baseRes = getResourceFromName("roombase")
	assert(baseRes)
	
	self.name = room.id
	self.res = getResourceFromName(self.name)
	if(self.res) then
		if(getResourceState(self.res) == "running") then
			stopResource(self.res)
			self.res = false
			
			-- MTA doesn't allow resource removal here - delay it
			self.timer = setTimer(function()
				deleteResource(self.name)
				self.res = copyResource(baseRes, self.name)
				self.timer = false
				
				if(self.res and self.startQueued) then
					self:start()
				end
			end, 50, 1)
		else
			deleteResource(self.name)
			self.res = copyResource(baseRes, self.name)
		end
	else
		self.res = copyResource(baseRes, self.name)
	end
	
	return self
end
