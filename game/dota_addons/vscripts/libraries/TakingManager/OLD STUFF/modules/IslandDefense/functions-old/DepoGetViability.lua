

-- Verify that the depo still exists and that it is actually a depo, and that the entity is allowed to deposit to it before allowing the entity to deposity contents to it.
function TakingManager:DepoGetViability(entity, depo)
	if depo and not depo:IsNull() and depo['isDepo'] == true and depo['id'] == entity['id'] and entity['taking']['allowed'][depo['name']] == true then
		return true
	else
		return false
	end
end