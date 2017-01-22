--[[
	Put all lua files that need to be required here.
--]]
local REQUIRE = {
 	['events'] = {
	},
	['functions'] = {
		'ConfigureDepo',
		'ConfigureEntity',
		'ConfigureNode',
		'DepoGetViability',
		'DepoNotViable',
		'EntityAddResource',
		'EntityBeginTakingAnimation',
		'EntityCannotFindNewDepo',
		'EntityCannotFindNewNode',
		'EntityDepositPackContents',
		'EntityGetAbility',
		'EntityGetNewDepo',
		'EntityGetNewNode',
		'EntityIsPackFull',
		'EntityReturnToDepo',
		'EntityReturnToNode',
		'NodeGetViability',
		'NodeNotViable',
		'PopupDeposit'
	},
	['utilities'] = {
	}
}

for tFolder, tTable in pairs(REQUIRE) do
	for _, tFile in pairs(tTable) do
		require('libraries/TakingManager/Modules/'..TM_MODULE_FOLDER_TO_LOAD..'/'..tFolder..'/'..tFile)
	end
end