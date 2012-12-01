addEvent("dbg_onPerfStatsReq", true)
addEvent("dbg_onPerfStats", true)

local function onPerfStatsReq(cat, opts, filter)
	if(not g_Players[client].admin) then return end
	
	if(source == g_Root) then
		local cols, rows = getPerformanceStats(cat, opts, filter)
		triggerClientEvent(client, "dbg_onPerfStats", source, cols, rows, cat, opts, filter)
	else
		triggerClientEvent(source, "dbg_onPerfStatsReq", source, cols, rows, cat, opts, filter, client)
	end
end

local function onPerfStatsSync(cols, rows, cat, opts, filter, player)
	if(not g_Players[player].admin) then return end
	
	triggerClientEvent(player, "dbg_onPerfStats", client, cols, rows, cat, opts, filter)
end

addEventHandler("dbg_onPerfStatsReq", g_Root, onPerfStatsReq)
addEventHandler("dbg_onPerfStats", g_Root, onPerfStatsSync)
