

--
function TakingManager:EntityReturnToDepo(entity)
	local depo = entity['depo']
	if self:DepoGetViability(depo) then
		entity:CastAbilityOnTarget(depo, self:EntityGetAbility(entity, 'return_to_depo'), entity['id'])
	else
		depo = self:EntityGetNewDepo(entity)
		if depo then
			entity:CastAbilityOnTarget(depo, self:EntityGetAbility(entity, 'return_to_depo'), entity['id'])
		else
			self:EntityCannotFindNewDepo(entity)
		end
	end
	return
end