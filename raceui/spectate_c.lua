local g_White = tocolor(255, 255, 255)
local g_Font = "bankgothic"
local g_FontScale = 0.8
local g_FontHeight = dxGetFontHeight(g_FontScale, g_Font)
local g_SpecPrevImg, g_SpecNextImg
local g_SpecPrevActiveImg, g_SpecNextActiveImg
local g_SpecPrevActive, g_SpecNextActive
local g_SpecModeLabel, g_SpecModeTargetLabel

local function rednerSpectate()
	local specMode = getElementData(g_Me, "race.spectating")
	g_SpecModeLabel:setVisible(specMode)
	--g_SpecModeLabel:setBuffered(getTickCount()%2000 > 1000)
	g_SpecModeTargetLabel:setVisible(specMode)
	
	if(not specMode) then return end
	
	--dxDrawText("Spectate Mode", 0, 100, g_ScrW, 0, g_White, g_FontScale, g_Font, "center")
	
	local target = getCameraTarget()
	if(target and getElementType(target) == "vehicle") then
		target = getVehicleOccupant(target)
	end
	if(target) then
		local targetName = getPlayerName(target)
		g_SpecModeTargetLabel:setText("Spectating "..targetName)
	else
		g_SpecModeTargetLabel:setText("No one to spectate")
	end
	
	if(g_SpecPrevActive) then
		g_SpecPrevActiveImg:render()
	else
		g_SpecPrevImg:render()
	end
	
	if(g_SpecNextActive) then
		g_SpecNextActiveImg:render()
	else
		g_SpecNextImg:render()
	end
end

local function spectate()
	local enabled = isSpectateModeEnabled()
	setSpectateModeEnabled(not enabled)
end

local function spectatePrevReq(key, keyState)
	g_SpecPrevActive = (keyState == "down")
	
	if(keyState == "up") then
		spectatePrev()
	end
end

local function spectateNextReq(key, keyState)
	g_SpecNextActive = (keyState == "down")
	
	if(keyState == "up") then
		spectateNext()
	end
end

function initSpectate()
	g_SpecPrevImg = DxImg.create("img/specprev.png")
	g_SpecPrevImg:setPos(g_ScrW/2 - 200 - g_SpecPrevImg.w, g_ScrH - 100 - g_SpecPrevImg.h/2)
	g_SpecPrevActiveImg = DxImg.create("img/specprev_hi.png")
	g_SpecPrevActiveImg:setPos(g_ScrW/2 - 200 - g_SpecPrevImg.w, g_ScrH - 100 - g_SpecPrevImg.h/2)
	
	g_SpecNextImg = DxImg.create("img/specnext.png")
	g_SpecNextImg:setPos(g_ScrW/2 + 200, g_ScrH - 100 - g_SpecNextImg.h/2)
	g_SpecNextActiveImg = DxImg.create("img/specnext_hi.png")
	g_SpecNextActiveImg:setPos(g_ScrW/2 + 200, g_ScrH - 100 - g_SpecNextImg.h/2)
	
	g_SpecModeLabel = DxLabel.create("Spectate Mode", 0, 100, g_ScrW, 0)
	g_SpecModeLabel:setAlign("center")
	g_SpecModeLabel:setFont(g_Font, g_FontScale)
	g_SpecModeLabel:setVisible(false)
	g_SpecModeLabel:setBorder(1)
	--g_SpecModeLabel:setShadow(128, 3, 3, 1)
	
	g_SpecModeTargetLabel = DxLabel.create("", 0, g_ScrH - 100, g_ScrW)
	g_SpecModeTargetLabel:setAlign("center")
	g_SpecModeTargetLabel:setVerticalAlign("center")
	g_SpecModeTargetLabel:setFont(g_Font, g_FontScale)
	g_SpecModeTargetLabel:setColorCoded(false)
	g_SpecModeTargetLabel:setVisible(false)
	
	bindKey("b", "down", spectate)
	bindKey("arrow_l", "both", spectatePrevReq)
	bindKey("arrow_r", "both", spectateNextReq)
	
	addEventHandler("onClientRender", g_Root, rednerSpectate)
end
