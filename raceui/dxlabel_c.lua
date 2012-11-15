DxLabel = {}
DxLabel.__mt = {__index = DxLabel}
DxLabel.list = {}

function DxLabel:render()
	if(not self.visible) then return end
	
	if(self.buffered) then
		self:renderBuffer()
	else
		self:renderInternal(self.left, self.top, self.right, self.bottom, self.alignX, self.alignY)
	end
end

function DxLabel:renderBuffer()
	if(self.dirty or not self.buffer) then
		self:updateBuffer()
	end
	
	local x, y = self.left, self.top
	if(self.alignX == "center") then
		x = (self.left + self.right - self.bufferW)/2
	end
	if(self.alignY == "center") then
		y = (self.top + self.bottom - self.bufferH)/2
	end
	dxDrawImage(x, y, self.bufferW, self.bufferH, self.buffer)
end

function DxLabel:renderInternal(left, top, right, bottom, alignX, alignY)
	if(self.shadow) then
		-- render target has alpha channel and doesnt add alpha values
		local a
		if(self.buffered) then
			a = self.shadow
		else
			local n = (self.shadowBlur + 1)
			a = math.floor(255 - ((1 - self.shadow/255)^(1/n))*255)
		end
		local color = tocolor(0, 0, 0, a)
		
		for offX = self.shadowOffsetX - self.shadowBlur, self.shadowOffsetX + self.shadowBlur do
			for offY = self.shadowOffsetY - self.shadowBlur, self.shadowOffsetY + self.shadowBlur do
				dxDrawText(self.textWithoutCodes, left + offX, top + offY, right + offX, bottom + offY, color, self.scale, self.font, alignX, alignY, self.clip)
			end
		end
	end
	
	if(self.border) then
		for offX = -self.border, self.border do
			for offY = -self.border, self.border do
				if(offX ~= 0 or offY ~= 0) then
					dxDrawText(self.textWithoutCodes, left + offX, top + offY, right + offX, bottom + offY, self.borderColor, self.scale, self.font, alignX, alignY, self.clip)
				end
			end
		end
	end
	
	dxDrawText(self.text, left, top, right, bottom, self.color, self.scale, self.font, alignX, alignY, self.clip, false, false, self.colorCoded)
end

function DxLabel:updateBuffer()
	if(self.buffer) then
		destroyElement(self.buffer)
	end
	
	local marginLeft, marginTop, marginRight, marginBottom = 0, 0, 0, 0
	if(self.shadow) then
		marginLeft = math.max(marginLeft, -self.shadowOffsetX + self.shadowBlur)
		marginRight = math.max(marginRight, self.shadowOffsetX + self.shadowBlur)
		marginTop = math.max(marginTop, -self.shadowOffsetY + self.shadowBlur)
		marginBottom = math.max(marginBottom, self.shadowOffsetY + self.shadowBlur)
	end
	
	if(self.border) then
		marginLeft = math.max(marginLeft, self.border)
		marginRight = math.max(marginRight, self.border)
		marginTop = math.max(marginTop, self.border)
		marginBottom = math.max(marginBottom, self.border)
	end
	
	self.bufferW = dxGetTextWidth(self.text, self.scale, self.font) + marginLeft + marginRight
	self.bufferH = dxGetFontHeight(self.scale, self.font) + marginTop + marginBottom
	
	self.buffer = dxCreateRenderTarget(self.bufferW, self.bufferH, true)
	
	dxSetRenderTarget(self.buffer, true)
	--dxDrawRectangle(0, 0, self.bufferW, self.bufferH, tocolor(255, 128, 128))
	--dxDrawRectangle(marginLeft, marginTop, self.bufferW - marginLeft - marginRight, self.bufferH - marginTop - marginBottom, tocolor(255, 255, 128))
	self:renderInternal(marginLeft, marginTop, self.bufferW - marginLeft, self.bufferH - marginTop, "left", "top")
	self.dirty = false
	dxSetRenderTarget()
end

function DxLabel:setText(text)
	if(self.text == text) then return end
	
	self.text = text
	self.textWithoutCodes = self.colorCoded and self.text:gsub("#%x%x%x%x%x%x", "") or self.text
	self.dirty = true
end

function DxLabel:setPosition(left, top, right, bottom)
	self.left = left
	self.top = top
	self.right = right or left
	self.bottom = bottom or top
end

function DxLabel:setColor(clr)
	self.color = clr
	self.dirty = true
end

function DxLabel:setScale(scale)
	self.scale = scale
	self.dirty = true
end

function DxLabel:setFont(font, scale)
	self.font = font
	self.scale = scale or self.scale
	self.dirty = true
end

function DxLabel:setShadow(alpha, offsetX, offsetY, blur, color)
	self.shadow = alpha
	self.shadowOffsetX = offsetX or 2
	self.shadowOffsetY = offsetY or 2
	self.shadowBlur = blur or 0
	self.dirty = true
end

function DxLabel:setBorder(value, color)
	self.border = value
	self.borderColor = color or tocolor(0, 0, 0)
	self.dirty = true
end

function DxLabel:setVisible(visible)
	self.visible = visible
end

function DxLabel:setAlign(align)
	self.alignX = align
end

function DxLabel:setVerticalAlign(valign)
	self.alignY = valign
end

function DxLabel:setColorCoded(colorCoded)
	self.colorCoded = colorCoded
	self.textWithoutCodes = self.colorCoded and self.text:gsub("#%x%x%x%x%x%x", "") or self.text
	self.dirty = true
end

function DxLabel:setBuffered(buffered)
	if(not buffered and self.buffer) then
		destroyElement(self.buffer)
		self.buffer = false
	end
	
	self.buffered = buffered
end

function DxLabel:destroy()
	DxLabel.list[self] = nil
	
	if(self.buffer) then
		destroyElement(self.buffer)
		self.buffer = false
	end
end

function DxLabel.create(text, left, top, right, bottom)
	local self = setmetatable({}, DxLabel.__mt)
	self.text = text
	self.textWithoutCodes = text
	self.left = left
	self.top = top
	self.right = right or left
	self.bottom = bottom or top
	self.color = tocolor(255, 255, 255)
	self.scale = 1
	self.font = "default"
	self.shadow = false
	self.border = false
	self.alignX = "left"
	self.alignY = "top"
	self.clip = false
	self.colorCoded = false
	self.visible = true
	self.buffered = false
	
	DxLabel.list[self] = true
	return self
end

function DxLabel.renderAll()
	for text, _ in pairs(DxLabel.list) do
		text:render()
	end
end

addEventHandler("onClientRender", g_Root, DxLabel.renderAll)

--[[
n
1: s*(1-a)+a*c -> a
2: (s*(1-a)+a*c)*(1-a)+a*c -> a+a*(1-a)
3: ((s*(1-a)+a*c)*(1-a)+a*c)*(1-a)+a*c ->a+a*(1-a)+(1-a)*(1-a)*a

-> a*(1-(1-a)^n)/(1-(1-a)) = 1-(1-a)^n
ok

x = 1-(1-a)^n
(1-a)^n = 1-x
1-a = (1-x)^(1/n)
a = 1 - (1-x)^(1/n)

x/255 = 1-(1-a/255)^n
]]