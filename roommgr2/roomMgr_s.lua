local g_roomToDim = {}
local g_lastUsedDim = 0

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

function getRoomResource(res, roomId)
    local resName = getResourceName(res)
    local roomResName = buildRoomResourceName(resName, roomId)
    return getResourceFromName(roomResName)
end

function restartResourceInRoom(res, roomId)
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

function stopResourceInRoom(res, roomId)
    local roomRes = getRoomResource(res, roomId)
    if not roomRes then
        outputDebugString('Room resource does not exist', 2)
        return false
    end
    return stopResource(roomRes)
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
            -- Note: we have info from roombase and we can't have two...
            local infoNode = xmlFindChild(destMeta, 'info', 0)
            copyNodeAttributes(srcNode, infoNode)
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
    createSettingNode(settingsNode, '#_roomId', roomId)
    createSettingNode(settingsNode, '#_roomDim', dim)

    xmlSaveFile(destMeta)
    xmlUnloadFile(destMeta)

    return serverFiles, clientFiles
end

function startResourceInRoom(res, roomId)
    -- create resource to start
    -- sandbox
    -- download resources client-side using downloadFile
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

    local serverFiles, clientFiles = setupRoomResourceMeta(roomResName, resName, roomId, dim)

    for i, info in ipairs(serverFiles) do
        fileCopy(':'..resName..'/'..info.src, ':'..roomResName..'/'..info.src, true)
        if info.kind == 'map' then
            fixMapFile(':'..roomResName..'/'..info.src, roomId, dim)
        end
    end
    for i, info in ipairs(clientFiles) do
        fileCopy(':'..resName..'/'..info.src, ':'..roomResName..'/'..info.src, true)
    end

    return startResource(roomRes)
end

local function stopAndDeleteResource(res)
    local result = stopResource(res)
    -- Delete resource after stopping is finished
    setTimer(function ()
        if getResourceState(res) == 'loaded' then
            deleteResource(getResourceName(res))
        end
    end, 50, 1)
    return result
end

function stopResourceInRoom(res, roomId)
    local resName = getResourceName(res)
    local roomResName = buildRoomResourceName(resName, roomId)
    local roomRes = getResourceFromName(roomResName)
    return stopAndDeleteResource(roomRes)
end

addEvent('onPlayerLeaveRoom')
addEvent('onPlayerEnterRoom')

function setPlayerRoom(player, roomId)
    assert(getElementType(player) == 'player')

    local prevRoomId = getElementData(player, 'roomid')
    if prevRoomId then
        triggerEvent('onPlayerLeaveRoom', player, prevRoomId)
        triggerClientEvent(player, 'onClientPlayerLeaveRoom', player, prevRoomId)
    end
    
    setElementData(player, 'roomid', roomId)
    if roomId then
        local dim = getRoomDimension(roomId)
        setElementDimension(player, dim)
        triggerEvent('onPlayerEnterRoom', player, roomId)
        triggerClientEvent(player, 'onClientPlayerEnterRoom', player, roomId)
    end
end

function getPlayerRoom(player)
    return getElementData(player, 'roomid')
end

function getRooms()
    return {}
end

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

addEventHandler('onPlayerJoin', root, function ()
    -- Set lobby room for new players
    assert(getElementType(source) == 'player')
    setElementData(source, 'roomid', '_lobby')
end, true, 'high+100')
