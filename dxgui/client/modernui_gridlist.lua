local span = "______________________________________________________________________"

UiGridList = UiCopyTable(dxMain)

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
		selected = 0,
		posYOfSlider = 0,
		isSliderActive = false,
		isClicked = false,
		isActive = false,
		showSlider = false,
		el = createElement("dxGridList"),
		children = {}
	}, UiGridList.__mt)
	addToAllRender(grid)
	if parent then
		grid.parent = parent
		parent:AddChild(grid)
	end
	return grid
end

function UiGridList:addColumn(name,size)
	if #self.columns > 0 then return false end
	table.insert(self.columns,{name=name,size=1--[[size]],vals={},redraw=true,tg=false})
	return #self.columns
end

function UiGridList:addValToColumn(col,data)
	if not self.columns[col] then return false end
	table.insert(self.columns[col].vals,data)
	self.columns[col].redraw=true
	return #self.columns[col].vals
end

function UiGridList:onRender()
	if not self:getVisible() then
		return
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx, posy = self:getOnScreenPosition()
	local sx,sy = self:getSize()
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
	dxDrawImage(posx,posy,sx,sy,self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiGridList:setScrool(val)
	self.scrool = val
	self.redraw = true
end

function UiGridList:onMouseMove(x, y)
	if self.isSliderActive then
		local posx,posy = self:getOnScreenPosition()
		local sizex,sizey = self:getSize()
		local size = self.sx*0.1
		local maxy = sizey-20-(size*2)-20
		self.posYOfSlider = y - (posy+15+size+15)
		if self.posYOfSlider < 0 then
			self.posYOfSlider = 0
		elseif self.posYOfSlider > maxy then
			self.posYOfSlider = maxy
		end
		local procent = (self.posYOfSlider/maxy)*100
		local scrool = #self.columns[1].vals*20 - (((sizey-20)/20)*20)
		self:setScrool(procent/100*scrool)
		self.redraw = true
	end
end

function UiGridList:getSelectedItem()
	return self.selected
end

function UiGridList:getItemText(col,idx)
	if not self.columns[col] then return false end
	if not self.columns[col].vals[idx] then return false end
	return self.columns[col].vals[idx]
end

function UiGridList:clearColumn(col)
	local items = #self.columns[col].vals
	for i=items,1,-1 do
		table.remove(self.columns[col].vals,i)
	end
	self.selected = 0
	self.columns[col].redraw = true
	self.redraw = true
end

function UiGridList:getItemCount(col)
	if not self.columns[col] then return false end
	return #self.columns[col].vals
end

function UiGridList:setItemText(col,idx,text)
	if not self.columns[col] then return false end
	if not self.columns[col].vals[idx] then return false end
	self.columns[col].vals[idx] = text
	self.columns[col].redraw = true
	self.redraw = true
end

function UiGridList:deleteItem(col,idx)
	if not self.columns[col] then return false end
	if not self.columns[col].vals[idx] then return false end
	table.remove(self.columns[col].vals,idx)
	self.columns[col].redraw = true
	self.redraw = true
end

function UiGridList:onMouseEnter()
	self.isActive = true
end

function UiGridList:onMouseLeave()
	self.isActive = false
	self.isSliderActive = false
end

function UiGridList:onMouseWheel(down)
	if self.isActive then
		if down then
			if self.scrool - 7 < 0 then
				self:setScrool(0)
				return
			end
			self:setScrool(self.scrool - 7)
			return
		else
			self:setScrool(self.scrool + 7)
			return
		end
	end
end

function UiGridList:onMouseClick(btn, state, x, y)
	self.isClicked = state == "down"
	if btn == "left" then
		local posx,posy = self:getOnScreenPosition()
		local sizex,sizey = self:getSize()
		local size = self.sx*0.1
		if state == "down" then
			if self.showSlider then
				if math.between(x,posx+sizex-size,posx+sizex) and math.between(y,posy+20+size,posy+sizey-size) then
					self.isSliderActive = true
				end
			end
		elseif state == "up" then
			if self.showSlider then
				if self.isSliderActive then
					self.isSliderActive = false
					return
				end
				if math.between(x,posx+sizex-size,posx+sizex) and math.between(y,posy+20,posy+20+size) then
					if self.scrool - 7 < 0 then
						self:setScrool(0)
						return
					end
					self:setScrool(self.scrool - 7)
					return
				end
				if math.between(x,posx+sizex-size,posx+sizex)  and math.between(y,posy+sizey-size,posy+sizey) then
					self:setScrool(self.scrool + 7)
					return
				end
			end
			if #self.columns > 0 then
				local count = #self.columns[1].vals
				local startY = 20 + posy - self.scrool
				for i=1,count do
					if math.between(y,startY+((i-1)*20),startY+(i*20)) then
						--outputChatBox(" y="..y.." startY="..startY.." min="..startY+((i-1)*20).." max="..startY+(i*20).." scroll="..self.scrool.." " ..i.." "..self.columns[1].vals[i])
						self.selected = i
						self.columns[1].redraw = true
						self.redraw = true
						triggerEvent("onDxGUIClick",self.el,btn,state,x,y)
						return
					end
				end
				self.selected = 0
				self.columns[1].redraw = true
				self.redraw = true
			end
		end
	end
	triggerEvent("onDxGUIClick",self.el,btn,state,x,y)
end

function UiGridList:setBorderColor(r,g,b,a)
	self.bordercolor = tocolor(r or 0,g or 0,b or 0,a or 255)
end

function UiGridList:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy,true)
	end
	dxSetRenderTarget(self.rt,true)
		dxDrawRectangle(0, 0, self.sx, self.sy, tocolor(90,90,90,255))
		local lastposx = 0
		local lastposy = 0
		for k,v in ipairs(self.columns or {}) do
			lastposy = 0
			local actualposx,actualposy = lastposx,lastposy
			lastposx = lastposx+self.sx*v.size
			lastposy = lastposy+20
			if not v.rt or v.redraw then
				if v.rt then
					destroyElement(v.rt)
				end
				local lastposyc = 0
				v.rt = dxCreateRenderTarget(self.sx*v.size, #v.vals*20 or 0)
				dxSetRenderTarget(v.rt)
				for a,b in pairs(v.vals) do
					dxDrawRectangle(0, lastposyc,self.sx*v.size, 20, ifElse(a==self.selected,tocolor(209,232,255),ifElse(a%2==0,tocolor(51,51,51),tocolor(70,70,70))))
					dxDrawText(b,0,lastposyc,self.sx*v.size,lastposyc+20,tocolor(0,0,0), 0.5,cache.Font, "center", "center")
					lastposyc = lastposyc+20
				end
				self.showSlider = lastposyc+15 > self.sy
				v.redraw = false
				dxSetRenderTarget(self.rt)
				if v.rt then
					dxDrawImage(actualposx,lastposy-self.scrool,self.sx*v.size,#v.vals*20,v.rt)
				end
			else
				dxDrawImage(actualposx,lastposy-self.scrool,self.sx*v.size,#v.vals*20,v.rt)
			end
			dxDrawRectangle(actualposx, 0,self.sx*v.size, 20, tocolor(228,235,242))
			dxDrawText(v.name,5,0,self.sx*v.size,20,tocolor(0,0,0), 0.5,cache.Font, "center", "center")
		end
		if self.showSlider then
			local size = self.sx*0.1
			dxDrawRectangle(self.sx-size, 20+size,size, self.sy-(size*2)-20, tocolor(240,240,240,200))
			dxDrawRectangle(self.sx-size, 20,size, size, tocolor(240,240,240,255))
			dxDrawImage(self.sx-size+2, 20+2,size-4, size-4,"image/appbar.chevron.up.png")
			dxDrawRectangle(self.sx-size, self.sy-size,size, size, tocolor(240,240,240,255))
			dxDrawImage(self.sx-size+2, self.sy-size+2,size-4, size-4,"image/appbar.chevron.down.png")
			dxDrawRectangle(self.sx-size, 20+size+self.posYOfSlider,size, size, tocolor(32,165,233,255))
		end
	dxSetRenderTarget()
	self.redraw = false
end