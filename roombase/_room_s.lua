local g_Root = getRootElement()
local g_Res = getThisResource()
local g_ResRoot = getResourceRootElement()
local g_EventHandlers = {}
local g_Dim = false

addEvent("room_onStart")

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

local function destroyMap()
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
			if(not destroyElement(el)) then
				outputDebugString("destroyElement "..getElementType(el).." failed", 2)
			else
				destroyedCount = destroyedCount + 1
			end
		end
	end
	
	local timers = getTimers()
	for i, timer in ipairs(timers) do
		killTimer(timer)
	end
end

local function onStart(scripts)
	g_Dim = getElementDimension(g_ResRoot)
	
	for i, path in ipairs(scripts) do
		local file = fileOpen(path, true)
		if(file) then
			local size = fileGetSize(file)
			local buf = size > 0 and fileRead(file, size) or ""
			fileClose(file)
			local func = loadstring(buf, path)
			func()
		else
			outputDebugString("Failed to load server-side script "..path, 1)
		end
	end
	
	triggerMapEventHandlers("onClientResourceStart", g_ResRoot, g_Res)
end

addEventHandler("room_onStart", g_ResRoot, onStart)

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
	local elements = _getElementsByType(type)
	if(type ~= "player" or not elements) then
		return elements
	end
	
	local ret = {}
	local roomID = getElementData(g_ResRoot, "roomid")
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
