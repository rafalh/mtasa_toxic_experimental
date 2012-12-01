local SCREENSHOT_QUALITY = 30
local SCREENSHOT_BANDWIDTH = 32*1024
local SCREENSHOT_MAX_RESOLUTION = 1024*768

addEvent("dbg_onScreenShotReq", true)

local function onScreenShotReq(player, w, h)
	if(not g_Players[client].admin) then return end
	
	g_Players[client].screenShot = player
	if(not g_Players[player].takingScreenShot) then
		g_Players[player].takingScreenShot = true
		if(w*h > SCREENSHOT_MAX_RESOLUTION) then
			local a = (w*h) / SCREENSHOT_MAX_RESOLUTION
			w = w / a^0.5
			h = h / a^0.5
			assert(w*h <= SCREENSHOT_MAX_RESOLUTION + 1)
		end
		takePlayerScreenShot(player, w, h, "", SCREENSHOT_QUALITY, SCREENSHOT_BANDWIDTH)
	end
end

local function onPlayerScreenShot(res, status, imageData)
	if(res ~= g_Res) then return end
	
	assert(g_Players[source].takingScreenShot)
	g_Players[source].takingScreenShot = false
	
	if(status == "ok" and imageData:len() > 65000) then
		outputDebugString("Screen-shot is too big - "..imageData:len().."B", 2)
	end
	
	for player, pdata in pairs(g_Players) do
		if(pdata.screenShot and pdata.screenShot == source) then
			pdata.screenShot = false
			if(status == "ok") then
				triggerClientEvent(player, "dbg_onScreenShot", source, imageData)
			else
				outputChatBox("Failed to take player screenshot: "..status, player, 255, 0, 0)
			end
		end
	end
end

addEventHandler("dbg_onScreenShotReq", g_Root, onScreenShotReq)
addEventHandler("onPlayerScreenShot", g_Root, onPlayerScreenShot)
