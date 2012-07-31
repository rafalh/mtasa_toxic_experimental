local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()
local g_ModelForPickupType = { nitro = 2221, repair = 2222, vehiclechange = 2223 }
local g_Pickups = {}

local Pickups = {}

function Pickups.load()
	Pickups.unload()
	
	local pickups = getElementsByType("racepickup")
	for i, el in ipairs(pickups) do
		local x = tonumber(getElementData(el, "posX"))
		local y = tonumber(getElementData(el, "posY"))
		local z = tonumber(getElementData(el, "posZ"))
		local type = getElementData(el, "type")
		local model = g_ModelForPickupType[type]
		if(x and y and z and model) then
			local pickup = {}
			
			pickup.obj = createObject(model, x, y, z)
			setElementDimension(pickup.obj, 1)
			
			pickup.type = type
			pickup.vehicle = tonumber(getElementData(el, "vehicle"))
			
			local col = createColSphere(x, y, z, 4)
			g_Pickups[col] = pickup
		end
	end
	
	outputChatBox("Loaded "..#pickups.." pickups")
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

function Pickups.onCollision(el)
	local pickup = g_Pickups[source]
	if(not pickup or getElementType(el) ~= "vehicle") then return end
	
	if(pickup.type == "nitro") then
		addVehicleUpgrade(el, 1010)
	elseif(pickup.type == "repair") then
		fixVehicle(el)
	elseif(pickup.type == "vehiclechange") then
		setElementModel(el, pickup.vehicle)
	else
		return
	end
	
	playSoundFrontEnd(46)
end

addEventHandler("onClientResourceStart", g_ResRoot, Pickups.init)
addEventHandler("onClientMapStarting", g_Root, Pickups.load)
addEventHandler("onClientMapStopping", g_Root, Pickups.unload)
addEventHandler("onClientPreRender", g_Root, Pickups.animate)
addEventHandler("onClientColShapeHit", g_Root, Pickups.onCollision)
