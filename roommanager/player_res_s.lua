local g_FreeResources = {}
local g_BusyResources = {}
local g_ResourcesCount = 0
local g_PlayerResPrefix = "playermap"
local g_RoomBaseRes = getResourceFromName("roombase")

PlayerRes = {}

function PlayerRes.alloc()
	if(#g_FreeResources > 0) then
		local res = table.remove(g_FreeResources)
		g_BusyResources[res] = true
		return res
	end
	
	g_ResourcesCount = g_ResourcesCount + 1
	local res_name = g_PlayerResPrefix..g_ResourcesCount
	local res = copyResource(g_RoomBaseRes, res_name)
	
	return res
end

function PlayerRes.free(res)
	table.insert(g_FreeResources, res)
	g_BusyResources[res] = nil
end

function PlayerRes.init()
	local i = 1
	while(true) do
		local res_name = g_PlayerResPrefix..i
		local res = getResourceFromName(res_name)
		if(not res) then break end
		if(getResourceState(res) == "running") then
			stopResource(res)
			setTimer(deleteResource, 50, 1, res_name)
		else
			deleteResource(res_name)
		end
		
		i = i + 1
	end
end
