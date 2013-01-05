UiComboBox = UiCopyTable(dxMain)

function UiComboBox:Create(x, y, sx, sy,text,parent)
	local combobox = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		text = text,
		children = {},
		el = createElement("dxcombobox"),
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		types = "combobox",
		bordercolor = tocolor(184,184,182),
		backgroudcolor = tocolor(255,255,255),
		datas = {},
		list = {visible=false,size=0,precent=0,outOfScreen=0}
	}, UiComboBox.__mt)
	addToAllRender(combobox)
	--table.insert(combobox.datas,text)
	if parent then
		combobox.parent = parent
		parent:AddChild(combobox)
	end
	return combobox
end

function UiComboBox:deleteAllItem()
	self.datas = {}
	self.redraw = true
end

function UiComboBox:addItem(text)
	table.insert(self.datas,text)
	self.redraw = true
	--return #self.datas
end

function UiComboBox:onMouseMove(x,y)
	if self.isSliderActive then
		local posx,posy = self:getOnScreenPosition()
		local sx,sy = self:getSize()
		local procent = ((y-(posy+40))/(((posy+40)+(sy-60))-(posy+40)))*100
		if procent > 100 then procent = 100 end
		if procent < 0 then procent = 0 end
		self.list.precent = procent
		self.redraw = true
	end
end

