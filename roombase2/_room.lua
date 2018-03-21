local g_root = getRootElement()
local g_eventHandlerWrappers = {}
local g_eventHandlers = {}
-- Globals: g_roomId, g_roomDim

-- it's broken
--setmetatable(g_eventHandlerWrappers, { __mode = 'v' })
--setmetatable(g_eventHandlers, { __mode = 'v' })


function _room_runEventHandlers(eventName, eventSource, ...)
	local oldSource = source
	source = eventSource
	
	local el = eventSource
	while(true) do
		local handlers = g_eventHandlers[el] and g_eventHandlers[el][eventName] or {}
		for i, func in ipairs(handlers) do
			func(...)
		end
		
		if(el == g_root) then break end
		el = getElementParent(el)
	end
	
	source = oldSource
end

local _removeEventHandler = removeEventHandler
function _room_removeAllEventHandlers()
    local removedHandlers = 0
    for el, events in pairs(g_eventHandlers) do
        if isElement(el) then -- fixme: hack?
            for name, funcList in pairs(events or {}) do
				for i, func in pairs(funcList or {}) do
                    _removeEventHandler(name, el, func)
                    removedHandlers = removedHandlers + 1
                end
			end
		else
			outputDebugString('Invalid element in g_eventHandlers '..tostring(el), 2)
        end
	end
    g_eventHandlers = {}
    return removedHandlers
end

-- hooks

local _addEventHandler = addEventHandler
_room_addEventHandler = _addEventHandler
function addEventHandler(name, attachedTo, func, ...)
	local wrapper = g_eventHandlerWrappers[func]
	if not wrapper and func then
		local originalFunc = func
		wrapper = function (...)
			local sourceResourceRoomId = sourceResourceRoot and getElementData(sourceResourceRoot, 'roomid')
			if sourceResourceRoomId and sourceResourceRoomId ~= g_roomId then 
				--outputDebugString('event blocked#1 '..name, 3)
				return
			end

			local elRoomId = getElementData(source, 'roomid')
			if elRoomId and elRoomId ~= g_roomId then
				--outputDebugString('event blocked#2 '..name..' '..tostring(elRoomId)..' '..tostring(source), 3)
				return
			end

			if name == 'onResourcePreStart' then
				local res = ({...})[1]
				local resRoomId = getResourceName(res):match('^_.+@(.+)$')
				if resRoomId and resRoomId ~= g_roomId then
					--outputDebugString('event blocked#3 '..name..' '..tostring(elRoomId)..' '..tostring(source), 3)
					return
				end
			end

			originalFunc(...)
			if _room_clearEventHandlerEnv then
				_room_clearEventHandlerEnv()
			end
		end
		g_eventHandlerWrappers[func] = wrapper
	end
	func = wrapper

	local ret = _addEventHandler(name, attachedTo, func, ...)
	if not ret then
		outputDebugString(debug.traceback(), 2)
		return ret
	end
	--outputDebugString('addEventHandler '..name, 3)
	if not g_eventHandlers[attachedTo] then
		g_eventHandlers[attachedTo] = {}
	end
	
	if not g_eventHandlers[attachedTo][name] then
		g_eventHandlers[attachedTo][name] = {}
	end
	
	table.insert(g_eventHandlers[attachedTo][name], func)
	return ret
end

local _removeEventHandler = removeEventHandler
function removeEventHandler(name, attachedTo, func)
	local wrapper = g_eventHandlerWrappers[func]
	if wrapper then
		func = wrapper
	end

	local ret = _removeEventHandler(name, attachedTo, func)
	if(not ret) then return ret end
	
	local eventHandlers = g_eventHandlers[attachedTo] and g_eventHandlers[attachedTo][name] or {}
	for i, curFunc in ipairs(eventHandlers) do
		if curFunc == func then
			table.remove(eventHandlers, i)
			break
		end
	end
	
	return ret
end

local _getElementsByType = getElementsByType
function getElementsByType(type, ...)
	local elements = _getElementsByType(type, ...)
	if not elements then return elements end
	local filteredElements = {}
    for i, el in ipairs(elements) do
        local elRoomId = getElementData(el, 'roomid')
		if not elRoomId or elRoomId == g_roomId then
			table.insert(filteredElements, el)
		end
	end
	return filteredElements
end
if Element then Element.getAllByType = getElementsByType end

local _getElementByID = getElementByID
function getElementByID(id, ...)
	local el = getElementByID('_'..id..'@'..g_roomId)
	if not el then
		el = getElementByID(id)
	end
	return el
end
if Element then Element.getByID = getElementByID end

local _setElementDimension = setElementDimension
function setElementDimension(el, dim)
	if dim == 0 then
		dim = g_roomDim
	end
	return _setElementDimension(el, dim)
end
if Element then Element.setDimension = setElementDimension end

local function hookCreateElementFunction(funName, oopName)
	local oldFun = _G[funName]
	_G[funName] = function (...)
		local el = oldFun(...)
		if el then
			_setElementDimension(el, g_roomDim)
			setElementData(el, 'roomid', g_roomId)
		else
			local args = ''
			for i, v in ipairs({...}) do
				args = args..tostring(v)..' '
			end
			outputDebugString('Args: '..args, 2)
			outputDebugString(debug.traceback(), 2)
		end
		return el
	end

	local oop = _G[oopName]
	if oop then
		--local meta = getmetatable(oop)
		--meta.__call = _G[funName]
		oop.create = _G[funName]
	end
end

local _createElement = createElement
function createElement(elementType, elementID, ...)
	elementID = elementID and '_'..g_roomId..'@'..elementID
	local el = _createElement(elementType, elementID, ...)
	if el then
		_setElementDimension(el, g_roomDim)
		setElementData(el, 'roomid', g_roomId)
	end
	return el
end
if Element then Element.create = createElement end

hookCreateElementFunction('createBlip', 'Blip')
hookCreateElementFunction('createColCircle', 'ColShape.Circle')
hookCreateElementFunction('createColCuboid', 'ColShape.Cuboid')
hookCreateElementFunction('createColRectangle', 'ColShape.Rectangle')
hookCreateElementFunction('createColSphere', 'ColShape.Sphere')
hookCreateElementFunction('createColTube', 'ColShape.Tube')
hookCreateElementFunction('createColPolygon', 'ColShape.Polygon')
hookCreateElementFunction('createEffect', 'Effect')
hookCreateElementFunction('createLight', 'Light')
hookCreateElementFunction('createMarker', 'Marker')
hookCreateElementFunction('createObject', 'Object')
hookCreateElementFunction('createPed', 'Ped')
hookCreateElementFunction('createPickup', 'Pickup')
-- Note: projectile is created in 'creator' dimension
hookCreateElementFunction('createRadarArea', 'RadarArea')
hookCreateElementFunction('createSearchLight', 'SearchLight')
hookCreateElementFunction('createVehicle', 'Vehicle')
hookCreateElementFunction('createWater', 'Water')
hookCreateElementFunction('createWeapon', 'Weapon')
