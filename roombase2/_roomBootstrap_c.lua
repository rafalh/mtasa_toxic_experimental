local g_clientFiles
local g_downloadCounter = 0
local g_resName = getResourceName(resource)
local g_resourceRoot = getResourceRootElement(getThisResource())
g_roomDim = 0

local function fileGetContents(path)
	local file = fileOpen(path, true)
	if not file then
		outputDebugString("Failed to open "..path, 2)
		return false
	end
	
	local size = fileGetSize(file)
	local buf = size > 0 and fileRead(file, size) or ''
	fileClose(file)
	
	return buf
end

local function loadScript(path)
	local data = fileGetContents(path)
	if not data then return false end
	
	local func, msg = loadstring(data, g_resName.."/"..path)
	if not func then
		outputDebugString("Failed to load "..path..": "..msg, 2)
		return false
	end

	return func
end

local function execScript(path, scriptFunc)
	local status, msg = pcall(scriptFunc)
	if not status then
		outputDebugString("Loading "..path.." failed: "..msg, 2)
		return false
	end
	
	return true
end

local function tableSize(tbl)
	local n = 0
	for k, v in pairs(tbl) do
		n = n + 1
	end
	return n
end

local function startAfterDownload()
	outputDebugString('Starting client-side scripts in '..g_resName, 3)

	-- Setup environment
	local env = {}
	env._G = env
	setmetatable(env, {__index = _G})
	g_roomEnv = env

	for i, info in ipairs(g_clientFiles) do
		if info.kind == 'script' then
			if not info.once then
				--setfenv(0, env)
				--setfenv(1, env)
			end
			if not info.scriptFunc then
				info.scriptFunc = loadScript(info.src)
			end
			if not info.once or not info.executed then
				if not info.once then
					setfenv(info.scriptFunc, env)
				end
				execScript(info.src, info.scriptFunc)
				info.executed = true
			end
		end
	end

	--outputDebugString('Calling onClientResourceStart in room (bootstrap)', 3)
	_room_runEventHandlers('onClientResourceStart', g_resourceRoot)
	--outputDebugString('Calling onClientResourceStart in room done', 3)
end

addEvent('_onClientFiles', true)

addEventHandler('onClientResourceStart', g_resourceRoot, function ()
	local roomId = g_resName:match('^_.+@(.+)$')
	setElementData(g_resourceRoot, 'roomid', roomId)
	-- Make sure resource root has roomid corectly set
	triggerServerEvent('_onReady', g_resourceRoot)
end, false, 'high+100')

addEventHandler('_onClientFiles', g_resourceRoot, function (clientFiles, roomId, roomDim)
	g_roomId = roomId
	g_roomDim = roomDim
	-- TODO: compare?
	if g_downloadCounter == #clientFiles then
		--outputDebugString('Downloaded all files before in '..g_resName, 3)
		startAfterDownload()
	else
		g_clientFiles = clientFiles
		for i, info in ipairs(clientFiles) do
			downloadFile(info.src)
		end
	end
end)

addEventHandler('onClientFileDownloadComplete', g_resourceRoot, function (fileName, success)
	if success then
		g_downloadCounter = g_downloadCounter + 1
		--outputDebugString('Download completed for '..fileName, 3)
		if g_downloadCounter == #g_clientFiles then
			--outputDebugString('Downloaded all files in '..g_resName, 3)
			startAfterDownload()
		end
	else
		outputDebugString('Download failed for '..fileName, 1)
	end
end)
