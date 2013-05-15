local g_Wnd, g_Imglocal g_CloseBtn, g_CopyRightLabellocal g_PlayersList = falselocal g_Player = localPlayeraddEvent("dbg_onScreenShot", true)local function updateImage()	local w, h = guiGetSize(g_Wnd, false)	triggerServerEvent("dbg_onScreenShotReq", localPlayer, g_Player, w - 20, h - 100)endlocal function onPlayerChange(player)	g_Player = player		if(g_Img) then		destroyElement(g_Img)		g_Img = false	end	updateImage()		local title = "Screen-shot - "..getPlayerName(g_Player):gsub ("#%x%x%x%x%x%x", "")	guiSetText(g_Wnd, title)endlocal function onResize()	local minW, minH = 320, 150	local w, h = guiGetSize(source, false)		if(w < minW or h < minH) then		w = math.max(minW, w)		h = math.max(minH, h)		guiSetSize(source, w, h, false)	end		if(g_Img) then		guiSetSize(g_Img, w - 20, h - 100, false)	end	guiSetPosition(g_CloseBtn, w - 80 - 10, h - 25 - 10, false)	guiSetPosition(g_CopyRightLabel, 10, h - 15 - 10, false)endfunction closeScreenShotWnd()	if(not g_Wnd) then return end		destroyElement(g_Wnd)	g_Wnd = false	g_Img = false		showCursor(false)endfunction openScreenShotWnd()	if(g_Wnd) then		guiBringToFront(g_Wnd)		return	end		g_Player = localPlayer		local w, h = 640+20, 480+55+40	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2	local title = "Screen-shot - "..getPlayerName(g_Player):gsub ("#%x%x%x%x%x%x", "")	g_Wnd = guiCreateWindow(x, y, w, h, title, false)	addEventHandler("onClientGUISize", g_Wnd, onResize, false)		guiCreateLabel(10, 25+2, 40, 20, "Player:", false, g_Wnd)	g_PlayersList = PlayersList.create(50, 25, 150, 250,g_Wnd)	g_PlayersList:updatePlayers()	g_PlayersList.callback = onPlayerChange		local refreshBtn = guiCreateButton(210, 25, 80, 25, "Refresh", false, g_Wnd)	addEventHandler("onClientGUIClick", refreshBtn, updateImage, false)		g_CloseBtn = guiCreateButton(w - 80 - 10, h - 25 - 10, 80, 25, "Close", false, g_Wnd)	addEventHandler("onClientGUIClick", g_CloseBtn, closeScreenShotWnd, false)		g_CopyRightLabel = guiCreateLabel(10, h - 15 - 10, 200, 15, "Copyright (c) 2012-2013 rafalh and Bober", false, g_Wnd)	guiSetFont(g_CopyRightLabel, "default-small")		updateImage()	showCursor(true)endlocal function onScreenShot(imgData)	if(not g_Wnd or source ~= g_Player) then return end		local file = fileCreate("screenshot.jpg")	if(not file) then return end		fileWrite(file, imgData)	fileClose(file)		if(g_Img) then		guiStaticImageLoadImage(g_Img, "screenshot.jpg")	else		local w, h = guiGetSize(g_Wnd, false)		g_Img = guiCreateStaticImage(10, 55, w - 20, h - 100, "screenshot.jpg", false, g_Wnd)	endendaddEventHandler("dbg_onScreenShot", root, onScreenShot)