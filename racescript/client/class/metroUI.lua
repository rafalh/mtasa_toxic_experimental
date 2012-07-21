cache.metroUIFontGUI = guiCreateFont("files/font/segoe.ttf",12)
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

function metroUISetTextKafelek(pod,texts)
	guiSetText(cache.metroUIKafelek[pod].text,texts)
end

function metroUISetKafelekObraz(id,path)
	guiStaticImageLoadImage (cache.metroUIKafelek[id].obraz, path)
end

function onMetroUIClick(button,state,absoluteX,absoluteY)
	if cache.inMetroClick[source] then
		cache.inMetroClick[source].func(button,state,absoluteX,absoluteY,cache.inMetroClick[source].arg)
	end
end

function onMouseEnter()
	local sr = cache.metroUIKafelek[source]
	if sr then
		guiSetAlpha(source,0.5)
	else
		local elementParent = getElementParent(source)
		if elementParent then
			local sr = cache.metroUIKafelek[elementParent]
			if sr then
				guiSetAlpha(elementParent,0.5)
			end
		end
	end
end

function onMouseLeave()
	local sr = cache.metroUIKafelek[source]
	if sr then
		guiSetAlpha(source,1)
	else
		local elementParent = getElementParent(source)
		if elementParent then
			local sr = cache.metroUIKafelek[elementParent]
			if sr then
				guiSetAlpha(elementParent,1)
			end
		end
	end
end

addEventHandler( "onClientMouseEnter", getResourceRootElement(getThisResource()), onMouseEnter)
addEventHandler( "onClientMouseLeave", getResourceRootElement(getThisResource()), onMouseLeave)
addEventHandler("onClientGUIClick",getResourceRootElement(getThisResource()),onMetroUIClick)