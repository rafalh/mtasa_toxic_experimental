cache = {}


function onResourceStart(res)
	if getThisResource() ~= res then return end
	local resToStart = 
	{
		onDatabaseStart,
		onLoginStart
	}
	for k,v in ipairs(resToStart) do
		if v then
			v()
		end
	end
end

function getPlayerID(player)
	return tonumber(getElementData(player,"playerID"))
end

function givePlayerPoint(player,toadd)
	local id = getPlayerID(player)
	if id then
		if tonumber(toadd) then
			dbExec(cache.sqlconnect,"UPDATE race SET punkty=punkty+?? WHERE id=??",toadd,id)
		end
	end
end

function givePlayerCash(player,toadd)
	local id = getPlayerID(player)
	if id then
		if tonumber(toadd) then
			dbExec(cache.sqlconnect,"UPDATE race SET kasa=kasa+?? WHERE id=??",toadd,id)
		end
	end
end

addEventHandler ( "onResourceStart", getRootElement(), onResourceStart)