function UiComboBox:getSize()
	if self.list.visible then
		return self.sx,self.list.outOfScreen == 0 and 20+(#self.datas*20) or self.sy
	end
	return self.sx,20
end

function UiComboBox:getText()
	return self.text
end

function UiComboBox:setText(text)
	self.text = text
	self.redraw = true
end

function UiComboBox:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx, posy = self:getOnScreenPosition()
	dxDrawImage(posx, posy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiComboBox:onMouseEnter()
	self.bordercolor = tocolor(81,96,89)
	self.redraw = true
end

function UiComboBox:onMouseLeave()
	if self.list.visible then return end
	self.bordercolor = tocolor(184,184,182)
	self.isSliderActive = false
	self.redraw = true
end

function UiComboBox:onMouseClick(btn, state, x, y)
	if btn == "left" then
		if state == "down" then
			if self.list.outOfScreen ~= 0 then
				local posx,posy = self:getOnScreenPosition()
				local sx,sy = self:getSize()
				local scrollpos = posy+40+((self.sy-80)*(self.list.precent/100))
				if math.between(x,posx+sx-20,posx+sx) and math.between(y,scrollpos,scrollpos+20) then
					self.isSliderActive = true
				end
			end
		elseif state == "up" then
			if self.isSliderActive then
				self.isSliderActive = false
				self.redraw = true
				return
			end
			local px,py = self:getOnScreenPosition()
			local sx,sy = self:getSize()
			local bool = ((math.between(x,px+sx-20,px+sx) and math.between(y,py,py+20)) and true or false)
			if bool then
				self.list.visible = not self.list.visible
				self.redraw = true
				if self.list.visible then
					dxMoveToFont(self)
				end
				return
			end
			if self.list.visible and self.list.outOfScreen~=0 then
				if math.between(x,px+sx-20,px+sx) and math.between(y,py+20,py+40) then
					if self.list.precent <= 0 then return end
					self.list.precent = self.list.precent - 1
					self.redraw = true
					return
				end
				if math.between(x,px+sx-20,px+sx) and math.between(y,py+sy-20,py+sy) then
					if self.list.precent >= 100 then return end
					self.list.precent = self.list.precent + 1
					self.redraw = true
					return
				end
			end
			if self.list.visible then
				if math.between(x,px,px+sx-ifElse(self.list.outOfScreen~=0,20,0)) and math.between(y,py+20,py+sy) then
					local check = y - (py+20+2)
					local ids = 1
					local scroll = 0-(self.list.outOfScreen)*(self.list.precent/100)
					for k,v in pairs(self.datas) do
						if (ids*20)+scroll > check then
							self.text = v
							self.list.visible = false
							self:onMouseLeave()
							triggerEvent("onDxGUIChanged",self.el)
							return
						end
						ids = ids + 1
					end
				end
			end
		end
	end
end

function UiComboBox:setBorderColor(r,g,b,a)
	self.bordercolor = tocolor(r or 0,g or 0,b or 0,a or 255)
end

function UiComboBox:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	local bordercolor = self.bordercolor
	local sizeofimage = 10
	local bordersize = 2
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0, 0, self.sx  , 20, self.backgroudcolor)
		dxDrawRectangle(0, 0, self.sx, bordersize, bordercolor)
		dxDrawRectangle(0, 20-bordersize, self.sx, bordersize, bordercolor)
		dxDrawRectangle(self.sx-bordersize, 0, bordersize,20, bordercolor)
		dxDrawRectangle(0, 0, bordersize, 20, bordercolor)
		dxDrawRectangle(self.sx - sizeofimage - 10, 0, 2,20, bordercolor)
		dxDrawText(self.text, 10, 5, self.sx - 5 , 20 - 5,tocolor(0,0,0), cache.scaleOfFont,cache.Font, "left", "center",false,true)
		dxDrawImage(self.sx - sizeofimage - 5,5,sizeofimage,sizeofimage,"image/appbar.chevron.down.png")
	dxSetRenderTarget()
	if self.list.rt and isElement(self.list.rt) then
		destroyElement(self.list.rt)
	end
	if self.list.visible then
		self.list.rt = dxCreateRenderTarget(self.sx, #self.datas*20)
		dxSetRenderTarget(self.list.rt,true)
			dxDrawRectangle(0, 0, self.sx , table.size(self.datas)*20, self.backgroudcolor)
			dxDrawRectangle(0, (#self.datas*20)-bordersize, self.sx, bordersize, bordercolor)
			dxDrawRectangle((#self.datas*20)-bordersize, 0, bordersize,self.sy, bordercolor)
			dxDrawRectangle(0, 0, bordersize, (#self.datas*20), bordercolor)
			local elid = 0
			self.list.outOfScreen = 0
			for k,v in pairs(self.datas) do
				dxDrawRectangle(0, elid*20, self.sx , 20, tocolor(230, 230, 230, 255))
				dxDrawText(tostring(v), 10, elid*20, self.sx - 5 , 20,tocolor(0,0,0), cache.scaleOfFont,cache.Font)
				if eldi ~= 0 then
					dxDrawRectangle(0, elid*20, self.sx, bordersize, tocolor(184,184,182))
				end
				elid = elid + 1
				if elid*20 > self.sy-20 then
					self.list.outOfScreen = self.list.outOfScreen + 20
				end
			end
		dxSetRenderTarget()
		if self.list.outOfScreen == 0 then
			dxSetRenderTarget(self.rt)
				dxDrawImage(0,20,self.sx,#self.datas*20,self.list.rt)
			dxSetRenderTarget()
		else
			local temp = dxCreateRenderTarget(self.sx, self.sy-20)
			dxSetRenderTarget(temp,true)
				dxDrawImage(0,0-((self.list.outOfScreen)*(self.list.precent/100)),self.sx,#self.datas*20,self.list.rt)
			dxSetRenderTarget(self.rt)
				dxDrawImage(0,20,self.sx,self.sy-20,temp)
				destroyElement(temp)
				--slider BEGIN
					local size = 10
					dxDrawRectangle(self.sx-20, 20,20, self.sy-20, tocolor(240,240,240,200))
					dxDrawRectangle(self.sx-20, 20,20, 20, tocolor(240,240,240,255))
					dxDrawImage(self.sx-20, 20,20, 18,"image/appbar.chevron.up.png")
					dxDrawRectangle(self.sx-20, self.sy-20,20, 20, tocolor(240,240,240,255))
					dxDrawImage(self.sx-20, self.sy-20,20, 20,"image/appbar.chevron.down.png")
					dxDrawRectangle(self.sx-20, 40+((self.sy-80)*(self.list.precent/100)),20,20, tocolor(32,165,233,255))
				--slider END
			dxSetRenderTarget()
		end
	end
	self.redraw = false
end

function UiComboBox:onMouseWheel(down)
	if self.list.visible and self.list.outOfScreen ~= 0 then
		if down then
			if self.list.precent - 1 < 0 then return end
			self.list.precent = self.list.precent - 1
			self.redraw = true
		else
			if self.list.precent + 1 > 100 then return end
			self.list.precent = self.list.precent + 1
			self.redraw = true
		end
	end
end