UiEdit = UiCopyTable(dxMain)

function UiEdit:Create(x, y, sx, sy,title,parent)
	local edit = setmetatable({
		text = title,
		x=x,
		y=y, 
		sx = tostring(sx) or 0,
		sy = tonumber(sy) or 0,
		children = {},
		parent = false,
		visible = true,
		down = false,
		redraw = true,
		active = false,
		enabled = true,
		color = tocolor(0,0,0),
		backgroudcolor = tocolor(255,255,255),
		isPassword = false,
		types = "edit",
		defaultText = "",
		el = createElement("dxEdit")
	}, UiEdit.__mt)
	addToAllRender(edit)
	if parent then
		edit.parent = parent
		parent:AddChild(edit)
	end
	return edit
end

function UiEdit:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx,posy = self:getOnScreenPosition()
	dxDrawImage(posx,posy,self.sx,self.sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiEdit:setDefaultText(text)
	self.defaultText = text
	self.redraw = true
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

function UiEdit:onMouseLeave()
	self.hover = false
	self.redraw = true
end

function UiEdit:onMouseClick(btn, state, x, y)
	if(btn == "left") then
		self.active = true
		self.redraw = true
	end
end

function UiEdit:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy)
	end
	dxSetRenderTarget(self.rt,true)
	
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
	
	local long = dxGetTextWidth (text, 0.5, cache.Font) or 0
	
	dxDrawRectangle(0, 0, self.sx, self.sy, self.backgroudcolor)
	dxDrawRectangle(0, 0, self.sx, 1, bordercolor)
	dxDrawRectangle(0, self.sy-1, self.sx, 1, bordercolor)
	dxDrawRectangle(self.sx-1, 0, 1,self.sy, bordercolor)
	dxDrawRectangle(0, 0, 1, self.sy, bordercolor)
	local toaddx = 0
	if long+15 > tonumber(self.sx) then
		toaddx = long+15 - self.sx
	end
	dxDrawText(text, 5-toaddx, 1, self.sx - 5, self.sy - 2, self.color, cache.scaleOfFont, cache.Font, "left", "center", true)
	if text == "" then
		dxDrawText(self.defaultText, 5, 1, self.sx-5, self.sy-2, tocolor(126,126,126,255), cache.scaleOfFont,cache.Font, "left", "center", true)
	end
	if self.active then
		dxDrawText("|", 5 + long - toaddx, 1, self.sx - 5, self.sy - 2, tocolor(0, 0, 0), cache.scaleOfFont, cache.Font, "left", "center", true)
		guiSetInputMode ("no_binds")
	else
		guiSetInputMode("allow_binds")
	end
	dxSetRenderTarget()
	self.redraw = false
end