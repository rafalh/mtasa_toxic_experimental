local g_GUI

addEvent("main_onLoginReq", true)
addEvent("main_onLoginStatus", true)

local function onLoginClick()
	local name = guiGetText(g_GUI.name)
	local pw = guiGetText(g_GUI.pw)
	
	guiSetText(g_GUI.info, "Please wait...")
	guiLabelSetColor(g_GUI.info, 255, 255, 255)
	
	triggerServerEvent("main_onLogin", g_ResRoot, name, pw)
end

local function onRegisterClick()
	closeLoginWnd()
	openRegisterWnd()
end

local function onPlayAsGuestClick()
	triggerServerEvent("main_onLogin", g_ResRoot, false, false)
	closeLoginWnd()
end

local function onLoginStatus(success)
	if(success) then
		closeLoginWnd()
	elseif(g_GUI) then
		guiSetText(g_GUI.info, "Wrong username or password")
		guiLabelSetColor(g_GUI.info, 255, 0, 0)
	end
end

function closeLoginWnd()
	if(not g_GUI) then return end
	
	guiSetInputEnabled(false)
	g_GUI:destroy()
	g_GUI = false
end

function openLoginWnd(loginFailed)
	closeLoginWnd()
	
	g_GUI = GUI.create("loginWnd")
	
	guiSetInputEnabled(true)
	addEventHandler("onClientGUIClick", g_GUI.logBtn, onLoginClick, false)
	addEventHandler("onClientGUIClick", g_GUI.regBtn, onRegisterClick, false)
	addEventHandler("onClientGUIClick", g_GUI.guestBtn, onPlayAsGuestClick, false)
end

addEventHandler("main_onLoginReq", g_ResRoot, openLoginWnd)
addEventHandler("main_onLoginStatus", g_ResRoot, onLoginStatus)
