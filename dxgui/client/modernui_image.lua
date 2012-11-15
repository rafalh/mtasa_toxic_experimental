UiImage = {}

UiImage.__mt = {__index = UiImage}

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

function UiImage:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getOnScreenPosition()
	end
	return self.x+xp,self.y+xy
end

function UiImage:getEnabled()
	return self.enabled
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

function UiImage:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiImage:getType()
	return self.types
end

function UiImage:AddChild(child)
	table.insert(self.children, child)
end

function UiImage:setVisible(visible)
	self.visible = visible
end

function UiImage:getPosition()
	return self.x,self.y
end

function UiImage:getSize()
	return self.sx,self.sy
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

function UiImage:delete()
	deleteElementFromAllElements(self)
	self = nil
end

function UiImage:onMouseEnter()
end

function UiImage:onMouseLeave()
end

function UiImage:onMouseMove(x,y)
	
end

function UiImage:setImage(src)
	self.src = src
	self.redraw = true
end

function UiImage:onMouseClick(btn, state, x, y)
end

function UiImage:onRestore()
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