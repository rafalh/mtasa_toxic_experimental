function onDatabaseStart()
	cache.sqlconnect = dbConnect("mysql", "host=94.23.102.253;dbname=cpsrace;port=3306", "cpsrace", "qweDQhnjTuJpPQuq","share=1")
	--cache.sqlconnect = dbConnect("mysql", "host=127.0.0.1;dbname=CPS", "root")
	if not cache.sqlconnect then
		outputChatBox("Nie można uruchomić skryptu "..getResourceName(getThisResource())..": Nie można połączyć bazą MYSQL. Zgłoś to pilnie do administratora",getRootElement(),255,0,0)
		outputDebugString("Nie można połączyć bazą MYSQL")
		--cancelEvent()
		--return
	end
end

function mysqlQuery(querty,...)
	local cor = coroutine.create(
		function (querty,...)
			local qh = dbQuery(cache.sqlconnect,querty,unpack({...}))
			local result, numrows, errmsg = dbPoll( qh, -1 )
			dbFree(qh)
			return result, numrows, errmsg
		end
	)
	local ret,result, numrows, errmsg = coroutine.resume(cor,querty,...)
	return result, numrows, errmsg 
end