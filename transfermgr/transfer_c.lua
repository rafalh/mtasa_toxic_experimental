addEvent("transfer_onInit", true)
addEvent("transfer_onCancel", true)
addEvent("transfer_onBlock", true)

local TIMEOUT_MS = 20000

Transfer = {}
Transfer.__mt = {__index = Transfer}
Transfer.elMap = {}
Transfer.bytesToDo = 0
Transfer.bytesDone = 0

function Transfer:completeItem(item)
	self.items[item.checksum] = nil
	if(item.destPath) then
		if(item.cache) then
			fileCopy(item.checksum, item.destPath, true)
		else
			local file = fileCreate(item.destPath)
			if(file) then
				fileWrite(file, item.buf)
				fileClose(file)
			end
		end
	end
	
	--outputDebugString("Item transfer completed: "..item.checksum, 3)
	triggerEvent("onItemTransferComplete", self.el, item.destPath or item.buf, unpack(item.args))
	
	if(not next(self.items)) then
		--outputDebugString("Transfer completed", 3)
		triggerEvent("onTransferComplete", self.el)
		triggerServerEvent("transfer_onComplete", self.el)
		self:destroy()
	end
end

function Transfer:onInit(itemsInfo)
	resetTimer(self.timer)
	
	local checksums = {}
	local completedItems = {}
	local bytesToDo = 0
	for i, info in ipairs(itemsInfo) do
		local item = {}
		item.size = info[1]
		item.bytesWritten = 0
		item.checksum = info[2]
		item.destPath = info[3]
		item.cache = info[4]
		item.args = info[5]
		item.buf = ""
		
		self.items[item.checksum] = item
		
		local cached = false
		local file = fileExists(item.checksum) and fileOpen(item.checksum, true)
		if(file) then
			local size = fileGetSize(file)
			local buf = ((size > 0) and fileRead(file, size)) or ""
			local checksum = md5(buf)
			if(buf:len() == item.size and item.checksum == checksum) then
				cached = true
				
				if(not item.destPath) then
					item.buf = buf
				end
			else
				outputDebugString("Cache is outdated ("..buf:len().." vs "..item.size..", "..checksum.." vs "..item.checksum..")", 2)
			end
			fileClose(file)
		end
		
		if(not cached) then
			if(fileExists(item.checksum)) then
				fileDelete(item.checksum)
			end
			
			bytesToDo = bytesToDo + item.size
			table.insert(checksums, item.checksum)
		else
			-- dont complete here or server will get many onTransferComplete events
			table.insert(completedItems, item)
		end
	end
	
	triggerServerEvent("transfer_onReady", self.el, checksums)
	
	for i, item in ipairs(completedItems) do
		self:completeItem(item)
	end
	
	self.bytesToDo = bytesToDo
	Transfer.bytesToDo = Transfer.bytesToDo + bytesToDo
end

function Transfer:onBlock(block, checksum)
	local item = self.items[checksum]
	if(not item) then
		outputDebugString("Transfer block ignored!", 2)
		return
	end
	
	resetTimer(self.timer)
	
	if(item.cache) then
		local file
		if(fileExists(checksum)) then
			file = fileOpen(checksum)
			fileSetPos(file, fileGetSize(file))
		else
			file = fileCreate(checksum)
		end
		
		if(not file) then return end
		
		fileWrite(file, block)
		fileClose(file)
	end
	
	if(not item.cache or not item.destPath) then
		item.buf = item.buf..block
	end
	
	item.bytesWritten = item.bytesWritten + block:len()
	assert(item.bytesWritten <= item.size)
	
	self.bytesDone = self.bytesDone + block:len()
	Transfer.bytesDone = Transfer.bytesDone + block:len()
	
	if(item.bytesWritten == item.size) then
		self:completeItem(item)
	end
end

function Transfer:onTimedOut()
	outputChatBox("Transfer timed out!", 255, 0, 0)
	triggerServerEvent("transfer_onFailed", self.el)
	self:destroy()
end

function Transfer:destroy()
	self.items = {}
	if(self.timer) then
		killTimer(self.timer)
		self.timer = false
	end
	
	Transfer.bytesDone = Transfer.bytesDone - self.bytesDone
	Transfer.bytesToDo = Transfer.bytesToDo - self.bytesToDo
	
	Transfer.elMap[self.el] = nil
end

function Transfer.create(el)
	local self = setmetatable({}, Transfer.__mt)
	self.el = el
	self.items = {}
	self.bytesToDo = 0
	self.bytesDone = 0
	self.timer = setTimer(function()
		self:onTimedOut()
	end, TIMEOUT_MS, 1)
	Transfer.elMap[self.el] = self
	return self
end

addEventHandler("transfer_onInit", root, function(info)
	if(Transfer.elMap[source]) then
		outputDebugString("Invalid transfer!", 2)
		return
	end
	local transfer = Transfer.create(source)
	transfer:onInit(info)
end)

addEventHandler("transfer_onBlock", root, function(block, checksum)
	local transfer = Transfer.elMap[source]
	if(not transfer) then
		outputDebugString("Invalid transfer!", 2)
		return
	end
	transfer:onBlock(block, checksum)
end)

addEventHandler("transfer_onCancel", root, function()
	local transfer = Transfer.elMap[source]
	if(not transfer) then
		outputDebugString("Invalid transfer!", 2)
		return
	end
	transfer:destroy()
end)
