local g_Root = getRootElement()
local g_Imports = {}

function import(resName)
	local res = getResourceFromName(resName)
	if(not res) then
		outputDebugString("Failed to import from"..resName, 2)
		return false
	end
	
	g_Imports[resName] = {}
	
	local functions = getResourceExportedFunctions(res)
	for i, func in ipairs(functions) do
		_G[func] = function(...) return call(res, func, ...) end
		table.insert(g_Imports[resName], func)
	end
	
	return true
end

local function onResStart(res)
	local resName = getResourceName(res)
	if(g_Imports[resName]) then
		import(resName)
	end
end

local function onResStop(res)
	local resName = getResourceName(res)
	if(not g_Imports[resName]) then return end
	
	for i, func in ipairs(g_Imports[resName]) do
		_G[func] = nil
	end
	
	g_Imports[resName] = {}
end

if(triggerClientEvent) then -- server
	addEventHandler("onResourceStart", g_Root, onResStart)
	addEventHandler("onResourceStop", g_Root, onResStop)
else -- client
	addEventHandler("onClientResourceStart", g_Root, onResStart)
	addEventHandler("onClientResourceStop", g_Root, onResStop)
end
