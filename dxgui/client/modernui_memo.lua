UiMemo = {}

UiMemo.__mt = {__index = UiMemo}

function UiMemo:Create(x, y, sx, sy,text,parent)
	local text = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		text = text,
		children = {},
		el = createElement("dxmemo"),
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		types = "text",
		bordercolor = tocolor(0,0,0)
	}, UiMemo.__mt)
	addToAllRender(text)
	if parent then
		text.parent = parent
		parent:AddChild(text)
	end
	return text
end
function UiMemo:getEnabled()
	return self.enabled
end

function UiMemo:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	return self.x+xp,self.y+xy
end

function UiMemo:setText(text)
	self.text = text
	self.redraw = true
end

function UiMemo:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiMemo:onMouseMove(x,y)

end

function UiMemo:getType()
	return self.types
end

function UiMemo:AddChild(child)
	table.insert(self.children, child)
end

function UiMemo:SetVisible(visible)
	self.visible = visible
end

function UiMemo:getPosition()
	return self.x,self.y
end

function UiMemo:getSize()
	return self.sx,self.sy
end

function UiMemo:onRender()
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
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,buttonfond, "left", "center")
	dxDrawImage(self.x+xp,self.y+xy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiMemo:onMouseEnter()
end

function UiMemo:onMouseLeave()
end

function UiMemo:onMouseClick(btn, state, x, y)
end

function UiMemo:onRestore()
	self.redraw = true
end

function UiMemo:setBorderColor(r,g,b,a)
	self.bordercolor = tocolor(r or 0,g or 0,b or 0,a or 255)
end

function UiMemo:delete()
	deleteElementFromAllElements(self)
	self = nil
end

function UiMemo:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	local bordercolor = self.bordercolor
	dxSetRenderTarget(self.rt)
		dxDrawRectangle(0, 0, self.sx  , self.sy, tocolor(255, 255, 255, 255))
		dxDrawRectangle(0, 0, self.sx, 1, bordercolor)
		dxDrawRectangle(0, self.sy-1, self.sx, 1, bordercolor)
		dxDrawRectangle(self.sx-1, 0, 1,self.sy, bordercolor)
		dxDrawRectangle(0, 0, 1, self.sy, bordercolor)
		dxDrawText(self.text, 5, 5, self.sx - 5 , self.sy - 5,tocolor(0,0,0), 0.5,buttonfond, "left", "center",false,true)
	dxSetRenderTarget()
	self.redraw = false
end