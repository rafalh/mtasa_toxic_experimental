Transfer = {}
Transfer.__mt = {__index = Transfer}
Transfer.elMap = {}

local TRANSFER_SPEED = 8*1024*1024
local BLOCK_SIZE = 65500

addEvent("transfer_onReady", true)
addEvent("transfer_onComplete", true)
addEvent("transfer_onFailed", true)

function Transfer:loadFile(path)
	local file = fileOpen(path, true)
	if(not file) then
		return false
	end
	
	local size = fileGetSize(file)
	local buf = fileRead(file, size)
	fileClose(file)
	
	local info = {}
	info.size = size
	info.checksum = md5(buf)
	info.blocks = {}
	
	while(buf:len() > 0) do
		local block = buf:sub(1, BLOCK_SIZE)
		buf = buf:sub(block:len() + 1)
		table.insert(info.blocks, block)
	end
	
	return info
end

function Transfer:loadData(data)
	local info = {}
	info.size = data:len()
	info.checksum = md5(data)
	info.blocks = {}
	
	while(data:len() > 0) do
		local block = data:sub(1, BLOCK_SIZE)
		data = data:sub(block:len() + 1)
		table.insert(info.blocks, block)
	end
	
	return info
end

function Transfer:addFile(srcPath, destPath, ...)
	local info = self:loadFile(srcPath)
	if(not info) then return false end
	
	info.destPath = destPath
	info.cache = true
	info.args = {...}
	table.insert(self.items, info)
	return true
end

function Transfer:addData(data, cache, ...)
	local info = self:loadData(data)
	if(not info) then return false end
	
	info.destPath = false
	info.cache = cache
	info.args = {...}
	table.insert(self.items, info)
	return true
end

function Transfer:start(player)
	if(self.players[player]) then
		outputDebugString("Invalid player", 2)
		return false
	end
	
	local info = {}
	for i, item in ipairs(self.items) do
		table.insert(info, {item.size, item.checksum, item.destPath, item.cache, item.args})
	end
	if(not triggerClientEvent(player, "transfer_onInit", self.el, info)) then
		outputDebugString("triggerClientEvent failed for "..getPlayerName(player), 1)
		return false
	end
	
	self.players[player] = {}
	return true
end

function Transfer:stop(player)
	if(not self.players[player]) then
		outputDebugString("Invalid player", 2)
		return
	end
	
	for i, handle in ipairs(self.players[player]) do
		cancelLatentEvent(player, handle)
	end
	if(getResourceState(resource) ~= "stopping") then
		triggerClientEvent(player, "transfer_onCancel", self.el)
	end
	self.players[player] = nil
end

function Transfer:destroy(ignoreEl)
	for player, _ in pairs(self.players) do
		self:stop(player)
	end
	
	Transfer.elMap[self.el] = nil
	if(not ignoreEl) then
		destroyElement(self.el)
	end
end

function Transfer:sendItem(player, item)
	for i, block in ipairs(item.blocks) do
		if(not triggerLatentClientEvent(player, "transfer_onBlock", TRANSFER_SPEED, self.el, block, item.checksum)) then
			outputDebugString("triggerLatentClientEvent failed", 2)
			return false
		end
		
		local handles = getLatentEventHandles(player)
		local handle = handles[#handles]
		assert(handle)
		table.insert(self.players[player], handle)
	end
	
	return true
end

function Transfer:onReady(player, checksums)
	if(not self.players[player]) then
		outputDebugString("Invalid player", 2)
		return
	end
	
	--outputDebugString("Transfer ready for "..getPlayerName(player), 3)
	
	for i, item in ipairs(self.items) do
		local found = false
		for i, checksum in ipairs(checksums) do
			if(item.checksum == checksum) then
				found = true
				break
			end
		end
		
		if(found) then
			self:sendItem(player, item)
		end
	end
end

function Transfer:onComplete(player)
	if(not self.players[player]) then
		outputDebugString("Invalid player", 2)
		return
	end
	
	outputDebugString("Transfer complete for "..getPlayerName(player), 3)
	
	triggerEvent("onTransferComplete", self.el, player)
	self.players[player] = nil
end

function Transfer:onFailed(player)
	outputDebugString("Transfer failed for "..getPlayerName(player), 1)
	for i, handle in ipairs(self.players) do
		local status = getLatentEventStatus(handle)
		if(status) then
			outputDebugString("Latent event "..tostring(handle).." - totalSize "..status.totalSize..", percentComplete "..status.percentComplete, 1)
		end
	end
end

function Transfer.create()
	local self = setmetatable({}, Transfer.__mt)
	self.items = {}
	self.players = {}
	self.el = createElement("transfer")
	
	Transfer.elMap[self.el] = self
	return self
end

addEventHandler("transfer_onReady", root, function(checksums)
	local transfer = Transfer.elMap[source]
	if(transfer) then
		transfer:onReady(client, checksums)
	else
		outputDebugString("Invalid transfer", 2)
	end
end)

addEventHandler("transfer_onComplete", root, function()
	local transfer = Transfer.elMap[source]
	if(transfer) then
		transfer:onComplete(client)
	else
		outputDebugString("Invalid transfer", 2)
	end
end)

addEventHandler("transfer_onFailed", root, function()
	local transfer = Transfer.elMap[source]
	if(transfer) then
		transfer:onFailed(client)
	else
		outputDebugString("Invalid transfer", 2)
	end
end)

addEventHandler("onElementDestroy", root, function()
	local transfer = Transfer.elMap[source]
	if(transfer) then
		transfer:destroy(true)
	end
end)
