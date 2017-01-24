

--
function TakingManager:EntityReturnToNode(entity, node)
	if self:NodeGetViability(node) then
		entity:CastAbilityOnTarget(node, self:EntityGetAbility(entity, 'taking_'..(node['type'])), entity['id'])
	else
		node = self:EntityGetNewNode(entity)
		if self:NodeGetViability(node) then
			entity:CastAbilityOnTarget(node, self:EntityGetAbility(entity, 'taking_'..(node['type'])), entity['id'])
		else
			self:EntityCannotFindNewNode(entity)
		end
	end
	return
end