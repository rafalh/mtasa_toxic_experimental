local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()

local function initMap()
end

local function init()
end

addEventHandler("onClientMapStarting", g_Root, initMap)
addEventHandler("onClientResourceStart", g_ResRoot, init)
