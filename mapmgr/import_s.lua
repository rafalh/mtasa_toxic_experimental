function import(res_name)
	local res = getResourceFromName(res_name)
	if(not res) then
		outputDebugString("Failed to import from"..res_name, 2)
		return false
	end
	
	local functions = getResourceExportedFunctions(res)
	for i, func in ipairs(functions) do
		_G[func] = function(...) return call(res, func, ...) end
	end
	
	return true
end
