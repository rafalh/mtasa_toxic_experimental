local function outputDebug() end
local function isServer() return true end
local function isClient() return false end

---------------------------------------------------------------------------
-- TimerMgr
---------------------------------------------------------------------------
TimerMgr = {}
TimerMgr.list = {}

-- Create a timer with tags
function TimerMgr.createTimerFor( ... )
	-- Make a dictionary of tags for easy lookup
	local tagMap = {}
	for _,arg in ipairs({ ... }) do
		tagMap[tostring(arg)] = 1
	end
	local timer = Timer:create(true)
	table.insert( TimerMgr.list, { timer=timer, tagMap=tagMap } )
	outputDebug( "TIMERS", getScriptLocation() .. " create - number of timers:" .. tostring(#TimerMgr.list) )
	return timer
end

-- Timer must have all the tags specified
function TimerMgr.hasTimerFor( ... )
	local timers = TimerMgr.getTimersByTags(...)
	return #timers > 0
end

-- Timers must have all the tags specified
function TimerMgr.destroyTimersFor( ... )
	local timers = TimerMgr.getTimersByTags(...)
	for _,timer in ipairs(timers) do
		timer:destroy()
	end
end

-- Remove specific timer from the list
function TimerMgr.removeTimer( timer )
	for _,item in ipairs(TimerMgr.list) do
		if item.timer == timer then
			table.removevalue(TimerMgr.list, item)
			outputDebug( "TIMERS", getScriptLocation() .. " remove - number of timers:" .. tostring(#TimerMgr.list) )
		end
	end
end

-- Get all timers which contains all matching tags
function TimerMgr.getTimersByTags( ... )
	-- Get list of tags to find
	local findtags = {}
	for _,arg in ipairs({ ... }) do
		table.insert( findtags, tostring(arg) )
	end
	-- Check each timer
	local timers = {}
	for i,item in ipairs(TimerMgr.list) do
		local bFound = true
		for _,tag in ipairs(findtags) do
			if item.tagMap[tag] ~= 1 then
				bFound = false
				break
			end
		end
		if bFound then
			table.insert( timers, item.timer )
		end
	end
	return timers
end


if isServer() then
	addEventHandler ( "onElementDestroy", root,
		function()
			TimerMgr.destroyTimersFor( source )
		end
	)
end

if isClient() then
	addEventHandler ( "onClientElementDestroy", root,
		function()
			TimerMgr.destroyTimersFor( source )
		end
	)
end


---------------------------------------------------------------------------
-- Timer - Wraps a standard timer
---------------------------------------------------------------------------
Timer = {}
Timer.__index = Timer
Timer.instances = {}

-- Create a Timer instance
function Timer:create(autodestroy)
    local id = #Timer.instances + 1
    Timer.instances[id] = setmetatable(
        {
            id = id,
            timer = nil,      -- Actual timer
            autodestroy = autodestroy,
        },
        self
    )
    return Timer.instances[id]
end

-- Destroy a Timer instance
function Timer:destroy()
    self:killTimer()
    TimerMgr.removeTimer(self)
    Timer.instances[self.id] = nil
    self.id = 0
end

-- Check if timer is valid
function Timer:isActive()
    return self.timer ~= nil
end

-- killTimer
function Timer:killTimer()
    if self.timer then
        killTimer( self.timer )
        self.timer = nil
    end
end

-- setTimer
function Timer:setTimer( theFunction, timeInterval, timesToExecute, ... )
    self:killTimer()
    self.fn = theFunction
    self.count = timesToExecute
    self.dodestroy = false
    self.args = { ... }
	if timeInterval < 50 then
		timeInterval = 50
	end
    self.timer = setTimer( function() self:handleFunctionCall() end, timeInterval, timesToExecute )
end

function Timer:handleFunctionCall()
    -- Delete reference to timer if there are no more repeats
    if self.count > 0 then
        self.count = self.count - 1
        if self.count == 0 then
            self.timer = nil
            self.dodestroy = self.autodestroy
        end
    end
    self.fn(unpack(self.args))
    if self.dodestroy then
        self:destroy()
    end
end