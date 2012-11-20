local g_GUI

addEvent("main_onLoginReq", true)
addEvent("main_onLoginStatus", true)

local function onLoginClick(btn,state)
	if btn ~= "left" or state ~= "up" then return end
	local name = dxGetText(g_GUI.name)
	local pw = dxGetText(g_GUI.pw)
	
	dxSetText(g_GUI.info, "Please wait...")
	dxSetColor(g_GUI.info, 255, 255, 255)
	
	triggerServerEvent("main_onLogin", g_ResRoot, name, pw)
end

local function onRegisterClick(btn,state)
	if btn ~= "left" or state ~= "up" then return end
	closeLoginWnd()
	openRegisterWnd()
end

local function onPlayAsGuestClick(btn,state)
	if btn ~= "left" or state ~= "up" then return end
	triggerServerEvent("main_onLogin", g_ResRoot, false, false)
	closeLoginWnd()
end

local function onLoginStatus(success)
	if(success) then
		closeLoginWnd()
	elseif(g_GUI) then
		dxSetText(g_GUI.info, "Wrong username or password")
		dxSetColor(g_GUI.info, 255, 0, 0)
	end
end

function closeLoginWnd()
	if(not g_GUI) then return end
	
	guiSetInputEnabled(false)
	showCursor(false)
	g_GUI:destroy()
	g_GUI = false
end

function openLoginWnd(loginFailed)
	closeLoginWnd()
	
	g_GUI = GUI.create("loginWnd")
	
	guiSetInputEnabled(true)
	showCursor(true)
	addEventHandler("onDxGUIClick", g_GUI.logBtn, onLoginClick, false)
	addEventHandler("onDxGUIClick", g_GUI.regBtn, onRegisterClick, false)
	addEventHandler("onDxGUIClick", g_GUI.guestBtn, onPlayAsGuestClick, false)
end

addEventHandler("main_onLoginReq", g_ResRoot, openLoginWnd)
addEventHandler("main_onLoginStatus", g_ResRoot, onLoginStatus)
