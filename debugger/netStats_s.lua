addEvent("dbg_onNetStatsReq", true)

local function onNetStatsReq(target)
	if(not g_Players[client].admin) then return end
	
	local netStats
	if(target == root) then
		netStats = getNetworkStats()
	else
		netStats = getNetworkStats(target)
	end
	triggerClientEvent(client, "dbg_onNetStats", source, netStats, target)
end

addEventHandler("dbg_onNetStatsReq", root, onNetStatsReq)
