

-- GLOBALS
TM_RESOURCE_CAPACITIES = {'gold' = 5, 'lumber' = 5, 'total' = 5}
TM_SEARCH_RADIUS = {'depo' = 500, 'node' = 500}







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


--------------------
ConfigureTakingEntity
	if EntityManager['KV_FILES'][entity['name']]['NodesHarvestable'] then
		split them by space and add them as types
ConfigureNode
ConfigureDepo  --maybe