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
		list = {visible=false,size=0}
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
end

function UiComboBox:onMouseMove(x,y)

end

function UiComboBox:getSize()
	if self.list.visible then
		return self.sx,self.sy+(#self.datas*20)
	end
	return self.sx,self.sy
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
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
	dxDrawImage(posx, posy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
	if self.list.rt and self.list.visible then
		dxDrawImage(posx,posy+self.sy+2,self.sx,#self.datas*20,self.list.rt,0,0,0,tocolor(255,255,255,255),true)
	end
end

function UiComboBox:onMouseEnter()
	self.bordercolor = tocolor(81,96,89)
	self.redraw = true
end

function UiComboBox:onMouseLeave()
	self.bordercolor = tocolor(184,184,182)
	self.redraw = true
end

function UiComboBox:onMouseClick(btn, state, x, y)
	if btn == "left" and state == "up" then
		if self.list.visible then
			local px,py = self:getOnScreenPosition()
			if x > px and x < px+self.sx and y > py+self.sy+2 and y < py+self.sy+2+(#self.datas*20) then
				local check = y - (py+self.sy+2)
				local ids = 1
				for k,v in pairs(self.datas) do
					if (ids*20) > check then
						self.text = v
						self:onMouseLeave()
						self.list.visible = false
						triggerEvent("onDxGUIChanged",self.el)
						return
					end
					ids = ids + 1
				end
			end
		end
		local posx,posy = self:getOnScreenPosition()
		local bool = ((posx+self.sx-self.sy-10 <= x and posy+self.sy >= y) and true or false)
		if bool then
			self.list.visible = not self.list.visible
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
	local sizeofimage = self.sy - 10
	local bordersize = 2
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0, 0, self.sx  , self.sy, self.backgroudcolor)
		dxDrawRectangle(0, 0, self.sx, bordersize, bordercolor)
		dxDrawRectangle(0, self.sy-bordersize, self.sx, bordersize, bordercolor)
		dxDrawRectangle(self.sx-bordersize, 0, bordersize,self.sy, bordercolor)
		dxDrawRectangle(0, 0, bordersize, self.sy, bordercolor)
		dxDrawRectangle(self.sx - sizeofimage - 10, 0, 2,self.sy, bordercolor)
		dxDrawText(self.text, 10, 5, self.sx - 5 , self.sy - 5,tocolor(0,0,0), cache.scaleOfFont,cache.Font, "left", "center",false,true)
		dxDrawImage(self.sx - sizeofimage - 5,5,sizeofimage,sizeofimage,"image/appbar.chevron.down.png")
	dxSetRenderTarget()
	if self.list.rt then
		destroyElement(self.list.rt)
	end
	self.list.rt = dxCreateRenderTarget(self.sx, #self.datas*20,true)
	dxSetRenderTarget(self.list.rt,true)
		dxDrawRectangle(0, 0, self.sx , table.size(self.datas)*20, self.backgroudcolor)
		dxDrawRectangle(0, (#self.datas*20)-bordersize, self.sx, bordersize, bordercolor)
		dxDrawRectangle((#self.datas*20)-bordersize, 0, bordersize,self.sy, bordercolor)
		dxDrawRectangle(0, 0, bordersize, (#self.datas*20), bordercolor)
		local elid = 0
		for k,v in pairs(self.datas) do
			dxDrawRectangle(0, elid*20, self.sx , 20, tocolor(230, 230, 230, 255))
			dxDrawText(tostring(v), 10, elid*20, self.sx - 5 , 20,tocolor(0,0,0), cache.scaleOfFont,cache.Font)
			if eldi ~= 0 then
				dxDrawRectangle(0, elid*20, self.sx, bordersize, tocolor(184,184,182))
			end
			elid = elid + 1
		end
	dxSetRenderTarget()
	self.redraw = false
end