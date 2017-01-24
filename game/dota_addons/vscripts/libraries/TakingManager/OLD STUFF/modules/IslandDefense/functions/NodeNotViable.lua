

--
function TakingManager:NodeNotViable(entity)
	local depo = self:EntityGetNewDepo(entity)
	if depo then
		entity:CastAbilityOnTarget(depo, self:EntityGetAbility(entity, 'return_to_depo'), entity['id'])
		return
	else
		entity:CastAbilityOnTarget(entity, self:EntityGetAbility(entity, 'taking_sleep'), entity['id'])
		return
	end
end