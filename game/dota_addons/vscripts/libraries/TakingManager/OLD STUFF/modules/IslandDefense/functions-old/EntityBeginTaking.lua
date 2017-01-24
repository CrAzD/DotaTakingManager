


function TakingManager:EntityBeginTaking(entity, node)
	entity:SetModifierStackCount('modifer_has_lumber', entity, entity['pack']['current'])
	entity:StartGesture(entity['taking']['takingAnimation'])

	return
end