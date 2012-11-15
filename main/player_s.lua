Player = {}
Player.__mt = {__index = Player}
Player.elMap = {}

addEvent("main_onLogin", true)
addEvent("main_onRegisterReq", true)
addEvent("main_onReady", true)

function Player:isGuest()
	local account = getPlayerAccount(self.el)
	return isGuestAccount(account)
end

function Player:onReady()
	if(self.joining) then
		if(self:isGuest()) then
			triggerClientEvent(self.el, "main_onLoginReq", g_ResRoot)
		else
			self.joining = false
		end
	end
	
	if(not self.joining) then
		local room = getPlayerRoom(self.el)
		if(not room) then
			triggerClientEvent(self.el, "main_onSelectRoomReq", g_ResRoot)
		end
	end
end

function Player:onLoginReq(name, passwd, remember)
	if(name) then
		local account = getAccount(name, passwd)
		local success = account and logIn(self.el, account, passwd)
		if(not success) then -- if we succeeded onLogin do the rest
			triggerClientEvent(self.el, "main_onLoginStatus", g_ResRoot, false)
		end
	else -- play as guest
		self:onLogin()
	end
end

function Player:onLogin()
	triggerClientEvent(self.el, "main_onLoginStatus", g_ResRoot, true)
	
	if(self.joining) then
		local room = getPlayerRoom(self.el)
		if(not room) then
			triggerClientEvent(self.el, "main_onSelectRoomReq", g_ResRoot)
		end
		self.joining = false
	end
end

function Player:onRegister(name, passwd)
	local account = addAccount(name, passwd)
	triggerClientEvent(self.el, "main_onRegStatus", g_ResRoot, account and true)
end

function Player:destroy()
	Player.elMap[self.el] = nil
end

function Player.create(el, joining)
	local self = setmetatable({}, Player.__mt)
	self.el = el
	self.joining = joining
	Player.elMap[self.el] = self
	return self
end

function initPlayers()
	for i, playerEl in ipairs(getElementsByType("player")) do
		Player.create(playerEl, true) -- TEMP!
		assert(Player.elMap[playerEl])
	end
end

addEventHandler("onPlayerJoin", g_Root, function()
	Player.create(source, true)
end)

addEventHandler("onPlayerQuit", g_Root, function()
	local player = Player.elMap[source]
	if(player) then
		player:destroy()
	end
end)

addEventHandler("onPlayerLogin", g_Root, function()
	local player = Player.elMap[source]
	if(player) then
		player:onLogin()
	end
end)

addEventHandler("main_onReady", g_ResRoot, function()
	local player = Player.elMap[client]
	if(player) then
		player:onReady()
	end
end)

addEventHandler("main_onLogin", g_ResRoot, function(name, passwd, remember)
	local player = Player.elMap[client]
	if(player) then
		player:onLoginReq(name, passwd, remember)
	end
end)

addEventHandler("main_onRegisterReq", g_ResRoot, function(name, passwd)
	local player = Player.elMap[client]
	if(player) then
		player:onRegister(name, passwd)
	end
end)
