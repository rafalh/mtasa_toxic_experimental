UiPanel = {}

function UiPanel:GetChildFromPt(x, y)
	for i, child in ipairs(self.children) do
		if(child.rc:CheckPt(x, y)) then
			return child
		end
	end
end

function UiPanel:AddChild(child)
	if(self.el) then
		setElementParent(child.el, self.el)
	end
	table.insert(self.children, child)
end

function UiPanel:onMouseEnter()
	self.hover = true
end

function UiPanel:onMouseLeave()
	if(self.hover_el) then
		self.hover_el:onMouseLeave()
	end
	
	self.hover = false
	self.hover_el = false
end

function UiPanel:onMouseMove(x, y)
	local child = self:GetChildFromPt(x, y)
	if(child ~= self.hover_el) then
		if(self.hover_el) then
			self.hover_el:onMouseLeave()
		end
		
		self.hover_el = child
		
		if(self.hover_el) then
			self.hover_el:onMouseEnter()
		end
	end
	
	if(self.hover_el) then
		self.hover_el:onMouseMove(x, y)
	end
end

function UiPanel:onMouseClick(btn, state, x, y)
	local child = self:GetChildFromPt(x, y) outputChatBox("click")
	if(child) then
		outputChatBox("ch click")
		child:onMouseClick(btn, state, x, y)
	end
end

function UiPanel:onRender(clip_rect)
	local rc = self.rc
	
	if(clip_rect) then
		rc = rc:Intersect(clip_rect)
	end
	
	for i, child in ipairs(self.children) do
		child:onRender(rc)
	end
end

function UiPanel:onRestore()
	for i, child in ipairs(self.children) do
		child:onRestore()
	end
end

function UiPanel:Init(x, y, w, h, parent)
	local abs_x, abs_y = x, y
	if(parent) then
		abs_x = abs_x + parent.rc.x
		abs_y = abs_y + parent.rc.y
	end
	
	self.rc = UiRect:Create(abs_x, abs_y, w, h)
	self.children = {}
	
	if(parent) then
		parent:AddChild(self)
	end
end

UiPanel.__mt = {__index = UiPanel}

function UiPanel:Create(x, y, w, h, parent)
	local panel = setmetatable({}, UiPanel.__mt)
	panel.el = createElement("dxpanel")
	panel:Init(x, y, w, h, parent)
	return panel
end
