UiEdit = {}
UiEdit.__mt = {__index = UiEdit}

function UiEdit:Create(x, y, sx, sy,title,parent)
	local edit = setmetatable({
		text = title,
		x=x,
		y=y, 
		sx = sx,
		sy = sy,
		children = {},
		parent = false,
		visible = true,
		down = false,
		redraw = true,
		active = false,
		enabled = true,
		isPassword = false,
		types = "edit"
	}, UiEdit.__mt)
	addToAllRender(edit)
	if parent then
		edit.parent = parent
		parent:AddChild(edit)
	end
	return edit
end

local g_EditClr = tocolor(204, 217, 204)
local g_EditHoverClr = tocolor(255, 255, 255)
local g_EditActiveClr = g_BtnClr
local g_EditTextClr = tocolor(0, 0, 0)

function UiEdit:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateBuffer()
	end
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	dxDrawImage(self.x+xp,self.y+xy,self.sx,self.sy,self.buf,0,0,0,tocolor(255,255,255,255),true)
end

function UiEdit:getEnabled()
	return self.enabled
end

function UiEdit:getOnScreenPosition()
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	return self.x+xp,self.y+xy
end

function UiEdit:getPosition()
	return self.x,self.y
end

function UiEdit:getSize()
	return self.sx,self.sy
end

function UiEdit:setIsPassword(bool)
	self.isPassword = bool
end

function UiEdit:getText()
	return self.text
end

function UiEdit:setText(text)
	self.text = text
	self.redraw = true
end

function UiEdit:onMouseEnter()
	self.hover = true
	self.redraw = true
end

function UiEdit:getVisible()
	if self.parent then
		return (self.parent:getVisible() and self.visible)
	end
	return self.visible
end

function UiEdit:setVisible(visibl)
	self.visible = visibl
end

function UiEdit:onMouseLeave()
	self.hover = false
	self.redraw = true
end

function UiEdit:onMouseMove(x,y)
end

function UiEdit:onRestore()
	self.redraw = true
end

function UiEdit:onMouseClick(btn, state, x, y)
	if(btn == "left") then
		self.active = true
		self.redraw = true
	end
end

function UiEdit:getType()
	return self.types
end

function UiEdit:UpdateBuffer()
	if(not self.buf) then
		self.buf = dxCreateRenderTarget(self.sx, self.sy)
	end
	dxSetRenderTarget(self.buf,true)
	
	local text = self.text
	local cachetext = ""
	if self.isPassword then
		local long = string.len(text)
		if long > 0 then
			for i=1,long do
				cachetext = cachetext.."*"
			end
			text = cachetext
		end
	end
	local clr = g_EditClr
	local bordercolor = tocolor(217,217,217)
	if self.hover or self.active then
		clr = g_EditHoverClr
	end
	if self.active then
		bordercolor = tocolor(86,157,229)
	end
	
	local long = dxGetTextWidth (text, 0.5, buttonfond)
	
	dxDrawRectangle(0, 0, self.sx, self.sy, clr)
	dxDrawRectangle(0, 0, self.sx, 1, bordercolor)
	dxDrawRectangle(0, self.sy-1, self.sx, 1, bordercolor)
	dxDrawRectangle(self.sx-1, 0, 1,self.sy, bordercolor)
	dxDrawRectangle(0, 0, 1, self.sy, bordercolor)
	local toaddx = 0
	if long+15 >self.sx then
		toaddx = long+15 - self.sx
	end
	dxDrawText(text, 5-toaddx, 5, self.sx - 5, self.sy - 5, g_EditTextClr, 0.5, buttonfond, "left", "center", true)
	if self.active then
		dxDrawText("|", 5 + long - toaddx, 0, self.sx - 5, self.sy - 5, g_EditTextClr, 0.5, buttonfond, "left", "center", true)
		guiSetInputMode ("no_binds")
	else
		guiSetInputMode("allow_binds")
	end
	dxSetRenderTarget()
	self.redraw = false
end