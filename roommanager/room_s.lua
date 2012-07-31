local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_TransferSpeed = 8*1024*1024

g_Rooms = {}
g_ElementToRoom = {}

-- Room CLASS

Room = {}

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

function Room:loadSettings(node)
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		if(name == "setting" and attr.name and attr.value) then
			local k = attr.name:gsub("^[#%*]", "")
			local v = fromJSON(attr.value) or attr.value
			self.settings[k] = v
		end
	end
end

function Room:sendMap(player)
	--outputChatBox("sendmap "..tostring(player.res_root))
	assert(player.res_root and isElement(player.res_root))
	triggerLatentClientEvent(player.el, "onMapInit", g_TransferSpeed, player.res_root, self.dim, self.settings, self.map_size)
	
	for i, file in ipairs(self.files) do
		for i, block in ipairs(file.blocks) do
			triggerLatentClientEvent(player.el, "onFileTransfer", g_TransferSpeed, player.res_root, file.path, file.type, i, #file.blocks, block)
		end
	end
	
	triggerLatentClientEvent(player.el, "onMapStartReq", g_TransferSpeed, player.res_root)
end

function Room:loadMapFiles()
	local node = xmlLoadFile(self.map_path.."/meta.xml")
	if(not node) then
		outputDebugString("Failed to load meta", 1)
		return false
	end
	
	self.settings = {
		gamespeed = 1,
		time = "12:0",
		weather = 0,
		gravity = 0.008,
		waveheight = 0 }
	self.files = {}
	self.map_size = 0
	
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		if(name == "script" and attr.src and attr.type ~= "client") then
			outputDebugString("Server side scripts are not supported. Ignoring "..attr.src, 2)
		elseif((name == "map" or name == "script" or name == "file") and attr.src) then
			local file = {path = attr.src, type = name}
			file.blocks, file.size = loadFile(self.map_path.."/"..attr.src)
			if(file.blocks) then
				table.insert(self.files, file)
				self.map_size = self.map_size + file.size
			else
				outputDebugString("Failed to load "..attr.src, 1)
			end
		elseif(name == "settings") then
			self:loadSettings(subnode)
		end
	end
	
	xmlUnloadFile(node)
	return true
end

function Room:startMap(path)
	-- Stop old map
	self:stopMap()
	
	self.map_path = path
	outputDebugString("Starting map "..path, 3)
	
	-- Load map files
	if(not self:loadMapFiles()) then
		return false
	end
	
	for i, player in ipairs(self.players) do
		player:reloadMap()
	end
	
	return true
end

function Room:stopMap()
	if(not self.map_path) then
		return false
	end
	
	outputDebugString("Stopping map", 3)
	
	self.map_path = false
	self.files = false
	self.map = false
	
	for i, player in ipairs(self.players) do
		player:reloadMap()
	end
	
	return true
end

function Room:loadMapElements(path)
	local node = xmlLoadFile(self.map_path.."/"..path)
	if(not node) then
		return false
	end
	
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		if(not self.map[name]) then
			self.map[name] = {}
		end
		
		table.insert(self.map[name], attr)
	end
	
	xmlUnloadFile(node)
end

function Room:getMapElements(type)
	if(not self.map) then
		self.map = {}
		for i, file in ipairs(self.files) do
			if(file.type == "map") then
				self:loadMapElements(file.path)
			end
		end
	end
	
	if(type) then
		return self.map[type]
	else
		return self.map
	end
end

function Room:addPlayer(player)
	table.insert(self.players, player)
	
	if(self.map_path) then
		player:reloadMap()
	end
end

function Room:removePlayer(player)
	for i, player2 in ipairs(self.players) do
		if(player2 == player) then
			table.remove(self.players, i)
			player:reloadMap()
			break
		end
	end
end

function Room:getPlayers()
	return self.players
end

function Room:destroy(ignore_el)
	self:stopMap()
	g_Rooms[self.id] = nil
	g_ElementToRoom[self.el] = nil
	
	if(not ignore_el) then
		destroyElement(self.el)
	end
end

function Room:create(id)
	assert(id and id:len() > 0)
	
	if(g_Rooms[id]) then
		return g_Rooms[id]
	end
	
	local room = setmetatable({}, Room.__mt)
	room.id = id
	room.el = createElement("gameroom", id)
	room.players = {}
	room.dim = 1
	setElementDimension(room.el, room.dim)
	
	g_Rooms[id] = room
	g_ElementToRoom[room.el] = room
	return room
end

Room.__mt = {__index = Room}
