cache.metroUITextDraw = {}
cache.metroUIFontGUI = guiCreateFont("files/font/segoe.ttf",12)
cache.metroUIFontDX = dxCreateFont ("files/font/segoe.ttf",40)
cache.inMetroClick = {}
cache.metroUIKafelek = {}

function metroUIcreate(x,y,sx,sy,color,text,image,addons,parent)
	local podklad = guiCreateStaticImage (x, y, sx,sy,"images/metroUI/colors/"..color..".png", false,parent or nil)
	local mainobraz = guiCreateStaticImage (sx/2-64, 5, 128, 128,image, false,podklad )
	local textlab = guiCreateLabel(5,135,155,25,text,false,podklad)
	guiSetFont(textlab,cache.metroUIFontGUI)
	if addons then
		if addons.onClick then
			cache.inMetroClick[mainobraz] = {func=addons.onClick.func,arg=addons.onClick.arg}
			cache.inMetroClick[podklad] = {func=addons.onClick.func,arg=addons.onClick.arg}
			cache.inMetroClick[textlab] = {func=addons.onClick.func,arg=addons.onClick.arg}
		end
	end
	cache.metroUIKafelek[podklad] = {obraz=mainobraz,text=textlab}
	return podklad
end

function metroUITextcreate(text,x,y,sx,sy,color,scale)
	local id = math.random(1,2000000)
	cache.metroUITextDraw[id] = {text=text,x=x,y=y,sx=sx,sy=sy,color=color,scale=scale,enabled=true}
	return id
end

function metroUISetTextKafelek(pod,texts)
	guiSetText(cache.metroUIKafelek[pod].text,texts)
end

function metroUITextSetVisible(id,bool)
	cache.metroUITextDraw[id].enabled = bool
end

function metroUITextsetText(id,text)
	cache.metroUITextDraw[id].text = text
end

function metroUITextSetPosition(id,x,y)
	cache.metroUITextDraw[id].x = x
	cache.metroUITextDraw[id].y = y
end

function metroUISetKafelekObraz(id,path)
	guiStaticImageLoadImage (cache.metroUIKafelek[id].obraz, path)
end

function metroUITextDelete(id)
	cache.metroUITextDraw[id] = nil
end

function onMetroUIClick(button,state,absoluteX,absoluteY)
	if cache.inMetroClick[source] then
		cache.inMetroClick[source].func(button,state,absoluteX,absoluteY,cache.inMetroClick[source].arg)
	end
end

function onMetroUIRender()
	for k,v in pairs(cache.metroUITextDraw) do
		if v.enabled then
			dxDrawText(v.text,v.x,v.y,v.sx,v.sy,v.color,v.scale,cache.metroUIFontDX)
		end
	end
end

addEventHandler("onClientRender",getRootElement(),onMetroUIRender)
addEventHandler("onClientGUIClick",getResourceRootElement(getThisResource()),onMetroUIClick)