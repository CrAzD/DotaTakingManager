

--
function TakingManager:EntityBeginTakingAnimation(entity, node)
	for resource in entity['taking']['types']
		if entity[resource] > 0 then
			entity:SetModifierStackCount(('modifier_'..resource..'_stack_count'), entity, entity[resource])
		end
	end
	entity:StartGesture(entity['taking']['animation'][entity['node']['type']])
	return
end