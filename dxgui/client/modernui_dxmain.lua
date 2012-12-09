dxMain = {}
dxMain.__mt = {__index = dxMain}

function dxMain:delete()
	deleteElementFromAllElements(self.el)
	if isElement(self.el) then
		destroyElement(self.el)
	end
	if isElement(self.rt) then
		destroyElement(self.rt)
	end
	for k,v in ipairs(self.children) do
		v:delete()
	end
	self = nil
end

function dxMain:setPosition(x,y)
	self.x,self.y = x,y
end

function dxMain:AddChild(child)
	table.insert(self.children, child)
end

function dxMain:getType()
	return self.types
end

function dxMain:setColor(r,g,b,a)
	self.color = tocolor(r or 255,g or 255,b or 255,a or 255)
	self.redraw = true
end

function dxMain:setBackgroud(r,g,b,a)
	self.backgroudcolor = tocolor(r or 255,g or 255,b or 255,a or 255)
	self.redraw = true
end

function dxMain:getEnabled()
	if self.parent then
		return (self.parent:getEnabled() and self.enabled)
	end
	return self.enabled
end

function dxMain:setEnabled(enabled)
	self.enabled = enabled
end

function dxMain:getSize()
	return self.sx,self.sy
end

function dxMain:setSize(sx,sy)
	self.sx, self.sy = sx,sy
	self.rt = false
	self.redraw = true
end

function dxMain:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function dxMain:setVisible(visibl)
	self.visible = visibl
end

function dxMain:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getOnScreenPosition()
	end
	return self.x+xp,self.y+xy
end

function dxMain:getPosition()
	return self.x,self.y
end

function dxMain:onRestore()
	self.redraw = true
end

function dxMain:onMouseWheel(down)
end

function dxMain:onMouseEnter()
end

function dxMain:onMouseLeave()
end

function dxMain:onMouseMove(x,y)
end

function dxMain:onMouseClick(btn, state, x, y)
end

function dxMain:onRender()
end

function dxMain:UpdateRT()
end