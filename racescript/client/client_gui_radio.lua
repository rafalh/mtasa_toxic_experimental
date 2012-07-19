cache.radios = {}
cache.changeLabel = false
cache.radioActualChannel = false
cache.radioGUIVisible = false

function onGuiRadioStart()
	cache.radioNameLabel = metroUITextcreate("Radio",resolution[1]/2-350,resolution[2]/2-275,400,40,tocolor(255,255,255),1)
	cache.radioBackButton = guiCreateStaticImage(resolution[1]/2-400,resolution[2]/2-260,48,48,"images/metroUI/back.png",false)
	cache.radioScrollPanel = guiCreateScrollPane(resolution[1]/2-350,resolution[2]/2-200, 680,400, false)
	local radio = xmlLoadFile ( "config/radio.xml")
	if radio then
		local ids = 0
		local rdpos = {x=0,y=0}
		while xmlFindChild (radio,"radio", ids) do
			local node = xmlFindChild (radio,"radio", ids)
			local args = xmlNodeGetAttributes(node)
			metroUIcreate(5+(rdpos.x*165),5+(rdpos.y*165),160,160,"niebieski",args.name or "Radio: "..args.id,"images/gui/radio/"..args.id..".png",{onClick={func=onGuiMetroClick,arg=args.id}},cache.radioScrollPanel)
			if rdpos.x == 3 then
				rdpos.x = 0
				rdpos.y = rdpos.y + 1
			else
				rdpos.x = rdpos.x + 1
			end
			ids = ids + 1
			cache.radios[args.id] = args
		end
		xmlUnloadFile(radio)
	end
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
	metroUITextSetVisible(cache.radioNameLabel,bool)
	guiSetVisible(cache.radioBackButton,bool)
	guiSetVisible(cache.radioScrollPanel,bool)
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

function changeRadioChannel(id)
	if cache.changeLabel then
		metroUITextDelete(cache.changeLabel)
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
		metroUITextsetText(cache.radioNameLabel,"Radio")
		metroUISetTextKafelek(getMainMetroKafelek(5),"Radio")
		metroUISetKafelekObraz(getMainMetroKafelek(5),"images/gui/main/radio.png")
		return
	end
	cache.changeLabel = metroUITextcreate("zmienianie radia...",resolution[1]/2-350,resolution[2]/2+200,400,40,tocolor(255,255,255),0.5)
	if not cache.radioGUIVisible then
		metroUITextSetPosition(cache.changeLabel,5,resolution[2]-30)
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
		metroUITextsetText(cache.radioNameLabel,"Radio: "..(cache.radios[id].name or id))
		metroUISetTextKafelek(getMainMetroKafelek(5),"Radio: "..(cache.radios[id].name or id))
		metroUISetKafelekObraz(getMainMetroKafelek(5),"images/gui/radio/"..id..".png")
		metroUITextDelete(cache.changeLabel)
		cache.radioActualChannel = id
		cache.changeLabel = nil
	end,500,1)
end