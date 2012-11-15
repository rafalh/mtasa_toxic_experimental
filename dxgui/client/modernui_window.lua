UiWindow = {}
UiWindow.__mt = {__index = UiWindow}

function UiWindow:Create(x, y, sx, sy,title)
	local wnd = setmetatable({
		text = title,
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		down = false,
		el = createElement("dxwnd"),
		types = "text",
		children = {},
		visible = true,
		redraw = true,
		enabled = true,
		types = "window",
		redraw = true,
		color = tocolor(33,94,33),
		textcolor = tocolor(255,255,255, 255),
	}, UiWindow.__mt)
	addToAllRender(wnd)
	return wnd
end


function UiWindow:onRender()
	if(self.redraw) then
		self:UpdateRT()
	end
	if not self:getVisible() then
		return
	end
	dxDrawImage(self.x,self.y,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiWindow:getOnScreenPosition()
	return self.x,self.y
end

function UiWindow:getEnabled()
	return self.enabled
end

function UiWindow:setEnabled(enabled)
	self.enabled = enabled
end

function UiWindow:setText(text)
	self.text = text
	self.redraw = true
end

function UiWindow:setColor(r,g,b,a)
	self.color = tocolor(r or 0,g or 0,b or 0,a or 255)
	self.redraw = true
end

function UiWindow:setTextColor(r,g,b,a)
	self.textcolor = tocolor(r or 0,g or 0,b or 0,a or 255)
	self.redraw = true
end

function UiWindow:delete()
	deleteElementFromAllElements(self.el)
	if isElement(self.el) then
		destroyElement(self.el)
	end
	for k,v in ipairs(self.children) do
		v:delete()
	end
	self = nil
end

function UiWindow:setPosition(x,y)
	self.x,self.y = x,y
end

function UiWindow:getSize()
	return self.sx,self.sy
end

function UiWindow:setSize(sx,sy)
	self.sx, self.sy = sx,sy
	self.rt = false
	self.redraw = true
end

function UiWindow:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
	
	dxDrawRectangle(0, 0, self.sx, self.sy, tocolor(255,255,255,255))
	dxDrawRectangle(0, 0, self.sx, 30, self.color)
	dxDrawText(self.text, 5, 5, self.sx - 5, self.sy - 5, self.textcolor, 0.5, buttonfond, "center", "top", true)
	
	dxDrawRectangle(0, self.sy-5, self.sx, 5, self.color)
	dxDrawRectangle(self.sx-5, 0, 5,self.sy, self.color)
	dxDrawRectangle(0, 0, 5, self.sy,self.color)
	
	dxSetRenderTarget()
	self.redraw = false
end

function UiWindow:AddChild(child)
	table.insert(self.children, child)
end

function UiWindow:setChild(child)
	self.parent = child
end

function UiWindow:getType()
	return self.types
end

function UiWindow:getVisible()
	return self.visible
end

function UiWindow:setVisible(visibl)
	self.visible = visibl
end

function UiWindow:getPosition()
	return self.x,self.y
end

function UiWindow:onMouseEnter()
end

function UiWindow:onMouseLeave()
end

function UiWindow:onMouseMove(x, y)
end

function UiWindow:onMouseClick(btn, state, x, y)
end

function UiWindow:onRestore()
	self.redraw = true
end
