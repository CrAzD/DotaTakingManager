

-- Add value of resource to the entities pack
	-- This can be changed to be very robust and add multiple types of resources per taking event.

	-- However this is as simple as can been, seeing as this is all IslandDefense needs.
function TakingManager:EntityAddResourceToPack(entity, resource)
	entity['pack']['total'] = entity['pack']['total'] + resource['value']
	entity['pack'][resource['type']] = entity['pack'][resource['type']] + resource['value']

	return
end