addEvent("dbg_onRunCodeReq", true)
addEvent("dbg_onRunCodeResult", true)

local function onRunCodeReq(codeStr, target)
	if(not g_Players[client].admin) then return end
	
	if(target == g_ResRoot) then
		local func = loadstring(codeStr)
		if(not func) then
			dbgOutput("Failed to load code", client)
		else
			local results = {func()}
			local resultStr = dbgToString(unpack(results))
			dbgOutput("Code executed! Result: "..resultStr, client)
		end
	else
		triggerClientEvent(target, "dbg_onRunCodeReq", client, codeStr)
	end
end

local function onRunCodeResult(resultStr)
	if(not g_Players[source].admin) then return end
	
	local playerName = getPlayerName(client):gsub ("#%x%x%x%x%x%x", "")
	
	if(not resultStr) then
		dbgOutput("Failed to load code ("..playerName..")", source)
	else
		
		dbgOutput("Code executed ("..playerName..")! Result: "..resultStr, source)
	end
end

addEventHandler("dbg_onRunCodeReq", g_Root, onRunCodeReq)
addEventHandler("dbg_onRunCodeResult", g_Root, onRunCodeResult)
