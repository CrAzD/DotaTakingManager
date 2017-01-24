

--
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