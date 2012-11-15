local g_ScrW, g_ScrH = guiGetScreenSize()

function onRender()
	assert(Transfer.bytesDone <= Transfer.bytesToDo)
	if(Transfer.bytesDone == Transfer.bytesToDo) then return end
	
	local progress = Transfer.bytesDone / Transfer.bytesToDo
	local w, h = 400, 40
	local x, y = (g_ScrW - w)/2, g_ScrH - h - 100
	dxDrawRectangle(x, y, progress*w, h, tocolor(64, 0, 255, 64))
	dxDrawRectangle(x + progress*w, y, (1 - progress)*w, h, tocolor(255, 196, 0, 64))
	dxDrawText(math.floor(progress*100).."%", x, y, x + w, y + h, tocolor(255, 255, 255), 1, "bankgothic", "center", "center")
end

addEventHandler("onClientRender", root, onRender)