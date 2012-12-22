local g_Wnd, g_CatsList, g_StatsList
local g_OptsEdit, g_FilterEdit
local g_CloseBtn, g_CopyRightLabel
local g_Timer, g_UpdateTimer
local g_Target, g_TargetsList

local REFRESH_INTERVAL = 3000

addEvent("dbg_onPerfStats", true)
addEvent("dbg_onPerfStatsReq", true)

local function updateStats()
	local cat = guiGetText(g_CatsList)
	local opts = guiGetText(g_OptsEdit)
	local filter = guiGetText(g_FilterEdit)
	if(cat ~= "") then
		triggerServerEvent("dbg_onPerfStatsReq", g_Target, cat, opts, filter)
	end
end

local function onStats(cols, rows, cat, opts, filter)
	if(not g_Wnd or source ~= g_Target) then return end
	
	if(cat == "") then -- Categories sync
		local cat = guiGetText(g_CatsList)
		guiComboBoxClear(g_CatsList)
		for i, row in ipairs(rows) do
			local idx = guiComboBoxAddItem(g_CatsList, row[1])
			
			if(row[1] == cat) then
				guiComboBoxSetSelected(g_CatsList, idx)
				updateStats()
			end
		end
	else -- Stats sync
		local cat2 = guiGetText(g_CatsList)
		local opts2 = guiGetText(g_OptsEdit)
		local filter2 = guiGetText(g_FilterEdit)
		if(cat ~= cat2 or opts ~= opts2 or filter ~= filter2) then return end
		
		guiGridListClear(g_StatsList)
		for i = 1, guiGridListGetColumnCount(g_StatsList) do
			guiGridListRemoveColumn(g_StatsList, 1)
		end
		
		local colIDs = {}
		for i, colName in ipairs(cols) do
			colIDs[i] = guiGridListAddColumn(g_StatsList, colName, 0.2)
		end
		
		for i, row in ipairs(rows) do
			local rowID = guiGridListAddRow(g_StatsList)
			for j, data in ipairs(row) do
				guiGridListSetItemText(g_StatsList, rowID, colIDs[j], data, false, false)
			end
		end
	end
end

local function resetUpdateTimer()
	if(not g_UpdateTimer) then
		g_UpdateTimer = setTimer(function()
			g_UpdateTimer = false
			updateStats()
		end, 500, 1)
	else
		resetTimer(g_UpdateTimer)
	end
end

local function updateCats()
	triggerServerEvent("dbg_onPerfStatsReq", g_Target, "")
end

local function onTargetChange(target)
	g_Target = target
	guiGridListClear(g_StatsList)
	updateCats()
end

local function onResize()
	local minW, minH = 620, 150
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

function closePerfStatsWnd()
	if(not g_Wnd) then return end
	
	killTimer(g_Timer)
	if(g_UpdateTimer) then
		killTimer(g_UpdateTimer)
		g_UpdateTimer = false
	end
	destroyElement(g_Wnd)
	g_Wnd = false
	
	guiSetInputEnabled(false)
end

function openPerfStatsWnd()
	if(g_Wnd) then
		guiBringToFront(g_Wnd)
		return
	end
	
	g_Target = g_Root
	
	local w, h = 640, 480
	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2
	g_Wnd = guiCreateWindow(x, y, w, h, "Performance statistics", false)
	addEventHandler("onClientGUISize", g_Wnd, onResize, false)
	
	guiCreateLabel(10, 25+2, 50, 20, "Target:", false, g_Wnd)
	g_TargetsList = PlayersList.create(60, 25, 100, 250, g_Wnd)
	g_TargetsList:addStaticElement("Server", g_Root)
	g_TargetsList:setDefault(g_Root)
	g_TargetsList:updatePlayers()
	g_TargetsList.callback = onTargetChange
	
	guiCreateLabel(170, 25+2, 60, 20, "Category:", false, g_Wnd)
	g_CatsList = guiCreateComboBox(230, 25, 120, 150, "", false, g_Wnd)
	updateCats()
	addEventHandler("onClientGUIComboBoxAccepted", g_CatsList, updateStats, false)
	
	guiCreateLabel(360, 25+2, 50, 20, "Options:", false, g_Wnd)
	g_OptsEdit = guiCreateEdit(410, 25, 60, 20, "", false, g_Wnd)
	addEventHandler("onClientGUIChanged", g_OptsEdit, resetUpdateTimer, false)
	
	guiCreateLabel(480, 25+2, 40, 20, "Filter:", false, g_Wnd)
	g_FilterEdit = guiCreateEdit(520, 25, 80, 20, "", false, g_Wnd)
	addEventHandler("onClientGUIChanged", g_FilterEdit, resetUpdateTimer, false)
	
	g_StatsList = guiCreateGridList(10, 55, w - 20, h - 100, false, g_Wnd)
	updateStats()
	
	g_CloseBtn = guiCreateButton(w - 80 - 10, h - 25 - 10, 80, 25, "Close", false, g_Wnd)
	addEventHandler("onClientGUIClick", g_CloseBtn, closePerfStatsWnd, false)
	
	g_CopyRightLabel = guiCreateLabel(10, h - 15 - 10, 160, 15, "Copyright (c) 2012 rafalh", false, g_Wnd)
	guiSetFont(g_CopyRightLabel, "default-small")
	
	g_Timer = setTimer(updateStats, REFRESH_INTERVAL, 0)
	guiSetInputEnabled(true)
end

local function onPerfStatsReq(cols, rows, cat, opts, filter, player)
	local cols, rows = getPerformanceStats(cat, opts, filter)
	triggerServerEvent("dbg_onPerfStats", source, cols, rows, cat, opts, filter, player)
end

addEventHandler("dbg_onPerfStats", g_Root, onStats)
addEventHandler("dbg_onPerfStatsReq", g_Root, onPerfStatsReq)
