local g_Root = getRootElement()
local g_Res = getThisResource()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()
local g_Files = {map = {}, file = {}, script = {}}
local g_EventHandlers = {}
local g_Dim, g_Settings, g_MapPath
local g_MapStr = ""
local g_MapStarted = false

addEvent("onMapInit", true)
addEvent("onMapStartReq", true)
addEvent("onMapStopReq", true)
addEvent("onItemTransferComplete")
addEvent("onClientMapStarting")
addEvent("onClientMapStopping")

local function createDbgTimer()
	local ticks = getTickCount()
	local func = function(title,time)
		local dt = getTickCount() - ticks
		local time = time or 50
		ticks = ticks + dt
		if(dt > time) then
			outputDebugString("Too slow ("..dt.." ms) - "..(title or "unknown place"), 2)
		end
	end
	return func
end

local function triggerMapEventHandlers(eventName, eventSource, ...)
	local oldSource = source
	source = eventSource
	
	local el = eventSource
	while(true) do
		local handlers = g_EventHandlers[el] and g_EventHandlers[el][eventName] or {}
		for i, func in ipairs(handlers) do
			func(...)
		end
		
		if(el == g_Root) then break end
		el = getElementParent(el)
	end
	
	source = oldSource
end

local function saveFileList(list)
	local buf = table.concat(list, "\n")
	local file = fileCreate("_filelist")
	if(not file) then return false end
	fileWrite(file, buf)
	fileClose(file)
	return true
end

local function loadFileList()
	local file = fileExists("_filelist") and fileOpen("_filelist", true)
	if(not file) then return false end
	local size = fileGetSize(file)
	local buf = size > 0 and fileRead(file, fileGetSize(file)) or ""
	fileClose(file)
	local list = split(buf, "\n")
	return list
end

local function deleteDelayed()
	local list = loadFileList() or {}
	for i, path in ipairs(list) do
		if(fileExists(path)) then
			fileDelete(path)
		end
	end
	if(fileExists("_filelist")) then
		fileDelete("_filelist")
	end
end

