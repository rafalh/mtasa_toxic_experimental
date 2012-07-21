metroUIButton = {}
metroUIButton.__index = metroUIButton
metroUIButtonOnClick = {}
local guifont = guiCreateFont ("file/segoe.ttf")

function metroUIButton.create(x,y,sx,sy,text,labelcolor,backgroundcolor,parent)
	local backgroud = guiCreateStaticImage(x,y,sx,sy,"image/"..backgroundcolor..".png",false,(parent or nil))
	local label = guiCreateLabel(0,0,sx,sy,text,false,backgroud)
	guiLabelSetVerticalAlign(label,"center")
	guiLabelSetHorizontalAlign(label,"center")
	guiSetFont(label,guifont)
	if table.size(labelcolor) == 3 then
		guiLabelSetColor(label,labelcolor.r,labelcolor.g,labelcolor.b)
	end
	return setmetatable(
	{
		backgroud = backgroud;
		label = label;
	},metroUIButton)
end

function metroUIButton:onClick(func,args)
	metroUIButtonOnClick[self.backgroud] = {f=func,a=args}
	metroUIButtonOnClick[self.label] = {f=func,a=args}
end

function metroUIButton:setBackgroundColor(color)
	guiStaticImageLoadImage(self.backgroud,"image/"..color..".png")
end

function onMetroTextClick(button,state,absoluteX,absoluteY)
	if metroUIButtonOnClick[source] then
		metroUIButtonOnClick[source].f(button,state,absoluteX,absoluteY,metroUIButtonOnClick[source].a)
	end
end

function table.size(tab)
	local length = 0
	for _ in pairs(tab) do length = length + 1 end
	return length
end

addEventHandler( "onClientGUIClick", getResourceRootElement( getThisResource() ), onMetroTextClick)