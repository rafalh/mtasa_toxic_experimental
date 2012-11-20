UiCheckbox = UiCopyTable(dxMain)

function UiCheckbox:Create(x, y,sx,sy,text,checked,parent)
	local check = setmetatable({
		x=x,
		y=y,
		sx = sx,
		sy = sy,
		text = text,
		el = createElement("dxcheck"),
		checked = checked,
		children = {},
		parent = false,
		visible = true,
		redraw = true,
		hover = false,
		down = false,
		enabled = true,
		types = "checkbox"
	}, UiCheckbox.__mt)
	addToAllRender(check)
	if parent then
		check.parent = parent
		parent:AddChild(check)
	end
	return check
end
function UiCheckbox:getChecked()
	return self.checked
end

function UiCheckbox:setChecked(bool)
	self.checked = bool
end

function UiCheckbox:onMouseMove(x,y)

end

function UiCheckbox:onRender()
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
	dxDrawImage(self.x+xp,self.y+xy,self.sx,19,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiCheckbox:onMouseEnter()
	self.hover = true
	self.redraw = true
end

function UiCheckbox:onMouseLeave()
	self.hover = false
	self.redraw = true
end

function UiCheckbox:onMouseClick(btn, state, x, y)
	if(btn == "left") then
		self.down = (state == "down")
		if state == "up" then
			self.checked = not self.checked
		end
		self.redraw = true
	end
	triggerEvent("onModernUIClick",localPlayer,self.el,btn,state,x,y)
end

function UiCheckbox:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx,19,true)
	end
	local color = tocolor(25, 153, 0, 255)
	if self.checked then
		if self.down then
			color = tocolor(77,208,50)
		elseif self.hover then
			color = tocolor(73,157,53)
		end
	else
		color = tocolor(166,166,166)
		if self.hover then
			color = tocolor(181,181,181)
		end
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0, 0, 50, 19, tocolor(166, 166, 166, 255))
		dxDrawRectangle(2, 2, 46, 15, tocolor(255, 255, 255, 255))
		dxDrawRectangle(3, 3, 44, 13,color)
		if self.checked then
			dxDrawRectangle(38, 0, 12, 19,tocolor(0,0,0))
		else
			dxDrawRectangle(0, 0, 12, 19,tocolor(0,0,0))
		end
		dxDrawText(self.text,55,0,200,19,tocolor(0,0,0), 0.5,cache.Font, "left", "center")
	dxSetRenderTarget()
	self.redraw = false
end