UiTile = UiCopyTable(dxMain)

function UiTile:Create(x, y, sx, sy,image,text,parent)
	local tile = setmetatable({
		x=x,
		y=y, 
		sx=sx, 
		sy=sy,
		text = text,
		children = {},
		parent = false,
		visible = true,
		el = createElement("dxtile"),
		hover = false,
		redraw = true,
		enabled = true,
		types = "tile",
		color = tocolor(41,123,237),
		bordercolor = tocolor(60,128,238),
		image = image,
		imagedata = {x=0,y=0,fullsize=false},
		text = text,
		oldimg = false,
		newimg = false,
		animset = false,
		cacheenabled = true,
		tickStart = 0,
		animationEnabled = true,
	}, UiTile.__mt)
	addToAllRender(tile)
	if image and image ~= "" and fileExists(image) then
		local myTexture = dxCreateTexture(image)
		local width, height = dxGetMaterialSize( myTexture )
		tile.imagedata = {x=width,y=height}
		destroyElement(myTexture)
	else
		tile.image = false
	end
	if parent then
		tile.parent = parent
		parent:AddChild(tile)
	end
	return tile
end

function UiTile:setText(text)
	self.text = text
	self.redraw = true
end

function UiTile:setImage(image,fullsize)
	if not fullsize then
		local myTexture = dxCreateTexture(image)
		local width, height = dxGetMaterialSize( myTexture )
		self.imagedata = {x=width,y=height,fullsize=false}
		destroyElement(myTexture)
		self.image = image
		self.redraw = true
	else
		if self.animationEnabled then
			self.oldimg = (type(self.image)=="string" and dxCreateTexture(self.image) or self.image)
			self.newimg = (type(image)=="string" and dxCreateTexture(image) or image)
			self.shader = dxCreateShader ( "file/rotationShader.fx" )
			dxSetShaderValue ( self.shader, "g_Texture", self.oldimg )
			self.imagedata = {x=self.sx,y=self.sy,fullsize=true}
			self.animset = true
			self.tickStart = getTickCount ()
		else
			self.imagedata = {x=self.sx,y=self.sy,fullsize=true}
			self.image = image
			self.redraw = true
		end
	end
end

function UiTile:onRender()
	if not self:getVisible() then
		return
	end
	if self.animset then
		local a = math.fmod ( ( getTickCount () - self.tickStart+1500 ) / 1000, 2 * math.pi )
		dxSetShaderValue ( self.shader, "g_Pos", self.sx/2, self.sy/2 )
		dxSetShaderValue ( self.shader, "g_ScrSize", self.sx,self.sy )
		if a > math.pi-(math.pi*0.5) and a < math.pi+(math.pi*0.5) then
			if ( a < math.pi ) then
				dxSetShaderValue ( self.shader, "g_Texture", self.oldimg )
				dxSetShaderValue ( self.shader, "g_fAngle", math.pi/2 - a )
			else
				dxSetShaderValue ( self.shader, "g_Texture", self.newimg )
				dxSetShaderValue ( self.shader, "g_fAngle", math.pi/2 - a + math.pi )
			end
			self.image = self.shader
			self.redraw = true
		elseif a > math.pi+(math.pi*0.5) then
			self.animset = false
			self.image = self.newimg
			self.newimg = false
			if isElement(self.oldimg) then
				destroyElement(self.oldimg)
			end
			if isElement(self.shader) then
				destroyElement(self.shader)
			end
			self.shader = false
			self.oldimg = false
			self.redraw = true
		end
	end
	if(self.redraw) then
		self:UpdateRT()
	end
	local posx, posy = self:getOnScreenPosition()
	local clicked = 0
	if self.down then
		clicked = 2
	end
	--dxDrawText(self.text, self.x+xp,self.y+xy,self.sx,self.sy,tocolor(255,255,255), 1,cache.Font, "left", "center")
	if self.hover and self:getEnabled() then
		dxDrawRectangle(posx-3+clicked, posy-3+clicked, self.sx+6-(clicked*2), self.sy+6-(clicked*2),tocolor(33,87,33,255),true)
	else
		self.hover = false
	end
	dxDrawImage(posx+clicked,posy+clicked,self.sx-(clicked*2),self.sy-(clicked*2),self.rt,0,0,0,tocolor(255,255,255,255),true)
end

function UiTile:setProperty(name,...)
	local args = {...}
	if name == "animationEnabled" then
		self.animationEnabled = args[1]
	elseif name == "bordercolor" then
		self.bordercolor = tocolor(args[1],args[2],args[3],args[4] or 255)
		self.redraw = true
	end
end

function UiTile:onMouseEnter()
	if self:getEnabled() then
		self.hover = true
		self.redraw = true
	end
end

function UiTile:onMouseLeave()
	if self:getEnabled() then
		self.hover = false
		self.redraw = true
	end
end

function UiTile:onMouseClick(btn, state, x, y)
	if self:getEnabled() then
		if btn == "left" then
			self.down = (state == "down")
		end
		triggerEvent("onModernUIClick",localPlayer,self.el,btn,state,x,y)
		triggerEvent("onDxGUIClick",self.el,btn,state,x,y)
	end
end

--function UiTile:setColor(r,g,b)
	--self.bordercolor = tocolor(r or 0,g or 0,b or 0)
--end

function UiTile:UpdateRT()
	if(not self.rt) then
		self.rt = dxCreateRenderTarget(self.sx, self.sy)
	end
	local fontheight = dxGetFontHeight (0.4,cache.Font)
	local imagesizex,imagesizey = self.sx-10,self.sy-fontheight-14
	local imageposx,imageposy = (self.sx - imagesizex)/2,(self.sy-imagesizey-fontheight)/2
	if not self.imagedata.fullsize then
		if self.imagedata.x-10 < imagesizex then
			imagesizex = self.imagedata.x
			imageposx = (self.sx - imagesizex)/2
		end
		if self.imagedata.y-fontheight-14 < imagesizey then
			imagesizey = self.imagedata.y
			imageposy = (self.sy-imagesizey-fontheight)/2
		end
	else
		imagesizex,imagesizey,imageposx,imageposy = self.sx,self.sy,0,0
	end
	local clr = self.color
	local borderclr = self.bordercolor
	if not self:getEnabled() then
		clr = tocolor(43,42,37)
	end
	dxSetRenderTarget(self.rt)
		dxDrawRectangle(0, 0, self.sx  , self.sy,clr)
		dxDrawRectangle(0, 0, self.sx, 3, borderclr)
		dxDrawRectangle(0, self.sy-3, self.sx, 3,borderclr)
		dxDrawRectangle(self.sx-3, 0, 3,self.sy, borderclr)
		dxDrawRectangle(0, 0, 3, self.sy,borderclr)
		if self.image then
			dxDrawImage(imageposx,imageposy, imagesizex,imagesizey,self.image,0,0,0,tocolor(255,255,255,255))
		end
		dxDrawText(self.text, 18, self.sy-fontheight-9+1, self.sx , 20,tocolor(0,0,0,255), 0.4,cache.Font)
		dxDrawText(self.text, 17, self.sy-fontheight-9, self.sx , 20,tocolor(255,255,255,255), 0.4,cache.Font)
	dxSetRenderTarget()
	self.redraw = false
end