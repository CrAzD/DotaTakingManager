

if TakingManager == nil then
	_G.TakingManager = class({})
end

TakingManager['INFO'] = {
	['VERSION'] = '0.01',
	['URL'] = 'https://github.com/CrAzD/DotaTakingManager',
	['DESCRIPTION'] = 'Turns entities into resources and entities into takers.'
}

TakingManager['users'] = {} --Table that ties the userID to a specific player
TakingManager['players'] = {} --Table that holds everything for each player
TakingManager['developers'] = {} --Table that holds the steamids of developers.

--[[
	Put all lua files that need to be required here.
--]]
local REQUIRE = {
 	['events'] = {
 		'entity_killed',
		'game_rules_state_change'
	},
	['functions'] = {
		'AbilityAdd',
		'AbilityRemove',
		'AbilityReplace',
		'EntityConfigure',
		'EntityCreate',
		'EntityCreateDummy',
		'EntityCreateUnit',
		'EntityDestroy',
		'EntityDestroyFast',
		'EntityReplaceHeroWith',
		'EntityUpdateVector',
		'PlayerConfigure'
	},
	['utilities'] = {
		'ParticleCleanup'
	}
}

for tFolder, tTable in pairs(REQUIRE) do
	for _, tFile in pairs(tTable) do
		require('libraries/EntityManager/'..tFolder..'/'..tFile)
	end
end