



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

	if TakingManager:EntityCheckCarryCapacity(entity) then
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

function TakingManager:DepoGetEntity(entity)
	local depo = entity['depo'] or nil
	if depo and not depo:IsNull() then
		return depo
	else
		return(self:DepoLocateWithinRange(entity))
	end
end





--[[
	Functions below here are all for the most basic methods of taking.
]]--
function TakingManager:ResourceGetAmountTaken(resource)
	return resource['takingValue']
end

function TakingManager:ResourceAddToEntityPack(entity, amount)
	entity['pack'] = entity['pack'] + amount

	return true
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