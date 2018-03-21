local g_resource = getThisResource()
local g_resourceRoot = getResourceRootElement()
local g_localPlayer = getLocalPlayer()
local g_commandsNames = {}


local function destroyAllElements()
	local destroyedCount = 0
	local subroots = getElementChildren(g_resourceRoot)
	for i, subroot in ipairs(subroots) do
		for i, el in ipairs(getElementChildren(subroot)) do
			if isElementLocal(el) then
				if not destroyElement(el) then
					outputDebugString("destroyElement "..getElementType(el).." failed", 2)
				else
					destroyedCount = destroyedCount + 1
				end
			end
		end
	end
	outputDebugString("Destroyed "..destroyedCount.." elements", 3)
	
	-- Server-side elements?
	-- local cnt = #getElementsByType("sound", g_resourceRoot)
	-- if(cnt ~= 0) then outputDebugString("Found "..cnt.." sounds", 2) end
	-- cnt = #getElementsByType("checkpoint", g_resourceRoot)
	-- if(cnt ~= 0) then outputDebugString("Found "..cnt.." checkpoints", 2) end
	-- cnt = #getElementsByType("spawnpoint", g_resourceRoot)
	-- if(cnt ~= 0) then outputDebugString("Found "..cnt.." spawnpoints", 2) end
	-- cnt = #getElementsByType("racepickup", g_resourceRoot)
	-- if(cnt ~= 0) then outputDebugString("Found "..cnt.." pickups", 2) end
end

local function killAllTimers()
	local timers = getTimers()
	for i, timer in ipairs(timers) do
		killTimer(timer)
	end
	outputDebugString("Killed "..tostring(#timers).." timers", 3)
end

local function removeAllCommandHandlers()
	local numSuccess, numError = 0, 0
	for _, command in ipairs(g_commandsNames) do
		if removeCommandHandler(command) then
			numSuccess = numSuccess + 1
		else
			numError = numError + 1
		end
	end
	if numSuccess > 0 or numError > 0 then
		outputDebugString(('Removed %d command handlers (%d errors)'):format(numSuccess, numError), 3)
	end
end

local function unbindAllKeys()
	local keyTable = { "mouse1", "mouse2", "mouse3", "mouse4", "mouse5", "mouse_wheel_up", "mouse_wheel_down", "arrow_l", "arrow_u",
		"arrow_r", "arrow_d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
		"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "num_0", "num_1", "num_2", "num_3", "num_4", "num_5",
		"num_6", "num_7", "num_8", "num_9", "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "F1", "F2", "F3", "F4", "F5",
		"F6", "F7", "F8", "F9", "F10", "F11", "F12", "backspace", "tab", "lalt", "ralt", "enter", "space", "pgup", "pgdn", "end", "home",
		"insert", "delete", "lshift", "rshift", "lctrl", "rctrl", "[", "]", "pause", "capslock", "scroll", ";", ",", "-", ".", "/", "#", "\\", "=" }

	local num = 0
	for _, key in ipairs(keyTable) do
		if unbindKey(key) then
			num = num + 1
		end
	end
	if num > 0 then
		outputDebugString(('Unbound %d keys'):format(num), 3)
	end
end

local function destroyRuntimeObjects()
	local removedHandlers = _room_removeAllEventHandlers()
	outputDebugString("Removed "..tostring(removedHandlers).." event handlers", 3)
	
	destroyAllElements()
	killAllTimers()
	removeAllCommandHandlers()
	unbindAllKeys()
end

addEventHandler('onClientPlayerEnterRoom', g_localPlayer, function ()
	--outputDebugString('Calling onClientResourceStart in room (after onClientPlayerEnterRoom)', 3)
	--_room_runEventHandlers('onClientResourceStart', g_resourceRoot)
end)

addEventHandler('onClientPlayerLeaveRoom', g_localPlayer, function ()
	_room_runEventHandlers('onClientResourceStop', g_resourceRoot)
	destroyRuntimeObjects()
end)

function _room_clearEventHandlerEnv()
	-- Remove globals
	g_roomEnv.source = nil
	g_roomEnv.this = nil
	g_roomEnv.sourceResource = nil
	g_roomEnv.sourceResourceRoot = nil
	g_roomEnv.client = nil
	g_roomEnv.eventName = nil
end

-- HOOKS

local _addCommandHandler = addCommandHandler
function addCommandHandler(commandName, ...)
	local ret = _addCommandHandler(commandName, ...)
	if ret then
		table.insert(g_commandsNames, commandName)
	end
	return ret
end
