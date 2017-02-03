

require('libraries/TakingManager/Manager')
if TakingManager == nil then
    _G.TakingManager = TakingManagerInitialization(class({}))
else
    _G.TakingManager = TakingManagerInitialization(TakingManager)
end
local manager = TakingManager

-- Information about the library
manager['version'] = 0.03
manager['url'] = 'https://github.com/CrAzD/DotaTakingManager'
manager['description'] = ''

-- General setup and configuration
manager['entity'] = GameRules:GetGameModeEntity()

-- KV file loading and initialization
manager['kv'] = {
    ['nodes'] = LoadKeyValues('scripts/kv/tm_nodes.kv') or {}
}

manager['setup'] = {}

-- Messages and info spam
print('\nTakingManager:  Initialization complete...'..
    '\n\tVersion:  '..tostring(manager['version'])..
    '\n\tURL:  '..manager['url']
)