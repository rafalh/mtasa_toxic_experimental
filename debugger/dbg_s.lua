g_Res = getThisResource()
resourceRoot = getResourceRootElement()
g_Players = {}
g_updatePlayerList = 0

local MAX_PLAYER_MESSAGES = 30

addEvent("dbg_onMsg", true)
addEvent("dbg_onLogSyncReq", true)

local function addDbgMsg(msg, lvl, file, line, player)
	local ticks = getTickCount()
	local info = {ticks, msg, lvl, file, line,getTimeStamp ()}
	
	if(not g_Players[player]) then
		g_Players[player] = {}
	end
	
	if(#g_Players[player] >= MAX_PLAYER_MESSAGES) then
		table.remove(g_Players[player], 1)
	end
	table.insert(g_Players[player], info)
	--g_Players[player].lastTimeAdded = getTimeStamp ()
	
	for player2, pdata in pairs(g_Players) do
		if(pdata.logSync and (player == root or pdata.logSync == player)) then
			triggerClientEvent(player2, "dbg_onLogSync", pdata.logSync, {info})
		end
	end
end

local function mergeLogs(log1, log2)
	local ret = {}
	local i, j = 1, 1
	while(log1[i] or log2[j]) do
		local info = false
		if((log1[i] and log2[j] and log1[i][1] < log2[j][1]) or not log2[j]) then
			info = log1[i]
			i = i + 1
		else
			info = log2[j]
			j = j + 1
		end
		table.insert(ret, info)
	end
	return ret
end

local function onServerDbgMsg(msg, lvl, file, line)
	addDbgMsg(msg, lvl, file or "", line or "", root)
	g_Players[root].lastTimeAdded = getTimeStamp ()
end

local function onPlayerDbgMsg(msg, lvl, file, line)
	addDbgMsg(msg, lvl, file, line, client)
	g_Players[client].lastTimeAdded = getTimeStamp ()
end

local function onLogSyncReq(player)
	if(not g_Players[client].logSync) then return end
	
	g_Players[client].logSync = player
	
	if(player) then
		local logData = player == "Server" and g_Players[root] or g_Players[player]
		triggerClientEvent(client, "dbg_onLogSync", player, logData)
	end
end

local function onPlayerJoin()
	g_Players[source] = {}
	g_updatePlayerList = getTimeStamp ()
end

local function onPlayerQuit()
	g_Players[source] = nil
	g_updatePlayerList = getTimeStamp ()
end

local function onPlayerChangeNick()
	g_updatePlayerList = getTimeStamp ()
end

local function init()
	for i, player in ipairs(getElementsByType("player")) do
		g_Players[player] = {}
	end
	
	g_Players[root] = {}
end

addCommandHandler("dbg", function(player)
	if(g_Players[player].logSync) then return end
	
	if(not hasObjectPermissionTo(player, "resource.debugger", false)) then
		outputChatBox("dbg: Access is denied", player, 255, 0, 0)
		return
	else
		g_Players[player].admin = true
	end
	
	g_Players[player].logSync = player
	local logData = mergeLogs(g_Players[root], g_Players[player])
	triggerClientEvent(player, "dbg_onDisplayReq", resourceRoot, logData)
end)

function getTimeStamp ()
	local t = getRealTime()
	return t.timestamp
end

addEventHandler("onDebugMessage", root, onServerDbgMsg)
addEventHandler("dbg_onMsg", root, onPlayerDbgMsg)
addEventHandler("dbg_onLogSyncReq", root, onLogSyncReq)
addEventHandler("onPlayerJoin", root, onPlayerJoin)
addEventHandler("onPlayerQuit", root, onPlayerQuit)
addEventHandler("onPlayerChangeNick",root,onPlayerChangeNick)
addEventHandler("onResourceStart", resourceRoot, init)
