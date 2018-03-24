local g_roomToDim = {}
local g_lastUsedDim = 0
local g_readyPlayers = {}
local g_roomWorldState = {}

function createRoom(id)

end

local function buildRoomResourceName(baseResourceName, roomId)
    return '_'..baseResourceName..'@'..roomId
end

local function getRoomIdFromResourceName(resName)
    local roomId = resName:match('^_.+@(.+)$')
    return roomId
end

local function getRoomIdFromResource(resource)
    local resName = getResourceName(resource)
    return getRoomIdFromResourceName(resName)
end

local function copyNodeAttributes(srcNode, destNode)
    for k, v in pairs(xmlNodeGetAttributes(srcNode)) do
        xmlNodeSetAttribute(destNode, k, v)
    end
end

local function copyNodeInto(node, parent)
    local name = xmlNodeGetName(node)
    local value = xmlNodeGetValue(node)
    local attr = xmlNodeGetAttributes(node)
    local nodeNew = xmlCreateChild(parent, name)
    xmlNodeSetValue(nodeNew, value)
    copyNodeAttributes(node, nodeNew)
    return nodeNew
end

local function copyNodeChildren(srcNode, destNode)
    for i, subnode in ipairs(xmlNodeGetChildren(srcNode)) do
        local subnodeNew = copyNodeInto(subnode, destNode)
        copyNodeChildren(subnode, subnodeNew)
    end
end

local function createSettingNode(settingsNode, name, value)
    local setting = xmlCreateChild(settingsNode, 'setting')
    xmlNodeSetAttribute(setting, 'name', name)
    xmlNodeSetAttribute(setting, 'value', toJSON(value))
end

local function fixMapFile(src, roomId, dim)
    local mapNode = xmlLoadFile(src)
    for i, subnode in ipairs(xmlNodeGetChildren(mapNode)) do
        local id = xmlNodeGetAttribute(subnode, 'id')
        if id then
            xmlNodeSetAttribute(subnode, 'id', '_'..id..'@'..roomId)
        end

        local nextid = xmlNodeGetAttribute(subnode, 'nextid')
        if nextid then
            xmlNodeSetAttribute(subnode, 'nextid', '_'..nextid..'@'..roomId)
        end

        xmlNodeSetAttribute(subnode, 'dimension', dim)
    end
    xmlSaveFile(mapNode)
    xmlUnloadFile(mapNode)
end

local function getRoomResourceByName(resName, roomId)
    local roomResName = buildRoomResourceName(resName, roomId)
    return getResourceFromName(roomResName)
end

local function getRoomResource(res, roomId)
    local resName = getResourceName(res)
    return getRoomResourceByName(resName, roomId)
end

local function getRoomDimension(roomId)
    local dim = g_roomToDim[roomId]
    if not dim then
        g_lastUsedDim = g_lastUsedDim + 1
        dim = g_lastUsedDim
        g_roomToDim[roomId] = dim
    end
    return dim
end

