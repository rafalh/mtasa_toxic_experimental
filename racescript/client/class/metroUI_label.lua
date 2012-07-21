metroUIText = {}
metroUIText.__index = metroUIText
cache.metroUITextRender = {}
cache.metroUIFontDX = dxCreateFont ("files/font/segoe.ttf",40)

function metroUIText.create(text,x,y,sx,sy,color,scale)
	local data = setmetatable({text=text,x=x,y=y,sx=sx,sy=sy,color=color,scale=scale,visible=true},metroUIText)
	cache.metroUITextRender[data] = true
	return data
end

function metroUIText:setVisible(bool)
	self.visible = bool
end

function metroUIText:setText(text)
	self.text = text
end

function metroUIText:setPosition(x,y)
	self.x = x
	self.y = y
end

function metroUIText:delete()
	cache.metroUITextRender[self] = nil
	self = nil
end

function onMetroUIRender()
	for v,l in pairs(cache.metroUITextRender) do
		if v.visible then
			dxDrawText(v.text,v.x,v.y,v.sx,v.sy,v.color,v.scale,cache.metroUIFontDX)
		end
	end
end

addEventHandler("onClientRender",getRootElement(),onMetroUIRender)