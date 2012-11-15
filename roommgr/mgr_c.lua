g_Root = getRootElement()
g_ResRoot = getResourceRootElement()

addEvent("onClientPlayerChangeRoom")
addEvent("roommgr_onPlayerChangeRoom", true)

local function onPlayerChangeRoom(...)
	triggerEvent("onClientPlayerChangeRoom", source, ...)
end

local function init()
	triggerServerEvent("roommgr_onPlayerReady", g_ResRoot)
end

addEventHandler("roommgr_onPlayerChangeRoom", g_Root, onPlayerChangeRoom)
addEventHandler("onResourceStart", g_ResRoot, init)