local function setupRoomResourceMeta(destResName, srcResName, roomId, dim)
    local clientFiles = {}
    local serverFiles = {}
    local includedResources = {}
    local srcMeta = xmlLoadFile(':'..srcResName..'/meta.xml')
    local destMeta = xmlLoadFile(':'..destResName..'/meta.xml')
    local settingsNode

    for i, srcNode in ipairs(xmlNodeGetChildren(srcMeta)) do
        local nodeName = xmlNodeGetName(srcNode)
        local attr = xmlNodeGetAttributes(srcNode)
        local flagClientFile, flagServerFile = false, false
        if nodeName == 'script' then
            if attr.type == 'client' or attr.type == 'shared' then
                flagClientFile = true
            end
            if attr.type ~= 'client' then
                local destNode = copyNodeInto(srcNode, destMeta)
                xmlNodeSetAttribute(destNode, 'type', 'server')
                flagServerFile = true
            end
        elseif nodeName == 'map' then
            local destNode = copyNodeInto(srcNode, destMeta)
            xmlNodeSetAttribute(destNode, 'dimension', tostring(dim))
            flagServerFile = true
        elseif nodeName == 'file' then
            flagClientFile = true
        elseif nodeName == 'config' or nodeName == 'html' then
            copyNodeInto(srcNode, destMeta)
            flagServerFile = true
        elseif nodeName == 'settings' then
            settingsNode = xmlCreateChild(destMeta, 'settings')
            copyNodeChildren(srcNode, settingsNode)
        elseif nodeName == 'info' then
            -- Note: only one node is allowed
            local existingNode = xmlFindChild(destMeta, nodeName, 0)
            copyNodeAttributes(srcNode, existingNode)
        elseif nodeName == 'min_mta_version' then
            -- Note: only one node is allowed
            local existingNode = xmlFindChild(destMeta, nodeName, 0)
            copyNodeAttributes(srcNode, existingNode)
        elseif nodeName == 'include' then
            table.insert(includedResources, attr.resource)
        else
            -- Copy all unknown nodes
            copyNodeInto(srcNode, destMeta)
        end

        if flagServerFile then
            table.insert(serverFiles, { kind = nodeName, src = attr.src })
        end
        if flagClientFile then
            local fileNode = xmlCreateChild(destMeta, 'file')
            xmlNodeSetAttribute(fileNode, 'download', 'false')
            xmlNodeSetAttribute(fileNode, 'src', attr.src)
            table.insert(clientFiles, { kind = nodeName, src = attr.src })
        end
    end
    xmlUnloadFile(srcMeta)
    
    if not settingsNode then
        settingsNode = xmlCreateChild(destMeta, 'settings')
    end
    createSettingNode(settingsNode, '#_clientFiles', clientFiles)
    createSettingNode(settingsNode, '#_includedResources', includedResources)
    createSettingNode(settingsNode, '#_roomId', roomId)
    createSettingNode(settingsNode, '#_roomDim', dim)

    xmlSaveFile(destMeta)
    xmlUnloadFile(destMeta)

    return serverFiles, clientFiles
end

local function copyResourceAclGroups(srcResName, destResName)
    for i, group in ipairs(aclGroupList()) do
        if isObjectInACLGroup('resource.'..srcResName, group) then
            aclGroupAddObject(group, 'resource.'..destResName)
        end
    end
end

local function removeResourceFromAclGroups(resName)
    for i, group in ipairs(aclGroupList()) do
        aclGroupRemoveObject(group, 'resource.'..resName)
    end
end

local function createRoomResource(res, roomId)
    local resName = getResourceName(res)
    local roomBaseRes = getResourceFromName('roombase')
    local roomResName = buildRoomResourceName(resName, roomId)
    local dim = getRoomDimension(roomId)

    -- Delete old resource if exists
    local roomRes = getResourceFromName(roomResName)
    if roomRes and getResourceState(roomRes) == 'running' then
        outputDebugString('Resource is already running', 2)
        return false
    end

    if roomRes then
        deleteResource(roomResName)
    end

    -- Note: we copy roombase resource instead of original resource to skip reinserting all server-scripts
    -- (there is no function to insert XML node at arbitrary place)
    roomRes = copyResource(roomBaseRes, roomResName, '[rooms]')
    if not roomRes then
        error('Failed to copy resource')
    end

    -- Update meta.xml
    local serverFiles, clientFiles = setupRoomResourceMeta(roomResName, resName, roomId, dim)

    -- Copy files
    for i, info in ipairs(serverFiles) do
        fileCopy(':'..resName..'/'..info.src, ':'..roomResName..'/'..info.src, true)
        if info.kind == 'map' then
            fixMapFile(':'..roomResName..'/'..info.src, roomId, dim)
        end
    end
    for i, info in ipairs(clientFiles) do
        fileCopy(':'..resName..'/'..info.src, ':'..roomResName..'/'..info.src, true)
    end

    -- Setup permissions
    copyResourceAclGroups(resName, roomResName)

    return roomRes
end

