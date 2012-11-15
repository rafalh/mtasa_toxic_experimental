local g_Root = getRootElement()

addEvent("race_onSpectateReq", true)
addEvent("race_onSpectate", true)

function Player:setSpectateMode(enabled)
	if(self.specMode == enabled) then return end
	
	self.specMode = enabled
	setElementData(self.el, "race.spectating", self.specMode)
	self:triggerEvent("race_onSpectate", self.el, self.specMode)
	
	if(self.alive) then
		self:setFrozen(self.specMode)
		self:setVisible(not self.specMode)
	end
end

function Player:onSpectateReq(enabled)
	if(self.game.state ~= "running" or not self.alive) then return end
	
	-- FIXME: allow for admins
	if(enabled and not self.game.respawn) then
		outputDebugString("Spectate mode not allowed", 3)
		return
	end
	
	if(self.alive and not self.specMode) then
		self:savePos()
	end
	
	self:setSpectateMode(enabled)
	
	if(self.alive and not self.specMode) then
		self:loadPos(true)
	end
end

local function onSpectateReq(enabled)
	local player = Player.elMap[client]
	if(not player) then return end
	player:onSpectateReq(enabled)
end

addEventHandler("race_onSpectateReq", g_Root, onSpectateReq)
