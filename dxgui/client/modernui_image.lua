UiImage = UiCopyTable(dxMain)

function UiImage:Create(x, y, sx, sy,src,parent)
	local image = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		src = src,
		children = {},
		parent = false,
		el = createElement("dximage"),
		visible = true,
		enabled = true,
		redraw = true,
		types = "image",
		rotation = 0,
		rotationCenterOffsetX = 0,
		rotationCenterOffsetY = 0,
	}, UiImage.__mt)
	addToAllRender(image)
	if parent then
		image.parent = parent
		parent:AddChild(image)
	end
	return image
end

function UiImage:setProperty(prop,val)
	if prop == "rotation" then
		self.rotation = val
	elseif prop == "rotationCenterOffsetX" then
		self.rotationCenterOffsetX = val
	elseif prop == "rotationCenterOffsetY" then
		self.rotationCenterOffsetY = val
	end
end

function UiImage:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx,posy = self:getOnScreenPosition()
	dxDrawImage(posx,posy,self.sx,self.sy,self.rt,self.rotation,self.rotationCenterOffsetX,self.rotationCenterOffsetY,tocolor(255,255,255,255),true)
end

function UiImage:onMouseEnter()
	triggerEvent("onDxGUIEnter",self.el)
end

function UiImage:onMouseLeave()
	if isElement(self.el) then
		triggerEvent("onDxGUILeave",self.el)
	end
end

function UiImage:onMouseClick(btn, state, x, y)
	triggerEvent("onDxGUIClick",self.el,btn,state,x,y)
	if isElement(self.el) then
		if state == "down" then
			triggerEvent("onDxGUIDown",self.el,btn,x,y)
		elseif state == "up" then
			triggerEvent("onDxGUIUp",self.el,btn,x,y)
		end
	end
end

function UiImage:onMouseMove(x,y)
	triggerEvent("onDxGUIMove",self.el,x,y)
end

function UiImage:setImage(src)
	self.src = src
	self.redraw = true
end

function UiImage:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawImage(0,0,self.sx,self.sy,self.src)
	dxSetRenderTarget()
	self.redraw = false
end