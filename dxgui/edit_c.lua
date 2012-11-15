local g_EditClr = tocolor(64, 128, 255)
local g_EditHoverClr = tocolor(128, 196, 255)
local g_EditActiveClr = g_BtnClr
local g_EditTextClr = tocolor(255, 255, 255)

UiButton = UiCopyTable(UiPanel)

function UiEdit:onRender(clip_rect)
	if(self.redraw) then
		self:UpdateBuffer()
	end
	local rc = self.rc:Intersect(clip_rect)
	local src_x = rc.x - self.rc.x
	local src_y = rc.y - self.rc.y
	dxDrawImageSection(rc.x, rc.y, rc.w, rc.h, src_x, src_y, rc.w, rc.h, self.buf)
end

function UiEdit:onMouseEnter()
	self.hover = true
	self.redraw = true
end

function UiEdit:onMouseLeave()
	self.hover = false
	self.redraw = true
end

function UiEdit:onMouseClick(btn, state, x, y)
	if(btn == "left") then
		self.down = (state == "down")
		self.redraw = true
	end
end

function UiEdit:UpdateBuffer()
	if(not self.buf) then
		self.buf = dxCreateRenderTarget(self.rc.w, self.rc.h)
	end
	dxSetRenderTarget(self.buf)
	
	local clr = g_EditClr
	if(self.down) then
		clr = g_EditActiveClr
	elseif(self.hover) then
		clr = g_EditHoverClr
	end
	
	dxDrawRectangle(0, 0, self.rc.w, self.rc.h, clr)
	dxDrawText(self.text, 5, 5, self.rc.w - 5, self.rc.h - 5, g_EditTextClr, 1, "bankgothic", "center", "center", true)
	
	dxSetRenderTarget()
	self.redraw = false
end

UiEdit.__mt = {__index = UiEdit}

function UiEdit:Create(title, x, y, w, h, parent)
	local edit = setmetatable({
		text = title,
		el = createElement("dxedit"),
		down = false,
		redraw = true
	}, UiEdit.__mt)
	
	UiPanel.Init(edit, x, y, w, h, parent)
	
	return edit
end