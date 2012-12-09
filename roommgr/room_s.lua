local CACHE_MAPS = true

addEvent("onRoomMapStart")
addEvent("onRoomMapStop")

-- Room CLASS

Room = {}
Room.__mt = {__index = Room}
Room.list = {}
Room.elMap = {}
Room.dimToRoom = {}

for i = 1, 100 do
	-- Don't use dimensions 0-100
	Room.dimToRoom[i] = false
end

local function loadFile(path)
	local file = fileOpen(path, true)
	if(not file) then
		return false
	end
	
	local size = 0
	local blocks = {}
	while(not fileIsEOF(file)) do
		local block = fileRead(file, 65500)
		table.insert(blocks, block)
		
		size = size + block:len()
	end
	
	fileClose(file)
	return blocks, size
end

function Room:sendMap(player)
	outputDebugString("sendMap "..player:getName().." "..self.id, 3)
	triggerClientEvent(player.el, "onMapInit", self.res.root, self.dim, self.mapSettings, self.mapPath)
	assert(startTransfer(self.mapTransfer, player.el))
end

function Room:fixMapSettings()
	local defaultSettings = {
		gamespeed = 1,
		time = "12:0",
		weather = 0,
		gravity = 0.008,
		waveheight = 0 }
	
	for key, val in pairs(defaultSettings) do
		if(self.mapSettings[key] == nil) then
			self.mapSettings[key] = val
		end
	end
end

function Room:resetMap()
	self.mapSettings = {}
	self:fixMapSettings()
	
	self.mapEl = false
	self.mapPath = false
	self.files = {script = {}, map = {}, file = {}, config = {}}
	self.serverScripts = {}
	self.mapInfo = {}
	
	if(isElement(self.mapTransfer)) then
		destroyElement(self.mapTransfer)
	end
	self.mapTransfer = false
	
	removeElementData(self.el, "mapinfo")
end

local function copyFiles(srcPath, destPath, ignored)
	ignored = ignored or {}
	local filenames = fileFind(srcPath.."/*", "file")
	for i, filename in ipairs(filenames) do
		if(not ignored[filename]) then
			fileCopy(srcPath.."/"..filename, destPath.."/"..filename)
		end
	end
	
	local dirs = fileFind(srcPath.."/*", "directory")
	for i, dir in ipairs(dirs) do
		copyFiles(srcPath.."/"..dir, destPath.."/"..dir, ignored)
	end
end

local function deleteFiles(path, ignored)
	ignored = ignored or {}
	local filenames = fileFind(path.."/*", "file")
	for i, filename in ipairs(filenames) do
		if(not ignored[filename]) then
			fileDelete(path.."/"..filename)
		end
	end
	
	local dirs = fileFind(path.."/*", "directory")
	for i, dir in ipairs(dirs) do
		deleteFiles(path.."/"..dir, ignored)
	end
end

function Room:compressMap()
	local start = getTickCount()
	for elType, elList in pairs(self.mapEl) do
		local isBuiltIn = elType == "object" or elType == "marker" or elType == "vehicle" or elType == "vehicle"
		
		for i, elData in ipairs(elList) do
			if(elData.dimension == "0") then
				elData.dimension = nil
			end
			if(elData.interior == "0") then
				elData.interior = nil
			end
			if(elData.doublesided == "false") then
				elData.doublesided = nil
			end
			if(isBuiltIn) then
				-- Some Editor stuff
				elData.background = nil
				elData.border = nil
				elData.foreground = nil
				elData.framesFaded = nil
				elData.framesToFade = nil
				elData.height = nil
				elData.width = nil
				elData.state = nil
				elData.text = nil
				elData.x = nil
				elData.y = nil
			end
			for key, val in pairs(elData) do
				local num = tonumber(val)
				if(num) then
					elData[key] = num
				end
			end
		end
	end
	local dt = getTickCount() - start
	if(dt > 100) then
		outputDebugString("compressMap took "..dt.." ms", 2)
	end
end

function Room:onMapResReady()
	local ignored = {["_room_c.lua"] = true, ["_room_s.lua"] = true}
	deleteFiles(":"..self.res.name, ignored)
	copyFiles(self.mapFullPath, ":"..self.res.name, ignored)
	
	local meta = Meta.create(":"..self.res.name.."/meta.xml")
	if(not meta) then return end
	
	-- load data from meta.xml
	self.mapInfo = meta:getInfo()
	self.mapSettings = meta:getSettings()
	self:fixMapSettings()
	self.files = meta:removeClientFiles()
	self.serverScripts = meta:removeServerSideScripts()
	meta:addScript("_room_s.lua", "server")
	meta:addScript("_room_c.lua", "client")
	meta:destroy()
	
	-- add files to transfer
	local cachedFileTypes = {"file", "script"}
	for i, fileType in ipairs(cachedFileTypes) do
		local fileList = self.files[fileType]
		for i, path in ipairs(fileList) do
			local srcPath = self.mapFullPath.."/"..path
			local destPath = ":"..self.res.name.."/"..path
			addTransferFile(self.mapTransfer, srcPath, destPath)
		end
	end
	
	self.mapEl = {}
	for i, filename in ipairs(self.files.map) do
		self:loadMapElements(filename)
	end
	self:compressMap()
	
	local mapStr = toJSON(self.mapEl)
	local mapSize = mapStr:len()
	if(compressJSON) then
		local start = getTickCount()
		mapStr = compressJSON(mapStr)
		local dt = getTickCount() - start
		outputDebugString(("compressJSON took %u ms (ratio %.2f)"):format(dt, mapStr:len() / mapSize), 3)
	end
	
	addTransferData(self.mapTransfer, mapStr, CACHE_MAPS, self.id, "map")
	
	-- Synchronize map info
	setElementData(self.el, "mapinfo", self.mapInfo)
