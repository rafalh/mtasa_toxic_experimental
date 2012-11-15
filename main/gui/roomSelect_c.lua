RoomSelectGui = {}
RoomSelectGui.__mt = {__index = RoomSelectGui}

addEvent("main_onSelectRoomReq", true)

function RoomSelectGui:destroy()
	destroyElement(self.wnd)
	guiSetInputEnabled(false)
end

function RoomSelectGui:onRoomBtnClick(room)
	if(isElement(room)) then
		setCurrentRoom(room)
		self:destroy()
	else
		outputDebugString("Invalid room", 1)
	end
end

function RoomSelectGui.create()
	local self = setmetatable({}, RoomSelectGui.__mt)
	
	local rooms = getRooms()
	local w, h = 200, 100 + #rooms * 30
	local x, y = (g_ScrW - w)/2, (g_ScrH - h)/2
	self.wnd = guiCreateWindow(x, y, w, h, "Select room", false)
	
	for i, room in ipairs(rooms) do
		local title = getElementData(room, "title") or getElementID(room)
		local roomBtn = guiCreateButton(10, i*30, w - 20, 25, title, false, self.wnd)
		addEventHandler("onClientGUIClick", roomBtn, function()
			self:onRoomBtnClick(room)
		end, false)
	end
	
	local closeBtn = guiCreateButton(w - 80 - 10, h - 25 - 10, 80, 25, "Close", false, self.wnd)
	addEventHandler("onClientGUIClick", closeBtn, function()
		self:destroy()
	end, false)
	
	guiSetInputEnabled(true)
	return self
end

addEventHandler("main_onSelectRoomReq", g_ResRoot, RoomSelectGui.create)
