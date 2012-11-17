UiScrollPanel = {}

UiScrollPanel.__mt = {__index = UiScrollPanel}

function UiScrollPanel:Create(x, y, sx, sy,parent)
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
		types = "scrollpanel",
		isclicked = false
	}, UiScrollPanel.__mt)
	addToAllRender(texts)
	if parent then
		texts.parent = parent
		parent:AddChild(texts)
	end
	return texts
end
function UiScrollPanel:getEnabled()
	return self.enabled
end

function UiScrollPanel:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiScrollPanel:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	return self.x+xp,self.y+xy
end

function UiScrollPanel:getType()
	return self.types
end

function UiScrollPanel:AddChild(child)
	table.insert(self.children, child)
end

function UiScrollPanel:setVisible(visible)
	self.visible = visible
end

function UiScrollPanel:getPosition()
	return self.x,self.y
end

function UiScrollPanel:getSize()
	return self.sx,self.sy
end

function UiScrollPanel:delete()
	deleteElementFromAllElements(self)
	self = nil
end

function UiScrollPanel:setPosition(x,y)
	self.x = x
	self.y = y
end

function UiScrollPanel:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
	dxDrawImage(self.x+xp,self.y+xy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiScrollPanel:setSize(size)
	self.size = size
	self.redraw = true
end

function UiScrollPanel:onMouseEnter()
end

function UiScrollPanel:onMouseLeave()
end

function UiScrollPanel:onMouseMove(x,y)
end

function UiScrollPanel:onMouseClick(btn, state, x, y)
	if btn == "left" then
		if state == "down" then
			self.isclicked = true
		else
			self.isclicked = false
		end
	end
end

function UiScrollPanel:onRestore()
	self.redraw = true
end

function UiScrollPanel:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0, 0, self.sx, self.sy, tocolor(255,255,255,105))
		dxDrawRectangle(self.sx-30, 0, 30, 30, tocolor(240,240,240,255))
		dxDrawImage(self.sx-30,0,30,30,"image/modernui/appbar.chevron.up.png")
		dxDrawRectangle(self.sx-30, 100, 30, 30, tocolor(205,205,205,255))
		dxDrawRectangle(self.sx-30, self.sy-30, 30, 30, tocolor(240,240,240,255))
		dxDrawImage(self.sx-30,self.sy-30,30,30,"image/modernui/appbar.chevron.down.png")
	dxSetRenderTarget()
	self.redraw = false
end