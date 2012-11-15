local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local all_elements = {}
local cache_elements = {}
local all_elements_revers = {}
buttonfond = dxCreateFont("file/segoe.ttf",24)
local resourceChild = {}
if not cache then
	cache = {}
end
cache.elementToClass = {}

function CheckPtMain(x, y,cx,cy,sx,sy)
	return (x >= cx and y >= cy and x < cx+sx and y < cy+sy)
end

function GetChildFromPtMain(x, y)
	if isConsoleActive () then return false end
	for i, child in pairs(all_elements_revers) do
		if child:getVisible() and child:getEnabled() then
			local contin = true
			if child.parent then
				if not child.parent:getVisible() then
					contin = false
				end
			end
			if contin then
				if #child.children > 0 then
					for a,childs in pairs(child.children) do
						local childx,childy = 0,0
						local posx,posy = childs:getOnScreenPosition()
						local sizex,sizey = childs:getSize()
						local var = CheckPtMain(x, y,posx, posy,sizex,sizey)
						if var then
							return childs
						end
					end
				end
				local posx,posy = child:getOnScreenPosition()
				local sizex,sizey = child:getSize()
				local var = CheckPtMain(x, y,posx, posy,sizex,sizey)
				if var then
					return child
				end
			end
		end
	end
end

local function UiInit()	
	--local edit = UiEdit:Create(200, 200, 200, 30,"",wnd)
	--[[--local wnd = UiCreateWindow("Test", 100, 100, 200, 200)
	local wnd = UiPanel:Create(resolution[1]/2-160,resolution[2]/2-100)
	--local btn = UiButton:Create("OK", 200, 400, 100, 30,tocolor(64, 128, 255),tocolor(128, 196, 255),wnd)
	wnd:setBackgroud(235,100,tocolor(88,88,88))
	local btn2 = UiButton:Create("", 205, 70, 30, 30,wnd)
	btn2:setType("image",{src="image/modernui/appbar.arrow.right.png",x=1,y=1,sx=28,sy=28})
	local edit = UiEdit:Create("", 105, 70, 100, 30,wnd)
	local text = UiText:Create("", 105, 0, 200, 30,wnd)
	local text2 = UiText:Create("Bober", 105, 30, 200, 30,wnd)
	local image = UiImage:Create("image/avatars/7984_1346631010.jpg",0,0,100,100,wnd)
	--wnd:setColor(0,255)
	--
	wnd:setVisible(false)
	local wnd2 = UiWindow:Create("Jakiś text",200,200,200,200)
	UiButton:Create("Zapisz i zamknij", 50, 100, 130, 30,wnd2)
	--wnd2:setColor(0,255)
	--window:setVisible(false)
	--UiCheckbox:Create(200, 200,false)
	--edit:setIsPassword(true)
	]]

	--[[local btn4 = UiButton:Create("", resolution[1]/2, resolution[2]-100, 200, 50)
	btn4:setType("mix",
	{
		{type="image",src="image/modernui/appbar.add.png",x=1,y=1,sx=48,sy=48},
		{type="text",x=55,y=15,sx=250,sy=50,text="Dodaj nowe konto",scale=0.5,alignX="left",alignY="top"}
	})]]
	--[[local grid = UiGridList:Create(200,200,200,200)
	local col = grid:addColumn("asdf",1)
	for i=1,50 do
		grid:addValToColumn(col,tostring(i))
	end]]
	--[[local val = 0
	setTimer(function () val=val+3 grid:setScrool(val) end,50,200)
	setTimer(function ()
	for i=51,100 do
		grid:addValToColumn(col,tostring(i))
	end
	setTimer(function () val=val+3 grid:setScrool(val) end,50,200)
	end,11000,1)]]
	--[[local progress = UiProgress:Create(200,200,200,50)
	setTimer(function () progress:setProgress(progress:getProgress() + 1) end,200,100)]]
	--local tile = UiTile:Create(200,200,120,120,"image/avatars/7984_1346631010.jpg","DM")
	--local tile = UiTile:Create(400,200,120,120,"image/modernui/appbar.add.png","Jakiś text")
	--[[local btn3 = UiButton:Create("", resolution[1]/2-210, resolution[2]-100, 200, 50)
	btn3:setType("mix",
	{
	{type="image",src="image/modernui/appbar.add.png",x=1,y=1,sx=48,sy=48},
	{type="text",x=40,y=15,sx=250,sy=50,text="Dodaj istniejące konto",scale=0.5,alignX="left",alignY="top"}
	})]]
	--showCursor(true)
	--[[local wnd2 = UiWindow:Create(200,300,300,200,"Jakiś text")
	local combo = UiComboBox:Create(50, 50, 200, 24,"asdf",wnd2)
	for i=1,10 do
	combo:addItem(i)
	end]]
	--UiScrollPanel:Create(200, 200, 200, 200)
end

local function UiRender()
	local videomem = dxGetStatus ().VideoMemoryFreeForMTA
	if videomem == 0 then
		local text = tostring("Nie posiadasz pamięci na karcie graficznej do wyświetleniu interfejsu serwera")
		local dlugosc = dxGetTextWidth (text,1.5)
		dxDrawText(text,resolution[1]/2-(dlugosc/2), resolution[2]/2,100,100,tocolor (255, 0, 0, 255 ),1.5)
		return
	end
	for k,v in pairs(all_elements) do
		v:onRender()
	end
end

function addToAllRender(class)
	table.insert(all_elements,class)
	table.insert(all_elements_revers,1,class)
end

