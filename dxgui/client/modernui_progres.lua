UiProgress = {}

UiProgress.__mt = {__index = UiProgress}

function UiProgress:Create(x, y, sx, sy,parent)
	local pr = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		children = {},
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		el = createElement("dxprogress"),
		types = "progress",
		backgroundcolor = tocolor(222,219,222),
		strapcolor = tocolor(0,211,41),
		bordercolor = tocolor(174,171,174),
		progress = 0
	}, UiProgress.__mt)
	addToAllRender(pr)
	if parent then
		pr.parent = parent
		parent:AddChild(pr)
	end
	return pr
end
function UiProgress:getEnabled()
	return self.enabled
end

function UiProgress:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiProgress:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getOnScreenPosition()
	end
	return self.x+xp,self.y+xy
end

function UiProgress:setColor(r,g,b,a)
	self.color = tocolor(r or 0,g or 0,b or 0,a or 255)
end

function UiProgress:getType()
	return self.types
end

function UiProgress:AddChild(child)
	table.insert(self.children, child)
end

function UiProgress:getSize()
	return self.sx,self.sy
end

function UiProgress:SetVisible(visible)
	self.visible = visible
end

function UiProgress:getPosition()
	return self.x,self.y
end

function UiProgress:delete()
	deleteElementFromAllElements(self.el)
	if isElement(self.el) then
		destroyElement(self.el)
	end
	for k,v in ipairs(self.children) do
		v:delete()
	end
	self = nil
end

function UiProgress:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local xp,xy = self:getOnScreenPosition()
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,buttonfond, "left", "center")
	dxDrawImage(xp,xy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiProgress:onMouseEnter()
end

function UiProgress:onMouseLeave()
end

function UiProgress:onMouseMove(x,y)
end

function UiProgress:onMouseClick(btn, state, x, y)
end

function UiProgress:onRestore()
	self.redraw = true
end

function UiProgress:setProgress(num)
	self.progress = num
	self.redraw = true
end

function UiProgress:getProgress()
	return self.progress
end

function UiProgress:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0, 0, self.sx, self.sy,self.backgroundcolor)
		dxDrawRectangle(0, 0, self.sx, self.sy, clr)
		dxDrawRectangle(0, 0, self.sx, 1, self.bordercolor)
		dxDrawRectangle(0, self.sy-1, self.sx, 1, self.bordercolor)
		dxDrawRectangle(self.sx-1, 0, 1,self.sy, self.bordercolor)
		dxDrawRectangle(0, 0, 1, self.sy, self.bordercolor)
		dxDrawRectangle(0, 0, self.sx*(self.progress/100), self.sy,self.strapcolor)
	dxSetRenderTarget()
	self.redraw = false
end