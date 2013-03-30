g_Root = getRootElement()
g_Res = getThisResource()
g_ResRoot = getResourceRootElement()
g_Players = {}

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
	
	for player2, pdata in pairs(g_Players) do
		if(pdata.logSync and (player == g_Root or pdata.logSync == player)) then
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
	addDbgMsg(msg, lvl, file or "", line or "", g_Root)
end

local function onPlayerDbgMsg(msg, lvl, file, line)
	addDbgMsg(msg, lvl, file, line, client)
end

local function onLogSyncReq(player)
	if(not g_Players[client].logSync) then return end
	
	g_Players[client].logSync = player
	
	if(player) then
		local logData = player == "Server" and g_Players[g_Root] or g_Players[player]
		triggerClientEvent(client, "dbg_onLogSync", player, logData)
	end
end

local function onPlayerJoin()
	g_Players[source] = {}
end

local function onPlayerQuit()
	g_Players[source] = nil
end

local function init()
	for i, player in ipairs(getElementsByType("player")) do
		g_Players[player] = {}
	end
	
	g_Players[g_Root] = {}
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
	local logData = mergeLogs(g_Players[g_Root], g_Players[player])
	triggerClientEvent(player, "dbg_onDisplayReq", g_ResRoot, logData)
end)

function getTimeStamp ()
	local t = getRealTime()
	return t.timestamp
end

addEventHandler("onDebugMessage", g_Root, onServerDbgMsg)
addEventHandler("dbg_onMsg", g_Root, onPlayerDbgMsg)
addEventHandler("dbg_onLogSyncReq", g_Root, onLogSyncReq)
addEventHandler("onPlayerJoin", g_Root, onPlayerJoin)
addEventHandler("onPlayerQuit", g_Root, onPlayerQuit)
addEventHandler("onResourceStart", g_ResRoot, init)
