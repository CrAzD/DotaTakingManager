

-- Make sure EntityManager has been loaded, if not spit out an error and do NOT load.
if not EntityManager
	print('[TakingManager]  EntityManager is missing, not loading.')
	return false
end


-- Setup TM Class
if TakingManager == nil then
	_G.TakingManager = class({})
end


-- Setup Globals
TakingManager['INFO'] = {
	['VERSION'] = '0.01',
	['URL'] = 'https://github.com/CrAzD/DotaTakingManager',
	['DESCRIPTION'] = 'Turns entities into resources and/or takers.'
}


-- Load required scripts
local REQUIRE = {
 	['events'] = {
 		'depositSpellStart',
		'takingChannelSucceeded',
		'takingSpellStart'
	},
	['functions'] = {
 		'OnDepositSpellStart',
		'OnTakingChannelSucceeded',
		'OnTakingSpellStart'
	},
	['utilities'] = {
		'toboolean'
	}
}

for tFolder, tTable in pairs(REQUIRE) do
	for _, tFile in pairs(tTable) do
		require('libraries/TakingManager/'..tFolder..'/'..tFile)
	end
end

require('libraries/TakingManager/settings.lua')
require('libraries/TakingManager/'..TM_MODULE_FOLDER_TO_LOAD..'/load.lua')

-- Parse EntityManager Heroes and Units globals for Taking configured ones.
TakingManager['ENTITIES'] = {}
for _, tempTable in pairs({EntityManager['KV_FILES']['HEROES'], EntityManager['KV_FILES']['UNITS']}) do
	for entityName, entityTable in pairs(tempTable) do
		for entityKey, entityVariable in pairs(entityTable) do
			if entityKey == 'taking' then
				TakingManager['ENTITIES'][entityName] = {}
				for key, variable in pairs(entityVariable) do
					if key == 'nodes' or key == 'depos' then
						TakingManager['ENTITIES'][entityName][key] = {}
						for k in string.gmatch(variable, '%S+') do
							TakingManager['ENTITIES'][entityName][key][k] = true
						end
					elseif key == 'types' then
						TakingManager['ENTITIES'][entityName]['types'] = {}
						for k, v in pairs(variable) do
							TakingManager['ENTITIES'][entityName]['types'][k] = toboolean(v)
						end
					elseif key == 'searchRadiuses' or key == 'capacities' then
						TakingManager['ENTITIES'][entityName][key] = {}
						for k, v in pairs(variable) do
							TakingManager['ENTITIES'][entityName][key][k] = tonumber(v)
						end
					else
						TakingManager['ENTITIES'][entityName][key] = variable
					end
				end
			end
		end
	end
end