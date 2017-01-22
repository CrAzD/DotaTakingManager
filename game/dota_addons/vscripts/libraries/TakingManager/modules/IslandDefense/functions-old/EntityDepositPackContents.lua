


function TakingManager:EntityDepositPackContents(entity)
	local player = entity['owningPlayer']

	player['lumber'] = player['lumber'] + entity['lumber']
	player['gold'] = player['lumber'] + entity['gold']

	if entity['lumber'] > 0 then
		TakingManager:PopupDeposit('lumber', entity['lumber'])
		CustomGameEventManager:Send_ServerToPlayer(player, 'player_lumber_changed', {entity['lumber']})
	end
	if entity['gold'] > 0 then
		TakingManager:PopupDeposit('gold', entity['gold'])
		CustomGameEventManager:Send_ServerToPlayer(player, 'player_gold_changed', {entity['gold']})
	end

	entity['lumber'] = 0
	entity['gold'] = 0

	return
end