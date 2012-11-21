local g_Root = getRootElement()
local DM_VEHICLES = {
	[425] = true, -- Hunter
	[520] = true, -- Hydra
	[464] = true, -- RC Baron
}

-- Pickups CLASS
Pickups = {}

addEvent("race_onPlayerPickup", true)

function Pickups:onMapStart()
	local pickups = getRoomMapElements(self.game.room, "racepickup")
	self.map = {}
	for i, pickup in ipairs(pickups) do
		if(pickup.id and pickup.type) then
			pickup.vehicle = tonumber(pickup.vehicle)
			self.map[pickup.id] = pickup
		end
	end
end

function Pickups:onMapStop()
	self.map = {}
end

function Pickups:onPlayerPickup(player, id)
	if(not player.alive) then return end
	
	local pickup = self.map[id]
	if(not pickup) then return end
	
	local veh = player:getVehicle()
	if(not veh) then return end
	
	playSoundFrontEnd(player.el,46)
	if(pickup.type == "nitro") then
		removeVehicleUpgrade(veh, 1010)
		addVehicleUpgrade(veh, 1010)
	elseif(pickup.type == "repair") then
		fixVehicle(veh)
	elseif(pickup.type == "vehiclechange" and pickup.vehicle) then
		setElementModel(veh, pickup.vehicle)
		if(self.game.isDM and DM_VEHICLES[pickup.vehicle]) then
			self.game:onPlayerFinish(player)
		end
	end
end

function Pickups:destroy()
	self.map = {}
	self.game = false
end

function Pickups.create(game)
	local self = setmetatable({}, Pickups.__mt)
	self.game = game
	return self
end

Pickups.__mt = {__index = Pickups}

addEventHandler("race_onPlayerPickup", g_Root, function(id)
	local player = Player.elMap[source]
	local game = player and player.game
	if(not game) then return end
	
	game.pickups:onPlayerPickup(player, id)
end)

