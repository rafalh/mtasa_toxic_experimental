local span = "______________________________________________________________________"

UiGridList = {}

UiGridList.__mt = {__index = UiGridList}

function UiGridList:Create( x, y, sx, sy,parent)
	local grid = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		parent = false,
		visible = true,
		redraw = true,
		enabled = true,
		columns = {},
		scrool = 0,
		children = {}
	}, UiGridList.__mt)
	addToAllRender(grid)
	if parent then
		grid.parent = parent
		parent:AddChild(grid)
	end
	return grid
end
function UiGridList:getEnabled()
	return self.enabled
end

function UiGridList:addColumn(name,size)
	table.insert(self.columns,{name=name,size=size,vals={},redraw=true,tg=false})
	for k,v in pairs(self.columns) do
		if v.name == name and v.size == size then
			return k
		end
	end
end

function UiGridList:addValToColumn(col,data)
	table.insert(self.columns[col].vals,data)
	self.columns[col].redraw=true
end

function UiGridList:getVisible()
	return self.visible
end

function UiGridList:getType()
	return self.types
end

function UiGridList:AddChild(child)
	table.insert(self.children, child)
end

function UiGridList:SetVisible(visible)
	self.visible = visible
end

function UiGridList:getPosition()
	return self.x,self.y
end

function UiGridList:onRender()
	if self.parent then
		if not self.parent:getVisible() then
			return
		end
	end
	if not self.visible then
		return
	end
	if(self.redraw) then
		self:UpdateBuffer()
	end
	local xp,xy = 0,0
	if self.parent then
		xp,xy = self.parent:getPosition()
	end
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,buttonfond, "left", "center")
	dxDrawImage(self.x+xp,self.y+xy,self.sx,self.sy,self.buf,0,0,0,tocolor(255,255,255,255),true)
end

function UiGridList:setScrool(val)
	self.scrool = val
	self.redraw = true
end

function UiGridList:onMouseMove(x, y)
end

function UiGridList:onMouseEnter()
end

function UiGridList:onMouseLeave()
end

function UiGridList:onMouseClick(btn, state, x, y)
end

function UiGridList:onRestore()
	self.redraw = true
end

function UiGridList:setBorderColor(r,g,b,a)
	self.bordercolor = tocolor(r or 0,g or 0,b or 0,a or 255)
end

function UiGridList:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt)
		dxDrawRectangle(0, 0, self.sx, self.sy, tocolor(255,255,255))
		local lastposx = 0
		local lastposy = 0
		for k,v in ipairs(self.columns) do
			lastposy = 0
			local actualposx,actualposy = lastposx,lastposy
			lastposx = lastposx+self.sx*v.size
			lastposy = lastposy+15
			if not v.rt or v.redraw then
				if v.rt then
					destroyElement(v.rt)
				end
				local lastposyc = 0
				v.rt = dxCreateRenderTarget(self.sx*v.size, #v.vals*15)
				dxSetRenderTarget(v.rt)
				for a,b in pairs(v.vals) do
					dxDrawRectangle(0, lastposyc,self.sx*v.size, 15, ifElse(a%2==0,tocolor(51,51,51),tocolor(70,70,70)))
					dxDrawText(b,0,lastposyc,self.sx*v.size,lastposyc+15,tocolor(0,0,0), 0.5,buttonfond, "center", "center")
					lastposyc = lastposyc+15
				end
				v.redraw = false
				dxSetRenderTarget(self.rt)
				dxDrawImage(actualposx,lastposy-self.scrool,self.sx*v.size,#v.vals*15,v.rt)
			else
				dxDrawImage(actualposx,lastposy-self.scrool,self.sx*v.size,#v.vals*15,v.rt)
			end
			dxDrawRectangle(actualposx, 0,self.sx*v.size, 15, tocolor(228,235,242))
			dxDrawText(v.name,5,0,self.sx*v.size,15,tocolor(0,0,0), 0.5,buttonfond, "center", "center")
		end
	dxSetRenderTarget()
	self.redraw = false
end