addEvent("dbg_onNetStatsReq", true)

local function onNetStatsReq(target)
	if(not g_Players[client].admin) then return end
	
	local netStats
	if(target == g_Root) then
		netStats = getNetworkStats()
	else
		netStats = getNetworkStats(target)
	end
	triggerClientEvent(client, "dbg_onNetStats", source, netStats, target)
end

addEventHandler("dbg_onNetStatsReq", g_Root, onNetStatsReq)
