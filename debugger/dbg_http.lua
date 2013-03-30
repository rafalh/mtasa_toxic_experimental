function getDebuggerHTTPRequest(player)
	local tanger = (player == "Server" and root or getPlayerFromName(player))
	return g_Players[tanger]
end

function getTangerList()
	local tangerList = {}
	for k,v in ipairs(getElementsByType("player")) do
		table.insert(tangerList,getPlayerName(v))
	end
	return tangerList
end