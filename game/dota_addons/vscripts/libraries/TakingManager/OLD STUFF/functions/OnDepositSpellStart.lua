

--
function TakingManager:OnDepositSpellStart(data)
	local entity = data['caster'] 
	local depo = data['target']

	if self:DepoGetViability(entity, depo) then
		self:EntityDepositPackContents(entity)
		self:EntityReturnToNode(entity)
	else
		self:DepoNotViable(entity)
	end
	return
end