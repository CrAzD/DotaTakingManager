

-- TakingManager
-- By: CrAzD
require('libraries/TakingManager/Manager')
local manager = TakingManagerInitialization(class({}))

-- Information
manager['version'] = 0.09
manager['url'] = 'https://github.com/CrAzD/DotaTakingManager'
manager['emMinimumVersion'] = 0.64

-- General setup and configuration
manager['indexed'] = {}
manager['entity'] = GameRules:GetGameModeEntity()

-- KV file loading and initialization
manager['kv'] = {
    ['nodes'] = LoadKeyValues('scripts/kv/tm_nodes.kv') or {},
    ['takers'] = LoadKeyValues('scripts/kv/tm_takers.kv') or {}
}

-- Check if EM has been iniltialized
if not EntityManager or not EntityManager['initialized'] then
	print('TakingManager: EntityManager required but missing. Please download and require before TakingManager.')
	return
end
-- Check if EM's version meets the minimum required for TM
if EntityManager['version'] < manager['emMinimumVersion'] then
	print('TakingManager: EntityManager below minimum required verison. \n\tPlease update EntityManager to at least version '..manager['emMinimumVersion'])
	return
end
-- Check if TM has been iniltialized
    -- If not iniltialize
if not manager['initialized'] then
    manager['setup'] = {}
    manager.StartUp()
end

-- Messages and info spam
print('\nTakingManager:  Initialization complete...'..
    '\n\tVersion:  '..tostring(manager['version'])..
    '\n\tURL:  '..manager['url']
)

return(manager)