local DBG_LEVEL_NAMES = {[0] = "Custom", [1] = "Error", [2] = "Warning", [3] = "Info"}
local DBG_LEVEL_COLORS = {[0] = {255, 255, 255}, [1] = {255, 0, 0}, [2] = {255, 255, 0}, [3] = {0, 255, 0}}
local MAX_ROWS = 50

local g_InputCounter = 0
local g_Wnd, g_LogList, g_PlayersList, g_FilterEdit
local g_CloseBtn, g_CopyRightLabel,g_LoadingLabel
local g_RefreshTimer
local g_Level = 2
local g_Player = localPlayer
local g_DbgLog = {}

addEvent("dbg_onDisplayReq", true)
addEvent("dbg_onLogSync", true)

local _showCursor = showCursor
function showCursor(visible)
	if(visible) then
		g_InputCounter = g_InputCounter + 1
		if(g_InputCounter > 0) then
			_showCursor(true)
		end
	else
		g_InputCounter = g_InputCounter - 1
		if(g_InputCounter <= 0) then
			_showCursor(false)
		end
		
		assert(g_InputCounter >= 0, tostring(g_InputCounter))
	end
end

function guiSetInputEnabled()
	assert(false, "guiSetInputEnabled is deprecated")
end


local function addRowToList(info)
	if(info[3] > g_Level) then return end
	
	local w, h = guiGetSize(g_LogList, false)
	local maxRows = (h - 45)/14
	local rowsCount = guiGridListGetRowCount(g_LogList)
	for i = 1, rowsCount - maxRows + 1 do
		guiGridListRemoveRow(g_LogList, 0)
	end
	assert(guiGridListGetRowCount(g_LogList) < maxRows)
	
	local row = guiGridListAddRow(g_LogList)
	local level = DBG_LEVEL_NAMES[info[3]] or tostring(info[3])
	local msg = tostring(info[2])
	local location = tostring(info[4])..":"..tostring(info[5])
	local times = tostring(info[6])
	
	local filter = guiGetText(g_FilterEdit):lower()
	if(filter ~= "" and 
			not level:lower():find(filter, 1, true) and
			not msg:lower():find(filter, 1, true) and
			not location:lower():find(filter, 1, true)) then return end
	
	local clr = DBG_LEVEL_COLORS[info[3]] or {255, 255, 255}
	local r, g, b = unpack(clr)
	
	guiGridListSetItemText(g_LogList, row, 1, level, false, false)
	guiGridListSetItemColor(g_LogList, row, 1, r, g, b)
	guiGridListSetItemText(g_LogList, row, 2,location, false, false)
	guiGridListSetItemColor(g_LogList, row, 2, r, g, b)
	guiGridListSetItemText(g_LogList, row, 3, msg, false, false)
	guiGridListSetItemColor(g_LogList, row, 3, r, g, b)
	guiGridListSetItemText(g_LogList, row, 4, getRealTimeFromTimeStamp(times), false, false)
	guiGridListSetItemColor(g_LogList, row, 4, r, g, b)
end

