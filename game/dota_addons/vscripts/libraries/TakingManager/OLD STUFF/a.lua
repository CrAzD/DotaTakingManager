

entity['taking'] = {
	['depo'] = {},
	['node'] = {},
	['searchRadius'] = {
		['node'] = 2500,
		['depo'] = 2500
	}
}

function TakingManager:EntityReturnToDepo(entity)
	if TakingManager:DepoIsViable(entity['taking']['depo']) then
		if entity['taking']['depo'] and not entity['taking']['depo']:IsNull() then
		else
		end
	else
		local tDepo = TakingManager:EntityLocateNewDepo(entity)
		if tDepo then
		else
			TakingManager:EntityCannotFindNearbyDepo(entity)
		end
	end

	return
end

function TakingManager:EntityLocateNewDepo(entity)
	EntityManager:EntityUpdateVector(entity)

	local oldDepo = entity['taking']['depo']
	entity['taking']['depo'] = nil

	if oldDepo and oldDepo['name'] then
		local depos = Entities:FindAllByClassnameWithin(oldDepo['name'], entity['vector'], entity['taking']['searchRadius']['depo'])
		if depos and #depos > 0 then
			local nearest = {
				['distance'] = 9999999999999999999999999999999999999999999999999999999999999999999999999999
			}

			for i=0, #depos do
				if depos[i] then
					local depo = depos[i]
					local distance = GridNav:FindPathLength(entity['vector'], depo['origin'])
					
					if distance < nearest['distance'] and GridNav:CanFindPath(entity['vector'], depo['origin']) then
						nearest['distance'] = distance
						nearest['depo'] = depo
					end
				end
			end

			return nearest['depo'] or nil
		end
	else
		return nil
	end
end

function TakingManager:EntityCannotFindNearbyDepo(entity)
	entity:CastAbilityOnTarget(entity, entity['abilities']['taking_sleep'], entity['id'])	
end

function OnTakingSucceeded(data)
	-- Finished taking X resources
		-- Add node value to pack contents
		-- CHECK if pack is at capacity
			-- If so CHECK if depo is still alive
				-- If so return to depo
					-- Deposit Contents
					-- CHECK if resource node is viable
						-- If so cast taking ability on node
						-- If NOT run EntityLocateNewNode on entity
							-- If so cast taking ability on node
							-- If NOT SLEEP
				-- If NOT search for another nearby depo (within max range)
					-- If SO return to depo
						-- Deposit Contents
						-- CHECK if resource node is viable
							-- If so cast taking ability on node
							-- If NOT run EntityLocateNewNode on entity
								-- If so cast taking ability on node
								-- If NOT SLEEP
					-- If NOT SLEEP
	local entity = data['caster']
	local node = data['target']

	-- Get node value and add it to pack contents
	TakingManager:PackAddResource(entity, TakingManager:ResourceGetValue(node))

	if TakingManager:PackIsFull(entity) then
		TakingManager:EntityReturnToDepo(entity)
	else
		TakingManager:EntityReturnToNode(entity, node)
	end

	return
end

function TakingManager:PackAddResource(entity, resource)
	entity['pack']['amount'] = entity['pack']['amount'] + resource['value']

	return
end

function TakingManager:ResourceGetValue(node)
	return {['name'] = node['name'], ['value'] = node['value']}
end

function TakingManager:PackIsFull(entity)
	if entity['pack']['amount'] >= entity['pack']['capacity'] then
		return true
	else
		return false
	end
end

function TakingManager:EntityReturnToDepo(entity)
end

function TakingManager:EntityReturnToNode(entity, node)
	if TakingManager:NodeIsViable(node) then
		TakingManager:EntityTakeNode(entity, node)
	else
		tNode = TakingManager:EntityLocateNewNode(entity)
		if tNode then
			TakingManager:EntityTakeNode(entity, tNode)
		else
			TakingManager:EntityCannotFindNearbyNode(entity)
		end
	end

	return
end

function TakingManager:NodeIsViable(node)
	if node and not node:IsNull() then
		return true
	else
		return false
	end
end

function TakingManager:EntityTakeNode(entity, node)
	entity['taking']['node'] = node
	entity:CastAbilityOnTarget(node, entity['abilities']['resource_taking'], entity['id'])
return

