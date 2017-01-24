

--
function TakingManager:EntityReturnToNode(entity, node)
	if TakingManager:NodeIsViable(node) then
	else
		node = TakingManager:EntityGetNewNode(entity)
		if node then
			entity['taking']['node'] = node
			TakingManager:EntityTakeNode(entity, node)
		else
			TakingManager:EntityCannotFindNearbyNode(entity)
		end
	end
	return
end