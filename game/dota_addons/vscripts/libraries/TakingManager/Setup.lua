

-- TakingManager
-- By: CrAzD
require('libraries/TakingManager/Manager')
local manager = TakingManagerInitialization(class({}))

-- Information
manager['version'] = 0.10
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

-- Check dependency initialization and minimum version met.
if EntityManager and EntityManager['initialized'] then
    if EntityManager['version'] < manager['emMinimumVersion'] then
        print('BuildingManager: DEPENDENCY VERSION NOT MET!'..
            '\n\tEntityManager must be at least verison-'..tostring(manager['emMinimumVersion'])..' to be compatible with BuildingManager.'
        )
        return(nil)
    end
else
    print('BuildingManager: DEPENDENCY NOT LOADED!'..
        '\n\tEntityManager version-'..tostring(manager['emMinimumVersion'])..' (or above) missing or not loaded before BuildingManager.'
    )
    return(nil)
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