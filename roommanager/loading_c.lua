local g_Root = getRootElement()
local g_ProgressWnd, g_ProgressBar
local g_ProgressTimer = false
local g_MapRes = false
local g_ScrW, g_ScrH = guiGetScreenSize()

addEvent("onClientMapLoading")
addEvent("onClientMapStarting")

local function destroyProgressGui()
	if(g_ProgressTimer) then
		killTimer(g_ProgressTimer)
		g_ProgressTimer = false
	end
	
	if(g_ProgressWnd) then
		destroyElement(g_ProgressWnd)
		g_ProgressWnd, g_ProgressBar = false, false
	end
end

local function createProgressGui()
	destroyProgressGui() -- destroy old GUI
	
	local w, h = 300, 40
	local x, y = (g_ScrW - w) / 2, g_ScrH - h - 100
	g_ProgressWnd = guiCreateWindow(x, y, w, h, "Map loading", false)
	g_ProgressBar = guiCreateProgressBar(0, 15, w, h - 15, false, g_ProgressWnd)
end

local function updateProgress()
	local bytes, total = call(g_MapRes, "getLoadingProgress")
	guiProgressBarSetProgress(g_ProgressBar, bytes/total*100)
	guiSetText(g_ProgressWnd, ("Map loading: %d kB / %d kB"):format(bytes / 1024, total / 1024))
end

local function onMapLoading(res)
	g_MapRes = res
	createProgressGui()
	g_ProgressTimer = setTimer(updateProgress, 200, 0)
end

local function onMapStarting(res)
	destroyProgressGui()
end

addEventHandler("onClientMapLoading", g_Root, onMapLoading)
addEventHandler("onClientMapStarting", g_Root, onMapStarting)
