g_ScrW, g_ScrH = guiGetScreenSize()

local localPlayerssages = {}

local MIN_MSG_DELAY = 500

local function onDbgMsg(message, level, file, line)
	local msgId = md5(message..level..(file or "")..(line or ""))
	local ticks = getTickCount()
	if(not localPlayerssages[msgId] or ticks - localPlayerssages[msgId] > MIN_MSG_DELAY) then
		localPlayerssages[msgId] = ticks
		triggerServerEvent("dbg_onMsg", resourceRoot, message, level, file or "", line or "")
	end
end

local function updateList()
	local ticks = getTickCount()
	local msgId, msgTicks = next(localPlayerssages, msgId)
	
	while(msgId) do
		local deleteID = msgId
		if(ticks - msgTicks > MIN_MSG_DELAY) then
			deleteID = msgId
		end
		
		msgId, msgTicks = next(localPlayerssages, msgId)
		
		if(deleteID) then
			localPlayerssages[deleteID] = nil
		end
	end
end

local function init()
	setTimer(updateList, 1000, 0)
end

addEventHandler("onClientDebugMessage", root, onDbgMsg)
addEventHandler("onClientResourceStart", resourceRoot, init)
