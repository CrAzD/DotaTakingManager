

-- Verify that the node still exists and that it is actually a node, and that the entity is allowed to take from it before allowing the entity to take from it.
function TakingManager:NodeGetViability(entity, node)
	if node and not node:IsNull() and node['isNode'] == true and entity['taking']['allowed'][node['name']] == true then
		return true
	else
		return false
	end
end