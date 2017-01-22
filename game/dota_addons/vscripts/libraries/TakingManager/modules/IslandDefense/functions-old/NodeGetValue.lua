

-- Return a table of resource value(s)
	-- This allows for multiple resources given from a single node.
	-- This allows for developers to manipulate how much of a resource an entity can get per taking. (Add RNG/Levels/Efficientcy/Etc).
	-- This allows for extra chance at resources off a node.
	-- This allows for developers to add bonus resources to drop from a node, IE: a gem from an iron node.

	-- Currently it is as basic as it can be, seeing as this is all IslandDefense calls for.
function TakingManager:NodeGetValue(node)
	return {['type'] = node['type'], ['value'] = node['value']}
end