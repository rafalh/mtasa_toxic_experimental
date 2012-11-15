local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()

local function updatePlayer(player, veh)
	if(not veh) then
		veh = getPedOccupiedVehicle(player)
		if(not veh) then return end
	end
	
	assert(isElement(veh))
	local ghost = getElementData(player, "race.ghost")
	
	--outputDebugString("update player "..getPlayerName(player).." - "..tostring(ghost), 3)
	
	for i, veh2 in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(veh, veh2, not ghost)
		setElementCollidableWith(veh2, veh, not ghost)
	end
	
	local alpha = ghost and 130 or 255
	setElementAlpha(player, alpha)
	setElementAlpha(veh, alpha)
end

function onPlayerVehEnter(veh)
	updatePlayer(source, veh)
end

local function onPlayerDataChange(dataName)
	if(dataName == "race.ghost") then
		updatePlayer(source)
	end
end

local function onPlayerJoin()
	local player = source
	addEventHandler("onClientElementDataChange", player, onPlayerDataChange)
end

local function init()
	for i, player in ipairs(getElementsByType("player")) do
		addEventHandler("onClientElementDataChange", player, onPlayerDataChange)
		updatePlayer(player)
	end
end

addEventHandler("onClientPlayerVehicleEnter", g_Root, onPlayerVehEnter)
addEventHandler("onClientPlayerJoin", g_Root, onPlayerJoin)
addEventHandler("onClientResourceStart", g_ResRoot, init)
