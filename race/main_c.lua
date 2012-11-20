g_Root = getRootElement()
g_ResRoot = getResourceRootElement()
g_Me = getLocalPlayer()

local g_StartTime = 0
local g_TimeLimit = false

addEvent("onClientGameStart", true)
addEvent("onClientGameStop", true)
addEvent("onClientGameCountdown", true)
addEvent("onClientInitGame", true)
addEvent("onClientPlayerWin", true)

local function onInitGame(mapInfo, timePassed, timeLimit)
	g_StartTime = timePassed and (getTickCount() - timePassed)
	g_TimeLimit = timeLimit
	setPedCanBeKnockedOffBike(g_Me, false)
end

local function onGameStart()
	g_StartTime = getTickCount()
	
	setBlurLevel(0)
end

local function onGameStop()
	g_StartTime = false
end

local function checkWater()
	if(not g_StartTime or isPlayerDead(g_Me)) then return end
	
	local veh = getPedOccupiedVehicle(g_Me)
	if(not veh) then return end
	
	local isBoat = (getVehicleType(veh) == "Boat")
	local x, y, z = getElementPosition(veh)
	local waterZ = getWaterLevel(x, y, z)
	local offset = (isBoat and 1) or 0.5
	if(waterZ and waterZ > z + offset) then
		setElementHealth(g_Me, 0)
	end
end

-- IMPORT race BEGIN

local function directionToRotation2D(x, y)
	return math.wrap(math.atan2( y, x ) * (360/6.28) - 90, 0, 360)
end

function alignVehicle(veh)
	local matrix = getElementMatrix(veh)
	local fwd = Vector.create(matrix[2][1], matrix[2][2], matrix[2][3])
	local up = Vector.create(matrix[3][1], matrix[3][2], matrix[3][3])
	
	local vel = Vector.create(getElementVelocity(veh))
	local rz
	
	if(vel:len() > 0.05 and up[3] < 0.001) then
		-- If velocity is valid, and we are upside down, use it to determine rotation
		rz = directionToRotation2D(vel[1], vel[2])
	else
		-- Otherwise use facing direction to determine rotation
		rz = directionToRotation2D(fwd[1], fwd[2])
	end
	
	setElementRotation(veh, 0, 0, rz)
end
-- IMPORT END

local function freezeCamera()
	local cameraMatrix = {getCameraMatrix()}
	setCameraMatrix(unpack(cameraMatrix))
end

local function onLocalPlayerWasted()
	toggleAllControls (false, true, false )
	freezeCamera()
	
	--[[local veh = getPedOccupiedVehicle(g_Me)
	if(veh) then
		--setElementFrozen(veh, true)
	end]]
end

local function initDelayed()
	import("roommgr")
	
	addEventHandler("onClientInitGame", g_Root, onInitGame)
	addEventHandler("onClientGameStart", g_Root, onGameStart)
	addEventHandler("onClientGameStop", g_Root, onGameStop)
	addEventHandler("onClientPlayerWasted", g_Me, onLocalPlayerWasted)
	
	triggerServerEvent("race_onPlayerReady", g_Me)
	setTimer(checkWater, 1000, 0)
end

local function init()
	setTimer(initDelayed, 50, 1)
end

function getTimePassed()
	if(not getCurrentRoom) then return false end
	
	local room = getCurrentRoom()
	local state = room and getElementData(room, "race.state")
	if(state ~= "running" or not g_StartTime) then
		return false
	end
	
	return getTickCount() - g_StartTime, g_TimeLimit
end

function requestRespawn()
	triggerServerEvent("race_onRespawnReq", g_ResRoot)
end

addEventHandler("onClientResourceStart", g_ResRoot, init)

