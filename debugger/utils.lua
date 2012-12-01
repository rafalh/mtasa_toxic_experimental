function dbgToString(...)
	local vars = {}
	for i, var in ipairs({...}) do
		if(isElement(var)) then
			local elType = getElementType(var)
			if(elType == "player") then
				table.insert(vars, elType.."("..getPlayerName(var)..")")
			else
				table.insert(vars, elType.."("..getElementID(var)..")")
			end
		elseif(type(var) == "string") then
			table.insert(vars, "\""..var.."\"")
		elseif(type(var) == "table") then
			local tbl = {}
			for key, val in pairs(var) do
				if(type(key) == "number" and key <= #var) then
					table.insert(tbl, dbgToString(val))
				else
					table.insert(tbl, "["..dbgToString(key).."]="..dbgToString(val))
				end
			end
			table.insert(vars, "{"..table.concat(tbl, ", ").."}")
		else
			table.insert(vars, tostring(var))
		end
	end
	if(#vars > 0) then
		return table.concat(vars, ", ")
	else
		return "nil"
	end
end

function dbgOutput(str, player)
	while(str:len() > 0) do
		local part = str:sub(1, 130)
		str = str:sub(part:len() + 1)
		outputChatBox(part, player or g_Root, 128, 128, 255)
	end
end