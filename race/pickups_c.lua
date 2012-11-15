local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()
local g_ModelForPickupType = { nitro = 2221, repair = 2222, vehiclechange = 2223 }
local g_Pickups = {}

local Pickups = {}

function Pickups.load()
	Pickups.unload()
	
	local room = getCurrentRoom()
	local dim = room and getElementDimension(room)
	if(not dim) then return end
	
	local pickups = getElementsByType("racepickup")
	for i, el in ipairs(pickups) do
		local x = tonumber(getElementData(el, "posX"))
		local y = tonumber(getElementData(el, "posY"))
		local z = tonumber(getElementData(el, "posZ"))
		local type = getElementData(el, "type")
		local model = g_ModelForPickupType[type]
		if(x and y and z and model) then
			local pickup = {}
			
			pickup.pos = {x, y, z}
			pickup.obj = createObject(model, x, y, z)
			setElementDimension(pickup.obj, dim)
			
			pickup.type = type
			pickup.id = getElementID(el)
			pickup.vehicle = tonumber(getElementData(el, "vehicle"))
			
			local col = createColSphere(x, y, z, 4)
			g_Pickups[col] = pickup
		end
	end
	
	--outputDebugString("Loaded "..#pickups.." pickups", 3)
end

function Pickups.unload()
	for col, pickup in pairs(g_Pickups) do
		destroyElement(col)
		destroyElement(pickup.obj)
	end
	g_Pickups = {}
end

function Pickups.init()
	-- load pickup models and textures
	for name, id in pairs(g_ModelForPickupType) do
		engineImportTXD(engineLoadTXD('model/'..name..'.txd'), id)
		engineReplaceModel(engineLoadDFF('model/'..name..'.dff', id), id)
		-- Double draw distance for pickups
		engineSetModelLODDistance(id, 60)
	end
end

function Pickups.animate()
	local a = getTickCount() / 5
	for col, pickup in pairs(g_Pickups) do
		setElementRotation(pickup.obj, 0, 0, a)
	end
end

function Pickups.render()
	local cx, cy, cz = getCameraMatrix()
	for col, pickup in pairs(g_Pickups) do
		local pos = {pickup.pos[1], pickup.pos[2], pickup.pos[3] + 1}
		local dist = ((pos[1] - cx)^2 + (pos[2] - cy)^2 + (pos[3] - cz)^2)^0.5
		if(dist < 100 and pickup.type == "vehiclechange") then
			local x, y = getScreenFromWorldPosition(unpack(pos))
			if(x) then
				local name = engineGetModelNameFromID(pickup.vehicle) or "unknown"
				local scale = 8/(dist^0.5)
				if(name) then
					dxDrawText(name, x, y, x, y, tocolor(255, 255, 255), scale, "default", "center")
				end
			end
		end
	end
end

function Pickups.onCollision(veh)
	local pickup = g_Pickups[source]
	if(not pickup or getElementType(veh) ~= "vehicle") then return end
	
	local player = getVehicleOccupant(veh)
	if(not player) then return end
	
	if(pickup.type == "nitro") then
		removeVehicleUpgrade(veh, 1010)
		addVehicleUpgrade(veh, 1010)
	elseif(pickup.type == "repair") then
		fixVehicle(veh)
	elseif(pickup.type == "vehiclechange" and pickup.vehicle) then
		local currentModel = getElementModel(veh)
		if(currentModel == pickup.vehicle) then
			return
		end
		
		setElementModel(veh, pickup.vehicle)
		alignVehicle(veh)
	else
		return
	end
	
	if(player == g_Me) then
		triggerServerEvent("race_onPlayerPickup", player, pickup.id)
	end
	if(el == getCameraTarget()) then
		playSoundFrontEnd(46)
	end
end

addEvent("onClientMapStarting")
addEvent("onClientMapStopping")
addEventHandler("onClientResourceStart", g_ResRoot, Pickups.init)
addEventHandler("onClientMapStarting", g_Root, Pickups.load)
addEventHandler("onClientMapStopping", g_Root, Pickups.unload)
addEventHandler("onClientPreRender", g_Root, Pickups.animate)
addEventHandler("onClientRender", g_Root, Pickups.render)
addEventHandler("onClientColShapeHit", g_Root, Pickups.onCollision)
