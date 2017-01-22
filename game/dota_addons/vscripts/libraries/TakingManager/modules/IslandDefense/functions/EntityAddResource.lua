

--
function TakingManager:EntityAddResource(entity, node)
	entity[node['type']] = entity[node['type']] + node['value']
	return
end