local function addLogRow(info)
	if(#g_DbgLog >= MAX_ROWS) then
		table.remove(g_DbgLog, 1)
	end
	table.insert(g_DbgLog, info)
	
	addRowToList(info)
end

local function refreshList()
	guiGridListClear(g_LogList)
	
	for i, info in ipairs(g_DbgLog) do
		addRowToList(info)
	end
	guiSetVisible(g_LoadingLabel,false)
end

local function onLogSync(data, player)
	if(player ~= g_Player or not g_Wnd) then return end
	
	for i, info in ipairs(data) do
		addLogRow(info)
	end
	guiSetVisible(g_LoadingLabel,false)
end

local function onPlayerChange(player)
	g_Player = player
	guiGridListClear(g_LogList)
	g_DbgLog = {}
	triggerServerEvent("dbg_onLogSyncReq", resourceRoot, player)
	guiSetVisible(g_LoadingLabel,true)
end

local function resetUpdateTimer()
	if(g_RefreshTimer) then
		resetTimer(g_RefreshTimer)
	else
		g_RefreshTimer = setTimer(function()
			g_RefreshTimer = false
			refreshList()
		end, 200, 1)
	end
end

local function onResize()
	local minW, minH = 500, 200
	local w, h = guiGetSize(source, false)
	
	if(w < minW or h < minH) then
		w = math.max(minW, w)
		h = math.max(minH, h)
		guiSetSize(source, w, h, false)
	end
	
	local dbgLogY = 25 + 40 + 30
	guiSetSize(g_LogList, w - 20, h - dbgLogY - 40, false)
	
	guiSetPosition(g_CloseBtn, w - 80 - 10, h - 25 - 10, false)
	guiSetPosition(g_CopyRightLabel, 10, h - 15 - 10, false)
	guiSetPosition(g_LoadingLabel, 160, h - 15 - 10, false)
	
	resetUpdateTimer()
end

local function onLevelChange()
	g_Level = guiComboBoxGetSelected(source) + 1
	refreshList()
end

function closeDbgLogWnd()
	if(not g_Wnd) then return end
	
	triggerServerEvent("dbg_onLogSyncReq", resourceRoot, false)
	
	if(g_RefreshTimer) then
		killTimer(g_RefreshTimer)
		g_RefreshTimer = false
	end
	destroyElement(g_Wnd)
	
	showCursor(false)
	g_Wnd = false
end

function openDbgLogWnd()
	if(g_Wnd) then
		guiBringToFront(g_Wnd)
		return
	end
	
	g_Player = localPlayer
	
	local w, h = 640, 560
	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2
	g_Wnd = guiCreateWindow(x, y, w, h, "Debugger", false)
	addEventHandler("onClientGUISize", g_Wnd, onResize, false)
	
	guiCreateLabel(10, 25+2, 40, 20, "Tools:", false, g_Wnd)
	local btnX = 50
	
	local runCodeBtn = guiCreateButton(btnX, 25, 80, 25, "Run code", false, g_Wnd)
	addEventHandler("onClientGUIClick", runCodeBtn, openRunCodeWnd, false)
	btnX = btnX + 80 + 10
	
	local screenShotBtn = guiCreateButton(btnX, 25, 80, 25, "Screen-shot", false, g_Wnd)
	addEventHandler("onClientGUIClick", screenShotBtn, openScreenShotWnd, false)
	btnX = btnX + 80 + 10
	
	local perfStatsBtn = guiCreateButton(btnX, 25, 120, 25, "Performance stats", false, g_Wnd)
	addEventHandler("onClientGUIClick", perfStatsBtn, openPerfStatsWnd, false)
	btnX = btnX + 120 + 10
	
	local netStatsBtn = guiCreateButton(btnX, 25, 120, 25, "Network stats", false, g_Wnd)
	addEventHandler("onClientGUIClick", netStatsBtn, openNetStatsWnd, false)
	btnX = btnX + 120 + 10
	
	guiCreateLabel(10, 65+2, 40, 20, "Player:", false, g_Wnd)
	g_PlayersList = PlayersList.create(50, 65, 150, 250, g_Wnd)
	g_PlayersList:addStaticElement("Server", root)
	g_PlayersList:setDefault(root)
	g_PlayersList:updatePlayers()
	g_PlayersList.callback = onPlayerChange
	
	guiCreateLabel(210, 65+2, 40, 20, "Level:", false, g_Wnd)
	g_LevelComboBox = guiCreateComboBox(250, 65, 80, 80, "", false, g_Wnd)
	guiComboBoxAddItem(g_LevelComboBox, "Error")
	guiComboBoxAddItem(g_LevelComboBox, "Warning")
	guiComboBoxAddItem(g_LevelComboBox, "Info")
	g_Level = 2 -- warning
	guiComboBoxSetSelected(g_LevelComboBox, g_Level - 1)
	addEventHandler("onClientGUIComboBoxAccepted", g_LevelComboBox, onLevelChange, false)
	
	guiCreateLabel(340, 65+2, 50, 20, "Filter:", false, g_Wnd)
	g_FilterEdit = guiCreateEdit(390, 65, 80, 20, "", false, g_Wnd)
	addEventHandler("onClientGUIChanged", g_FilterEdit, resetUpdateTimer, false)
	
	local dbgLogY = 25 + 40 + 30
	g_LogList = guiCreateGridList(10, dbgLogY, w - 20, h - dbgLogY - 40, false, g_Wnd)
	guiGridListSetSortingEnabled(g_LogList, false)
	guiGridListAddColumn(g_LogList, "Level", 0.1)
	guiGridListAddColumn(g_LogList, "Location", 0.25)
	guiGridListAddColumn(g_LogList, "Message", 0.4)
	guiGridListAddColumn(g_LogList, "Time", 0.2)
	
	g_CloseBtn = guiCreateButton(w - 80 - 10, h - 25 - 10, 80, 25, "Close", false, g_Wnd)
	addEventHandler("onClientGUIClick", g_CloseBtn, closeDbgLogWnd, false)
	
	g_CopyRightLabel = guiCreateLabel(10, h - 15 - 10, 200, 15, "Copyright (c) 2012-2013 rafalh and Bober", false, g_Wnd)
	guiSetFont(g_CopyRightLabel, "default-small")
	
	g_LoadingLabel = guiCreateLabel(guiLabelGetTextExtent (g_CopyRightLabel) + 10 + 5, h - 15 - 10, 160, 15, "Loading...", false, g_Wnd)
	guiSetFont(g_LoadingLabel, "default-small")
	guiSetVisible(g_LoadingLabel,false)
	
	guiSetInputMode("no_binds_when_editing")
	showCursor(true)
end

addEventHandler("dbg_onDisplayReq", resourceRoot, function(data)
	openDbgLogWnd()
	onLogSync(data, localPlayer)
end)

addEventHandler("dbg_onLogSync", root, function(data)
	onLogSync(data, source)
end)