function dxMoveToFont(gui)
	for k,v in pairs(all_elements) do
		if gui == v then
			local temp = v
			table.remove(all_elements,k)
			table.insert(all_elements,temp)
			for k,v in pairs(v.children) do
				for w,a in pairs(all_elements) do
					if a == v then
						local temp = v
						table.remove(all_elements,w)
						table.insert(all_elements,temp)
					end
				end
			end
			for k,v in pairs(all_elements_revers) do
				if v == gui then
					local temp = v
					table.remove(all_elements_revers,k)
					table.insert(all_elements_revers,1,temp)
					for k,v in pairs(v.children) do
						for w,a in pairs(all_elements_revers) do
							if a == v then
								local temp = v
								table.remove(all_elements_revers,w)
								table.insert(all_elements_revers,1,temp)
							end
						end
					end
				end
			end
			break
		end
	end
end

local function UiRestore()
	for k,v in pairs(all_elements) do
		v:onRestore()
	end
end

function deleteElementFromAllElements(el)
	for k,v in pairs(all_elements) do
		if v.el == el then
			table.remove(all_elements,k)
		end
	end
	for k,v in pairs(all_elements_revers) do
		if v.el == el then
			table.remove(all_elements,k)
		end
	end
end

function UiCopyTable(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	return ret
end

local function UiCursorMove(rel_x, rel_y, x, y)
	local child = GetChildFromPtMain(x, y)
	if(child ~= cache_elements.hover_el) then
		if(cache_elements.hover_el) then
			cache_elements.hover_el:onMouseLeave()
		end
			
		cache_elements.hover_el = child
		
		if(cache_elements.hover_el) then
			cache_elements.hover_el:onMouseEnter()
		end
	end
	if(cache_elements.hover_el) then
		cache_elements.hover_el:onMouseMove(x, y)
	end
end

local function UiClick(btn, state, x, y)
	local child = GetChildFromPtMain(x, y)
	if(child) then
		for i, child in pairs(all_elements) do
			if child:getType() == "edit" then
				child.active = false
				child.redraw = true
			end
		end
		--[[local outputEvent = true
		if state == "down" then
			cache.hoverdown = child
		elseif state == "up" and cache.hoverdown and child ~= cache.hoverdown then
			cache.hoverdown:onMouseClick(btn, state, x, y)
			cache.hoverdown = nil
			outputEvent = false
		end
		if outputEvent then]]
			child:onMouseClick(btn, state, x, y)
		--end
		if child:getType() ~= "edit" and child:getType() ~= "combobox" then
			for i, child in pairs(all_elements) do
				if child:getType() == "edit" then
					child.active = false
					child.redraw = true
				elseif child:getType() == "combobox" then
					child.list.visible = false
				end
			end
		end
	else
		--[[if state == "up" and cache.hoverdown then
			cache.hoverdown:onMouseClick(btn, state, x, y)
			cache.hoverdown = nil
		end]]
		for i, child in pairs(all_elements) do
			if child:getType() == "edit" then
				child.active = false
				child.redraw = true
			elseif child:getType() == "combobox" then
				child.list.visible = false
			end
		end
	end
end

function outputPressedCharacter(character)
	if isConsoleActive () then return false end
	for i, child in pairs(all_elements) do
		if child:getType() == "edit" then
			if child.active then
				child.text = tostring(child.text) .. tostring(character)
				child.redraw = true
			end
		end
	end
end

function addChildToResource(res,child)
	if not resourceChild[res] then
		resourceChild[res] = {}
	end
	table.insert(resourceChild[res],child)
end

function ResStop(stoppedResource)
	if resourceChild[stoppedResource] then
		for k,v in pairs(resourceChild[stoppedResource]) do
			cache.elementToClass[v.el] = nil
			v:delete()
		end
		resourceChild[stoppedResource] = nil
	end
end

function outputPressedKey(key,pressOrRelease)
	if isConsoleActive () then return false end
	if key == "backspace" then
		if pressOrRelease then
			for i, child in pairs(all_elements) do
				if child:getType() == "edit" then
					if child.active then
						child.text = tostring(child.text):sub(1,string.len(child.text)-1)
						child.redraw = true
						cache.isActiveTimerDeleteText = setTimer(
						function()
							if child.active then
								child.text = tostring(child.text):sub(1,string.len(child.text)-1)
								child.redraw = true
							else
								killTimer(cache.isActiveTimerDeleteText)
								cache.isActiveTimerDeleteText = nil
							end
						end,200,0)
					end
				end
			end
		else
			if cache.isActiveTimerDeleteText then
				killTimer(cache.isActiveTimerDeleteText)
				cache.isActiveTimerDeleteText = nil
			end
		end
	end
end

function modernuiwklej(komenda,text)
	for i, child in pairs(all_elements) do
		if child:getType() == "edit" then
			if child.active then
				child.text = tostring(child.text) .. tostring(text)
				child.redraw = true
			end
		end
	end
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

addCommandHandler("modernuiwklej",modernuiwklej)
addEventHandler("onClientResourceStart", g_ResRoot, UiInit)
addEventHandler("onClientResourceStop", g_Root, ResStop)
addEventHandler("onClientRender", g_Root, UiRender)
addEventHandler("onClientRestore", g_Root, UiRestore)
addEventHandler("onClientCursorMove", g_Root, UiCursorMove)
addEventHandler("onClientClick", g_Root, UiClick)
addEventHandler("onClientCharacter", g_Root, outputPressedCharacter)
addEventHandler("onClientKey", g_Root, outputPressedKey)
