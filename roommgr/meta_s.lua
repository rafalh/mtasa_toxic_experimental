Meta = {}
Meta.__mt = {__index = Meta}

function Meta:removeClientFiles()
	local files = {script = {}, file = {}, config = {}, map = {}}
	
	for i, subnode in ipairs(xmlNodeGetChildren(self.node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		local clientFile = false
		if((name == "script" or name == "config") and attr.src and attr.type == "client") then
			clientFile = true
		elseif((name == "file" or name == "map") and attr.src) then
			clientFile = true
		end
		
		if(clientFile) then
			table.insert(files[name], attr.src)
			xmlDestroyNode(subnode)
			self.changed = true
		end
	end
	
	return files
end

function Meta:removeServerSideScripts()
	local scripts = {}
	for i, subnode in ipairs(xmlNodeGetChildren(self.node)) do
		local name = xmlNodeGetName(subnode)
		local attr = xmlNodeGetAttributes(subnode)
		
		if(name == "script" and attr.src and attr.type ~= "client") then
			table.insert(scripts, attr.src)
			xmlDestroyNode(subnode)
			self.changed = true
		end
	end
	
	return scripts
end

function Meta:addScript(src, type)
	local subnode = xmlCreateChild(self.node, "script")
	xmlNodeSetAttribute(subnode, "src", src)
	if(type) then
		xmlNodeSetAttribute(subnode, "type", type)
	end
	self.changed = true
end

function Meta:getInfo()
	assert(self.node)
	local subnode = xmlFindChild(self.node, "info", 0)
	if(not subnode) then return false end
	
	local info = xmlNodeGetAttributes(subnode)
	return info
end

function Meta:getSettings()
	assert(self.node)
	local subnode = xmlFindChild(self.node, "settings", 0)
	if(not subnode) then return false end
	
	local settings = {}
	
	for i, settingNode in ipairs(xmlNodeGetChildren(subnode)) do
		local name = xmlNodeGetName(settingNode)
		local attr = xmlNodeGetAttributes(settingNode)
		
		if(name == "setting" and attr.name and attr.value) then
			local k = attr.name:gsub("^[#%*]", "")
			local v = fromJSON(attr.value) or attr.value
			settings[k] = v
		end
	end
	
	return settings
end

function Meta:destroy()
	if(self.changed) then
		xmlSaveFile(self.node)
		self.changed = false
	end
	
	xmlUnloadFile(self.node)
	self.node = false
end

function Meta.create(path)
	local node = xmlLoadFile(path)
	if(not node) then
		outputDebugString("Failed to load meta", 1)
		return false
	end
	
	local self = setmetatable({}, Meta.__mt)
	self.node = node
	return self
end
