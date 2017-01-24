

require('libraries/TakingManager/Manager')
if TakingManager == nil then
    _G.TakingManager = TakingManagerInitialization(class({}))
else
    _G.TakingManager = TakingManagerInitialization(TakingManager)
end
local manager = TakingManager

-- Information about the library
manager['version'] = 0.02
manager['url'] = 'https://github.com/CrAzD/DotaTakingManager'
manager['description'] = ''

-- General setup and configuration
manager['entity'] = GameRules:GetGameModeEntity()
manager['users'] = {}
manager['players'] = {}

-- KV file loading and initialization
manager['kv'] = {
    ['abilities'] = LoadKeyValues('scripts/npc/npc_abilities_custom.txt'),
    ['heroes'] = LoadKeyValues('scripts/npc/npc_heroes_custom.txt'),
    ['units'] = LoadKeyValues('scripts/npc/npc_units_custom.txt'),
    ['entities'] = {}
}
local kvTables = {['units'] = 'units', ['heroes'] = 'heroes'}
for _, kvTable in pairs(kvTables) do
    for key, value in pairs(manager['kv'][kvTable]) do
        manager['kv']['entities'][key] = value or nil
    end
end

-- Messages and info spam
print('\n\nEntityManager:  Initialization complete...'..
    '\n\tVersion:  '..tostring(manager['version'])..
    '\n\tURL:  '..manager['url']..
    '\n\tDescription:  '..manager['description']..
    '\n'
)



manager['animations']['taking'][node['type']]
    --tree/gold == ACT_DOTA_ATTACK