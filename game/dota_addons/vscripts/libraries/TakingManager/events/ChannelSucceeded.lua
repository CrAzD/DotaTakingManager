

ListenToGameEvent('player_connect_full', Dynamic_Wrap(HarvestingManager, 'OnChannelSucceeded'), self)

--[[------------------------------------------------------------------------------
    ChannelSucceeded
    	Once the peasant has finished channeling the harvest ability
    		Add 1 to harvest count
    		Check if full or if to keep harvesting
    			if full return to shelter, drop off lumber, and return to harvest
------------------------------------------------------------------------------]]--
function HarvestingManager:OnChannelSucceeded(data)
	local harvester = data['caster']

	harvester['harvest'] = harvester['harvest'] + 1
	harvester:SetModifierStackCount('modifier_has_lumber', harvester, harvester['harvest'])

	if harvester['harvest'] >= 5 then
		harvester:CastAbilityOnTarget(self:GetShelter(harvester), )


function OnHarvestChannelSucceeded(data)
	local harvester = data['caster']
	local tree = data['target']

	harvester['harvest'] = harvester['harvest'] + 1
	harvester:SetModifierStackCount('modifier_has_lumber', harvester, harvester['harvest'])

	if harvester['harvest'] >= 5 then
		harvester:CastAbilityOnTarget(GetShelter(harvester), harvester.ability['deposit_lumber'], harvester['id'])
	else
		if GetTree(harvester) then
			harvester:CastAbilityOnTarget(harvester['tree'], harvester.ability['harvest'], harvester['id'])
		else
			harvester:CastAbilityOnTarget(GetShelter(harvester), harvester.ability['deposit_lumber'], harvester['id'])
		end
	end
end
