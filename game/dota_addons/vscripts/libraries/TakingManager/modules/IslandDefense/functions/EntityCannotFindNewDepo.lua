

--
function TakingManager:EntityCannotFindNewDepo(entity)
	entity:CastAbilityOnTarget(depo, self:EntityGetAbility(entity, 'taking_sleep'), entity['id'])
	return
end
