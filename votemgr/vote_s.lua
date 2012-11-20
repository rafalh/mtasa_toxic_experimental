Vote = {}
Vote.__mt = {__index = Vote}
Vote.elMap = {}

addEvent("onVoteFinish")
addEvent("vote_onPlayerVote", true)

function Vote:onPlayerVote(player, optIdx)
	local prevOptIdx = self.players[player]
	local prevOpt = prevOptIdx and self.opts[prevOptIdx]
	
	self.players[player] = optIdx
	local opt = self.opts[optIdx]
	opt.votes = opt.votes + 1
	
	self:triggerClientEvent("vote_onOptVotesUpdate", self.el, prevOptIdx, optIdx)
	
	if(prevOpt) then
		prevOpt.votes = prevOpt.votes - 1
	else
		self.votesCount = self.votesCount + 1
	end
	
	local attendance = self.votesCount / self.playersCount * 100
	if(self.info.minAttendance and attendance >= self.info.minAttendance) then
		local opts = self:findBestOptions()
		local percentage = opts[1].votes/self.votesCount*100
		if(#opts == 1 and (not self.info.minPercentage or percentage >= self.info.minPercentage)) then
			self:finishVote(opts[1])
		end
	end
end

function Vote:onPlayerQuit(player)
	local optIdx = self.players[player]
	if(optIdx == nil) then return end
	
	if(optIdx) then
		self.votesCount = self.votesCount - 1
		local opt = self.opts[optIdx]
		opt.votes = opt.votes - 1
		self:triggerClientEvent("vote_onOptVotesUpdate", self.el, optIdx, false)
	end
	
	self.playersCount = self.playersCount - 1
	self.players[player] = nil
end

function Vote:onTimeout()
	local opts = self:findBestOptions()
	if(#opts == 1 or self.votesCount == 0 or self.votesCount == #self.opts or (self.info.maxNominations and self.nominations >= self.info.maxNominations)) then
		local opt = opts[math.random(1, #opts)]
		self:finishVote(opt)
		-- FIXME: chck if we can remove any option
	else -- draw
		self:nextNomination(opts)
	end
end

function Vote:finishVote(opt)
	if(self.info.minPercentage and opt.votes / self.votesCount * 100 < self.info.minPercentage) then
		opt = false
	end
	
	if(opt) then
		outputChatBox("Vote finished! ["..((opt and opt[1]) or "-").."]", self.info.visibleTo)
		triggerEvent("onVoteFinish", self.el, unpack(opt))
	else
		outputChatBox("vote failed!")
	end
	
	self:destroy()
end

function Vote:resetVotes()
	self.votesCount = 0
	
	for i, opt in ipairs(self.opts) do
		opt.votes = 0
	end
	
	for player, optIdx in pairs(self.players) do
		self.players[player] = false
	end
end

function Vote:triggerClientEvent(...)
	for player, optIdx in pairs(self.players) do
		triggerClientEvent(player, ...)
	end
end

function Vote:nextNomination(opts)
	self.nomination = self.nomination + 1
	
	for i, opt in ipairs(self.opts) do
		if(opt.votes < opts[1].votes) then
			table.remove(self.opts, i)
		end
	end
	
	self:resetVotes()
	
	self:triggerClientEvent("vote_nextNomination", self.el, self.opts)
end

function Vote:findBestOptions()
	local bestOpts = {}
	local minVotes = 0
	local draw = false
	for i, opt in ipairs(self.opts) do
		if(opt.votes > minVotes) then
			minVotes = opt.votes
			bestOpts = {opt}
		elseif(opt.votes == minVotes) then
			table.insert(bestOpts, opt)
		end
	end
	
	assert(#bestOpts > 0)
	return bestOpts
end

function Vote:destroy(ignoreEl)
	if(self.timer) then
		killTimer(self.timer)
		self.timer = false
	end
	
	Vote.elMap[self.el] = nil
	
	if(not ignoreEl) then
		if isElement(self.el) then
			destroyElement(self.el)
		end
	end
	
	--outputChatBox("Vote:destroy "..tostring(ignoreEl))
end

function Vote.create(info, opts)
	assert(info.title and isElement(info.visibleTo) and #opts >= 2)
	
	info.timeout = tonumber(info.timeout) or 15
	info.minPercentage = tonumber(info.minPercentage)
	info.allowChange = (info.allowChange == nil) or info.allowChange
	info.maxNominations = tonumber(info.maxNominations)
	info.minAttendance = tonumber(info.minAttendance) or 100
	
	local self = setmetatable({}, Vote.__mt)
	self.info = info
	self.opts = opts
	self.el = createElement("vote")
	self.nomination = 1
	self.players = {}
	self.playersCount = 0
	
	self:resetVotes()
	
	local players = getElementsByType("player", info.visibleTo)
	for i, player in ipairs(players) do
		self.players[player] = false
		self.playersCount = self.playersCount + 1
	end
	
	self:triggerClientEvent("vote_onStart", self.el, self.info, self.opts)
	
	self.timer = setTimer(function()
		self.timer = false
		self:onTimeout()
	end, self.info.timeout * 1000, 1)
	
	Vote.elMap[self.el] = self
	return self
end

addEventHandler("onElementDestroy", g_Root, function()
	local vote = Vote.elMap[source]
	if(not vote) then return end
	vote:destroy(true)
end)

addEventHandler("vote_onPlayerVote", g_Root, function(optIdx)
	local vote = Vote.elMap[source]
	if(not vote) then return end
	vote:onPlayerVote(client, optIdx)
end)

addEventHandler("vote_onPlayerQuit", g_Root, function(optIdx)
	for el, vote in pairs(Vote.elMap) do
		vote:onPlayerQuit(source)
	end
end)
