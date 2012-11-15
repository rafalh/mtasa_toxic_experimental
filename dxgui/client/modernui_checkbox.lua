UiCheckbox = {}

UiCheckbox.__mt = {__index = UiCheckbox}

function UiCheckbox:Create(x, y,wx,text,checked,parent)
	local check = setmetatable({
		x=x,
		y=y,
		sx = 50,
		wx = wx,
		sy = 19,
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

function UiCheckbox:getEnabled()
	return self.enabled
end

function UiCheckbox:setEnabled(bool)
	self.enabled = bool
end

function UiCheckbox:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiCheckbox:getType()
	return self.types
end

function UiCheckbox:getChecked()
	return self.checked
end

function UiCheckbox:setChecked(bool)
	self.checked = bool
end

function UiCheckbox:onMouseMove(x,y)

end

function UiCheckbox:AddChild(child)
	table.insert(self.children, child)
end

function UiCheckbox:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	return self.x+xp,self.y+xy
end

function UiCheckbox:SetVisible(visible)
	self.visible = visible
end

function UiCheckbox:getPosition()
	return self.x,self.y
end

function UiCheckbox:getSize()
	return self.sx,self.sy
end

function UiCheckbox:delete()
	deleteElementFromAllElements(self)
	self = nil
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
	dxDrawImage(self.x+xp,self.y+xy,self.wx,19,self.rt,0,0,0,tocolor(255,255,255,255),true)
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

function UiCheckbox:onRestore()
	self.redraw = true
end

function UiCheckbox:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.wx,19,true)
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
		dxDrawText(self.text,55,0,200,19,tocolor(0,0,0), 0.5,buttonfond, "left", "center")
	dxSetRenderTarget()
	self.redraw = false
end