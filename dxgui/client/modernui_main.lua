resolution = {guiGetScreenSize()}
local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement()
local all_elements = {}
local cache_elements = {}
local all_elements_revers = {}
local resourceChild = {}
if not cache then
	cache = {}
end

cache.Font = dxCreateFont("file/segoe.ttf",24)
cache.scaleOfFont = 0.5

cache.elementToClass = {}

function CheckPtMain(x, y,cx,cy,sx,sy)
	return (math.between(x,cx,cx+sx) and math.between(y,cy,cy+sy))
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
						if childs:getVisible() and childs:getEnabled() then
							local childx,childy = 0,0
							local posx,posy = childs:getOnScreenPosition()
							local sizex,sizey = childs:getSize()
							local var = CheckPtMain(x, y,posx, posy,sizex,sizey)
							if var then
								return childs
							end
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
	--local cb = UiComboBox:Create(200, 200, 200, 200,"asdf")
	--[[local cb = UiGridList:Create( 200, 200, 200, 100)]]
	--[[for i=1,11 do
		cb:addItem(i)
		--cb:addValToColumn(cl,i)
	end--]]
	--UiScrollBar:Create(200,200, 20, 100,false)
	--local tb = UiTab:Create(200,200,200,200)
	--tb:addTab("text")
	--tb:addTab("text2")
end

--[[function skroctext(text,longs)
	local long = string.len(text)
	local ls = 0
	for i=1,long do
		local letter = string.sub(text,i,i)
		local l = dxGetTextWidth (letter)
		ls = ls + l
		if ls > longs then
			return string.sub(text,1,i-3).."..."
		end
	end
	return text
end]]
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

function deleteElementFromAllElements(element)
	for k,v in pairs(all_elements) do
		if v.el == element then
			--outputChatBox("remove element id:"..k.." from: all_elements type: "..getElementType(v.el))
			table.remove(all_elements,k)
			break
		end
	end
	for k,v in pairs(all_elements_revers) do
		if v.el == element then
			--outputChatBox("remove element id: "..k.." from: all_elements_revers type: "..getElementType(v.el))
			table.remove(all_elements_revers,k)
			break
		end
	end
end

function UiCopyTable(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	ret.__mt = {__index = ret}
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
					child:onMouseLeave()
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
				child:onMouseLeave()
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
				triggerEvent("onDxGUIChanged",child.el)
			end
		end
	end
end

function getAllElements()
	return all_elements
end

function getFontSize(size,text)
	return dxGetTextWidth (text, size or 0.5, cache.Font),dxGetFontHeight(size or 0.5, cache.Font)
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
						triggerEvent("onDxGUIChanged",child.el)
						cache.isActiveTimerDeleteText = setTimer(
						function()
							if child.active then
								child.text = tostring(child.text):sub(1,string.len(child.text)-1)
								child.redraw = true
								triggerEvent("onDxGUIChanged",child.el)
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
				triggerEvent("onDxGUIChanged",child.el)
			end
		end
	end
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function ifElse(check,retA,retB)
	if check then return retA end
	return retB
end

function math.between(val,min,max)
	if val >= min and val <= max then
		return true
	end
	return false
end

function UiMouseWheel(_,_,upOrDown)
	if not isCursorShowing () then return end
	local x,y = getCursorPosition ( )
	local child = GetChildFromPtMain(x*resolution[1], y*resolution[2])
	if(child) then
		child:onMouseWheel(upOrDown == -1)
	end
end

bindKey( "mouse_wheel_up", "down", UiMouseWheel, -1 )
bindKey( "mouse_wheel_down", "down", UiMouseWheel, 1 )
addCommandHandler("modernuiwklej",modernuiwklej)
addEventHandler("onClientResourceStart", g_ResRoot, UiInit)
addEventHandler("onClientResourceStop", g_Root, ResStop)
addEventHandler("onClientRender", g_Root, UiRender)
addEventHandler("onClientRestore", g_Root, UiRestore)
addEventHandler("onClientCursorMove", g_Root, UiCursorMove)
--addEventHandler("onClientMouseWheel", g_Root, UiMouseWheel)
addEventHandler("onClientClick", g_Root, UiClick)
addEventHandler("onClientCharacter", g_Root, outputPressedCharacter)
addEventHandler("onClientKey", g_Root, outputPressedKey)
