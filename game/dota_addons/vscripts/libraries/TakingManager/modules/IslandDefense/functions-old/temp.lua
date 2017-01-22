

-- GLOBALS
TM_RESOURCE_CAPACITIES = {'gold' = 5, 'lumber' = 5, 'total' = 5}



-- ENTITY LOCALS TO MAKE SURE ARE CONFIGURED
entity['taking']['types'] = ['lumber', 'gold']
entity['taking']['animation']['**RESOURCE**']
entity['taking']['depo']
entity['taking']['node']
entity['taking']['searchRadius']['depo']
entity['taking']['depos']
depo['isDepo'] 
		entity:CastAbilityOnTarget(depo, entity['abilities']['taking_return_to_depo'], entity['id'])
		return
	else
		entity:CastAbilityOnTarget(entity, entity['abilities']['taking_sleep'], entity['id'])
**each entity needs to be giving the modifier_ for all resources upon configuration
	-- this goes into the npc.txt stuff
	('modifier_'..resource..'_stack_count') 
	isNode = true/false
	isTaker = true/false
		NodesHarvestable = 'lumber gold' --Seperated via space


-- EVENT->FUNCTIONS
function TakingManager:OnDepositSpellStart(data)
	local entity = data['caster'] 
	local depo = data['targer']

	if self:DepoGetViability(entity, depo) then
		self:EntityDepositPackContents(entity)
		self:EntityReturnToNode(entity)
	else
		self:DepoNotViable(entity)
	end
	return
end

function TakingManager:OnTakingChannelSucceeded(data)
	local entity = data['caster']
	local node = data['target']

	self:EntityAddResourceToPack(entity, node)

	if self:EntityIsPackFull(entity) then
		self:EntityReturnToDepo(entity)
	else
		self:EntityReturnToNode(entity)
	end
	return
end

function TakingManager:OnTakingSpellStart(data)
	local entity = data['caster']
	local node = data['target']

	if self:NodeGetViability(entity, node) then
		entity['taking']['node'] = node
		self:EntityBeginTakingAnimation(entity)
	else
		self:NodeNotViable(node)
	end
	return
end



-- EVENTS
function TakingManager:DepoGetViability(entity, depo)
	if depo and not depo:IsNull() and depo['isDepo'] == true and depo['id'] == entity['id'] and depo in entity['taking']['depos'] then
		return true
	else
		return false
	end
end

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

function TakingManager:EntityReturnToNode(entity, node)
	if self:NodeGetViability(node) then
		self:EntityTakeNode(entity, node)
	else
		node = self:EntityGetNewNode(entity)
		if self:NodeGetViability(node) then
			self:EntityTakeNode(entity, node)
		else
			self:EntityCannotFindNewNode(entity)
		end
	end
	return
end

function TakingManager:DepoNotViable(entity)
	local depo = self:EntityGetNewDepo(entity)
	if depo then
		entity['taking']['depo'] = depo
		self:EntityDepositPackContents(entity)
		self:EntityReturnToNode(entity)
	else
		self:EntityCannotFindNewDepo(entity)
	end
end

function TakingManager:NodeGetViability(node)
	if node and not node:IsNull() and node['isNode'] == true and node in entity['taking']['types'] then
		return true
	else
		return false
	end
end

function TakingManager:EntityGetNewDepo(entity)
	EntityManager:EntityUpdateVector(entity)

	local depoPrevious = entity['taking']['depo']
	entity['taking']['depo'] = nil

	if depoPrevious and depoPrevious['name'] then
		local depoList = Entities:FindAllByClassnameWithin(depoPrevious['name'], entity['vector'], entity['taking']['searchRadius']['depo'])
		local nearest = {
			['distance'] = -1
		}

		for i=0, #depoList do
			if depoList[i] then
				local depo = depoList[i]
				local distance = GridNav:FindPathLength(entity['vector'], depo['origin'])

				if distance < nearest['distance'] or nearest['distance'] == -1 then
					nearest['distance'] = distance
					nearest['depo'] = depo
				end
			end
		end
		return nearest['depo'] or nil
	else
		return nil
	end
	return nil
end

function TakingManager:EntityGetNewNode(entity)
	EntityManager:EntityUpdateVector(entity)

	local nodePrevious = entity['taking']['node']
	entity['taking']['node'] = nil

	if nodePrevious and nodePrevious['name'] then
		local nodeList = Entities:FindAllByClassnameWithin(nodePrevious['name'], entity['vector'], entity['taking']['searchRadius']['node'])
		local nearest = {
			['distance'] = -1
		}

		for i=0, #nodeList do
			if nodeList[i] then
				local node = nodeList[i]
				local distance = GridNav:FindPathLength(entity['vector'], node['origin'])

				if distance < nearest['distance'] or nearest['distance'] == -1 then
					nearest['distance'] = distance
					nearest['node'] = node
				end
			end
		end
		return nearest['node'] or nil
	else
		return nil
	end
	return nil
end

EntityCannotFindNewDepo
	--go to sleep
EntityCannotFindNewNode
	--return to depo without a node, look for new on there, go to sleep if cannot

--------------------

function TakingManager:EntityAddResourceToPack(entity, node)
	entity[node['type']] = entity[node['type']] + node['value']
	return
end

function TakingManager:EntityIsPackFull(entity)
	local total = 0
	for resource in entity['taking']['types'] do
		if entity['resource'] >= TM_RESOURCE_CAPACITIES[resource] then
			return true
		else
			total = total + entity['resource']
		end

		if total >= TM_RESOURCE_CAPACITIES['total'] then
			return true
		else
			return false
		end
	end
end

EntityReturnToDepo

EntityReturnToNode

function TakingManager:EntityTakeNode(entity, node)
	entity:CastAbilityOnTarget(node, self:EntityGetTakingAbility(entity), entity['id'])
end

function TakingManager:EntityGetTakingAbility(entity)
	--figure out how I'm going to grab the correct ability
	ability = nil
	return ability
end

--------------------

function TakingManager:EntityBeginTakingAnimation(entity, node)
	for resource in entity['taking']['types']
		if entity[resource] > 0 then
			entity:SetModifierStackCount(('modifier_'..resource..'_stack_count'), entity, entity[resource])
		end
	end
	entity:StartGesture(entity['taking']['animation'][entity['node']['type']])
	return
end

function TakingManager:NodeNotViable(entity)
	local depo = self:EntityGetNewDepo(entity)
	if depo then
		entity:CastAbilityOnTarget(depo, entity['abilities']['taking_return_to_depo'], entity['id'])
		return
	else
		entity:CastAbilityOnTarget(entity, entity['abilities']['taking_sleep'], entity['id'])
		return
	end
end


-------------------

ConfigureTakingEntity
	if EntityManager['KV_FILES'][entity['name']]['NodesHarvestable'] then
		split them by space and add them as types
ConfigureNode
ConfigureDepo  --maybe