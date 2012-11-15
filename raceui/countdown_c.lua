local g_Countdown, g_CountdownTicks
local g_CountdownImages = {}
local g_Scale = 0.8

local function renderCountdown()
	if(not g_Countdown) then return end
	
	local img = g_CountdownImages[g_Countdown]
	local w, h = img.w * g_Scale, img.h * g_Scale
	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2
	local ticks = getTickCount()
	local a = math.max(255 - (ticks - g_CountdownTicks)/1000*255, 0)
	local clr = tocolor(255, 255, 255, a)
	dxDrawImage(x, y, w, h, img.tex, 0, 0, 0, clr)
end

local function onCountdown(count)
	playSoundFrontEnd(43)
	
	g_Countdown = count
	g_CountdownTicks = getTickCount()
	if(count <= 0) then
		setTimer(function()
			g_Countdown = false
		end, 1000, 1)
	end
end

function initCountdown()
	for i = 0, 3 do
		local img = {}
		img.tex = dxCreateTexture("img/countdown_"..i..".png", "argb", false)
		img.w, img.h = dxGetMaterialSize(img.tex)
		g_CountdownImages[i] = img
	end
	
	addEventHandler("onClientGameCountdown", g_Root, onCountdown)
	addEventHandler("onClientRender", g_Root, renderCountdown)
end
