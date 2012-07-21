cache.mainpanelKafelki = {}
cache.mainpanelText = false
cache.mainPanelEnabled = false

function onMainPanelStart()
	cache.mainpanelText = metroUIText.create("Panel użytkownika",resolution[1]/2-245,resolution[2]/2-285,400,40,tocolor(255,255,255),0.5)
	table.insert(cache.mainpanelKafelki,metroUIcreate(resolution[1]/2-245,resolution[2]/2-245,160, 160,"niebieski","Statystyki","images/gui/main/statystyki.png",{onClick={func=onClickMainPanel,arg="staty"}}))
	table.insert(cache.mainpanelKafelki,metroUIcreate(resolution[1]/2-80,resolution[2]/2-245,160, 160,"niebieski","Profil","images/gui/main/profil.png",{onClick={func=onClickMainPanel,arg="profil"}}))
	table.insert(cache.mainpanelKafelki,metroUIcreate(resolution[1]/2+85,resolution[2]/2-245,160, 160,"niebieski","Sklep","images/gui/main/sklep.png",{onClick={func=onClickMainPanel,arg="sklep"}}))
	table.insert(cache.mainpanelKafelki,metroUIcreate(resolution[1]/2+85,resolution[2]/2-80,160, 160,"niebieski","Ustawienia","images/gui/main/ustawienia.png",{onClick={func=onClickMainPanel,arg="ustawienia"}}))
	table.insert(cache.mainpanelKafelki,metroUIcreate(resolution[1]/2-245,resolution[2]/2-80,325, 160,"niebieski","Radio","images/gui/main/radio.png",{onClick={func=onClickMainPanel,arg="radio"}}))
	table.insert(cache.mainpanelKafelki,metroUIcreate(resolution[1]/2+85,resolution[2]/2+85,160, 160,"niebieski","Wyjdz","images/gui/main/off.png",{onClick={func=onClickMainPanel,arg="off"}}))
	setMainPanelVisible(cache.mainPanelEnabled)
	bindKey("F2","down",setMainPanelEnabledBind)
end

function setMainPanelEnabledBind()
	if not cache.mainPanelEnabled then
		setMainPanelVisible(true)
		showCursor(true)
	end
end

function setMainPanelVisible(bool)
	for k,v in ipairs(cache.mainpanelKafelki) do
		guiSetVisible(v,bool)
	end
	cache.mainPanelEnabled = bool
	cache.mainpanelText:setVisible(bool)
end

function getMainMetroKafelek(id)
	return cache.mainpanelKafelki[id]
end

function onClickMainPanel(button,state,absoluteX,absoluteY,args)
	if button == "left" then
		if args == "staty" then
			setMainPanelVisible(false)
			setStatystykiGUIVisible(true)
		elseif args == "off" then
			setMainPanelVisible(false)
			showCursor(false)
		elseif args == "radio" then
			setMainPanelVisible(false)
			setGuiRadioVisible(true)
		end
	end
end