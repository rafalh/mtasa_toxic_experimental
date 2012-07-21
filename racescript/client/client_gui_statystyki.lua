cache.isStatystykiEnabled = false
cache.statystyki = {}

function onGuiStatystykiStart()
	cache.statystykiNameLabel = metroUIText.create("Statystyki",resolution[1]/2-350,resolution[2]/2-275,400,40,tocolor(255,255,255),1)
	cache.statystykiBackButton = guiCreateStaticImage(resolution[1]/2-400,resolution[2]/2-260,48,48,"images/metroUI/back.png",false)
	setStatystykiGUIVisible(false)
end

function setStatystykiGUIVisible(bool)
	guiSetVisible(cache.statystykiBackButton,bool)
	cache.statystykiNameLabel:setVisible(bool)
	cache.isStatystykiEnabled = bool
	if bool then
		triggerServerEvent("racescript:server:statystyki:get",localPlayer)
	end
end

function onGuiStatystykiRender()
	if cache.isStatystykiEnabled then
		local stats = 
		{
			{"Cash",cache.statystyki.kasa or "--Wartość nieznana--",0},
			{"Punkty",cache.statystyki.punkty or "--Wartość nieznana--",0},
			{"DM:","",0},
				{"Zagrane",cache.statystyki.dmgrane or "--Wartość nieznana--",20},
				{"Wygrane",cache.statystyki.dmwygrane or "--Wartość nieznana--",20},
			{"Wyścigi:","",0},
				{"Miejsce: 1",cache.statystyki.miejsce1 or "--Wartość nieznana--",20},
				{"Miejsce: 2",cache.statystyki.miejsce2 or "--Wartość nieznana--",20},
				{"Miejsce: 3",cache.statystyki.miejsce3 or "--Wartość nieznana--",20},
			{"Ranga",cache.statystyki.ranga or "--Wartość nieznana--",0},
			{"Ratio",cache.statystyki.ratio or "--Wartość nieznana--",0},
			{"Timehere",cache.statystyki.timehere or "--Wartość nieznana--",0},
		}
		local startY = resolution[2]/2-200
		dxDrawRectangle (resolution[1]/4,startY,resolution[1]/2,#stats*20,tocolor(94,94,94,200))
		for k,v in ipairs(stats) do
			if k%2 ~= 0 then
				dxDrawRectangle (resolution[1]/4,startY,resolution[1]/2,20,tocolor(0,162,232,150))
			end
			dxDrawText(v[1],resolution[1]/2-340+v[3],startY-5,200,20,tocolor(255,255,255),0.4,cache.metroUIFontDX)
			dxDrawText(v[2],resolution[1]/2,startY-5,200,20,tocolor(255,255,255),0.4,cache.metroUIFontDX)
			startY = startY + 20
		end
	end
end

function onGuiStatystykiClick(bt,button,state,absoluteX,absoluteY)
	if button == "left" then
		if bt == cache.statystykiBackButton then
			setStatystykiGUIVisible(false)
			setMainPanelVisible(true)
		end
	end
end

function getStatystyki(stats)
	cache.statystyki = stats
end

addEvent("racescript:client:statystyki:get",true)
addEventHandler("racescript:client:statystyki:get",getRootElement(),getStatystyki)