local function destroyMap()
	if(g_MapStarted) then
		triggerEvent("onClientMapStopping", g_Me)
		g_MapStarted = false
	end
	
	triggerMapEventHandlers("onClientResourceStop", g_ResRoot, g_Res)
	
	for el, events in pairs(g_EventHandlers) do
		for name, funcList in pairs(events or {}) do
			for i, func in pairs(funcList or {}) do
				removeEventHandler(name, el, func)
			end
		end
	end
	g_EventHandlers = {}
	
	local destroyedCount = 0
	local roots = getElementChildren(g_ResRoot)
	for i, root in ipairs(roots) do
		for i, el in ipairs(getElementChildren(root)) do
			if(isElementLocal(el)) then
				if(not destroyElement(el)) then
					outputDebugString("destroyElement "..getElementType(el).." failed", 2)
				else
					destroyedCount = destroyedCount + 1
				end
			end
		end
	end
	outputDebugString("Destroyed "..destroyedCount.." elements", 3)
	
	local cnt = #getElementsByType("sound", g_ResRoot)
	if(cnt ~= 0) then outputDebugString("Found "..cnt.." sounds", 2) end
	cnt = #getElementsByType("checkpoint", g_ResRoot)
	if(cnt ~= 0) then outputDebugString("Found "..cnt.." checkpoints", 2) end
	cnt = #getElementsByType("spawnpoint", g_ResRoot)
	if(cnt ~= 0) then outputDebugString("Found "..cnt.." spawnpoints", 2) end
	cnt = #getElementsByType("racepickup", g_ResRoot)
	if(cnt ~= 0) then outputDebugString("Found "..cnt.." pickups", 2) end
	
	local timers = getTimers()
	for i, timer in ipairs(timers) do
		killTimer(timer)
	end
	
	local delayedDelete = {}
	for fileType, files in pairs(g_Files) do
		for i, path in ipairs(files) do
			if(fileExists(path)) then
				if(not fileDelete(path)) then
					--outputDebugString("Failed to delete "..path, 2)
					table.insert(delayedDelete, path)
				end
			end
		end
		
		g_Files[fileType] = {}
	end
	
	if(#delayedDelete > 0) then
		saveFileList(delayedDelete)
	end
end

local function applySettings(settings)
	setGameSpeed(settings.gamespeed)
	local timeTbl = split(settings.time, ":")
	setTime(timeTbl[1], timeTbl[2])
	setWeather(settings.weather)
	setGravity(settings.gravity)
	setWaveHeight(settings.waveheight)
	setMinuteDuration(settings.locked_time and 0 or 1000)
end

local function onMapInit(dim, settings, path)
	destroyMap()
	
	g_Dim = dim
	g_Settings = settings
	g_MapPath = path or ""
end

local function fileGetContents(path)
	local file = fileOpen(path, true)
	if(not file) then
		outputDebugString("Failed to open "..path, 2)
		return false
	end
	
	local size = fileGetSize(file)
	local buf = size > 0 and fileRead(file, size) or ""
	fileClose(file)
	
	return buf
end

local function execScript(path)
	local data = fileGetContents(path)
	if(not data) then return false end
	
	local f, msg = loadstring(data, g_MapPath.."/"..path)
	if(not f) then
		outputDebugString("Failed to load "..path..": "..msg, 2)
		return false
	end
	
	local status, msg = pcall(f)
	if(not status) then
		outputDebugString("Loading "..path.." failed: "..msg, 2)
		return false
	end
	
	return true
end

local function loadObject(data)
	local model = tonumber(data.model)
	local x, y, z = tonumber(data.posX), tonumber(data.posY), tonumber(data.posZ)
	local rx, ry, rz = tonumber(data.rotX) or 0, tonumber(data.rotY) or 0, tonumber(data.rotZ) or 0
	if(model and x and y and z) then
		local obj = createObject(model, x, y, z, rx, ry, rz)
		if(obj) then
			if(data.id) then
				setElementID(obj, data.id)
			end
			if(LOAD_BUILTIN_ELEMENTS_DATA) then
				for k, v in pairs(data) do
					setElementData(obj, k, v, false)
				end
			end
		else
			outputDebugString("Failed to create object "..model, 2)
			return false
		end
	end
	return true
end

local function loadVehicle(data)
	local model = tonumber(data.model)
	local x, y, z = tonumber(data.posX), tonumber(data.posY), tonumber(data.posZ)
	local rx, ry, rz = tonumber(data.rotX) or 0, tonumber(data.rotY) or 0, tonumber(data.rotZ) or 0
	local paintjob = tonumber(data.paintjob)
	local color = data.color and split(data.color, ",")
	
	if(model and x and y and z) then
		local veh = createVehicle(model, x, y, z, rx, ry, rz)
		if(veh) then
			if(data.id) then
				setElementID(veh, data.id)
			end
			if(paintjob) then
				setVehiclePaintjob(veh, paintjob)
			end
			if(color and #color == 3) then
				setVehicleColor(veh, unpack(color))
			end
			if(LOAD_BUILTIN_ELEMENTS_DATA) then
				for k, v in pairs(data) do
					setElementData(veh, k, v, false)
				end
			end
		else
			outputDebugString("Failed to create vehicle "..model, 2)
			return false
		end
	end
	return true
end

local function loadMarker(data)
	local x, y, z = tonumber(data.posX), tonumber(data.posY), tonumber(data.posZ)
	local rx, ry, rz = tonumber(data.rotX) or 0, tonumber(data.rotY) or 0, tonumber(data.rotZ) or 0
	local clr = data.clr
	local type = data.type or "corona"
	local size = data.size or 4
	
	if(x and y and z) then
		local marker = createMarker(x, y, z, type, size)
		if(marker) then
			if(data.id) then
				setElementID(marker, data.id)
			end
			if(LOAD_BUILTIN_ELEMENTS_DATA) then
				for k, v in pairs(data) do
					setElementData(marker, k, v, false)
				end
			end
		else
			outputDebugString("Failed to create marker", 2)
			return false
		end
	end
	return true
end

local function loadElement(name, data)
	local el = createElement(name, data.id)
	if(el) then
		for k, v in pairs(data) do
			setElementData(el, k, v, false)
		end
	else
		outputDebugString("Failed to create element "..name, 2)
		return false
	end
	return true
end

local function loadMap(mapStr)
	local mapEl = fromJSON(mapStr)
	if(not mapEl) then
		outputDebugString("Failed to load map", 2)
		return false
	end
	
	local objCount, vehCount, markerCount, elCount = 0, 0, 0, 0
	local objCountFailed, vehCountFailed, markerCountFailed, elCountFailed = 0, 0, 0, 0
	
	for elType, elList in pairs(mapEl) do
		for i, data in ipairs(elList) do
			if(elType == "object") then
				local b = loadObject(data)
				if b then
					objCount = objCount + 1
				else
					objCountFailed = objCountFailed + 1
				end
			elseif(elType == "vehicle") then
				local b = loadVehicle(data)
				vehCount = vehCount + 1
				if b then
					vehCount = vehCount + 1
				else
					vehCountFailed = vehCountFailed + 1
				end
			elseif(elType == "marker") then
				local b = loadMarker(data)
				if b then
					markerCount = markerCount + 1
				else
					markerCountFailed = markerCountFailed + 1
				end
			else
				local b = loadElement(elType, data)
				if b then
					elCount = elCount + 1
				else
					elCountFailed = elCountFailed + 1
				end
			end
		end
	end
	
	outputDebugString("Loaded "..objCount.." ("..objCountFailed..") objects, "..vehCount.." ("..vehCountFailed..") vehicles, "..markerCount.." ("..markerCountFailed..") markers and "..elCount.." ("..elCountFailed..") elements", 3)
	
	return true
end

local function onItemTransferComplete(mapStr, roomId, name)
	if(roomId ~= getElementData(g_ResRoot, "roomid") or name ~= "map") then return end
	
	g_MapStr = mapStr
	--outputDebugString("onItemTransferComplete "..g_MapStr:len().." B", 3)
end

local function onMapStartReq(files)
	g_Files = files
	outputDebugString("onMapStartReq ("..#g_Files.map.." maps)", 3)
	local dbgTimer = createDbgTimer()
	
	applySettings(g_Settings)
	dbgTimer("settings")
	
	loadMap(g_MapStr)
	g_MapStr = ""
	dbgTimer("loadMap",200)
	
	for i, path in ipairs(g_Files.script) do
		execScript(path)
	end
	dbgTimer("execScript")
	
	setElementDimension(g_Me, g_Dim)
	
	triggerMapEventHandlers("onClientResourceStart", g_ResRoot, g_Res)
	dbgTimer("triggerMapEventHandlers")
	
	triggerEvent("onClientMapStarting", g_ResRoot, g_Res)
	triggerServerEvent("room_onMapStarting", g_ResRoot)
	g_MapStarted = true
	
	dbgTimer("misc")
end

local function onMapStopReq()
	destroyMap()
	outputDebugString("onMapStopReq", 3)
	g_MapStr = ""
end

local function onResStart()
	triggerServerEvent("room_onMapReady", g_ResRoot)
	deleteDelayed()
end

local function onResStop()
	destroyMap()
end

-- EVENTS
addEventHandler("onMapInit", g_ResRoot, onMapInit)
addEventHandler("onItemTransferComplete", g_Root, onItemTransferComplete)
addEventHandler("onMapStartReq", g_ResRoot, onMapStartReq)
addEventHandler("onMapStopReq", g_ResRoot, onMapStopReq)
addEventHandler("onClientResourceStart", g_ResRoot, onResStart)
addEventHandler("onClientResourceStop", g_ResRoot, onResStop)

-- HOOKS

local _addEventHandler = addEventHandler
function addEventHandler(name, attachedTo, func, ...)
	local ret = _addEventHandler(name, attachedTo, func, ...)
	if(not ret) then return ret end
	
	if(not g_EventHandlers[attachedTo]) then
		g_EventHandlers[attachedTo] = {}
	end
	
	if(not g_EventHandlers[attachedTo][name]) then
		g_EventHandlers[attachedTo][name] = {}
	end
	
	table.insert(g_EventHandlers[attachedTo][name], func)
	return ret
end

local _removeEventHandler = removeEventHandler
function removeEventHandler(name, attachedTo, func)
	local ret = _removeEventHandler(name, attachedTo, func)
	if(not ret) then return ret end
	
	local eventHandlers = g_EventHandlers[attachedTo] and g_EventHandlers[attachedTo][name] or {}
	for i, curFunc in ipairs(eventHandlers) do
		if(curFunc == func) then
			table.remove(eventHandlers, i)
			break
		end
	end
	
	return ret
end

local _getElementsByType = getElementsByType
function getElementsByType(type, ...)
	local elements = _getElementsByType(type, ...)
	if(type ~= "player" or not elements) then
		return elements
	end
	
	local ret = {}
	local roomID = getElementData(g_Me, "roomid")
	for i, player in ipairs(elements) do
		if(getElementData(player, "roomid") == roomID) then
			table.insert(ret, player)
		end
	end
	
	return ret
end

local _setElementDimension = setElementDimension
function setElementDimension(el, dim)
	if(dim == 0) then
		dim = g_Dim
	end
	return _setElementDimension(el, dim)
end

local _createObject = createObject
function createObject(...)
	local obj = _createObject(...)
	if(obj) then
		_setElementDimension(obj, g_Dim)
	end
	return obj
end

local _createVehicle = createVehicle
function createVehicle(...)
	local veh = _createVehicle(...)
	if(veh) then
		_setElementDimension(veh, g_Dim)
	end
	return veh
end

local _createMarker = createMarker
function createMarker(...)
	local marker = _createMarker(...)
	if(marker) then
		_setElementDimension(marker, g_Dim)
	end
	return marker
end