end

function Room:onMapResStart()
	setElementDimension(self.res.root, self.dim)
	triggerEvent("room_onStart", self.res.root, self.serverScripts)
	triggerEvent("onRoomMapStart", self.el, self.mapPath)
end

function Room:onTransferComplete(player)
	triggerClientEvent(player.el, "onMapStartReq", self.res.root, self.files)
end

function Room:verifyMap(path)
	-- TODO: better verification
	return fileExists(path.."/meta.xml")
end

function Room:startMap(path)
	-- Stop old map
	self:stopMap()
	self:resetMap()
	
	local fullPath = getMapFullPath(path)
	
	-- Check if map exists
	if(not self:verifyMap(fullPath)) then
		outputDebugString("Invalid map "..tostring(path), 2)
		return false
	end
	
	self.mapPath = path
	self.mapFullPath = fullPath
	self.mapTransfer = createTransfer()
	outputDebugString("Starting map "..self.mapPath.." in "..self.id, 3)
	
	-- Restart map resource
	if(not self.res:start()) then
		return false
	end
	
	return true
end

function Room:stopMap()
	if(not self.mapPath) then
		return false
	end
	
	outputDebugString("Stopping map in "..self.id, 3)
	triggerEvent("onRoomMapStop", self.el, self.mapInfo)
	
	for i, player in ipairs(self.players) do
		if(player.mapStarted) then
			player:onMapStop()
		end
	end
	
	self.res:stop()
	self:resetMap()
	
	return true
end

function Room:startGamemode(res)
	if(self.gamemode == res) then
		return true
	end
	
	self:stopGamemode()
	
	if(not res) then
		return true
	end
	
	if(getResourceState(res) ~= "running" and not startResource(res)) then
		outputDebugString("Failed to start gamemode", 2)
		return false
	end
	
	self.gamemode = res
	call(res, "startGamemodeInRoom", self.el)
	return true
end

function Room:stopGamemode()
	if(not self.gamemode) then
		return false
	end
	
	if(getResourceState(self.gamemode) == "running") then
		call(self.gamemode, "stopGamemodeInRoom", self.el)
	end
	self.gamemode = false
	return true
end

function Room:loadMapElements(path)
	local node = xmlLoadFile(self.mapFullPath.."/"..path)
	if(not node) then
		return false
	end
	
	if(not xmlNodeGetAttribute(node, "edf:definitions")) then
		self.mapInfo._MTARM = true
	else
		self.mapInfo._MTARM = nil
	end
	
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		if(not self.mapEl[name]) then
			self.mapEl[name] = {}
		end
		
		table.insert(self.mapEl[name], attr)
	end
	
	xmlUnloadFile(node)
end

function Room:getMapElements(type)
	if(not self.mapEl) then
		self.mapEl = {}
		for i, filename in ipairs(self.files.map) do
			self:loadMapElements(filename)
		end
	end
	
	if(type) then
		return self.mapEl[type] or {}
	else
		return self.mapEl
	end
end

function Room:addPlayer(player)
	-- Check if player is not in room yet
	for i, player2 in ipairs(self.players) do
		if(player2 == player) then
			return false
		end
	end
	
	-- Add player to the room
	table.insert(self.players, player)
	
	outputChatBox(player:getName().." joined "..self.id.." room!")
	
	return true
end

function Room:removePlayer(player)
	for i, player2 in ipairs(self.players) do
		if(player2 == player) then
			table.remove(self.players, i)
			
			outputChatBox(player:getName().." left "..self.id.." room!")
			if #self.players == 0 then
				self:stopMap()
				self:resetMap()
			end
			return true
		end
	end
	
	-- Not found
	return false
end

function Room:getPlayers()
	return self.players
end

function Room:destroy(ignoreEl)
	self:stopMap()
	self:stopGamemode()
	
	-- it is safe to remove players for table in loop
	for i, player in ipairs(self.players) do
		player:setRoom(false)
	end
	
	for el, player in pairs(Player.elMap) do
		player.readyRooms[self] = nil
	end
	
	self.res:destroy()
	self.res = false
	
	Room.list[self.id] = nil
	Room.elMap[self.el] = nil
	Room.dimToRoom[self.dim] = nil
	
	if(not ignoreEl) then
		destroyElement(self.el)
	end
end

function Room.create(id)
	assert(id and id:len() > 0)
	
	if(Room.list[id]) then
		return Room.list[id]
	end
	
	local self = setmetatable({}, Room.__mt)
	self.id = id
	self.el = createElement("game-room", id)
	self.players = {}
	
	self.dim = #Room.dimToRoom + 1
	Room.dimToRoom[self.dim] = self
	setElementDimension(self.el, self.dim)
	
	self.res = RoomRes.create(self)
	
	self:resetMap()
	
	Room.list[id] = self
	Room.elMap[self.el] = self
	return self
end

addEventHandler("onResourceStop", g_Root, function(res)
	for id, room in pairs(Room.list) do
		if(room.gamemode == res) then
			room.gamemode = false
		end
	end
end)

addEvent("onTransferComplete")
addEventHandler("onTransferComplete", root, function(playerEl)
	local player = Player.elMap[playerEl]
	if(not player or not player.room or source ~= player.room.mapTransfer) then return end
	player.room:onTransferComplete(player)
end)
