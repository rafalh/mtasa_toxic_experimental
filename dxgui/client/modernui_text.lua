UiText = {}

UiText.__mt = {__index = UiText}

function UiText:Create(x, y, sx, sy,text,parent)
	local texts = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		text = text,
		children = {},
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		el = createElement("dxtext"),
		size = 0.5,
		types = "text",
		color = tocolor(0,0,0)
	}, UiText.__mt)
	addToAllRender(texts)
	if parent then
		texts.parent = parent
		parent:AddChild(texts)
	end
	return texts
end
function UiText:getEnabled()
	return self.enabled
end

function UiText:setEnabled(bool)
	self.enabled = bool
end

function UiText:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiText:setColor(r,g,b,a)
	self.color = tocolor(r or 0,g or 0,b or 0,a or 255)
	self.redraw = true
end

function UiText:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getOnScreenPosition()
	end
	return self.x+xp,self.y+xy
end

function UiText:getType()
	return self.types
end

function UiText:getText()
	return self.text
end

function UiText:setText(text)
	self.text = text
	self.redraw = true
end

function UiText:AddChild(child)
	table.insert(self.children, child)
end

function UiText:setVisible(visible)
	self.visible = visible
end

function UiText:getPosition()
	return self.x,self.y
end

function UiText:getSize()
	return self.sx,self.sy
end

function UiText:delete()
	deleteElementFromAllElements(self.el)
	if isElement(self.el) then
		destroyElement(self.el)
	end
	for k,v in ipairs(self.children) do
		v:delete()
	end
	self = nil
end

function UiText:setPosition(x,y)
	self.x = x
	self.y = y
end

function UiText:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx,posy = self:getOnScreenPosition()
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,buttonfond, "left", "center")
	dxDrawImage(posx,posy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiText:setSize(size)
	self.size = size
	self.redraw = true
end

function UiText:onMouseEnter()
end

function UiText:onMouseLeave()
end

function UiText:onMouseMove(x,y)
end

function UiText:onMouseClick(btn, state, x, y)
	if self:getEnabled() then
		triggerEvent("onModernUIClick",localPlayer,self.el,btn,state,x,y)
	end
end

function UiText:onRestore()
	self.redraw = true
end

function UiText:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawText(self.text, 5, 5, self.sx - 5 , self.sy - 5,self.color, self.size,buttonfond, "left", "center")
	dxSetRenderTarget()
	self.redraw = false
end