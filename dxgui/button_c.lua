local g_BtnClr = tocolor(64, 128, 255)
local g_BtnHoverClr = tocolor(128, 196, 255)
local g_BtnActiveClr = g_BtnClr
local g_BtnTextClr = tocolor(255, 255, 255)

UiButton = UiCopyTable(UiPanel)

function UiButton:onRender(clip_rect)
	if(self.redraw) then
		self:UpdateBuffer()
	end
	local rc = self.rc:Intersect(clip_rect)
	local src_x = rc.x - self.rc.x
	local src_y = rc.y - self.rc.y
	dxDrawImageSection(rc.x, rc.y, rc.w, rc.h, src_x, src_y, rc.w, rc.h, self.buf)
end

function UiButton:onMouseEnter()
	self.hover = true
	self.redraw = true
end

function UiButton:onMouseLeave()
	self.hover = false
	self.redraw = true
end

function UiButton:onMouseClick(btn, state, x, y)
	if(btn == "left") then
		self.down = (state == "down")
		self.redraw = true
	end
end

function UiButton:onRestore()
	self.redraw = true
end

function UiButton:UpdateBuffer()
	if(not self.buf) then
		self.buf = dxCreateRenderTarget(self.rc.w, self.rc.h)
	end
	dxSetRenderTarget(self.buf)
	
	local clr = g_BtnClr
	if(self.down) then
		clr = g_BtnActiveClr
	elseif(self.hover) then
		clr = g_BtnHoverClr
	end
	
	dxDrawRectangle(0, 0, self.rc.w, self.rc.h, clr)
	dxDrawText(self.text, 5, 5, self.rc.w - 5, self.rc.h - 5, g_BtnTextClr, 1, "bankgothic", "center", "center", true)
	
	dxSetRenderTarget()
	self.redraw = false
end

UiButton.__mt = {__index = UiButton}

function UiButton:Create(title, x, y, w, h, parent)
	local btn = setmetatable({
		text = title,
		el = createElement("dxbtn"),
		down = false,
		redraw = true
	}, UiButton.__mt)
	
	UiPanel.Init(btn, x, y, w, h, parent)
	
	return btn
end