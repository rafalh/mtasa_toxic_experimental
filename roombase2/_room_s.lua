local g_root = getRootElement()
local g_resource = getThisResource()
local g_resourceRoot = getResourceRootElement()
local g_resourceName = getResourceName(g_resource)
local g_readyPlayers = {}


g_roomDim = get('#'..g_resourceName..'._roomDim')
g_roomId = get('#'..g_resourceName..'._roomId')


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
	outputDebugString('onResourceStart in '..g_resourceName)
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
if Player then getmetatable(Player).__index.spawn = spawnPlayer end

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
function startResource(res)
	local resName = getResourceName(res)
	local resRoomId = resName:match('^_.+@(.+)$')
	if resRoomId and resRoomId == g_roomId then
		return _startResource(res)
	else
		assert(not resRoomId, resRoomId)
		return call(_getResourceFromName('roommgr'), 'startResourceInRoom', res, g_roomId)
	end
end

local _stopResource = stopResource
function stopResource(res)
	local resName = getResourceName(res)
	local resRoomId = resName:match('^_.+@(.+)$')
	if resRoomId and resRoomId == g_roomId then
		return _stopResource(res)
	else
		assert(not resRoomId, resRoomId)
		return call(_getResourceFromName('roommgr'), 'stopResourceInRoom', res, g_roomId)
	end
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
