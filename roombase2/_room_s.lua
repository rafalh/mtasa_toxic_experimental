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
		outputDebugString('Not loading room for player '..getPlayerName(client), 3)
	end
end)

addEventHandler('onResourceStart', g_resourceRoot, function ()
	setElementData(g_resourceRoot, 'roomid', g_roomId)
end)

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

local _get = get
function get(name)
	local value = _get(name)
	if value ~= nil then return value end
	local access, resourceName, settingName = name:match('^([*#@]?)(.+)%.([^%.]+)$')
	if resourceName == g_resourceName then
		local baseResName = g_resourceName:match('_([^@]+)@[^@]+')
		value = _get('*'..baseResName..'.'..settingName)
	end
	return _get(name)
end

-- TODO: hook resource functions
--[[local _startResource = startResource
function startResource(res)
	local roomId = getElementData(g_ResRoot, 'roomid')
	exports.roommgr:startResourceInRoom(res, roomId)
end

local _stopResource = stopResource
function stopResource(res)
	local roomId = getElementData(g_ResRoot, 'roomid')
	exports.roommgr:stopResourceInRoom(res, roomId)
end

local _getResourceFromName = getResourceFromName
function getResourceFromName(resName)
	-- TODO
	return nil
end]]
