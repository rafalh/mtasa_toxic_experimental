local g_Wnd, g_StatsList
local g_CloseBtn, g_CopyRightLabel
local g_Target = g_Root
local g_Timer

local REFRESH_INTERVAL = 3000

addEvent("dbg_onNetStats", true)

local function updateStats()
	triggerServerEvent("dbg_onNetStatsReq", g_Me, g_Target)
end

local function onTargetChange(target)
	g_Target = target
	
	if(target == g_Root) then
		guiSetText(g_Wnd, "Network stats - Server")
	else
		local targetName = getPlayerName(g_Target):gsub ("#%x%x%x%x%x%x", "")
		guiSetText(g_Wnd, "Network stats - "..targetName)
	end
	
	updateStats()
end

local function onNetStats(netStats, target)
	if(target ~= g_Target) then return end
	
	guiGridListClear(g_StatsList)
	
	for key, value in pairs(netStats) do
		local row = guiGridListAddRow(g_StatsList)
		guiGridListSetItemText(g_StatsList, row, 1, key, false, false)
		guiGridListSetItemText(g_StatsList, row, 2, value, false, type(value) == "number")
	end
end

local function onResize()
	local minW, minH = 300, 150
	local w, h = guiGetSize(source, false)
	
	if(w < minW or h < minH) then
		w = math.max(minW, w)
		h = math.max(minH, h)
		guiSetSize(source, w, h, false)
	end
	
	guiSetSize(g_StatsList, w - 20, h - 100, false)
	guiSetPosition(g_CloseBtn, w - 80 - 10, h - 25 - 10, false)
	guiSetPosition(g_CopyRightLabel, 10, h - 15 - 10, false)
end

function closeNetStatsWnd()
	if(not g_Wnd) then return end
	
	destroyElement(g_Wnd)
	killTimer(g_Timer)
	g_Wnd = false
	
	guiSetInputEnabled(false)
end

function openNetStatsWnd()
	if(g_Wnd) then
		guiBringToFront(g_Wnd)
		return
	end
	
	local w, h = 400, 300
	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2
	g_Wnd = guiCreateWindow(x, y, w, h, "Network stats - Server", false)
	addEventHandler("onClientGUISize", g_Wnd, onResize, false)
	
	guiCreateLabel(10, 25+2, 50, 20, "Target:", false, g_Wnd)
	g_TargetsList = PlayersList.create(60, 25, 150, 250, g_Wnd)
	g_TargetsList:addStaticElement("Server", g_Root)
	g_TargetsList:setDefault(g_Root)
	g_TargetsList:updatePlayers()
	g_TargetsList.callback = onTargetChange
	
	g_StatsList = guiCreateGridList(10, 55, w - 20, h - 100, false, g_Wnd)
	guiGridListAddColumn(g_StatsList, "Name", 0.6)
	guiGridListAddColumn(g_StatsList, "Value", 0.3)
	
	g_CloseBtn = guiCreateButton(w - 80 - 10, h - 25 - 10, 80, 25, "Close", false, g_Wnd)
	addEventHandler("onClientGUIClick", g_CloseBtn, closeNetStatsWnd, false)
	
	g_CopyRightLabel = guiCreateLabel(10, h - 15 - 10, 160, 15, "Copyright (c) 2012 rafalh", false, g_Wnd)
	guiSetFont(g_CopyRightLabel, "default-small")
	
	updateStats()
	g_Timer = setTimer(updateStats, REFRESH_INTERVAL, 0)
	
	guiSetInputEnabled(true)
end

addEventHandler("dbg_onNetStats", g_Root, onNetStats)
