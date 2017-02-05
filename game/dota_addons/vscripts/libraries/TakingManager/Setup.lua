

require('libraries/TakingManager/Manager')
local manager = TakingManagerInitialization(class({}))

-- Information about the library
manager['version'] = 0.05
manager['url'] = 'https://github.com/CrAzD/DotaTakingManager'
manager['description'] = ''

-- General setup and configuration
manager['entity'] = GameRules:GetGameModeEntity()

-- KV file loading and initialization
manager['kv'] = {
    ['nodes'] = LoadKeyValues('scripts/kv/tm_nodes.kv') or {}
}

-- Check if EM has been iniltialized
    -- If so check if TM has been iniltialized
        -- If not iniltialize
if EntityManager and EntityManager['initialized'] and not manager['initialized'] then
    manager['setup'] = {}
    manager.StartUp()
end

-- Messages and info spam
print('\nTakingManager:  Initialization complete...'..
    '\n\tVersion:  '..tostring(manager['version'])..
    '\n\tURL:  '..manager['url']
)

return(manager)