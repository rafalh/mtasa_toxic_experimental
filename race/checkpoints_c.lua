local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()
local g_Player = g_Me
local g_Checkpoints = {}
local g_Current, g_Next

Checkpoints = {}

addEvent("race_onPlayerReachCp", true)

function Checkpoints.load()
	Checkpoints.unload()
	
	local room = getCurrentRoom()
	local mapInfo = getElementData(room, "mapinfo")
	
	local first
	local idToCp = {}
	
	local checkpoints = getElementsByType("checkpoint")
	if(#checkpoints == 0) then return end
	
	for i, el in ipairs(checkpoints) do
		local cp = {}
		cp.x = tonumber(getElementData(el, "posX")) or 0
		cp.y = tonumber(getElementData(el, "posY")) or 0
		cp.z = tonumber(getElementData(el, "posZ")) or 0
		cp.type = getElementData(el, "type") or "checkpoint"
		cp.vehModel = tonumber(getElementData(el, "vehicle"))
		cp.size = tonumber(getElementData(el, "size")) or 4
		cp.nextid = getElementData(el, "nextid")
		cp.id = getElementID(el)
		
		if(mapInfo._MTARM) then
			cp.size = cp.size * 4
		end
		
		cp.r, cp.g, cp.b, cp.a = getColorFromString(getElementData(el, "color") or "")
		if(not cp.r) then
			cp.r, cp.g, cp.b, cp.a = 0, 0, 255, 255
		end
		
		idToCp[cp.id] = cp
		if(not first) then
			first = cp
		end
	end
	
	local cp = first
	repeat
		table.insert(g_Checkpoints, cp)
		cp.idx = #g_Checkpoints
		cp = idToCp[cp.nextid or false]
	until(not cp)
	
	Checkpoints.setCurrent(first)
	--outputChatBox("Loaded "..#checkpoints.." checkpoints (client-side)")
end

function Checkpoints.unload()
	Checkpoints.destroyCp(g_Current)
	g_Current = false
	
	Checkpoints.destroyCp(g_Next)
	g_Next = false
	
	g_Checkpoints = {}
end

function Checkpoints.createCp(cp, isCurrent)
	if(not cp) then return end
	
	local room = getCurrentRoom()
	local dim = room and getElementDimension(room)
	if(not dim) then return end
	
	if(isCurrent) then
		cp.marker = createMarker(cp.x, cp.y, cp.z, cp.type, cp.size, cp.r, cp.g, cp.b, cp.a)
	elseif(cp.type == "checkpoint" or cp.type == "arrow") then
		cp.marker = createMarker(cp.x, cp.y, cp.z, cp.type, cp.size, cp.r/3, cp.g/3, cp.b/3, cp.a)
	else
		cp.marker = createMarker(cp.x, cp.y, cp.z, cp.type, cp.size, cp.r, cp.g, cp.b, cp.a/2)
	end
	setElementDimension(cp.marker, dim)
	
	if(cp.type == "checkpoint") then
		cp.colshape = createColCircle(cp.x, cp.y, cp.size + 4)
	else
		cp.colshape = createColSphere(cp.x, cp.y, cp.z, cp.size + 4)
	end
	setElementDimension(cp.colshape, dim)
	
	cp.blip = createBlip(cp.x, cp.y, cp.z, 0, isCurrent and 2 or 1, cp.r, cp.g, cp.b)
	setElementDimension(cp.blip, dim)
	
	local next_cp = g_Checkpoints[cp.idx + 1]
	if(next_cp) then
		setMarkerTarget(cp.marker, next_cp.x, next_cp.y, next_cp.z)
	else
		setMarkerIcon(cp.marker, "finish")
	end
end

function Checkpoints.destroyCp(cp)
	if(not cp) then return end
	
	destroyElement(cp.colshape)
	destroyElement(cp.marker)
	destroyElement(cp.blip)
end

function Checkpoints.setCurrent(cp)
	if(cp == g_Current) then return end
	
	Checkpoints.destroyCp(g_Current)
	Checkpoints.destroyCp(g_Next)
	
	g_Current = cp
	g_Next = cp and g_Checkpoints[cp.idx + 1]
	
	Checkpoints.createCp(g_Current, true)
	Checkpoints.createCp(g_Next)
end

function Checkpoints.spectate(player)
	g_Player = player or g_Me
	local cp = tonumber(getElementData(g_Player, "race.cp"))
	if(cp) then
		Checkpoints.setCurrent(g_Checkpoints[cp + 1])
	end
end

function Checkpoints.onCollision(veh)
	if(not g_Current or source ~= g_Current.colshape or getElementType(veh) ~= "vehicle") then return end
	
	local player = getVehicleOccupant(veh)
	if(not player) then return end
	
	if(player == g_Player) then
		if(g_Player == g_Me) then
			triggerServerEvent("race_onPlayerReachCp", player, g_Current.idx)
		end
		
		if(g_Current.vehModel) then
			local currentModel = getElementModel(veh)
			if(currentModel ~= g_Current.vehModel) then
				setElementModel(veh, g_Current.vehModel)
				alignVehicle(veh)
			end
		end
		
		Checkpoints.setCurrent(g_Next)
		playSoundFrontEnd(43)
	end
end

addEvent("onClientMapStarting")
addEvent("onClientMapStopping")
addEventHandler("onClientMapStarting", g_Root, Checkpoints.load)
addEventHandler("onClientMapStopping", g_Root, Checkpoints.unload)
addEventHandler("onClientColShapeHit", g_Root, Checkpoints.onCollision)
addEventHandler("onClientGameStop", g_Root, Checkpoints.unload)
