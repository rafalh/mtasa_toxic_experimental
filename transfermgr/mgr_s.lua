function createTransfer()
	local transfer = Transfer.create()
	assert(Transfer.elMap[transfer.el])
	return transfer.el
end

function addTransferFile(transferEl, srcPath, destPath, ...)
	local transfer = Transfer.elMap[transferEl]
	if(not transfer) then
		outputDebugString("Invalid transfer element "..tostring(transferEl), 2)
		return false
	end
	return transfer:addFile(srcPath, destPath, ...)
end

function addTransferData(transferEl, data, cache, ...)
	local transfer = Transfer.elMap[transferEl]
	if(not transfer) then
		outputDebugString("Invalid transfer element "..tostring(transferEl), 2)
		return false
	end
	return transfer:addData(data, cache, ...)
end

function startTransfer(transferEl, player)
	local transfer = Transfer.elMap[transferEl]
	if(not transfer) then
		outputDebugString("Invalid transfer element "..tostring(transferEl), 2)
		return false
	end
	return transfer:start(player)
end

function stopTransfer(transferEl, player)
	local transfer = Transfer.elMap[transferEl]
	if(not transfer) then
		outputDebugString("Invalid transfer element "..tostring(transferEl), 2)
		return false
	end
	return transfer:stop(player)
end
