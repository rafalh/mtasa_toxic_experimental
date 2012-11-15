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

local function renderTime()
	if(not getTimePassed) then return end
	
	local timePassed, timeLimit = getTimePassed()
	if(not timePassed or not timeLimit) then return end
	
	local secPassed = timePassed/1000
	local secLimit = timeLimit/1000
	
	local w, h = 200, 20
	local x, y = (g_ScrW - w)/2, 10
	local text = ("Time passed: %u:%02u/%u:%02u"):format(secPassed/60, secPassed%60, secLimit/60, secLimit%60)
	local progress = timePassed/timeLimit
	dxDrawRectangle(x, y, w * progress, h, tocolor(64, 0, 255, 64))
	dxDrawRectangle(x + w * progress, y, w * (1 - progress), h, tocolor(255, 196, 0, 64))
	dxDrawText(text, x, y, x + w, y + h, FONT_COLOR, 1, "default-bold", "center", "center")
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
	if(not room) then return end
	
	local mapInfo = getElementData(room, "mapinfo")
	if(not mapInfo) then return end
	
	local x, y = 10, g_ScrH - 50
	dxDrawText("Map: "..(mapInfo.name or "unknown"), x, y, x, y, FONT_COLOR, FONT_SCALE, FONT_FACE)
	dxDrawText("Author: "..(mapInfo.author or "unknown"), x, y + g_FontHeight, x, y + g_FontHeight, FONT_COLOR, FONT_SCALE, FONT_FACE)
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
	renderTime()
	renderRank()
	renderMapInfo()
	renderRespawnMsg()
	renderWaitingMsg()
end

local function onGameStart()
	outputChatBox("Start!")
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

local function initDelayed()
	import("race")
	import("roommgr")
	
	if(isPlayerDead(g_Me)) then
		g_DeathTime = getTickCount()
	end
	
	initCountdown()
	initSpectate()
	
	addEventHandler("onClientGameStart", g_Root, onGameStart)
	addEventHandler("onClientGameStop", g_Root, onGameStop)
	addEventHandler("onClientRender", g_Root, render)
	addEventHandler("onClientPlayerWin", g_Root, onPlayerWin)
	addEventHandler("onClientPlayerWasted", g_Me, onWasted)
	addEventHandler("onClientVehicleEnter", g_Root, onVehicleEnter)
	
	addCommandHandler("kill", kill)
	bindKey("k", "down", kill)
	
	bindKey(RESPAWN_KEY, "down", respawn)
end

local function init()
	-- import some times fail if not delayed
	setTimer(initDelayed, 50, 1)
end

addEventHandler("onClientResourceStart", g_ResRoot, init)