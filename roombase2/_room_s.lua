local g_root = getRootElement()
local g_resource = getThisResource()
local g_resourceRoot = getResourceRootElement()
local g_resourceName = getResourceName(g_resource)
local g_readyPlayers = {}

local g_wrappers = {}
setmetatable(g_wrappers, { __mode = 'v' })

g_roomDim = get('#'..g_resourceName..'._roomDim')
g_roomId = get('#'..g_resourceName..'._roomId')

local function startIncludedResources()
	local resources = get('#'..g_resourceName..'._includedResources')
	for i, resName in ipairs(resources) do
		local res = getResourceFromName(resName)
		if res then
			local roomRes = call(getResourceFromName('roommgr'), 'getResourceForRoom', res, g_roomId)
			if getResourceState(roomRes) == 'loaded' then
				startResource(roomRes)
			end
		end
	end
end
startIncludedResources()

local function loadClientFiles(player)
	local clientFiles = get('#'..g_resourceName..'._clientFiles')
	table.insert(clientFiles, 1, {kind='script', src='_room_c.lua', once=true})
	table.insert(clientFiles, 2, {kind='script', src='_room.lua', once=true})
	triggerClientEvent(player, '_onClientFiles', g_resourceRoot, clientFiles, g_roomId, g_roomDim)
end

addEvent('_onReady', true)
addEventHandler('_onReady', g_resourceRoot, function ()
	g_readyPlayers[client] = true
	local playerRoomId = getElementData(client, 'roomid')
	if playerRoomId == g_roomId then
		loadClientFiles(client)
	else
		outputDebugString('Not loading client-side scripts in resource '..g_resourceName..' for player '..getPlayerName(client), 3)
	end
end)

addEventHandler('onResourceStart', g_resourceRoot, function ()
	setElementData(g_resourceRoot, 'roomid', g_roomId)
end, false, 'high+100')

addEventHandler('onPlayerEnterRoom', g_root, function (roomId)
	if roomId == g_roomId and g_readyPlayers[source] then
		loadClientFiles(source)
		_room_runEventHandlers('onPlayerJoin', source)
	end
end)

addEventHandler('onPlayerLeaveRoom', g_root, function (roomId)
	if roomId == g_roomId then
		_room_runEventHandlers('onPlayerQuit', source, 'Quit', false)
	end
end)

-- HOOKS

local _spawnPlayer = spawnPlayer
function spawnPlayer(player, x, y, z, rotation, skinID, interior, dimension, ...)
	if not dimension or dimension == 0 then
		dimension = g_roomDim
	end
	return _spawnPlayer(player, x, y, z, rotation, skinID, interior, dimension, ...)
end
if Player then Player.spawn = spawnPlayer end

local _get = get
function get(name)
	local value = _get(name)
	if value ~= nil then return value end
	local access, resourceName, settingName = name:match('^([*#@]?)(.+)%.([^%.]+)$')
	if resourceName == g_resourceName then
		local baseResName = g_resourceName:match('^_(.+)@.+$')
		value = _get('*'..baseResName..'.'..settingName)
	end
	return _get(name)
end

