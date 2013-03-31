local g_Wnd = false
local g_Target = resourceRoot
local g_CodeEdit
local g_CloseBtn, g_CopyRightLabel

addEvent("dbg_onRunCodeReq", true)

local function onRunCodeReq(codeStr)
	local func = loadstring(codeStr)
	local results = func and {func()}
	local resultStr = func and dbgToString(unpack(results))
	triggerServerEvent("dbg_onRunCodeResult", source, resultStr)
end

local function onTargetChange(target)
	g_Target = target
	
	if(target == root) then
		guiSetText(g_Wnd, "Run code - All clients")
	elseif(target == resourceRoot) then
		guiSetText(g_Wnd, "Run code - Server")
	else
		local targetName = getPlayerName(g_Target):gsub ("#%x%x%x%x%x%x", "")
		guiSetText(g_Wnd, "Run code - "..targetName)
	end
end

local function runCode()
	local code = guiGetText(g_CodeEdit)
	triggerServerEvent("dbg_onRunCodeReq", resourceRoot, code, g_Target)
end

local function onResize()
	local minW, minH = 320, 150
	local w, h = guiGetSize(source, false)
	
	if(w < minW or h < minH) then
		w = math.max(minW, w)
		h = math.max(minH, h)
		guiSetSize(source, w, h, false)
	end
	
	guiSetSize(g_CodeEdit, w - 20, h - 100, false)
	guiSetPosition(g_CloseBtn, w - 80 - 10, h - 25 - 10, false)
	guiSetPosition(g_CopyRightLabel, 10, h - 15 - 10, false)
end

function closeRunCodeWnd()
	if(not g_Wnd) then return end
	
	destroyElement(g_Wnd)
	g_Wnd = false
	
	guiSetInputEnabled(false)
end

function openRunCodeWnd()
	if(g_Wnd) then
		guiBringToFront(g_Wnd)
		return
	end
	
	local w, h = 400, 200
	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2
	local title = "Run code - Server"
	g_Wnd = guiCreateWindow(x, y, w, h, title, false)
	addEventHandler("onClientGUISize", g_Wnd, onResize, false)
	
	guiCreateLabel(10, 25+2, 50, 20, "Target:", false, g_Wnd)
	g_TargetsList = PlayersList.create(60, 25, 150, 250, g_Wnd)
	g_TargetsList:addStaticElement("Server", resourceRoot)
	g_TargetsList:addStaticElement("All clients", root)
	g_TargetsList:setDefault(g_Target)
	g_TargetsList:updatePlayers()
	g_TargetsList.callback = onTargetChange
	
	local runCodeBtn = guiCreateButton(220, 25, 80, 25, "Run", false, g_Wnd)
	addEventHandler("onClientGUIClick", runCodeBtn, runCode, false)
	
	g_CodeEdit = guiCreateMemo(10, 55, w - 20, h - 100, "", false, g_Wnd)
	
	g_CloseBtn = guiCreateButton(w - 80 - 10, h - 25 - 10, 80, 25, "Close", false, g_Wnd)
	addEventHandler("onClientGUIClick", g_CloseBtn, closeRunCodeWnd, false)
	
	g_CopyRightLabel = guiCreateLabel(10, h - 15 - 10, 200, 15, "Copyright (c) 2012-2013 rafalh and Bober", false, g_Wnd)
	guiSetFont(g_CopyRightLabel, "default-small")
	
	guiSetInputEnabled(true)
end

addEventHandler("dbg_onRunCodeReq", root, onRunCodeReq)
