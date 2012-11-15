local g_WndClr = tocolor(0, 0, 0, 128)
local g_WndTitleClr = tocolor(128, 196, 255)

UiWindow = UiCopyTable(UiPanel)

function UiWindow:onRender(clip_rect)
	local rc = self.rc
	dxDrawRectangle(rc.x, rc.y, rc.w, rc.h, g_WndClr)
	dxDrawText(self.text, rc.x + 5, rc.y + 5, rc.x2 - 5, rc.y2 - 5, g_WndTitleClr, 1.2, "bankgothic", "left", "top", true)
	
	UiPanel.onRender(self)
end

UiWindow.__mt = {__index = UiWindow}

function UiWindow:Create(title, x, y, w, h)
	local wnd = setmetatable({
		text = title,
		el = createElement("dxwnd"),
	}, UiWindow.__mt)
	UiPanel.Init(wnd, x, y, w, h, UiScreen)
	return wnd
end