UiPanel = {}

UiPanel.__mt = {__index = UiPanel}

function UiPanel:Create(x, y, parent)
	local panel = setmetatable(
	{
		x=x,
		y=y, 
		sx = 0,
		sy = 0,
		background = false,
		children = {},
		parent = false,
		visible = true,
		enabled = true,
		el = createElement("dxpanel"),
		types = "panel",
	}, UiPanel.__mt)
	if parent then
		parent:AddChild(panel)
		panel.parent = parent
	end
	addToAllRender(panel)
	return panel
end

function UiPanel:getEnabled()
	return self.enabled
end

function UiPanel:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getOnScreenPosition()
	end
	return self.x+xp,self.y+xy
end

function UiPanel:setEnabled(enabled)
	self.enabled = enabled
end

function UiPanel:setBackgroud(sx,sy,color)
	self.background = {sx=sx,sy=sy,color=color}
end

function UiPanel:AddChild(child)
	table.insert(self.children, child)
end

function UiPanel:setChild(child)
	self.parent = child
end

function UiPanel:getType()
	return self.types
end

function UiPanel:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiPanel:setVisible(visibl)
	self.visible = visibl
end

function UiPanel:delete()
	deleteElementFromAllElements(self.el)
	if isElement(self.el) then
		destroyElement(self.el)
	end
	for k,v in ipairs(self.children) do
		v:delete()
	end
	self = nil
end

function UiPanel:getPosition()
	return self.x,self.y
end

function UiPanel:setPosition(x,y)
	self.x,self.y = x,y
end

function UiPanel:getSize()
	return self.sx,self.sy
end

function UiPanel:onMouseEnter()
end

function UiPanel:onMouseLeave()
end

function UiPanel:onMouseMove(x, y)
end

function UiPanel:onMouseClick(btn, state, x, y)
end

function UiPanel:onRender()
	if not self:getVisible() then
		return
	end
	if self.background then
		local posx,posy = self:getOnScreenPosition()
		dxDrawRectangle(posx-5,posy-5, self.background.sx+10, self.background.sy+10, self.background.color)
	end
end

function UiPanel:onRestore()
end
