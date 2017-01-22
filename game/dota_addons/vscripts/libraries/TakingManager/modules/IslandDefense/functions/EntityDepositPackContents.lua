

--
function TakingManager:EntityDepositPackContents(entity)
	local player = entity['owningPlayer']

	for resource in entity['taking']['types'] do
		if entity[resource] > 0 then
			player[resource] = player[resource] + entity[resource]
			self:PopupDeposit(resource, entity[resource])
			CustomGameEventManager:Send_ServerToPlayer(player, ('player_'..resource..'_changed', {entity[resource]}))
			entity[resource] = 0
		end
	end
	return
end