UiRadio = UiCopyTable(dxMain)

function UiRadio:Create(x, y, sx, sy,text,parent)
	local element = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		text = text,
		selected = false,
		active = false,
		el = createElement("dxRadioButton"),
		children = {}
	}, UiRadio.__mt)
	addToAllRender(element)
	if parent then
		element.parent = parent
		parent:AddChild(element)
	end
	return element
end

function UiRadio:isSelected()
	return self.selected
end

function UiRadio:getText()
	return self.text
end

function UiRadio:setSelected(bool)
	self.selected = bool
	self.redraw = true
end

function UiRadio:onMouseClick(btn, state, x, y)
	if btn == "left" and state == "up" then
		if parent then
			for k,v in pairs(children) do
				if tostring(getElementType(v.el)) == "dxRadioButton" then
					v:setSelected(false)
				end
			end
		else
			local allEl = getAllElements()
			for k,v in pairs(allEl) do
				if tostring(getElementType(v.el)) == "dxRadioButton" then
					v:setSelected(false)
				end
			end
		end
		self:setSelected(true)
	end
end

function UiRadio:onMouseEnter()
	self.active = true
	self.redraw = true
end

function UiRadio:onMouseLeave()
	self.active = false
	self.redraw = true
end

function UiRadio:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx, posy = self:getOnScreenPosition()
	local sx,sy = self:getSize()
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
	dxDrawImage(posx,posy,sx,sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiRadio:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawImage(0,0,self.sy,self.sy,self:isSelected() and "image/radioButton/radioButtonSelected.png" or "image/radioButton/radioButtonNormal.png")
		if self.active then
			dxDrawImage(0,0,self.sy,self.sy,"image/radioButton/radioButtonLight.png")
		end
		dxDrawText(self.text,self.sy + 2,0,self.sx-self.sy , self.sy,tocolor(0,0,0), 0.5,cache.Font, "left", "center",false,true)
	dxSetRenderTarget()
	self.redraw = false
end