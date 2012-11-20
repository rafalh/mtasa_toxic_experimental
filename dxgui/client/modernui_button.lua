UiButton = UiCopyTable(dxMain)

function UiButton:Create(x, y, sx, sy,title,parent)
	local btn = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		down = false,
		el = createElement("dxbtn"),
		btntype = "text",
		data = title,
		color = tocolor(51,153,51),
		children = {},
		parent = false,
		enabled = true,
		visible = true,
		redraw = true,
		types = "button",
		cacheenabled = true,
	}, UiButton.__mt)
	addToAllRender(btn)
	if parent then
		btn.parent = parent
		parent:AddChild(btn)
	end
	return btn
end

function UiButton:setEnabled(enabled)
	self.enabled = enabled
	self.cacheenabled = enabled
	self.redraw = true
end

function UiButton:onRender(clip_rect)
	if not self:getVisible() then
		return
	end
	if self:getEnabled() ~= self.cacheenabled then
		self.cacheenabled = self:getEnabled()
		self.redraw = true
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx, posy = self:getOnScreenPosition()
	local clicked = 0
	if self.enabled then
		if self.down then
			clicked = 2
		end
		if self.hover then
			dxDrawRectangle(posx-3+clicked, posy-3+clicked, self.sx+6-(clicked*2), self.sy+6-(clicked*2),tocolor(33,87,33,255),true)
		end
	end
	dxDrawImage(posx+clicked,posy+clicked,self.sx-(clicked*2),self.sy-(clicked*2),self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiButton:setType(type,datas)
	self.btntype = type
	self.data = datas
	self.redraw = true
end

function UiButton:setText(text)
	if self.btntype == "text" then
		self.data = text
		self.redraw = true
	end
end

function UiButton:onMouseEnter()
	self.hover = true
	self.redraw = true
end

function UiButton:onMouseLeave()
	self.hover = false
	self.redraw = true
end

function UiButton:onMouseMove(x,y)
end

function UiButton:onMouseClick(btn, state, x, y)
	if self:getEnabled() then
		if(btn == "left") then
			self.down = (state == "down")
			self.redraw = true
		end
		triggerEvent("onModernUIClick",localPlayer,self.el,btn,state,x,y)
		triggerEvent("onDxGUIClick",self.el,btn,state,x,y)
	end
end

function UiButton:onRestore()
	self.redraw = true
end

function UiButton:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy)
	end
	dxSetRenderTarget(self.rt,true)
	
	local clr = self.color
	if not self:getEnabled() then
		clr = tocolor(43,42,37)
	end
	
	dxDrawRectangle(0, 0, self.sx, self.sy, clr)
	if self.btntype == "text" then
		dxDrawText(self.data, 5, 5, self.sx - 5 , self.sy - 5, tocolor(255,255,255), cache.scaleOfFont,cache.Font, "center", "center", true)
	elseif self.btntype == "image" then
		dxDrawImage(self.data.x,self.data.y, self.data.sx , self.data.sy,self.data.src)
	elseif self.btntype == "mix" then
		for k,v in ipairs(self.data) do
			if v.type == "text" then
				dxDrawText(v.text, v.x,v.y, v.sx , v.sy, tocolor(255,255,255), v.scale,cache.Font, v.alignX, v.alignY, true)
			elseif v.type == "image" then
				dxDrawImage(v.x,v.y,v.sx,v.sy,v.src)
			end
		end
	end
	
	dxSetRenderTarget()
	self.redraw = false
end