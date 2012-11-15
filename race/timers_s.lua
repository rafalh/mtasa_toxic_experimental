local g_Root = getRootElement()

-- TimerMgr

TimerMgr = {}
TimerMgr.list = {}
TimerMgr.tagMap = {}

function TimerMgr.createTimerFor(...)
	local timer = Timer.create()
	timer.tags = {...}
	for i, tag in ipairs(timer.tags) do
		if(not TimerMgr.tagMap[tag]) then
			TimerMgr.tagMap[tag] = {}
		end
		table.insert(TimerMgr.tagMap[tag], timer)
	end
	return timer
end

function TimerMgr.removeTimer(timer)
	TimerMgr.list[timer.id] = nil
	for i, tag in ipairs(timer.tags) do
		table.removeValue(TimerMgr.tagMap[tag], timer)
	end
end

function TimerMgr.findTimerFor(...)
	local ret = {}
	local tags = {...}
	
	for i, tag in ipairs(tags) do
		for j, timer in pairs(TimerMgr.tagMap[tag] or {}) do
			table.insert(ret, timer)
		end
	end
	
	return ret
end

function TimerMgr.destroyTimerFor(...)
	local timers = TimerMgr.findTimerFor(...)
	
	for i, timer in ipairs(timers) do
		timer:destroy()
	end
	
	return #timers
end

function TimerMgr.onElDestroy()
	TimerMgr.destroyTimerFor(source)
end

addEventHandler("onElementDestroy", g_Root, TimerMgr.onElDestroy)

-- Timer
Timer = {}
Timer.__mt = {__index = Timer}

function Timer.create(fn, ms, count, ...)
	local timer = setmetatable({}, Timer.__mt)
	
	timer.id = #TimerMgr.list + 1
	TimerMgr.list[timer.id] = timer
	
	timer.tags = {}
	timer.args = {}
	
	--timer:set(fn, ms, count, ...)
	return timer
end

function Timer:set(fn, ms, count, ...)
	self.t = setTimer(self.onTick, ms, count or 1, self.id)
	self.fn = fn
	self.args = {...}
	self.count = count or 1
	return self
end

function Timer:kill()
	if(self.t) then
		killTimer(self.t)
		self.t = false
	end
end

function Timer:destroy()
	self:kill()
	TimerMgr.removeTimer(self)
end

function Timer.onTick(id)
	local timer = TimerMgr.list[id]
	assert(timer)
	
	timer.fn(unpack(timer.args))
	
	if(timer.count == 1) then
		timer.t = false
		timer:destroy()
	elseif(timer.count > 1) then
		timer.count = timer.count - 1
	end
end