-- exported
function getResourceForRoom(res, roomId)
    local resRoomId = getRoomIdFromResource(res)
    if resRoomId then
        if resRoomId == roomId then
            return res
        else
            outputDebugString('Resource from different room! Access denied', 2)
            return false
        end
    else
        local resName = getResourceName(res)
        local roomRes = getRoomResourceByName(resName, roomId)
        if roomRes and getResourceState(roomRes) == 'running' then
            -- Running resource from this room
            return roomRes
        end

        if getResourceState(res) == 'running' then
            -- Global running resource
            return res
        end

        -- (Re)Create room resource
        return createRoomResource(res, roomId)
    end
end

local function startResourceInRoom(res, roomId)
    -- recreate resource
    local roomRes = createRoomResource(res, roomId)

    -- Start the resource
    return startResource(roomRes)
end

local function deleteResourceFiles(resName)
    local metaNode = xmlLoadFile(':'..resName..'/meta.xml')
    for i, subnode in ipairs(xmlNodeGetChildren(metaNode)) do
        local nodeName = xmlNodeGetName(subnode)
        local attr = xmlNodeGetAttributes(subnode)
        if nodeName ~= 'info' then
            xmlDestroyNode(subnode)
            if attr.src and fileExists(':'..resName..'/'..attr.src) then
                fileDelete(':'..resName..'/'..attr.src)
            end
        end
    end
    xmlSaveFile(metaNode)
    xmlUnloadFile(metaNode)
end

local function destroyRoomResource(res)
    local resName = getResourceName(res)
    deleteResourceFiles(resName)
    deleteResource(resName)
    removeResourceFromAclGroups(resName)
end

local function stopResourceInRoom(res, roomId)
    local roomRes = getRoomResource(res, roomId)
    if not roomRes then
        outputDebugString('Room resource does not exist', 2)
        return false
    end
    if getResourceState(roomRes) == 'loaded' then
        destroyRoomResource(roomRes)
    end

    return stopResource(roomRes)
end

local function restartResourceInRoom(res, roomId)
    -- Stop if resource is running
    local roomRes = getRoomResource(res, roomId)
    if roomRes and getResourceState(roomRes) == 'running' then
        stopResourceInRoom(res, roomId)
    end
    -- Delay rest of code in case we are stopping old resource
    setTimer(function ()
        startResourceInRoom(res, roomId)
    end, 50, 1)
end

local function getRoomReadyPlayers(roomId)
    local result = {}
    for i, player in ipairs(getElementsByType('player')) do
        if getElementData(player, 'roomid') == roomId and g_readyPlayers[player] then
            table.insert(result, player)
        end
    end
    return result
end

local function sendRoomWorldState(roomId, player)
    local worldState = g_roomWorldState[roomId] or {}
    for stateName, stateValue in pairs(worldState) do
        --outputDebugString('sending world state '..stateName..' for room '..roomId)
        triggerClientEvent(player, '_room_onWorldSettingChange', resourceRoot, 'set'..stateName, unpack(stateValue))
    end
end

addEvent('onPlayerLeaveRoom')
addEvent('onPlayerEnterRoom')

function setPlayerRoom(player, roomId)
    assert(getElementType(player) == 'player')

    if isPedInVehicle(player) then
        removePedFromVehicle(player)
    end

    local prevRoomId = getElementData(player, 'roomid')
    if prevRoomId then
        triggerEvent('onPlayerLeaveRoom', player, prevRoomId)
        triggerClientEvent(player, 'onClientPlayerLeaveRoom', player, prevRoomId)
        --resetMapInfo(player)
    end

    setElementData(player, 'roomid', roomId)
    if roomId then
        local dim = getRoomDimension(roomId)
        setElementDimension(player, dim)
        triggerEvent('onPlayerEnterRoom', player, roomId)
        triggerClientEvent(player, 'onClientPlayerEnterRoom', player, roomId)

        if g_readyPlayers[player] then
            sendRoomWorldState(roomId, player)
        end
    end
end

function getPlayerRoom(player)
    return getElementData(player, 'roomid')
end

function getRooms()
    return {}
end

function getRoomWorldState(roomId, getFnName)
    local prefix, stateName = getFnName:match('^(%l+)(.+)$')
    if not prefix == 'get' and not prefix == 'is' and not prefix == 'are' then return end
    local worldState = g_roomWorldState[roomId] or {}
    local result = worldState[stateName]
	if not result then
		result = { _G[getFnName]() }
		g_worldSettings[stateName] = result
	end
	return unpack(result)
