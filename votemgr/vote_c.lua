local g_Root = getRootElement()
local g_Res = getThisResource()
local g_ResRoot = getResourceRootElement()
local g_Me = getLocalPlayer()
local g_ScrW, g_ScrH = guiGetScreenSize()

local ANIM_MS = 500

Vote = {}
Vote.__mt = {__index = Vote}
Vote.elMap = {}

addEvent("vote_onStart", true)
addEvent("vote_nextNomination", true)
addEvent("vote_onOptVotesUpdate", true)

function Vote:updateGUI()
	local delay = false
	if(self.wnd) then
		self:hide(true)
		delay = true
	end
	
	if(self.timeoutTimer) then
		killTimer(self.timeoutTimer)
	end
	
	local w, h = 200, 70 + #self.opts*40
	if(self.info.subtitle) then
		h = h + 20
	end
	local x, y = g_ScrW - w - 10, g_ScrH - h - 10
	self.wnd = guiCreateWindow(x, g_ScrH, w, h, self.info.title, false)
	
	local y = 20
	
	if(self.info.subtitle) then
		guiCreateLabel(10, y, w - 20, 15, self.info.subtitle, false, self.wnd)
		y = y + 20
	end
	
	for i, opt in ipairs(self.opts) do
		opt.label = guiCreateLabel(10, y, w - 20, 15, i..". "..opt[1], false, self.wnd)
		opt.bar = guiCreateProgressBar(10, y + 15, w - 20, 20, false, self.wnd)
		
		local onOptClick = function()
			self:onVote(i)
		end
		
		addEventHandler("onClientGUIClick", opt.label, onOptClick, false)
		addEventHandler("onClientGUIClick", opt.bar, onOptClick, false)
		y = y + 40
	end
	y = y + 5
	
	local infoLabel = guiCreateLabel(10, y, w - 20, 15, "Press 1 - "..#self.opts.." to vote", false, self.wnd)
	guiLabelSetHorizontalAlign(infoLabel, "center")
	guiSetAlpha(infoLabel, 0.5)
	y = y + 20
	
	self.currentTimeout = self.info.timeout
	self.timeoutLabel = guiCreateLabel(10, y, w - 20, 15, self.currentTimeout.." seconds left", false, self.wnd)
	guiLabelSetHorizontalAlign(self.timeoutLabel, "center")
	self.timeoutTimer = setTimer(function()
		self:onTimerTick()
	end, 1000, self.currentTimeout)
	
	if(delay) then
		self.showTimer = setTimer(function()
			self.showTimer = false
			self:show()
		end, ANIM_MS, 1)
	else
		self:show()
	end
end

function Vote:show()
	local x, y = guiGetPosition(self.wnd, false)
	local w, h = guiGetSize(self.wnd, false)
	Animation.createAndPlay(self.wnd, Animation.presets.guiMoveEx(x, g_ScrH - h - 10, ANIM_MS, false, x, g_ScrH, "OutBack"))
end

function Vote:hide(destroy)
	if(not self.wnd) then return end
	
	if(self.timeoutTimer) then
		killTimer(self.timeoutTimer)
		self.timeoutTimer = false
	end
	
	local x, y = guiGetPosition(self.wnd, false)
	Animation.createAndPlay(self.wnd, Animation.presets.guiMoveEx(x, g_ScrH, ANIM_MS, false, x, y, "InQuad"))
	
	if(destroy) then
		setTimer(destroyElement, ANIM_MS, 1, self.wnd)
		self.wnd = false
	end
end

function Vote:onTimerTick()
	self.currentTimeout = self.currentTimeout - 1
	guiSetText(self.timeoutLabel, self.currentTimeout.." seconds left")
	if(self.currentTimeout <= 3) then
		guiLabelSetColor(self.timeoutLabel, 255, 0, 0)
	elseif(self.currentTimeout <= 6) then
		guiLabelSetColor(self.timeoutLabel, 255, 255, 0)
	end
	
	if(self.currentTimeout == 0) then
		self:onTimeout()
	end
end

function Vote:onTimeout()
	self:hide(true)
	self:unbindKeys()
end

function Vote:onVote(optIdx)
	if(self.currentOpt) then
		if(not self.info.allowChange) then return end
		guiLabelSetColor(self.currentOpt.label, 255, 255, 255)
	end
	
	local opt = self.opts[optIdx]
	self.currentOpt = opt
	guiLabelSetColor(opt.label, 0, 255, 0)
	triggerServerEvent("vote_onPlayerVote", self.el, optIdx)
end

function Vote:onNextNomination(opts)
	self.opts = opts
	self.currentOpt = false
	self:updateGUI()
	self:bindKeys()
end

function Vote:updateOptBars()
	local playersCount = #getElementsByType("player", self.info.visibleTo)
	
	for i, opt in ipairs(self.opts) do
		guiProgressBarSetProgress(opt.bar, opt.votes / playersCount * 100)
	end
end

function Vote:onOptVotesUpdate(prevOptIdx, newOptIdx)
	local playersCount = #getElementsByType("player", self.info.visibleTo)
	
	local prevOpt = prevOptIdx and self.opts[prevOptIdx]
	if(prevOpt) then
		prevOpt.votes = prevOpt.votes - 1
		Animation.createAndPlay(prevOpt.bar, Animation.presets.guiProgressBarSetProgress(prevOpt.votes/playersCount*100, 500, false, "InOutQuad"))
	end
	
	local newOpt = newOptIdx and self.opts[newOptIdx]
	if(newOpt) then
		newOpt.votes = newOpt.votes + 1
		Animation.createAndPlay(newOpt.bar, Animation.presets.guiProgressBarSetProgress(newOpt.votes/playersCount*100, 500, false, "InOutQuad"))
	end
end

function Vote:bindKeys()
	if(self.keysBound) then return end
	self.keysBound = true
	
	for i, opt in ipairs(self.opts) do
		bindKey(tostring(i), "down", Vote.onKeyDown, self.el)
	end
end

function Vote:unbindKeys()
	if(not self.keysBound) then return end
	self.keysBound = false
	
	for i, opt in ipairs(self.opts) do
		unbindKey(tostring(i), "down", Vote.onKeyDown)
	end
end

function Vote:destroy()
	if(self.showTimer) then
		killTimer(self.showTimer)
		self.showTimer = false
	end
	self:unbindKeys()
	self:hide(true)
	Vote.elMap[self.el] = nil
end

function Vote.create(el, info, opts)
	local self = setmetatable({}, Vote.__mt)
	self.info = info
	self.opts = opts
	self.el = el
	self.keysBound = false
	self.currentOpt = false
	
	assert(not Vote.elMap[self.el])
	Vote.elMap[self.el] = self
	
	self:updateGUI()
	self:bindKeys()
	
	return self
end

function Vote.onKeyDown(key, keyState, voteEl)
	local optIdx = tonumber(key)
	local vote = Vote.elMap[voteEl]
	if(not vote or not optIdx) then return end
	vote:onVote(optIdx)
end

addEventHandler("onClientElementDestroy", g_Root, function()
	local vote = Vote.elMap[source]
	if(not vote) then return end
	vote:destroy()
end)

addEventHandler("vote_onStart", g_Root, function(info, opts)
	Vote.create(source, info, opts)
end)

addEventHandler("vote_nextNomination", g_Root, function(opts)
	local vote = Vote.elMap[source]
	if(not vote) then return end
	vote:onNextNomination(opts)
end)

addEventHandler("vote_onOptVotesUpdate", g_Root, function(prevOptIdx, newOptIdx)
	local vote = Vote.elMap[source]
	if(not vote) then return end
	vote:onOptVotesUpdate(prevOptIdx, newOptIdx)
end)
