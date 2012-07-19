cache = {}
resolution = {guiGetScreenSize()}


function onStart(res)
	if res ~= getThisResource() then return end
	local functostart =
	{
		onMainPanelStart,
		onGuiStatystykiStart,
		onGuiRadioStart
	}
	for k,v in ipairs(functostart) do
		if v then
			v()
		end
	end
end

function onStop(res)
	if res ~= getThisResource() then return end
	local functostop = 
	{
		onGuiRadioStop
	}
	for k,v in ipairs(functostop) do
		if v then
			v()
		end
	end
end

function onRender()
	local functiontorender =
	{
		onGuiStatystykiRender
	}
	for k,v in ipairs(functiontorender) do
		if v then
			v()
		end
	end
	--dxDrawLine(resolution[1]/2,0,resolution[1]/2,resolution[2],tocolor(255,0,255))
	--dxDrawLine(0,resolution[2]/2,resolution[1],resolution[2]/2,tocolor(255,0,255))
end

function onClick(button,state,absoluteX,absoluteY)
	onGuiStatystykiClick(source,button,state,absoluteX,absoluteY)
	onGuiRadioClick(source,button,state,absoluteX,absoluteY)
end

addEventHandler("onClientRender",getRootElement(),onRender)
addEventHandler("onClientResourceStart",getRootElement(),onStart)
addEventHandler("onClientResourceStop",getRootElement(),onStop)
addEventHandler("onClientGUIClick",getResourceRootElement(getThisResource()),onClick)