function getStatystyki()
	local sql = mysqlQuery("SELECT * FROM race WHERE id=??",getPlayerID(client))
	triggerClientEvent(client,"racescript:client:statystyki:get",client,sql[1])
end

function onPlayerFinish ( rank, time )
	local id = getPlayerID(source)
	if id then
		local cashadd = math.floor ( 345 * #getElementsByType ( "player" ) / rank )
		local pointsadd = math.floor ( #getElementsByType ( "player" ) / rank )
		givePlayerPoint(source,pointsadd)
		givePlayerCash(source,cashadd)
		if rank >= 1 and rank <= 3 then
			dbExec(cache.sqlconnect,"UPDATE race SET ??=??+1 WHERE id=??","miejsce"..rank,"miejsce"..rank,id)
		end
	end
end

addEvent("onPlayerFinish")
addEvent("racescript:server:statystyki:get",true)
addEventHandler("racescript:server:statystyki:get",getRootElement(),getStatystyki)
addEventHandler("onPlayerFinish",getRootElement(),onPlayerFinish)
