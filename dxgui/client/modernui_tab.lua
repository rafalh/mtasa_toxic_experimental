UiTab = UiCopyTable(dxMain)

function UiTab:Create(x, y, sx, sy,parent)
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
		el = createElement("dxTab"),
		tabs = {},
		children = {}
	}, UiTab.__mt)
	addToAllRender(element)
	if parent then
		element.parent = parent
		parent:AddChild(element)
	end
	return element
end

function UiTab:addTab(text)
	table.insert(self.tabs,{text=text})
	local inx = #self.tabs
	self.tabs[inx].btn = UiButton:Create(1+((inx-1)*51),1,50,28,text,self)
	self.tabs[inx].panel = UiPanel:Create(0, 30,self.sx,self.sy-30,self)
	return self.tabs[inx].panel
end

function UiTab:onRender()
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

function UiTab:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0,0, self.sx, self.sy,tocolor(80,80,80))
	dxSetRenderTarget()
	self.redraw = false
end