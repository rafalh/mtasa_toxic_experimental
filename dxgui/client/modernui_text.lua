UiText = UiCopyTable(dxMain)

function UiText:Create(x, y, sx, sy,text,parent)
	local texts = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		text = text,
		children = {},
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		el = createElement("dxtext"),
		alignX = "left",
		alignY = "center",
		types = "text",
		recreatert = false,
		color = tocolor(0,0,0)
	}, UiText.__mt)
	addToAllRender(texts)
	if parent then
		texts.parent = parent
		parent:AddChild(texts)
	end
	return texts
end

function UiText:SetAlign(horizontal,vertical)
	self.alignX = horizontal or (self.alignX or "left")
	self.alignY = vertical or (self.alignY or "center")
	self.redraw = true
end

function UiText:getText()
	return self.text
end

function UiText:setText(text)
	self.text = text
	self.redraw = true
end

function UiText:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx,posy = self:getOnScreenPosition()
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
	dxDrawImage(posx,posy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiText:setScale(size)
	self.scale = size
	self.redraw = true
end

function UiText:onMouseClick(btn, state, x, y)
	if self:getEnabled() then
		triggerEvent("onModernUIClick",localPlayer,self.el,btn,state,x,y)
		triggerEvent("onDxGUIClick",self.el,btn,state,x,y)
	end
end

function UiText:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawText(self.text, 5, 5, self.sx - 5 , self.sy - 5,self.color, (self.scale or cache.scaleOfFont),cache.Font, self.alignX,self.alignY)
	dxSetRenderTarget()
	self.redraw = false
end