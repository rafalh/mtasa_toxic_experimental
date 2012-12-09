UiPanel = UiCopyTable(dxMain)

function UiPanel:Create(x, y,sx,sy,parent)
	local panel = setmetatable(
	{
		x=x,
		y=y, 
		sx = sx,
		sy = sy,
		color = tocolor(255,255,255,0),
		children = {},
		parent = false,
		visible = true,
		enabled = true,
		el = createElement("dxpanel"),
		types = "panel",
	}, UiPanel.__mt)
	if parent then
		parent:AddChild(panel)
		panel.parent = parent
	end
	addToAllRender(panel)
	return panel
end

function UiPanel:onRender()
	if not self:getVisible() then
		return
	end
	if self.sx ~= 0 and self.sy ~= 0 then
		local posx,posy = self:getOnScreenPosition()
		dxDrawRectangle(posx,posy, self.sx, self.sy, self.color,true)
	end
end