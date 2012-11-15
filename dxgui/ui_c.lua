local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local g_Elements = {}

function UiCreateWindow(title, x, y, w, h)
	local wnd = UiWindow:Create(title, x, y, w, h)
	g_Elements[wnd.el] = wnd
	return wnd.el
end

function UiCreateButton(title, x, y, w, h, wnd_el)
	local wnd = g_Elements[wnd_el]
	local btn = UiButton:Create(title, x, y, w, h, wnd)
	return btn.el
end

local function UiInit()
	local w, h = guiGetScreenSize()
	UiScreen = UiPanel:Create(0, 0, w, h)
	
	local wnd = UiCreateWindow("Test", 100, 100, 200, 200)
	local btn = UiCreateButton("OK", 150, 50, 100, 30, wnd)
	UiShowCursor()
end

local function UiRender()
	UiScreen:onRender()
end

local function UiRestore()
	UiScreen:onRestore()
end

function UiCopyTable(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	return ret
end

local function UiCursorMove(rel_x, rel_y, x, y)
	UiScreen:onMouseMove(x, y)
end

local function UiClick(btn, state, x, y)
	outputChatBox("UiClick")
	UiScreen:onMouseClick(btn, state, x, y)
end

function outputPressedCharacter(character)
    outputChatBox("You pressed the character "..character.."!")
end
function outputPressedKey(key)
    outputChatBox("You pressed the key "..key.."!")
end

addEventHandler("onClientResourceStart", g_ResRoot, UiInit)
addEventHandler("onClientRender", g_Root, UiRender)
addEventHandler("onClientRestore", g_Root, UiRestore)
addEventHandler("onClientCursorMove", g_Root, UiCursorMove)
addEventHandler("onClientClick", g_Root, UiClick)
addEventHandler("onClientCharacter", g_Root, outputPressedCharacter)
addEventHandler("onClientKey", g_Root, outputPressedKey)
