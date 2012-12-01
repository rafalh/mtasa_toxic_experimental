g_Root = getRootElement()
g_ResRoot = getResourceRootElement()
g_Me = getLocalPlayer()
g_ScrW, g_ScrH = guiGetScreenSize()

local g_Messages = {}

local MIN_MSG_DELAY = 500

local function onDbgMsg(message, level, file, line)
	local msgId = md5(message..level..(file or "")..(line or ""))
	local ticks = getTickCount()
	if(not g_Messages[msgId] or ticks - g_Messages[msgId] > MIN_MSG_DELAY) then
		g_Messages[msgId] = ticks
		triggerServerEvent("dbg_onMsg", g_ResRoot, message, level, file or "", line or "")
	end
end

local function updateList()
	local ticks = getTickCount()
	local msgId, msgTicks = next(g_Messages, msgId)
	
	while(msgId) do
		local deleteID = msgId
		if(ticks - msgTicks > MIN_MSG_DELAY) then
			deleteID = msgId
		end
		
		msgId, msgTicks = next(g_Messages, msgId)
		
		if(deleteID) then
			g_Messages[deleteID] = nil
		end
	end
end

local function init()
	setTimer(updateList, 1000, 0)
end

addEventHandler("onClientDebugMessage", g_Root, onDbgMsg)
addEventHandler("onClientResourceStart", g_ResRoot, init)
