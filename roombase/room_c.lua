local g_Root = getRootElement()
local g_Res = getThisResource()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()
local g_Files = {map = {}, file = {}, script = {}}
local g_StartHandlers = {}
local g_Dimension, g_Settings
local g_Progress, g_Size = 0, 0
local g_MapStarted = false

local function applySettings(settings)
	setGameSpeed(settings.gamespeed)
	local time_tbl = split(settings.time, ":")
	setTime(time_tbl[1], time_tbl[2])
	setWeather(settings.weather)
	setGravity(settings.gravity)
	setWaveHeight(settings.waveheight)
	setMinuteDuration(settings.locked_time and 0 or 1000)
end

local function onMapInit(dim, settings, size)
	g_Dimension = dim
	g_Settings = settings
	g_Size = size
	
	triggerEvent("onClientMapLoading", g_ResRoot, g_Res)
end

local function onFileTransfer(path, type, idx, cnt, block)
	--outputDebugString("onFileTransfer "..path.." "..idx.."/"..cnt, 3)
	
	g_Progress = g_Progress + #block
	local file
	
	if(idx == 1) then
		file = fileCreate(path)
	else
		file = fileOpen(path)
		fileSetPos(file, fileGetSize(file))
	end
	
	if(not file) then
		outputDebugString("Failed to open "..path, 1)
		return
	end
	
	fileWrite(file, block)
	fileClose(file)
	
	if(idx == cnt) then
		table.insert(g_Files[type], path)
	end
end

local function fileGetContents ( path )
	local file = fileOpen ( path, true )
	if ( not file ) then
		outputDebugString ( "Failed to open "..path, 2 )
		return false
	end
	
	local size = fileGetSize ( file )
	local buf = size > 0 and fileRead ( file, size ) or ""
	fileClose ( file )
	
	return buf
end

local function execScript(path)
	local data = fileGetContents(path)
	if(not data) then return false end
	
	local f, msg = loadstring(data, path)
	if(not f) then
		outputDebugString("Failed to load "..path..": "..msg)
		return false
	end
	
	local status, msg = pcall(f)
	if(not status) then
		outputDebugString("Loading "..path.." failed: "..msg, 2)
		return false
	end
	
	return true
end

local function loadObject(attr)
	local model = tonumber(attr.model)
	local x, y, z = tonumber(attr.posX), tonumber(attr.posY), tonumber(attr.posZ)
	local rx, ry, rz = tonumber(attr.rotX) or 0, tonumber(attr.rotY) or 0, tonumber(attr.rotZ) or 0
	if(model and x and y and z) then
		local obj = createObject(model, x, y, z, rx, ry, rz)
		if(obj) then
			setElementID(obj, attr.id)
			for k, v in pairs(attr) do
				setElementData(obj, k, v, false)
			end
		else
			outputDebugString("Failed to create object "..model, 2)
		end
	end
end

local function loadVehicle(attr)
	local model = tonumber(attr.model)
	local x, y, z = tonumber(attr.posX), tonumber(attr.posY), tonumber(attr.posZ)
	local rx, ry, rz = tonumber(attr.rotX) or 0, tonumber(attr.rotY) or 0, tonumber(attr.rotZ) or 0
	local paintjob = tonumber(attr.paintjob)
	local color = attr.color and split(attr.color, ",")
	
	if(model and x and y and z) then
		local veh = createVehicle(model, x, y, z, rx, ry, rz)
		if(veh) then
			setElementID(veh, attr.id)
			if(paintjob) then
				setVehiclePaintjob(veh, paintjob)
			end
			if(color) then
				setVehicleColor(veh, unpack(color))
			end
			for k, v in pairs(attr) do
				setElementData(veh, k, v, false)
			end
		else
			outputDebugString("Failed to create vehicle "..model, 2)
		end
	end
end

local function loadElement(name, attr)
	local el = createElement(name, attr.id)
	if(el) then
		for k, v in pairs(attr) do
			setElementData(el, k, v, false)
		end
	else
		outputDebugString("Failed to create element "..name, 2)
	end
end

local function loadMap(path)
	local node = xmlLoadFile(path)
	if(not node) then return false end
	
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		if(name == "object") then
			loadObject(attr)
		elseif(name == "vehicle") then
			loadVehicle(attr)
		elseif(name == "marker") then
			outputDebugString("TODO", 2)
		else
			loadElement(name, attr)
		end
	end
	
	xmlUnloadFile(node)
	return true
end

local function updateDim()
	--local types = {"ped", "water", "sound", "vehicle", "object", "pickup", "marker", "colshape", "blip", "radararea", "spawnpoint"}
	
	for i, el in ipairs(getElementChildren(getResourceDynamicElementRoot(g_Res))) do
		setElementDimension(el, g_Dimension)
	end
	
	setElementDimension(g_Me, g_Dimension)
end

local function onMapStartReq()
	outputDebugString("onMapStartReq", 3)
	
	applySettings(g_Settings)
	
	for i, path in ipairs(g_Files.map) do
		loadMap(path)
	end
	
	for i, path in ipairs(g_Files.script) do
		execScript(path)
	end
	
	for i, func in ipairs(g_StartHandlers) do
		func(getThisResource())
	end
	
	updateDim()
	
	outputChatBox("YEEE")
	triggerEvent("onClientMapStarting", g_Me, g_Res)
	triggerServerEvent("onPlayerMapStarting", g_Me)
	g_MapStarted = true
end

local function onResStart()
	triggerServerEvent("onPlayerMapReady", g_Me)
end

local function onResStop()
	if(g_MapStarted) then
		triggerEvent("onClientMapStopping", g_Me)
	end
end

-- EXPORTS

function getLoadingProgress()
	return g_Progress, g_Size
end

-- EVENTS

addEvent("onMapInit", true)
addEvent("onFileTransfer", true)
addEvent("onMapStartReq", true)
addEventHandler("onMapInit", g_ResRoot, onMapInit)
addEventHandler("onFileTransfer", g_ResRoot, onFileTransfer)
addEventHandler("onMapStartReq", g_ResRoot, onMapStartReq)
addEventHandler("onClientResourceStart", g_ResRoot, onResStart)
addEventHandler("onClientResourceStop", g_ResRoot, onResStop)

-- addEventHandler hook
local _addEventHandler = addEventHandler
function addEventHandler(name, attachedTo, func, ...)
	if(name == "onClientResourceStart" and (attachedTo == g_ResRoot or attachedTo == g_Root)) then
		table.insert(g_StartHandlers, func)
	end
	
	return _addEventHandler(name, attachedTo, func, ...)
end
