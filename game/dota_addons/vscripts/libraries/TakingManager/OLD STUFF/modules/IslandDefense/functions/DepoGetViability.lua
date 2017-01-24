

-- Verify the depo exists, is a depo, and the taker is allowed to deposit to it.
function TakingManager:DepoGetViability(entity, depo)
	if depo and not depo:IsNull() and depo['isDepo'] == true and depo['id'] == entity['id'] and entity['taking']['depos'][depo['name']] then
		return true
	else
		return false
	end
end