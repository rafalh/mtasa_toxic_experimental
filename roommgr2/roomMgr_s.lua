local g_roomToDim = {}
local g_lastUsedDim = 0

function createRoom(id)

end

local function buildRoomResourceName(baseResourceName, roomId)
    return '_'..baseResourceName..'@'..roomId
end

local function copyNodeInto(node, parent)
    local name = xmlNodeGetName(node)
    local value = xmlNodeGetValue(node)
    local attr = xmlNodeGetAttributes(node)
    local nodeNew = xmlCreateChild(parent, name)
    xmlNodeSetValue(nodeNew, value)
    for k, v in pairs(attr) do
        xmlNodeSetAttribute(nodeNew, k, v)
    end
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
            xmlNodeSetAttribute(subnode, 'id', roomId..'-'..id)
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
    roomRes = copyResource(roomBaseRes, roomResName, '[rooms]')
    if not roomRes then
        error('Failed to copy resource')
    end

    local clientFiles = {}
    local serverFiles = {}
    local meta = xmlLoadFile(':'..resName..'/meta.xml')
    local metaNew = xmlLoadFile(':'..roomResName..'/meta.xml')
    local settingsNode = xmlCreateChild(metaNew, 'settings')

    for i, node in ipairs(xmlNodeGetChildren(meta)) do
        local nodeName = xmlNodeGetName(node)
        local attr = xmlNodeGetAttributes(node)
        local flagClient, flagServer = false, false
        if nodeName == 'map' then
            copyNodeInto(node, metaNew)
            flagServer = true
        elseif nodeName == 'script' then
            if attr.type == 'client' or attr.type == 'shared' then
                flagClient = true
            end
            if attr.type ~= 'client' then
                flagServer = true
            end
        elseif nodeName == 'file' then
            flagClient = true
        elseif nodeName == 'settings' then
            copyNodeChildren(node, settingsNode)
        elseif nodeName ~= 'info' and nodeName == 'oop' then
            -- Note: we have info from roombase and we can't have two...
            copyNodeInto(node, metaNew)
        elseif nodeName == 'config' then
            copyNodeInto(node, metaNew)
            flagServer = true
        end
        if flagServer then
            table.insert(serverFiles, { kind = nodeName, src = attr.src })
        end
        if flagClient then
            table.insert(clientFiles, { kind = nodeName, src = attr.src })
        end
    end
    local infoNode = xmlFindChild(meta, 'info', 0)
    local infoAttr = xmlNodeGetAttributes(infoNode)
    xmlUnloadFile(meta)
    
    for i, info in ipairs(serverFiles) do
        fileCopy(':'..resName..'/'..info.src, ':'..roomResName..'/'..info.src, true)
        if info.kind == 'map' then
            fixMapFile(':'..roomResName..'/'..info.src, roomId, dim)
        elseif info.kind == 'script' then
            local node = xmlCreateChild(metaNew, 'script')
            xmlNodeSetAttribute(node, 'type', 'server')
            xmlNodeSetAttribute(node, 'src', info.src)
        end
    end
    for i, info in ipairs(clientFiles) do
        local node = xmlCreateChild(metaNew, 'file')
        xmlNodeSetAttribute(node, 'download', 'false')
        xmlNodeSetAttribute(node, 'src', info.src)
        fileCopy(':'..resName..'/'..info.src, ':'..roomResName..'/'..info.src, true)
    end
    
    createSettingNode(settingsNode, '#_clientFiles', clientFiles)
    createSettingNode(settingsNode, '#_roomId', roomId)
    createSettingNode(settingsNode, '#_roomDim', dim)

    -- Copy info node attributes
    infoNode = xmlFindChild(metaNew, 'info', 0)
    for k, v in pairs(infoAttr) do
        xmlNodeSetAttribute(infoNode, k, v)
    end

    xmlSaveFile(metaNew)
    xmlUnloadFile(metaNew)

    return startResource(roomRes)
end

function stopResourceInRoom(res, roomId)
    local resName = getResourceName(res)
    local roomResName = buildRoomResourceName(resName, roomId)
    local roomRes = getResourceFromName(roomResName)
    stopResource(roomRes)
    -- FIXME: cleanup?
    --setTimer(function ()
    --    deleteResource(roomRes)
    --end, 50, 1)
end

addEvent('onPlayerLeaveRoom')
addEvent('onPlayerEnterRoom')

function setPlayerRoom(player, roomId)
    local prevRoomId = getElementData(player, 'roomid')
    triggerEvent('onPlayerLeaveRoom', player, prevRoomId)
    triggerClientEvent(player, 'onClientPlayerLeaveRoom', player, prevRoomId)
    
    setElementData(player, 'roomid', roomId)
    local dim = getRoomDimension(roomId)
    setElementDimension(player, dim)
    triggerEvent('onPlayerEnterRoom', player, roomId)
    triggerClientEvent(player, 'onClientPlayerEnterRoom', player, roomId)
end

addCommandHandler('startinroom', function (player, cmdName, resName, roomId)
    local res = getResourceFromName(resName)
    if not res then
        outputChatBox('not found')
        return
    end
    restartResourceInRoom(res, roomId)
    outputChatBox('OK')
end)

addCommandHandler('joinroom', function (player, cmdName, roomId)
    setPlayerRoom(player, roomId)
    outputChatBox('OK')
end)
