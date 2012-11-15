DxImg = {}
DxImg.__mt = {__index = DxImg}

function DxImg:render()
	dxDrawImage(self.x, self.y, self.w, self.h, self.tex)
end

function DxImg:setPos(x, y)
	self.x = x
	self.y = y
end

function DxImg.create(path, x, y)
	local self = setmetatable({}, DxImg.__mt)
	self.x = x or 0
	self.y = y or 0
	
	self.tex = dxCreateTexture(path, "argb", false)
	self.w, self.h = dxGetMaterialSize(self.tex)
	return self
end
