RoomSelectGui = {}
RoomSelectGui.__mt = {__index = RoomSelectGui}
addEvent("main_onSelectRoomReq", true)

function RoomSelectGui:destroy()
	dxDelete(self.wnd)
	guiSetInputEnabled(false)
	showCursor(false)
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
	local w, h = 200, 100 + (math.max(math.ceil(#rooms/2),1)) * 110
	local pw = (math.max(math.ceil(#rooms/2),1)) * 215
	local x, y = (g_ScrW - pw)/2, (g_ScrH - h)/2
	self.wnd = dxCreateWindow(x, y, pw, h, "Select room")
	local pos = {x=0,y=0}
	for i, room in ipairs(rooms) do
		local title = getElementData(room, "title") or getElementID(room)
		local roomBtn = dxCreateTile(10+(pos.x*(w+10)), 35+(pos.y)*110, w, 100,"img/register.png",title, self.wnd)--dxCreateButton(10, i*30, w - 20, 25, title, self.wnd)
		pos.x = pos.x + 1
		if pos.x > 1 then
			pos.x = 0
			pos.y = pos.y + 1
		end
		addEventHandler("onDxGUIClick", roomBtn, function(btn,state)
			if btn == "left" and state == "up" then
				self:onRoomBtnClick(room)
			end
		end, false)
	end
	
	local closeBtn = dxCreateButton(pw - 80 - 10, h - 25 - 10, 80, 25, "Close", self.wnd)
	addEventHandler("onDxGUIClick", closeBtn, function(btn,state)
		if btn == "left" and state == "up" then
			self:destroy()
		end
	end, false)
	
	guiSetInputEnabled(true)
	showCursor(true)
	return self
end

addEventHandler("main_onSelectRoomReq", g_ResRoot, RoomSelectGui.create)
