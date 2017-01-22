

--
function TakingManager:OnTakingSpellStart(data)
	local entity = data['caster']
	local node = data['target']

	if self:NodeGetViability(entity, node) then
		entity['taking']['node'] = node
		self:EntityBeginTakingAnimation(entity)
	else
		self:NodeNotViable(node)
	end
	return
end