end

function setRoomWorldState(roomId, getFnName, setFnName, ...)
    local prefix, stateName = getFnName:match('^(%l+)(.+)$')
    if not prefix == 'get' and not prefix == 'is' and not prefix == 'are' then return end
    local worldState = g_roomWorldState[roomId]
    if not worldState then
        worldState = {}
        g_roomWorldState[roomId] = worldState
    end
    worldState[stateName] = { ... }
    local roomPlayers = getRoomReadyPlayers(roomId)
	triggerClientEvent(roomPlayers, '_room_onWorldSettingChange', resourceRoot, setFnName, ...)
	return true
end

function resetRoomWorldState(roomId, getFnName, resetFnName)
    local prefix, stateName = getFnName:match('^(%l+)(.+)$')
    if not prefix == 'get' and not prefix == 'is' and not prefix == 'are' then return end
    local worldState = g_roomWorldState[roomId]
    if not worldState then
        worldState = {}
        g_roomWorldState[roomId] = worldState
    end
    worldState[stateName] = nil
    local roomPlayers = getRoomReadyPlayers(roomId)
	triggerClientEvent(roomPlayers, '_room_onWorldSettingChange', resourceRoot, resetFnName)
	return true
end

-- Event handlers

addEventHandler('onPlayerJoin', root, function ()
    -- Set lobby room for new players
    assert(getElementType(source) == 'player')
    setElementData(source, 'roomid', '_lobby')
end, true, 'high+100')

addEventHandler('onResourceStart', resourceRoot, function ()
    -- Add scoreboard column
    local scoreboardRes = getResourceFromName('scoreboard')
    if scoreboardRes and getResourceState(scoreboardRes) == 'running' then
        call(scoreboardRes, 'scoreboardAddColumn', 'roomid', g_Root, 50, 'Room')
    end

    -- Set lobby room for new players
    for i, player in ipairs(getElementsByType('player')) do
        local playerRoomId = getElementData(player, 'roomid')
        if not playerRoomId then
            setElementData(player, 'roomid', '_lobby')
            setElementDimension(player, 0)
        else
            local dim = getRoomDimension(playerRoomId)
            setElementDimension(player, dim)
        end
    end
end, true, 'high+100')

addEvent('onReady', true)
addEventHandler('onReady', resourceRoot, function ()
    g_readyPlayers[client] = true
    local roomId = getPlayerRoom(client)
    sendRoomWorldState(roomId, client)
end)

addEventHandler('onResourceStop', root, function (resource)
    local roomId = getRoomIdFromResource(resource)
    if not roomId then return end

    -- Delete resource after stopping is finished
    setTimer(function ()
        if getResourceState(res) == 'loaded' then
            destroyRoomResource(res)
        end
    end, 50, 1)
end, true, 'low+100')

-- Commands

addCommandHandler('startinroom', function (player, cmdName, resName, roomId)
    local res = getResourceFromName(resName)
    if not res then
        outputConsole('startinroom: Resource not found')
        return
    end
    outputConsole('startinroom: Starting resource')
    restartResourceInRoom(res, roomId)
end)

addCommandHandler('stopinroom', function (player, cmdName, resName, roomId)
    local res = getResourceFromName(resName)
    if not res then
        outputConsole('stopinroom: Resource not found')
        return
    end
    outputConsole('stopinroom: Stopping resource')
    stopResourceInRoom(res, roomId)
end)

addCommandHandler('stopallinroom', function (player, cmdName, roomId)
    outputConsole('stopallinroom: Stopping all resources in room')
    local resources = getResources()
    for i, res in ipairs(resources) do
        local resName = getResourceName(res)
        local resRoomId = resName:match('^_.+@(.+)$')
        if resRoomId == roomId then
            outputConsole('stopallinroom: Stopping '..resName)
            stopAndDeleteResource(res)
        end
    end
end)

addCommandHandler('joinroom', function (player, cmdName, roomId)
    outputConsole('joinroom: Joining room')
    setPlayerRoom(player, roomId)
end)
