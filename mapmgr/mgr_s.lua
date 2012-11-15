local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_MapsList = {}
local g_MapInfo = {}

function loadMapInfo(path)
	local node = xmlLoadFile(get("maps_dir").."/"..path.."/meta.xml")
	if(not node) then
		outputDebugString("Failed to load meta", 1)
		return false
	end
	
	local info = false
	local subnode = xmlFindChild(node, "info", 0)
	if(subnode) then
		info = xmlNodeGetAttributes(subnode)
	end
	
	xmlUnloadFile(node)
	return info
end

function getMapInfo(mapPath, key)
	if(not g_MapInfo[mapPath]) then
		g_MapInfo[mapPath] = loadMapInfo(mapPath)
	end
	
	local info = g_MapInfo[mapPath]
	if(not info) then
		return false
	end
	
	if(key) then
		return info[key]
	else
		return info
	end
end

local function loadMapsFromDir(path)
	local fullPath = get("maps_dir").."/"..path
	local pattern = fullPath.."*"
	local dirs = fileFind(pattern, "directory")
	for i, dir in ipairs(dirs) do
		local dirPath = path..dir
		if(dir:sub(1, 1) == "[" and dir:sub(dir:len()) == "]") then
			loadMapsFromDir(path..dir.."/")
		elseif(fileExists(fullPath..dir.."/meta.xml")) then
			table.insert(g_MapsList, path..dir)
		end
	end
end

function refreshMapsList()
	g_MapsList = {}
	g_MapInfo = {}
	loadMapsFromDir("")
end

function findMap(str, regExp)
	str = str:lower()
	for i, path in ipairs(g_MapsList) do
		local name = getMapInfo(path, "name") or path
		if(name:lower():find(str, 1, not regExp)) then
			return path
		end
	end
	
	return false
end

function findMaps(str, regExp)
	local results = {}
	str = str:lower()
	for i, path in ipairs(g_MapsList) do
		local name = getMapInfo(path, "name") or path
		if(name:lower():find(str, 1, not regExp)) then
			table.insert(results, path)
		end
	end
	
	return results
end

function getMapFullPath(path)
	return ":mapmgr/"..get("maps_dir").."/"..path
end

function getMapsList()
	return g_MapsList
end

function isMap(mapPath)
	for i, currentMapPath in ipairs(g_MapsList) do
		if(mapPath == currentMapPath) then
			return true
		end
	end
	return false
end

local function init()
	refreshMapsList()
end

addEventHandler("onResourceStart", g_ResRoot, init)

