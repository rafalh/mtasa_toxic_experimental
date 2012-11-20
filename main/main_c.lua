g_Root = getRootElement()
g_Me = getLocalPlayer()
g_ResRoot = getResourceRootElement()
g_ScrW, g_ScrH = guiGetScreenSize()

local function initDelayed()
	import("roommgr")
	import("dxgui")
	addEvent("onDxGUIClick",true)
	triggerServerEvent("main_onReady", g_ResRoot)
end

local function init()
	setTimer(initDelayed, 50, 1)
end

addEventHandler("onClientResourceStart", g_ResRoot, init)
