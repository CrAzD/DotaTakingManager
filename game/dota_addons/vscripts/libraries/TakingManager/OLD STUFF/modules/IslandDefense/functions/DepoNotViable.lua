

--
function TakingManager:DepoNotViable(entity)
	local depo = self:EntityGetNewDepo(entity)
	if depo then
		entity['taking']['depo'] = depo
		self:EntityDepositPackContents(entity)
		self:EntityReturnToNode(entity)
	else
		self:EntityCannotFindNewDepo(entity)
	end
end