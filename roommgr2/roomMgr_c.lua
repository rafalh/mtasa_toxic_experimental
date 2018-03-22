addEvent('onClientPlayerEnterRoom', true)
addEvent('onClientPlayerLeaveRoom', true)

addEvent('_room_onWorldSettingChange', true)
addEventHandler('_room_onWorldSettingChange', g_resourceRoot, function (setFnName, ...)
	if setFnName:match('^set%w+$') or setFnName:match('^reset%w+$') then
		outputDebugString(setFnName..' in '..getResourceName(g_resource), 3)
		_G[setFnName](...)
	else
		outputDebugString('Match failed for '..setFnName..'! Hacking attempt?', 2)
	end
end, false)

addEventHandler('onClientResourceStart', resourceRoot, function ()
    triggerServerEvent('onReady', resourceRoot)
end, false)
