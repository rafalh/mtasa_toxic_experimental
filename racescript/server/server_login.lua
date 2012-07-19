function onLoginStart()
	for i, a in ipairs ( getElementsByType ( "player" ) ) do
		local acc = getAccountName (getPlayerAccount(a))
		if acc ~= "guest" then
			local id = getPlayerID(a)
			if not id then
				local mysql = mysqlQuery("SELECT * FROM race WHERE player=?",acc)
				if mysql and mysql[1] then
					setElementData(a,"playerID",mysql[1].id)
				else
					dbExec(cache.sqlconnect,"INSERT INTO race (`player`,`serial`,`ip`,`nick`,`haslo`) VALUES (?,?,?,?,?)",acc,getPlayerSerial(a),getPlayerIP(a),getPlayerName(a),"")
					local datid = mysqlQuery("SELECT * FROM race WHERE id = LAST_INSERT_ID()")
					if datid and datid[1] then
						setElementData(a,"playerID",datid[1].id)
					end
				end
			end
		end
	end
end
