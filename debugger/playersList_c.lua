PlayersList = {}PlayersList.__mt = {__index = PlayersList}PlayersList.map = {}function PlayersList:addStaticElement(name, el)	table.insert(self.staticList, {name, el})endfunction PlayersList:setDefault(el)	self.default = elendfunction PlayersList:updatePlayers()	guiComboBoxClear(self.comboBox)	self.playerToIndex = {}	self.indexToPlayer = {}		for i, info in ipairs(self.staticList) do		local idx = guiComboBoxAddItem(self.comboBox, info[1])		self.indexToPlayer[idx] = info[2]		self.playerToIndex[info[2]] = idx	end		for i, player in ipairs(getElementsByType("player")) do		local playerName = getPlayerName(player):gsub ("#%x%x%x%x%x%x", "")		local idx = guiComboBoxAddItem(self.comboBox, playerName)		self.indexToPlayer[idx] = player		self.playerToIndex[player] = idx	end		local idx = self.playerToIndex[self.player]	if(not idx) then		idx = self.playerToIndex[self.default]		self.player = self.default				if(self.callback) then			self.callback(player)		end	end		guiComboBoxSetSelected(self.comboBox, idx)endfunction PlayersList:onPlayerChange()	local idx = guiComboBoxGetSelected(self.comboBox)	local player = self.indexToPlayer[idx]	if(player == self.player) then return end		self.player = player		if(self.callback) then		self.callback(player)	endendfunction PlayersList:destroy()	PlayersList.map[self.comboBox] = nilendfunction PlayersList.create(x, y, w, h, parent)	local self = setmetatable({}, PlayersList.__mt)		self.comboBox = guiCreateComboBox(x, y, w, h, "", false, parent)	addEventHandler("onClientGUIComboBoxAccepted", self.comboBox, function()		self:onPlayerChange()	end, false)	addEventHandler("onClientElementDestroy", self.comboBox, function()		self:destroy()	end, false)		self.default = g_Me	self.staticList = {}		PlayersList.map[self.comboBox] = self	return selfendaddEventHandler("onClientPlayerJoin", g_Root, function()	for el, list in pairs(PlayersList.map) do		list:updatePlayers()	endend)addEventHandler("onClientPlayerQuit", g_Root, function()	for el, list in pairs(PlayersList.map) do		list:updatePlayers()	endend)