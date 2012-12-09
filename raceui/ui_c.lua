local RESPAWN_KEY = "space"
local FONT_COLOR = tocolor(255, 255, 255)
local FONT_FACE = "bankgothic"
local FONT_SCALE = 0.8

g_Root = getRootElement()
g_ResRoot = getResourceRootElement()
g_Me = getLocalPlayer()
g_ScrW, g_ScrH = guiGetScreenSize()
local g_FontHeight = dxGetFontHeight(FONT_SCALE, FONT_FACE)
local g_DeathTime = false
local g_TimeGui = {}
local g_MapInfoGui = {}
local g_ComponentGui = {}

local function createTime()
	local w, h = 200, 20
	local x, y = (g_ScrW - w)/2, 10
	g_TimeGui["progress"] = dxCreateProgressBar(x, y,w, h)
	g_TimeGui["label"] = dxCreateLabel(0,0,w,h,"123",g_TimeGui["progress"])
	dxSetLabelAlign(g_TimeGui["label"],"center")
end

local function createMapInfo()
	local x, y = 10, g_ScrH - 50
	g_MapInfoGui["panel"] = dxCreatePanel(x, g_ScrH-40,100,40)
	dxSetColor(g_MapInfoGui["panel"],230,230,230,150)
	g_MapInfoGui["map"] = dxCreateLabel(0, 0,100,20,"123",g_MapInfoGui["panel"])
	g_MapInfoGui["autor"] = dxCreateLabel(0,20,100,20,"123",g_MapInfoGui["panel"])
	--dxSetColor(g_MapInfoGui["map"],255,255,255)
end

function createComponent()
	local sx = g_ScrW*0.1
	local x, y = g_ScrW-sx-50, 50
	g_ComponentGui["panel"] = dxCreatePanel(x,y,0,0)
	g_ComponentGui["hp"] = dxCreateProgressBar(0, 0,sx, 20,g_ComponentGui["panel"])
	g_ComponentGui["speed"] = dxCreateProgressBar(0, 25,sx, 20,g_ComponentGui["panel"])
	dxSetColor(g_ComponentGui["hp"],255,0,0)
	dxSetColor(g_ComponentGui["speed"],24,80,166)
end


local function renderTime()
	if(not getTimePassed) then 
		if dxGetVisible(g_TimeGui["progress"]) then
			dxSetVisible(g_TimeGui["progress"],false)
		end
		return
	end
	
	local timePassed, timeLimit = getTimePassed()
	if(not timePassed or not timeLimit) then
		if dxGetVisible(g_TimeGui["progress"]) then
			dxSetVisible(g_TimeGui["progress"],false)
		end
		return
	end
	if not dxGetVisible(g_TimeGui["progress"]) then
		dxSetVisible(g_TimeGui["progress"],true)
	end
	local secPassed = timePassed/1000
	local secLimit = timeLimit/1000
	local text = ("Time passed: %u:%02u/%u:%02u"):format(secPassed/60, secPassed%60, secLimit/60, secLimit%60)
	dxSetText(g_TimeGui["label"],text)
	local progress = timePassed/timeLimit
	dxProgressBarSetProgress(g_TimeGui["progress"],progress*100)
end

local function renderComponents()
	local target = getCameraTarget()
	if(target and getElementType(target) == "vehicle") then
		local hp = math.floor(math.max(getElementHealth(target) - 250, 0)/75 * 10)
		local x,y,z = getElementVelocity(target)
		local kmh = (x^2 + y^2 + z^2) ^ 0.5 * 1.61 * 100
		local speed = (1-((240-kmh)/240))*100
		dxProgressBarSetProgress(g_ComponentGui["hp"],hp)
		dxProgressBarSetProgress(g_ComponentGui["speed"],speed)
		if not dxGetVisible(g_ComponentGui["panel"]) then
			dxSetVisible(g_ComponentGui["panel"],true)
		end
	else
		if dxGetVisible(g_ComponentGui["panel"]) then
			dxSetVisible(g_ComponentGui["panel"],false)
		end
	end
end

local function renderRank()
	local x, y = g_ScrW - 150, g_ScrH - 50
	
	local target = getCameraTarget()
	if(target and getElementType(target) == "vehicle") then
		target = getVehicleOccupant(target)
	end
	if(not target) then return end
	
	local rank = getElementData(target, "race.rank")
	if(rank) then
		dxDrawText("Rank: "..rank, x, y, x, y, FONT_COLOR, FONT_SCALE, FONT_FACE)
	end
	
	local cp = getElementData(target, "race.cp")
	local cpCount = #getElementsByType("checkpoint")
	if(cp) then
		dxDrawText("CP: "..cp.."/"..cpCount, x, y + g_FontHeight, x, y + g_FontHeight, FONT_COLOR, FONT_SCALE, FONT_FACE)
	end
end

