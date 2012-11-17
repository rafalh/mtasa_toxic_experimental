local g_SpectateMode = false
local g_Me = getLocalPlayer()
local g_Target = false
local g_Root = getRootElement()

addEvent("race_onSpectateReq", true)
addEvent("race_onSpectate", true)
addEvent("onClientPlayerChangeRoom")

function isSpectateModeEnabled()
	return g_SpectateMode
end

function setSpectateModeEnabled(enabled)
	triggerServerEvent("race_onSpectateReq", g_Me, enabled)
end

local function getPlayersForSpectate()
	local players = getRoomPlayers(getCurrentRoom())
	local ret = {}
	for i, player in ipairs(players) do
		local specMode = getElementData(player, "race.spectating")
		if(not specMode and player ~= g_Me and not isPlayerDead(player)) then
			table.insert(ret, player)
		end
	end
	return ret
end

local function spectateSky()
	g_Target = false
	local cx, cy = getCameraMatrix()
	local _,_,pz = getElementPosition(localPlayer)
	setCameraMatrix(cx, cy, 1000+pz)
end

local function spectatePlayer(player)
	--local veh = getPedOccupiedVehicle(player)
	g_Target = player
	setCameraTarget(player)
	Checkpoints.spectate(player)
end

local function spectateNextPrev(dir)
	if(not g_SpectateMode) then return end
	
	local players = getPlayersForSpectate()
	
	if(#players == 0) then
		spectateSky()
	else
		local i = g_Target and table.find(players, g_Target)
		if(not i) then
			spectatePlayer(players[1])
		else
			i = math.wrap(i + dir, 1, #players)
			assert(i >= 1 and i <= #players)
			if(g_Target ~= players[i]) then
				spectatePlayer(players[i])
			end
		end
	end
end

function spectateNext()
	spectateNextPrev(1)
end

function spectatePrev()
	spectateNextPrev(-1)
end

local function onSpectate(enabled)
	g_SpectateMode = enabled
	if(enabled) then
		spectateNext()
	else
		setCameraTarget(g_Me)
		Checkpoints.spectate(false)
	end
	triggerEvent("onClientSpectateMode", g_Me, enabled)
end

local function onPlayerQuitOrWasted()
	if(g_SpectateMode and g_Target == source) then
		spectateNext()
	end
end

addEventHandler("race_onSpectate", g_Root, onSpectate)
addEventHandler("onClientPlayerQuit", g_Root, onPlayerQuitOrWasted)
addEventHandler("onClientPlayerWasted", g_Root, onPlayerQuitOrWasted)
addEventHandler("onClientPlayerChangeRoom", g_Root, onPlayerQuitOrWasted)