local function createPlayerFunctionWrapper(funName, fun, playerArgIndex, assumeRoot)
	playerArgIndex = playerArgIndex or 1
	assumeRoot = assumeRoot or false
	return function (...)
		local args = { ... }
		local playerArg = args[playerArgIndex]
		if assumeRoot and playerArg == nil then
			playerArg = g_root
		end
		if isElement(playerArg) and getElementType(playerArg) ~= 'player' then
			local result = true
			local players = getElementsByType('player', playerArg)
			--outputDebugString(funName..': changing player arg - num players '..#players..' in '..getResourceName(getThisResource()))
			
			for i, player in ipairs(players) do
				args[playerArgIndex] = player
				result = result and fun(unpack(args))
			end
			return result
		else
			--outputDebugString(funName..': not changing player arg in '..getResourceName(getThisResource()))
			return fun(...)
		end
	end
end

local function hookPlayerFunction(funName, ...)
	_G[funName] = createPlayerFunctionWrapper(funName, _G[funName], ...)
end

hookPlayerFunction('playSoundFrontEnd')
hookPlayerFunction('outputChatBox', 2)
hookPlayerFunction('fadeCamera', 1)
hookPlayerFunction('setCameraInterior', 1)
hookPlayerFunction('setCameraMatrix', 1)
hookPlayerFunction('setCameraTarget', 1)
hookPlayerFunction('showCursor', 1)
hookPlayerFunction('forcePlayerMap', 1)
hookPlayerFunction('setPlayerBlurLevel', 1)
hookPlayerFunction('setPlayerHudComponentVisible', 1)
hookPlayerFunction('setPlayerMoney', 1)
hookPlayerFunction('setPlayerMuted', 1)
hookPlayerFunction('setPlayerWantedLevel', 1)
hookPlayerFunction('showPlayerHudComponent', 1)
hookPlayerFunction('takePlayerMoney', 1)
hookPlayerFunction('detonateSatchels', 1)
hookPlayerFunction('outputConsole', 2, true)
hookPlayerFunction('showChat', 1)
hookPlayerFunction('resetMapInfo', 1, true)


-- Block setting global server state
local function dummy()
	return false
end
setGameType = dummy
setMapName = dummy
setFPSLimit = dummy
setGlitchEnabled = dummy

local function hookWorldFunction(getFnName, setFnName, resetFnName)
	local orgGetFn = _G[getFnName]
	_G[getFnName] = function ()
		return exports.roommgr:getRoomWorldState(g_roomId, getFnName)
	end

	_G[setFnName] = function (...)
		return exports.roommgr:setRoomWorldState(g_roomId, getFnName, setFnName, ...)
	end

	if resetFnName then
		_G[resetFnName] = function ()
			return exports.roommgr:resetRoomWorldState(g_roomId, getFnName, setFnName)
		end
	end
end

hookWorldFunction('areTrafficLightsLocked', 'setTrafficLightsLocked')
hookWorldFunction('getCloudsEnabled', 'setCloudsEnabled')
hookWorldFunction('getGameSpeed', 'setGameSpeed')
hookWorldFunction('getGravity', 'setGravity')
hookWorldFunction('getHeatHaze', 'setHeatHaze', 'resetHeatHaze')
hookWorldFunction('getJetpackMaxHeight', '')
hookWorldFunction('getMinuteDuration', 'setMinuteDuration')
hookWorldFunction('getSkyGradient', 'setSkyGradient', 'resetSkyGradient')
hookWorldFunction('getTime', 'setTime')
hookWorldFunction('getTrafficLightState', 'setTrafficLightState')
hookWorldFunction('getWeather', 'setWeather')
setWeatherBlended = dummy -- TODO
-- TODO: isGarageOpen setGarageOpen
hookWorldFunction('getInteriorSoundsEnabled', 'setInteriorSoundsEnabled')
hookWorldFunction('getRainLevel', 'setRainLevel', 'resetRainLevel')
hookWorldFunction('getSunSize', 'setSunSize', 'resetSunSize')
hookWorldFunction('getSunColor', 'setSunColor', 'resetSunColor')
hookWorldFunction('getWindVelocity', 'setWindVelocity', 'resetWindVelocity')
hookWorldFunction('getFarClipDistance', 'setFarClipDistance', 'resetFarClipDistance')
hookWorldFunction('getFogDistance', 'setFogDistance', 'resetFogDistance')
-- TODO: removeWorldModel restoreWorldModel restoreAllWorldModels
hookWorldFunction('getOcclusionsEnabled', 'setOcclusionsEnabled')
-- TODO: setJetpackWeaponEnabled getJetpackWeaponEnabled
hookWorldFunction('getAircraftMaxVelocity', 'setAircraftMaxVelocity')
hookWorldFunction('getMoonSize', 'setMoonSize', 'resetMoonSize')



local _triggerClientEvent = triggerClientEvent
function triggerClientEvent(sendTo, ...)
	-- Note: not using createPlayerFunctionWrapper because _triggerClientEvent can use array
	if type(sendTo) == 'string' then
		return triggerClientEvent(g_root, sendTo, ...)
	end
	if isElement(sendTo) then
		sendTo = getElementsByType('player', sendTo)
	end
	return _triggerClientEvent(sendTo, ...)
end

local _addCommandHandler = addCommandHandler
function addCommandHandler(commandName, handlerFunction, ...)
	local wrapper = g_wrappers[handlerFunction]
	if not wrapper then
		local originalFunc = handlerFunction
		wrapper = function (playerSource, ...)
			local playerRoomId = getElementData(playerSource, 'roomid')
			if playerRoomId ~= g_roomId then return end
			originalFunc(playerSource, ...)
		end
		g_wrappers[handlerFunction] = wrapper
	end
	handlerFunction = wrapper
	return _addCommandHandler(commandName, handlerFunction, ...)
end

local _removeCommandHandler = removeCommandHandler
function removeCommandHandler(commandName, handlerFunction)
	local wrapper = handlerFunction and g_wrappers[handlerFunction]
	if wrapper then
		handlerFunction = wrapper
	end
	return _removeCommandHandler(commandName, handlerFunction)
end

local _bindKey = bindKey
function bindKey(thePlayer, key, keyState, handlerFunction, ...)
	local wrapper = g_wrappers[handlerFunction]
	if not wrapper then
		local originalFunc = handlerFunction
		wrapper = function (player, ...)
			local playerRoomId = getElementData(player, 'roomid')
			if playerRoomId ~= g_roomId then return end
			originalFunc(player, ...)
		end
		g_wrappers[handlerFunction] = wrapper
	end
	handlerFunction = wrapper
	return _bindKey(thePlayer, key, keyState, handlerFunction, ...)
end

local _unbindKey = unbindKey
function unbindKey(thePlayer, key, keyState, handlerFunction, ...)
	local wrapper = handlerFunction and g_wrappers[handlerFunction]
	if wrapper then
		handlerFunction = wrapper
	end
	return _unbindKey(thePlayer, key, keyState, handlerFunction, ...)
end

local _getResources = getResources
function getResources(...)
	local resources = _getResources(...)
	local filteredResources = {}
	for i, res in ipairs(resources) do
		local resName = getResourceName(res)
		local resRoomId = resName:match('^_.+@(.+)$')
		-- Note: mapmanager expects to see running map in this list
		if not resRoomId or resRoomId == g_roomId then
			table.insert(filteredResources, res)
		end
	end
	return filteredResources
end

local _getResourceFromName = getResourceFromName
function getResourceFromName(resName)
	local roomRes = _getResourceFromName('_'..resName..'@'..g_roomId)
	if roomRes then return roomRes end
	return _getResourceFromName(resName)
end

local _startResource = startResource
function startResource(res, ...)
	local roomRes = call(_getResourceFromName('roommgr'), 'getResourceForRoom', res, g_roomId)
	return _startResource(roomRes, ...)
end

local _restartResource = restartResource
function restartResource(res, ...)
	local roomRes = call(_getResourceFromName('roommgr'), 'getResourceForRoom', res, g_roomId)
	return _restartResource(roomRes, ...)
end

local _stopResource = stopResource
function stopResource(res, ...)
	local roomRes = call(_getResourceFromName('roommgr'), 'getResourceForRoom', res, g_roomId)
	return _stopResource(roomRes, ...)
end

local exportsMT = getmetatable(exports)
local oldIndexFun = exportsMT.__index
exportsMT.__index = function (tbl, key)
	local roomResName = '_'..key..'@'..g_roomId
	if getResourceFromName(roomResName) then
		return oldIndexFun(tbl, roomResName)
	else
		return oldIndexFun(tbl, key)
	end
end
