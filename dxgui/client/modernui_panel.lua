UiPanel = UiCopyTable(dxMain)

function UiPanel:Create(x, y,sx,sy,parent)
	local panel = setmetatable(
	{
		x=x,
		y=y, 
		sx = sx,
		sy = sy,
		backgroundColor = {r=0,g=0,b=0},
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

function UiPanel:setBackgroud(r,g,b,a)
	self.backgroundColor = {r=r or 0,g=g or 0,b=b or 0,a=a or 0}
end

function UiPanel:onRender()
	if not self:getVisible() then
		return
	end
	if self.sx ~= 0 and self.sy ~= 0 then
		local posx,posy = self:getOnScreenPosition()
		dxDrawRectangle(posx,posy, self.sx, self.sy, tocolor(self.backgroundColor.r,self.backgroundColor.g,self.backgroundColor.b,self.backgroundColor.a))
	end
end