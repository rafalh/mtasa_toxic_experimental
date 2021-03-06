function dxCreateWindow(x,y,sx,sy,text)
	local wnd = UiWindow:Create(x,y,sx,sy,text)
	addChildToResource(sourceResource,wnd)
	cache.elementToClass[wnd.el] = wnd
	return wnd.el
end

function dxCreateButton(x,y,sx,sy,text,wnd)
	local btn = UiButton:Create(x,y,sx,sy,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[btn.el] = btn
	addChildToResource(sourceResource,btn)
	return btn.el
end

function dxButtonSetType(element,type,datas)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxbtn" then
		el:setType(type,datas)
	end
end

function dxEditSetDefaultText(element,text)
	local el = cache.elementToClass[element]
	if el then
		el:setDefaultText(text)
	end
end

function dxCheckBoxGetSelected(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getChecked()
	end
	return false
end

function dxCheckBoxSetSelected(element,state)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxcheck" then
		el:setChecked(state)
	end
end

function dxCreateMemo(x,y,sx,sy,text,wnd)
	local Memo = UiMemo:Create(x,y,sx,sy,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[Memo.el] = Memo
	addChildToResource(sourceResource,Memo)
	return Memo.el
end

function dxCreateEdit(x,y,sx,sy,text,wnd)
	local element = UiEdit:Create(x,y,sx,sy,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreateCheckBox(x,y,sx,sy,text,checked,wnd)
	local element = UiCheckbox:Create(x,y,sx,sy,text,checked,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreateImage(x,y,sx,sy,src,wnd)
	local image = UiImage:Create(x,y,sx,sy,":"..getResourceName(sourceResource).."/"..src,cache.elementToClass[wnd] or nil)
	cache.elementToClass[image.el] = image
	addChildToResource(sourceResource,image)
	return image.el
end

function dxCreateLabel(x,y,sx,sy,text,wnd)
	local element = UiText:Create(x,y,sx,sy,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreateProgressBar(x, y, sx, sy,wnd)
	local element = UiProgress:Create(x, y, sx, sy,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreateGridList(x, y, sx, sy,wnd)
	local element = UiGridList:Create(x, y, sx, sy,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreateRadioButton(x, y, sx, sy,text,wnd)
	local element = UiRadio:Create(x, y, sx, sy,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreateScrollBar(x, y, sx, sy,horizontal,wnd)
	local element = UiScrollBar:Create(x, y, sx, sy,horizontal,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxRadioButtonSetSelected(element,bool)
	local el = cache.elementToClass[element]
	if el then
		el:setSelected(bool)
	end
end

function dxRadioButtonGetSelected(element)
	local el = cache.elementToClass[element]
	if el then
		return el:isSelected()
	end
	return false
end

function dxScrollBarSetScrollPosition(element,int)
	local el = cache.elementToClass[element]
	if el then
		el:getScrollPos(int)
	end
end

function dxSetElementProperty(element,...)
	local el = cache.elementToClass[element]
	if el then
		el:setProperty(...)
	end
end

function dxScrollBarGetScrollPosition(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getScrollPos()
	end
	return false
end

function dxGridListAddColumn(element,name,size)
	local el = cache.elementToClass[element]
	if el then
		return el:addColumn(name,size)
	end
	return false
end

function dxGridListaddValToColumn(element,col,text)
	local el = cache.elementToClass[element]
	if el then
		return el:addValToColumn(col,text)
	end
	return
end

function dxGridListGetRowCount(element,col)
	local el = cache.elementToClass[element]
	if el then
		return el:getItemCount(col)
	end
	return false
end

function dxGridListRemoveRow(element,col,idx)
	local el = cache.elementToClass[element]
	if el then
		el:deleteItem(col,idx)
	end
end

function dxGridListClearColumn(element,col)
	local el = cache.elementToClass[element]
	if el then
		el:clearColumn(col,idx)
	end
end

function dxGridListGetSelectedItem (element)
	local el = cache.elementToClass[element]
	if el then
		return el:getSelectedItem()
	end
	return false
end

function dxGridListGetItemText(element,col,idx)
	local el = cache.elementToClass[element]
	if el then
		return el:getItemText(col,idx)
	end
	return false
end

function dxCreateComboBox(x, y, sx, sy,text,wnd)
	local element = UiComboBox:Create(x, y, sx, sy,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxCreatePanel(x, y,sx,sy,wnd)
	local element = UiPanel:Create(x, y,sx,sy,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxComboBoxAddItem(element,item)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxcombobox" then
		el:addItem(item)
	end
end

function dxComboBoxDeleteAllItem(element)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxcombobox" then
		el:deleteAllItem()
	end
end

function dxCreateTile(x, y, sx, sy,src,text,wnd)
	local element = UiTile:Create(x, y, sx, sy,":"..getResourceName(sourceResource).."/"..src,text,cache.elementToClass[wnd] or nil)
	cache.elementToClass[element.el] = element
	addChildToResource(sourceResource,element)
	return element.el
end

function dxProgressBarGetProgress(element)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxprogress" then
		return el:getProgress()
	end
	return false
end

function dxProgressBarSetProgress(element,progress)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxprogress" then
		el:setProgress(progress)
	end
end

function dxGetVisible(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getVisible()
	end
	return false
end

function dxEditSetMasked(element,bool)
	local el = cache.elementToClass[element]
	if el and getElementType(element) == "dxEdit" then
		el:setIsPassword(bool)
	end
	return false
end

function dxSetBackground(element,r,g,b,a)
	local el = cache.elementToClass[element]
	if el then
		el:setBackgroud(r,g,b,a)
	end
end

function dxSetScale(element,int)
	local el = cache.elementToClass[element]
	if el then
		el:setScale(int)
	end
end

function dxGetText(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getText()
	end
	return false
end

function dxGetPosition(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getPosition()
	end
	return false
end

function dxSetVisible(element,bool)
	local el = cache.elementToClass[element]
	if el then
		el:setVisible(bool)
	end
end

function dxSetText(element,text)
	local el = cache.elementToClass[element]
	if el then
		el:setText(text)
	end
end

function dxSetLabelAlign(element,horizontal,vertical)
	local el = cache.elementToClass[element]
	if el then
		el:SetAlign(horizontal,vertical)
	end
end

function dxGetFontSize(size,text)
	return getFontSize(size,text)
end

function dxSetColor(element,r,g,b,a)
	local el = cache.elementToClass[element]
	if el then
		el:setColor(r,g,b,a)
	end
end

function dxSetSize(element,x,y)
	local el = cache.elementToClass[element]
	if el then
		el:setSize(x,y)
	end
end

function dxGetSize(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getSize()
	end
end

function dxGetEnabled(element)
	local el = cache.elementToClass[element]
	if el then
		return el:getEnabled()
	end
end

function dxSetEnabled(element,bool)
	local el = cache.elementToClass[element]
	if el then
		el:setEnabled(bool)
	end
end

function dxDelete(element)
	local el = cache.elementToClass[element]
	if el then
		el:delete()
	end
end

function dxSetPosition(element,x,y)
	local el = cache.elementToClass[element]
	if el then
		el:setPosition(x,y)
	end
end

function dxSetImage(element,src,bool)
	local el = cache.elementToClass[element]
	if el then
		el:setImage(":"..getResourceName(sourceResource).."/"..src,bool)
	end
end

function dxBringToFont(element)
	local el = cache.elementToClass[element]
	if el then
		dxMoveToFont(el)
	end
end

function getDxFont()
	return cache.Font
end