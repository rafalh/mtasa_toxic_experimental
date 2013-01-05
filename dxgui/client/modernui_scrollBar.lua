UiScrollBar = UiCopyTable(dxMain)

function UiScrollBar:Create(x, y, sx, sy,horizontal,parent)
	local element = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		horizontal = horizontal,
		el = createElement("dxScrollBar"),
		isSliderActive = false,
		scroll = 0,
		children = {}
	}, UiScrollBar.__mt)
	addToAllRender(element)
	if parent then
		element.parent = parent
		parent:AddChild(element)
	end
	return element
end

function UiScrollBar:onMouseMove(x, y)
	if self.isSliderActive then
		local posx,posy = self:getOnScreenPosition()
		local sizex,sizey = self:getSize()
		local procent = ((y-(posy+20))/(((posy+20)+(sizey-40))-(posy+20)))*100
		if self.horizontal then
			procent = ((x-(posx+20))/(((posx+20)+(sizex-40))-(posx+20)))*100
		end
		if procent < 0 then
			procent = 0
		elseif procent > 100 then
			procent = 100
		end
		self:setScrollPos(procent)
	end
end

function UiScrollBar:onMouseEnter()
	self.isActive = true
end

function UiScrollBar:getScrollPos()
	return self.scroll
end

function UiScrollBar:setScrollPos(precent)
	self.scroll = precent
	self.redraw = true
	triggerEvent("onDxGUIScroll",self.el)
end

function UiScrollBar:onMouseLeave()
	self.isActive = false
	self.isSliderActive = false
end

function UiScrollBar:onMouseClick(btn, state, x, y)
	self.isClicked = state == "down"
	if btn == "left" then
		local posx,posy = self:getOnScreenPosition()
		local sizex,sizey = self:getSize()
		if state == "down" then
			if self.horizontal then
				if math.between(x,posx+20+((self.sx-60)*(self.scroll/100)),posx+20+((self.sx-60)*(self.scroll/100))+20) then
					self.isSliderActive = true
				end
			else
				if math.between(y,posy+20+((self.sy-60)*(self.scroll/100)),posy+20+((self.sy-60)*(self.scroll/100))+20) then
					self.isSliderActive = true
				end
			end
		elseif state == "up" then
			if self.isSliderActive then
				self.isSliderActive = false
				return
			end
			if self.horizontal then
				if math.between(x,posx,posx+20) then
					if self.scroll - 1 < 0 then
						self:setScrollPos(0)
						return
					end
					self:setScrollPos(self.scroll - 1)
					return
				end
				if math.between(x,posx+sizex-20,posx+sizex) then
					if self.scroll + 1 > 100 then
						self:setScrollPos(100)
						return
					end
					self:setScrollPos(self.scroll + 1)
					return
				end
			else
				if math.between(y,posy,posy+20) then
					if self.scroll - 1 < 0 then
						self:setScrollPos(0)
						return
					end
					self:setScrollPos(self.scroll - 1)
					return
				end
				if math.between(y,posy+sizey-20,posy+sizey) then
					if self.scroll + 1 > 100 then
						self:setScrollPos(100)
						return
					end
					self:setScrollPos(self.scroll + 1)
					return
				end
			end
		end
	end
end

function UiScrollBar:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx, posy = self:getOnScreenPosition()
	local sx,sy = self:getSize()
	dxDrawImage(posx,posy,sx,sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiScrollBar:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		if self.horizontal then
			dxDrawRectangle(0, 0,self.x, self.y, tocolor(80,80,80,250))
			dxDrawRectangle(0, 0,20, self.sy, tocolor(240,240,240,255))
			dxDrawImage(1, self.sy/2-10,20, 20,"image/appbar.chevron.left.png")
			dxDrawRectangle(self.sx-20, 0,20, self.sy, tocolor(240,240,240,255))
			dxDrawImage(self.sx-19, self.sy/2-10,20, 20,"image/appbar.chevron.right.png")
			dxDrawRectangle(20+((self.sx-60)*(self.scroll/100)),0,20,self.sy, tocolor(32,165,233,255))
		else
			dxDrawRectangle(0, 0,self.x, self.y, tocolor(80,80,80,250))
			dxDrawRectangle(0, 0,self.sx, 20, tocolor(240,240,240,255))
			dxDrawImage(self.sx/2-10, 1,20, 20,"image/appbar.chevron.up.png")
			dxDrawRectangle(0, self.sy-20,self.x, 20, tocolor(240,240,240,255))
			dxDrawImage(self.sx/2-10, self.sy-19,20, 20,"image/appbar.chevron.down.png")
			dxDrawRectangle(0,20+((self.sy-60)*(self.scroll/100)),self.sx,20, tocolor(32,165,233,255))
		end
	dxSetRenderTarget()
	self.redraw = false
end

function UiScrollBar:onMouseWheel(down)
	if self.isActive then
		if down then
			if self.scroll - 1 < 0 then return end
			self:setScrollPos(self.scroll - 1)
		else
			if self.scroll + 1 > 100 then return end
			self:setScrollPos(self.scroll + 1)
		end
	end
end