function TakingManager:EntityLocateNewNode(entity)
	EntityManager:EntityUpdateVector(entity)

	local oldNode = entity['taking']['node']
	entity['taking']['node'] = nil

	if oldNode and oldNode['name'] then
		local nodes = Entities:FindAllByClassnameWithin(oldNode['name'], entity['vector'], entity['taking']['searchRadius']['node'])
		if nodes and #nodes > 0 then
			local nearest = {
				['distance'] = 999999999999999999999999999999999999999999999999999999999999999999999999
			}

			for i = 0, #nodes do
				if nodes[i] then
					local node = nodes[i]
					local distance = GridNav:FindPathLength(entity['vector'], node['origin'])

					if distance < nearest['distance'] and GridNav:CanFindPath(entity['vector'], node['origin']) then
						nearest['distance'] = distance
						nearest['node'] = node
					end
				end
			end

			return nearest['node'] or nil
		end
	else
		return nil
	end
end

function TakingManager:EntityCannotFindNearbyNode(entity)
	entity:CastAbilityOnTarget(entity, entity['abilities']['taking_sleep'], entity['id'])
end


--[[
	OnTakingSucceeded
		It's the ability_channel_succeeded event, in the ability kv file.
		Each function has multiple variations, but only one variation will be loaded at the beginning of the game.
			For Example ResourceAddToEntityPack()
				Simple Variation:: Just add the amount taken to the current pack.
				Size Variation:: Each unit of resource has a size attached to it. Once the unit's pack is full (size not weight wise), drop all remaining resources on the ground as physical items.
				Weight Variation:: Each unit of resource has a weight tied to it. Once taking entity has reached weight capacity, drop all remaining resources on the ground as a physical item.
				Weight+Size Variation:: Each unit of resource has a size and weight. Once either has reached capacity drop all remaining resources on the ground as a physical item.

]]--
function OnTakingSucceeded(data)
	local entity = data['caster']
	local resource = data['target']

	TakingManager:ResourceAddToEntityPack(entity, TakingManager:ResourceGetAmountTaken(resource))

	if TakingManager:PackIsAtCapacity(entity) then
		local depo = 
		entity:CastAbilityOnTarget(TakingManager:DepoGetEntity(entity), entity['abilities']['resource_deposit'], entity['id'])
	else
		local node = TakingManager:ResourceNodeLocate(entity)
		if node then
			entity:CastAbilityOnTarget(node, entity['abilities']['resource_take'], entity['id'])
		else
			TakingManager:EntityFailedToFindNodeAI(entity)
		end
	end

	return
end


--[[
	Functions below here are all for the most basic method of taking.
]]--
function TakingManager:ResourceAddToEntityPack(entity, amount)
	entity['pack']['current'] = entity['pack']['current'] + amount

	return
end

function TakingManager:ResourceGetAmountTaken(resource)
	return resource['value']
end

function TakingManager:PackIsAtCapacity(entity)
	if entity['pack']['current'] >= entity['pack']['capacity'] then
		return true
	else
		return false
	end
end

function TakingManager:DepoGetEntity(entity)
	local depo = entity['depo'] or nil
	if depo and not depo:IsNull() then
		return depo
	else
		return(self:DepoLocateWithinRange(entity))
	end
end

function TakingManager:ResourceNodeLocate(entity)
	if entity['node'] and not entity['node']:IsNull() then
		return entity['node']
	else
		return nil
	end
end

function TakingManager:EntityFailedToFindNodeAI(entity)
	local depo = TakingManager:DepoGetEntity(entity)
	if depo then
		entity:CastAbilityOnTarget(depo, entity['abilities']['depo_find_new_node'], entity['id'])

		return
	else
		entity:CastAbilityOnTarget(entity, entity['abilities']['self_sleep'], entity['id'])

		return
	end
end


--[[------------------------------------------------------------------------------
    OnHarvestChannelSucceeded
    	Once the peasant has finished channeling the harvest ability
    		Add 1 to harvest count
    		Check if full or if to keep harvesting
    			if full return to shelter, drop off lumber, and return to harvest
------------------------------------------------------------------------------]]--
function OnHarvestChannelSucceeded(data)
	local harvester = data['caster']
	local tree = data['target']

	harvester['harvest'] = harvester['harvest'] + 1
	harvester:SetModifierStackCount('modifier_has_lumber', harvester, harvester['harvest'])

	if harvester['harvest'] >= 5 then
		harvester:CastAbilityOnTarget(GetShelter(harvester), harvester.ability['deposit_lumber'], harvester['id'])
	else
		if GetTree(harvester) then
			harvester:CastAbilityOnTarget(harvester['tree'], harvester.ability['harvest'], harvester['id'])
		else
			harvester:CastAbilityOnTarget(GetShelter(harvester), harvester.ability['deposit_lumber'], harvester['id'])
		end
	end
