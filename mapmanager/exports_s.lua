local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()

function refreshMapsList()
	g_MapsList = fileFind(get("maps_dir").."/*", "directory")
end

function findMap(str)
	str = str:lower()
	for i, name in ipairs(g_MapsList) do
		if(name:lower():find(str, 1, true)) then
			return name
		end
	end
	
	return false
end
