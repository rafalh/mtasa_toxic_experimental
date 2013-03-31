g_webTimeUpdate = {}

function getDebuggerHTTPRequest(player,needUpdate)
	if not g_webTimeUpdate[getAccountName(user)] then g_webTimeUpdate[getAccountName(user)] = {} end
	local targer = (player == "Server" and root or getPlayerFromName(player))
	if not targer then return false end
	if not needUpdate then
		if ( not g_Players[targer].lastTimeAdded) then
			return false
		end
		if not g_webTimeUpdate[getAccountName(user)][targer] then g_webTimeUpdate[getAccountName(user)][targer] = 0 end 
		if g_webTimeUpdate[getAccountName(user)][targer] > g_Players[targer].lastTimeAdded then
			return false
		end
		g_webTimeUpdate[getAccountName(user)][targer] = getTimeStamp ()
	end
	local tbl = g_Players[targer]
	return {tbl[1],tbl[2],tbl[3],tbl[4],tbl[5],tbl[6]}
end

function getTargerList(needUpdate)
	if not g_webTimeUpdate[getAccountName(user)] then g_webTimeUpdate[getAccountName(user)] = {} end
	if not g_webTimeUpdate[getAccountName(user)].playerListUpdate then g_webTimeUpdate[getAccountName(user)].playerListUpdate = 0 end
	if not needUpdate then
		if g_updatePlayerList < g_webTimeUpdate[getAccountName(user)].playerListUpdate then
			return false
		end
	end
	local tangerList = {}
	for k,v in ipairs(getElementsByType("player")) do
		table.insert(tangerList,getPlayerName(v))
	end
	g_webTimeUpdate[getAccountName(user)].playerListUpdate = getTimeStamp ()
	return tangerList
end