end


--[[------------------------------------------------------------------------------
    OnHarvestSpellStart
    	This is for when the harvest starts channeling the harvest ability
    	Check if the tree has been configured
    		if not configure it
    	Set tree has harvesters tree
    	Start harvesting animation
------------------------------------------------------------------------------]]--
function OnHarvestSpellStart(data)
	local harvester = data['caster']
	local tree = data['target']

	if tree and not tree['configured'] then
		TreeConfigure(tree)
	end

	harvester:SetModifierStackCount('modifier_has_lumber', harvester, harvester['harvest'])

	harvester['tree'] = tree
	harvester['treeOrigin'] = tree['origin']
	
	harvester:StartGesture(ACT_DOTA_ATTACK)
end


--[[------------------------------------------------------------------------------
    OnDepositSpellStart
    	Increase lumber for player
    	Display popup
    	Reset peasant harvesting variables
    	Attempt to return to tree and contiue harvesting
    		else just sleeps
------------------------------------------------------------------------------]]--
function OnDepositSpellStart(data)
	local harvester = data['caster']
	local player = harvester.owners['player']

	player['lumber'] = player['lumber'] + harvester['harvest']
	PopupLumber(harvester, (harvester['harvest'] * 5))
	CustomGameEventManager:Send_ServerToPlayer(player, 'player_lumber_changed', {lumber = math.floor(player['lumber'])})

	harvester['harvest'] = 0
	harvester:SetModifierStackCount('modifier_has_lumber', harvester, harvester['harvest'])

	if GetTree(harvester) then
		harvester:CastAbilityOnTarget(harvester['tree'], harvester.ability['harvest'], harvester['id'])
	end
end


--[[------------------------------------------------------------------------------
    TreeConfigure
    	Set variables inside the tree
------------------------------------------------------------------------------]]--
function TreeConfigure(tree)
	tree['index'] = tree:GetEntityIndex()
	tree['origin'] = tree:GetAbsOrigin()
	tree['configured'] = true
end


--[[------------------------------------------------------------------------------
    GetTree
    	Check if tree is still there
    		else return false
------------------------------------------------------------------------------]]--
function GetTree(harvester)
	tree = harvester['tree']
	if tree and IsValidEntity(tree) and not tree:IsNull() then
		return(true)
	else
		return(false)
	end
end


--[[------------------------------------------------------------------------------
    GetShelter
    	Check if shelter is still there
    		if so return true
    	If shelter is gone search for a new one, if none can be found return false
    		if can be found set the new shelter info for the peasant and return true
------------------------------------------------------------------------------]]--
function GetShelter(harvester)
	local shelter = harvester['shelter']

	if shelter and IsValidEntity(shelter) and not shelter:IsNull() then
		return(shelter)
	else
		if #harvester['sheltersNearby'] > 0 then
			local closest = {['length'] = -1, ['entity'] = nil}
			for k, v in harvester['sheltersNearby'] do
				local distance = GridNav:FindPathLength(harvester:GetAbsOrigin(), v['origin'])
				if closest['length'] == -1 or distance < closest['length'] then
					closest['length'] = distance
					closest['entity'] = v
				end
			end
			if closest['length'] ~= -1 then
				harvester['shelter'] = closest['entity']
				return(shelter)
			else
				return(harvester)
			end
		else
			return(harvester)
		end
	end
end


--[[------------------------------------------------------------------------------
    BuildWorker
    	Spawn the peasant
    	Check if the harvesting ability needs to be upgraded
------------------------------------------------------------------------------]]--
function HarvestConfigurePeasant(data)
	local caster = data['caster']
	local player = data.caster.owners['player']
	local unit = IdFunk:CreateUnit('unit-peasant', 'peasant', 2, caster:GetAbsOrigin(), caster, player)
	local upgrade = 0

	unit.owners['unit'] = caster
	unit['shelter'] = caster

	for i=1, 4 do
		if player.upgrades['research_harvest_lumber_imp_'..tostring(i)] == 1 then
			upgrade = i
		end
	end

	if upgrade > 0 then
		local oldAbility = unit.ability['harvest']
		local newName = 'research_harvest_lumber_imp_'..tostring(upgrade)

		unit:RemoveAbility('harvest_lumber_base')
		unit:AddAbility(newName):UpgradeAbility(true)

		local abi = unit:FindAbilityByName(newName)
		unit.ability['harvest'] = abi
		unit.ability[oldAbility['position']] = abi
		unit.ability[oldAbility['name']] = nil
		unit.ability[newName] = abi
	end
end