UiProgress = UiCopyTable(dxMain)

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
		backgroudcolor = tocolor(222,219,222),
		color = tocolor(0,211,41),
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

function UiProgress:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local xp,xy = self:getOnScreenPosition()
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
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
		dxDrawRectangle(0, 0, self.sx, self.sy,self.backgroudcolor)
		--dxDrawRectangle(0, 0, self.sx, self.sy, clr)
		dxDrawRectangle(0, 0, self.sx, 1, self.bordercolor)
		dxDrawRectangle(0, self.sy-1, self.sx, 1, self.bordercolor)
		dxDrawRectangle(self.sx-1, 0, 1,self.sy, self.bordercolor)
		dxDrawRectangle(0, 0, 1, self.sy, self.bordercolor)
		dxDrawRectangle(0, 0, self.sx*(self.progress/100), self.sy,self.color)
	dxSetRenderTarget()
	self.redraw = false
end