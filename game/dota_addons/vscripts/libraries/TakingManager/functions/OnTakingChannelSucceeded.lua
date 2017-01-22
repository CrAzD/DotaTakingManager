

--
function TakingManager:OnTakingChannelSucceeded(data)
	local entity = data['caster']
	local node = data['target']

	self:EntityAddResourceToPack(entity, node)

	if entity['taking']['depo'] == entity then
		self:EntityDepositToSelf(entity)
		self:EntityReturnToNode(entity)
	elseif self:EntityIsPackFull(entity) then
		self:EntityReturnToDepo(entity)
	else
		self:EntityReturnToNode(entity)
	end
	return
end