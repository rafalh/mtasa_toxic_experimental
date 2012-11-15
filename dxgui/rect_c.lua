UiRect = {}

function UiRect:CheckPt(x, y)
	return (x >= self.x and y >= self.y and x < self.x2 and y < self.y2)
end

function UiRect:Intersect(rc)
	assert(rc)
	local x = math.max(self.x, rc.x)
	local y = math.max(self.y, rc.y)
	local x2 = math.min(self.x2, rc.x2)
	local y2 = math.min(self.y2, rc.y2)
	if(x2 <= x or y2 <= y) then
		return UiRect:Create(0, 0, 0, 0)
	end
	return UiRect:Create(x, y, x2 - x, y2 - y)
end

UiRect.__mt = {__index = UiRect}

function UiRect:Create(x, y, w, h)
	local rc = setmetatable({
		x = x, y = y,
		w = w, h = h
	}, UiRect.__mt)
	rc.x2 = rc.x + rc.w
	rc.y2 = rc.y + rc.h
	return rc
end
