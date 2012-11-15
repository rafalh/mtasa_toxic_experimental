function table.copy(tbl, maxIdx)
	local ret = {}
	
	for k, v in pairs(tbl) do
		if(not maxIdx or k <= maxIdx) then
			ret[k] = v
		end
	end
	
	return ret
end

function table.find(tbl, val)
	for k, v in pairs(tbl) do
		if(v == val) then
			return k
		end
	end
	
	return false
end

function table.removeValue(tbl, val)
	local k = table.find(tbl, val)
	if(k) then
		table.remove(tbl, k)
	end
end

function table.empty()
	for k, v in pairs(tbl) do
		return false
	end
	
	return true
end

function tobool(val)
	return val == "true" or val == true
end

function math.clamp(val, min, max)
	if(val < min) then
		return min
	elseif(val > max) then
		return max
	else
		return val
	end
end

function math.wrap(val, min, max)
	if(min == max) then
		return min
	end
	return val - math.floor((val - min)/(max - min)) * (max - min)
end

local _assert = assert
function assert(expr, text)
	if(expr) then return end
	
	outputDebugString(text or "Assertion failed:", 1)
	if(not expr) then
		DbgTraceBack(1)
	end
	exit()
end

function DbgTraceBack(start, levels)
	start = start or 0
	levels = levels or math.huge
	
	local trace = debug.traceback ()
	local lines = split(trace, "\n")
	for i = start+3, start+3+levels-1 do
		if(not lines[i]) then break end
		outputDebugString ( lines[i]:sub ( 2 ), 1 )
	end
end

assert(math.wrap(5, 0, 2) == 1)
assert(math.wrap(-5, 0, 2) == 1)