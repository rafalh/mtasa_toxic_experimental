GUI = {}
GUI.__mt = {__index = GUI}
GUI.templates = false

function GUI.loadNode(node)
	local ctrl = xmlNodeGetAttributes(node)
	ctrl.type = xmlNodeGetName(node)
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local child = GUI.loadNode(subnode)
		table.insert(ctrl, child)
	end
	return ctrl
end

function GUI.loadTemplates(path)
	local node = xmlLoadFile(path)
	if(not node) then
		outputDebugString("xmlLoadFile "..path.." failed", 2)
		return false
	end
	
	GUI.templates = {}
	
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local ctrl = GUI.loadNode(subnode)
		if(ctrl.id) then
			GUI.templates[ctrl.id] = ctrl
		end
	end
	
	xmlUnloadFile(node)
	return true
end

function GUI.getTemplate(tplID)
	if(not GUI.templates) then
		if(not GUI.loadTemplates("gui/gui.xml")) then
			outputDebugString("Failed to load GUI", 1)
			return false
		end
	end
	
	local tpl = GUI.templates[tplID]
	return tpl
end

function GUI.computeCtrlPlacement(tpl, parent)
	local pw, ph
	if(parent) then
		pw, ph = guiGetSize(parent, false)
	else
		pw, ph = guiGetScreenSize()
	end
	
	local lx, cx, rx, w = tpl.lx, tpl.cx, tpl.rx, tpl.w
	local ty, cy, by, h = tpl.ty, tpl.cy, tpl.by, tpl.h
	
	-- First calculate x and w
	if(lx) then
		if(not w) then
			assert(rx, "lx and not (w or rx)")
			w = pw - tpl.lx - tpl.rx
		end
	elseif(rx) then
		-- Note: lx == nil
		assert(w, "rx and not (w or lx)")
		lx = pw - rx - w
	else
		assert(cx and w, "not (lx or rx) and not (cx and w)")
		lx = pw/2 + cx - w/2
	end
	
	-- Now calculate y and h
	if(ty) then
		if(not h) then
			assert(by, "lx and not (h or by)")
			h = ph - ty - by
		end
	elseif(by) then
		-- Note: ty == nil
		assert(h, "by and not (h or ty)")
		ty = ph - by - h
	else
		assert(cy and h, "not (ty or by) and not (cy and h)")
		ty = ph/2 + cy - h/2
	end
	
	return lx, ty, w, h
end

function GUI:createControl(tpl, parent)
	local x, y, w, h = GUI.computeCtrlPlacement(tpl, parent)
	
	local ctrl
	if ( tpl.type == "window") then
		ctrl = guiCreateWindow(x, y, w, h, tpl.title or "", false)
		if(tpl.sizeable == "false") then
			guiWindowSetSizable(ctrl, false)
		end
	elseif(tpl.type == "button") then
		ctrl = guiCreateButton(x, y, w, h, tpl.text or "", false, parent)
	elseif(tpl.type == "checkbox") then
		ctrl = guiCreateCheckBox(x, y, w, h, tpl.text or "", tpl.selected == "true", false, parent)
	elseif(tpl.type == "edit") then
		ctrl = guiCreateEdit(x, y, w, h, tpl.text or "", false, parent)
		if (tpl.readonly == "true") then
			guiEditSetReadOnly(ctrl, true)
		end
		if(tonumber(tpl.maxlen)) then
			guiEditSetMaxLength(ctrl, tonumber(tpl.maxlen))
		end
		if(tpl.masked == "true") then
			guiEditSetMasked(ctrl, true)
		end
	elseif(tpl.type == "memo") then
		ctrl = guiCreateMemo(x, y, w, h, tpl.text or "", false, parent)
		if(tpl.readonly == "true") then
			guiMemoSetReadOnly(ctrl, true)
		end
	elseif(tpl.type == "label") then
		ctrl = guiCreateLabel(x, y, w, h, tpl.text or "", false, parent)
		if(tpl.align) then
			guiLabelSetHorizontalAlign(ctrl, tpl.align)
		end
		if(tpl.color) then
			local r, g, b = getColorFromString(tpl.color)
			guiLabelSetColor(ctrl, r or 255, g or 255, b or 255)
		end
	elseif(tpl.type == "image") then
		ctrl = guiCreateStaticImage(x, y, w, h, tpl.src or "", false, parent)
	elseif(tpl.type == "list") then
		ctrl = guiCreateGridList( x, y, w, h, false, parent )
	elseif(tpl.type == "column") then
		ctrl = guiGridListAddColumn(parent, tpl.text or "", tpl.w or 0.5)
	else
		assert (false)
	end
	
	if(tpl.visible == "false") then
		guiSetVisible(ctrl, false)
	end
	if(tpl.alpha) then
		guiSetAlpha(ctrl, (tonumber(tpl.alpha) or 255)/255)
	end
	if(tpl.font) then
		guiSetFont(ctrl, tpl.font)
	end
	if(tpl.enabled == "false") then
		guiSetEnabled(ctrl, false)
	end
	
	if(tpl.id) then
		self[tpl.id] = ctrl
	end
	if(tpl.focus == "true") then
		self.focus = ctrl
	end
	if(tpl.defbtn) then
		addEventHandler("onClientGUIAccepted", ctrl, function()
			local btn = self[tpl.defbtn]
			if(btn) then
				triggerEvent("onClientGUIClick", btn, "left", "up")
			end
		end, false)
	end
	
	return ctrl
end

function GUI:createControls(tpl, parent)
	local ctrl = self:createControl(tpl, parent)
	for i, childTpl in ipairs(tpl) do
		self:createControl(childTpl, ctrl)
	end
	return ctrl
end

function GUI:destroy()
	destroyElement(self.wnd)
end

function GUI.create(id, parent)
	local self = setmetatable({}, GUI.__mt)
	self.parent = parent
	
	self.tpl = GUI.getTemplate(id)
	if(not self.tpl) then
		outputDebugString("Unknown template ID "..id, 1)
		return false
	end
	
	self.wnd = self:createControls(self.tpl, parent)
	if(not self.focus) then
		self.focus = self.wnd
	end
	guiBringToFront(self.focus)
	
	return self
end
