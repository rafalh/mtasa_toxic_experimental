addEvent("race_loadVehicleData", true)
addEvent("race_saveVehicleData", true)
addEvent("race_removeVehicleData", true)
addEvent("onClientMapStopping")

local g_Stack = {}

local function loadVehData(remove)
	--outputDebugString("loadVehData "..tostring(remove).." "..#g_Stack, 3)
	
	local veh = source
	local data = g_Stack[#g_Stack]
	if(not data) then return false end
	
	if(remove) then
		 g_Stack[#g_Stack] = nil
	end
	
	setElementModel(veh, data.model)
	--respawnVehicle(veh)
	setElementPosition(veh, unpack(data.pos))
	setElementRotation(veh, unpack(data.rot))
	setElementVelocity(veh, unpack(data.vel))
	setVehicleTurnVelocity(veh, unpack(data.turnVel))
	setElementHealth(veh, data.hp)
	if(data.landingGearDown ~= nil) then
		setVehicleLandingGearDown(veh, data.landingGearDown)
	end
	if(data.nitro) then
		addVehicleUpgrade(veh, data.nitro)
	end
	if(data.adjProp) then
		setVehicleAdjustableProperty(veh, data.adjProp)
	end
	if(data.rotorSpeed) then
		setHelicopterRotorSpeed(veh, data.rotorSpeed)
	end
end

local function saveVehData()
	local veh = source
	local data = {}
	
	data.model = getElementModel(veh)
	data.pos = {getElementPosition(veh)}
	data.rot = {getElementRotation(veh)}
	data.vel = {getElementVelocity(veh)}
	data.turnVel = {getVehicleTurnVelocity(veh)}
	data.hp = getElementHealth(veh)
	data.nitro = getVehicleUpgradeOnSlot(veh, 8)
	data.landingGearDown = getVehicleLandingGearDown(veh)
	data.adjProp = getVehicleAdjustableProperty(veh)
	data.rotorSpeed = getHelicopterRotorSpeed(veh)
	
	table.insert(g_Stack, data)
end

local function removeVehData()
	g_Stack[#g_Stack] = nil
end

local function destroyVehData()
	--outputDebugString("destroyVehData", 3)
	g_Stack = {}
end

addEventHandler("race_loadVehicleData", g_Root, loadVehData)
addEventHandler("race_saveVehicleData", g_Root, saveVehData)
addEventHandler("race_removeVehicleData", g_Root, removeVehData)
addEventHandler("onClientMapStopping", g_Root, destroyVehData)