local function renderMapInfo()
	local room = getCurrentRoom and getCurrentRoom()
	if(not room) then
		if dxGetVisible(g_MapInfoGui["panel"]) then
			dxSetVisible(g_MapInfoGui["panel"],false)
		end
		return
	end
	
	local mapInfo = getElementData(room, "mapinfo")
	if(not mapInfo) then
		if dxGetVisible(g_MapInfoGui["panel"]) then
			dxSetVisible(g_MapInfoGui["panel"],false)
		end
		return 
	end
	local maxS = {}
	local mapName = (mapInfo.name or "unknown")
	local author = (mapInfo.author or "unknown")
	if not dxGetVisible(g_MapInfoGui["panel"]) then
		dxSetVisible(g_MapInfoGui["panel"],true)
	end
	if dxGetText(g_MapInfoGui["map"]) ~= mapName then
		dxSetText(g_MapInfoGui["map"],mapName)
		local fx = dxGetFontSize(0.5,mapName)
		dxSetSize(g_MapInfoGui["map"],fx+10,20)
		table.insert(maxS,fx+15)
	end
	if dxGetText(g_MapInfoGui["autor"]) ~= author then
		dxSetText(g_MapInfoGui["autor"],author)
		local fx = dxGetFontSize(0.5,author)
		dxSetSize(g_MapInfoGui["autor"],fx+10,20)
		table.insert(maxS,fx+15)
	end
	if #maxS > 0 then
		local strmax = math.max(unpack(maxS))
		dxSetSize(g_MapInfoGui["panel"],strmax,40)
	end
end

local function renderRespawnMsg()
	if(not g_DeathTime or not getCurrentRoom) then return end
	
	local room = getCurrentRoom()
	local state = room and getElementData(room, "race.state")
	if(state ~= "running") then return end
	
	local respawn = room and getElementData(room, "race.respawn")
	
	if(type(respawn) == "number") then
		local dt = getTickCount() - g_DeathTime
		local secondsLeft = math.max(math.ceil(respawn - dt/1000), 0)
		dxDrawText("Respawn in "..secondsLeft.." seconds", 0, 0, g_ScrW, g_ScrH, FONT_COLOR, FONT_SCALE, FONT_FACE, "center", "center")
	elseif(respawn) then
		dxDrawText("Press "..RESPAWN_KEY.." to respawn", 0, 0, g_ScrW, g_ScrH, FONT_COLOR, FONT_SCALE, FONT_FACE, "center", "center")
	end
end

local function renderWaitingMsg()
	local room = getCurrentRoom and getCurrentRoom()
	local state = room and getElementData(room, "race.state")
	if(state ~= "waiting") then return end
	
	dxDrawText("Waiting for other players...", 0, 0, g_ScrW, g_ScrH, FONT_COLOR, FONT_SCALE, FONT_FACE, "center", "center")
end

local function render()
	renderRank()
	renderRespawnMsg()
	renderWaitingMsg()
	if getResourceFromName("dxgui") then
		renderMapInfo()
		renderTime()
		renderComponents()
	end
end

local function onGameStart()
	outputChatBox("Start!")
	showPlayerHudComponent ("all", false)
	showPlayerHudComponent ("radar", true)
end

local function onGameStop(reason)
	outputChatBox("Stop ("..tostring(reason)..")!")
end

local function onPlayerWin()
	outputChatBox(getPlayerName(source).." has won!")
end

local function onWasted()
	g_DeathTime = getTickCount()
end

local function onVehicleEnter(player)
	if(player == g_Me) then
		g_DeathTime = false
	end
end

local function kill()
	local room = getCurrentRoom()
	if(room and getElementData(room, "race.state") == "running") then
		setElementHealth(g_Me, 0)
	end
end

local function respawn()
	requestRespawn()
end

function createDxGui()
	createTime()
	createMapInfo()
	createComponent()
end

local function initDelayed()
	import("race")
	import("roommgr")
	import("dxgui",createDxGui)
	
	if(isPlayerDead(g_Me)) then
		g_DeathTime = getTickCount()
	end
	
	initCountdown()
	initSpectate()
	
	--gui
	createDxGui()
	
	addEventHandler("onClientGameStart", g_Root, onGameStart)
	addEventHandler("onClientGameStop", g_Root, onGameStop)
	addEventHandler("onClientRender", g_Root, render)
	addEventHandler("onClientPlayerWin", g_Root, onPlayerWin)
	addEventHandler("onClientPlayerWasted", g_Me, onWasted)
	addEventHandler("onClientVehicleEnter", g_Root, onVehicleEnter)
	
	addCommandHandler("kill", kill)
	bindKey("k", "down", kill)
	
	bindKey(RESPAWN_KEY, "down", respawn)
	
	showPlayerHudComponent ("all", false)
	showPlayerHudComponent ("radar", true)
end

local function init()
	-- import some times fail if not delayed
	setTimer(initDelayed, 50, 1)
end

addEventHandler("onClientResourceStart", g_ResRoot, init)