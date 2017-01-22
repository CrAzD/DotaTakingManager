
function TakingManager:EntityTakeNode(entity, node)
	entity:CastAbilityOnTarget(node, self:EntityGetTakingAbility(entity), entity['id'])
end