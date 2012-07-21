cache.radios = {}
cache.changeLabel = false
cache.radioActualChannel = false
cache.radioGUIVisible = false
cache.radiosTile = {}
cache.radioScreenOut = 0
cache.radioTempScroll = 0

function onGuiRadioStart()
	cache.radioNameLabel = metroUIText.create("Radio",60,resolution[2]/2-235,400,40,tocolor(255,255,255),1)
	cache.radioBackButton = guiCreateStaticImage(5,resolution[2]/2-220,48,48,"images/metroUI/back.png",false)
	cache.radioScroll = guiCreateScrollBar (5, resolution[2]/2+170, resolution[1]-5,15,true, false)
	local radio = xmlLoadFile ( "config/radio.xml")
	if radio then
		local ids = 0
		local rdpos = {x=0,y=0}
		local numerofXTile = 0
		while xmlFindChild (radio,"radio", ids) do
			local node = xmlFindChild (radio,"radio", ids)
			local args = xmlNodeGetAttributes(node)
			local tile = metroUIcreate(5+(rdpos.x*165),resolution[2]/2-165+(rdpos.y*165),160,160,"niebieski",args.name or "Radio: "..args.id,"images/gui/radio/"..args.id..".png",{onClick={func=onGuiMetroClick,arg=args.id}})
			if rdpos.y == 1 then
				rdpos.y = 0
				rdpos.x = rdpos.x + 1
				numerofXTile = numerofXTile + 1
			else
				rdpos.y = rdpos.y + 1
				cache.radioScreenOut = cache.radioScreenOut + 170
			end
			ids = ids + 1
			cache.radios[args.id] = args
			table.insert(cache.radiosTile,tile)
		end
		cache.radioScreenOut = (cache.radioScreenOut - (resolution[1] - 10)) / numerofXTile
		outputChatBox(cache.radioScreenOut)
		xmlUnloadFile(radio)
	end
	cache.radioTempScroll = guiScrollBarGetScrollPosition(cache.radioScroll)
	setGuiRadioVisible(cache.radioGUIVisible)
	local resCacheradioActualChannel = getElementData(localPlayer,"resCache:radioActualChannel")
	if resCacheradioActualChannel then
		changeRadioChannel(resCacheradioActualChannel)
	end
end

function onGuiRadioStop()
	local ids = cache.radioActualChannel
	if ids then
		setElementData(localPlayer,"resCache:radioActualChannel",ids)
	end
end

function setGuiRadioVisible(bool)
	cache.radioNameLabel:setVisible(bool)
	guiSetVisible(cache.radioBackButton,bool)
	guiSetVisible(cache.radioScroll,bool)
	for k,v in ipairs(cache.radiosTile) do
		guiSetVisible(v,bool)
	end
	showChat (not bool)
	cache.radioGUIVisible = bool
end

function onGuiRadioClick(bt,button,state,absoluteX,absoluteY)
	if button == "left" then
		if bt == cache.radioBackButton then
			setGuiRadioVisible(false)
			setMainPanelVisible(true)
		end
	end
end

function onGuiMetroClick(button,state,absoluteX,absoluteY,args)
	if button == "left" then
		if not isTimer(cache.radioChannelSetTimer) then
			changeRadioChannel(args)
		end
	end
end

function onRadioScroll(scroller)
	if scroller == cache.radioScroll then
		local scroll = guiScrollBarGetScrollPosition(scroller)
		if cache.radioTempScroll > scroll then
			for k,v in ipairs(cache.radiosTile) do
				local px = guiGetPosition(v,false)
				setMetroUITilePosition(v,px+cache.radioScreenOut)
			end
		elseif cache.radioTempScroll < scroll then
			for k,v in ipairs(cache.radiosTile) do
				local px = guiGetPosition(v,false)
				setMetroUITilePosition(v,px-cache.radioScreenOut)
			end
		end
		cache.radioTempScroll = scroll
	end
end

function changeRadioChannel(id)
	if cache.changeLabel then
		cache.changeLabel:delete()
		cache.changeLabel = nil
	end
	if id == "offs" then
		cache.radioActualChannel = false
		if isElement(cache.playerSounds) then
			destroyElement(cache.playerSounds)
		end
		if isTimer(cache.radioChannelSetTimer) then
			killTimer(cache.radioChannelSetTimer)
			cache.radioChannelSetTimer = nil
		end
		cache.radioNameLabel:setText("Radio")
		metroUISetTextKafelek(getMainMetroKafelek(5),"Radio")
		metroUISetKafelekObraz(getMainMetroKafelek(5),"images/gui/main/radio.png")
		return
	end
	cache.changeLabel = metroUIText.create("zmienianie radia...",resolution[1]/2-350,resolution[2]/2+200,400,40,tocolor(255,255,255),0.5)
	if not cache.radioGUIVisible then
		cache.changeLabel:setPosition(5,resolution[2]-30)
	end
	if isElement(cache.playerSounds) then
		destroyElement(cache.playerSounds)
	end
	if isTimer(cache.radioChannelSetTimer) then
		killTimer(cache.radioChannelSetTimer)
		cache.radioChannelSetTimer = nil
	end
	cache.radioChannelSetTimer = setTimer(
	function ()
		cache.playerSounds = playSound(cache.radios[id].url)
		cache.radioNameLabel:setText("Radio: "..(cache.radios[id].name or id))
		metroUISetTextKafelek(getMainMetroKafelek(5),"Radio: "..(cache.radios[id].name or id))
		metroUISetKafelekObraz(getMainMetroKafelek(5),"images/gui/radio/"..id..".png")
		cache.changeLabel:delete()
		cache.radioActualChannel = id
		cache.changeLabel = nil
	end,500,1)
end

addEventHandler("onClientGUIScroll",getRootElement(),onRadioScroll)