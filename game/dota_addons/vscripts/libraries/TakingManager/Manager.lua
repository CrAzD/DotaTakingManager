

--[[
]]--
function TakingManagerInitialization(manager)
    --[[
        manager TAKER
    ]]--
    function manager.Taker(entity)
        -- Functions

        function entity.TakingSpellStart(data)
            local node = data['target']

            if entity.PackCheckCapacity() then
                if entity.DepoIsViable(entity['depo']) then
                    entity.AI_TakingDeposit()
                    return
                else
                    if entity.DepoGetViable() then
                        entity.AI_TakingDeposit()
                        return
                    else
                        entity.AI_Idle()
                        return
                    end
                end
            elseif entity.NodeIsViable(node) then
                entity:StartGesture((entity['animation'][node['name']] or entity['animation']['default']))
                return
            else
                if entity.NodeGetViable() then
                    entity.AI_TakingTake()
                    return
                else
                    entity.AI_Idle()
                    return
                end
            end
        end

        function entity.TakingChannelSucceeded(data)
            local node = data['target']

            entity.PackAdd(node)

            if entity.PackCheckCapacity() then
                if entity.DepoIsViable(entity['depo']) then
                    entity.AI_TakingDeposit()
                    return
                else
                    if entity.DepoGetViable() then
                        entity.AI_TakingDeposit()
                        return
                    else
                        entity.AI_Idle()
                        return
                    end
                end
            else
                if entity.NodeIsViable(entity['node']) then
                    entity.AI_TakingTake()
                    return
                else
                    if entity.NodeGetViable() then
                        entity.AI_TakingTake()
                        return
                    else
                        entity.AI_Idle()
                        return
                    end
                end
            end
        end

        function entity.NodeGetViable()
            local node
            local nodeOld = entity['node'] or nil

            entity.LocationRefresh()

            if nodeOld and nodeOld['className'] then
                node = Entities:FindByClassnameNearest(nodeOld['className'], nodeOld['origin'], (entity['ai_radius']['all'] or entity['ai_radius'][nodeOld['className']] or 0))
                if not node then
                    node = Entities:FindByClassnameNearest(nodeOld['className'], entity['location'], (entity['ai_radius']['all'] or entity['ai_radius'][nodeOld['className']] or 0))
                end
            else
                for className, _ in pairs((entity['nodes'] or {})) do
                    node = Entities:FindByClassnameNearest(className, entity['location'], (entity['ai_radius']['all'] or entity['ai_radius'][className] or 0))
                    if node then
                        break
                    end
                end
            end

            if node and not node['takingConfigured'] then
                manager.Node(node)
                if not node['takingConfigured'] then
                    entity['node'] = nil
                    return false
                end
            end
            entity['node'] = node
            return true
        end

        function entity.NodeIsViable(node)
            if node and not node:IsNull() then
                if not node['takingConfigured'] then
                    manager.Node(node)
                    if not node['takingConfigured'] then
                        return false
                    end
                end

                if entity['nodes'][node['entityName']] then
                    entity['node'] = node
                    return true
                end
            end
            return false
        end

        function entity.DepositSpellStart(data)
            local depo = data['target']

            if entity.DepoIsViable(depo) then
                entity:StartGesture((entity['animation'][depo['name']] or entity['animation']['default']))
                return
            else
                if entity.DepoGetViable() then
                    entity.AI_TakingDeposit()
                    return
                else
                    entity.AI_Idle()
                    return
                end
            end
        end

        function entity.DepositChannelSucceeded(data)
            local depo = data['target']

            entity.PackDeposit()

            if entity.NodeIsViable(entity['node']) then
                entity.AI_TakingTake()
                return
            else
                if entity.NodeGetViable() then
                    entity.AI_TakingTake()
                    return
                else
                    entity.AI_Idle()
                    return
                end
            end
        end

        function entity.DepoGetViable()
            if entity['depos']['self'] then
                entity['depo'] = entity
                return true
            end

            local depo
            local depoOld = entity['depo'] or nil

            entity.LocationRefresh()

            if depoOld and depoOld['className'] then
                depo = Entities:FindByClassnameNearest(depoOld['className'], depoOld['origin'], (entity['ai_radius']['all'] or entity['ai_radius'][depoOld['className']] or 0))
                if not depo then
                    depo = Entities:FindByClassnameNearest(depoOld['className'], entity['location'], (entity['ai_radius']['all'] or entity['ai_radius'][depoOld['className']] or 0))
                end
            else
                for className, _ in pairs((entity['depos'] or {})) do
                    depo = Entities:FindByClassnameNearest(className, entity['location'], (entity['ai_radius']['all'] or entity['ai_radius'][className] or 0))
                    if depo then
                        break
                    end
                end
            end

            if depo and not depo['takingConfigured'] then
                manager.Depo(depo)
                if not depo['takingConfigured'] then
                    entity['depo'] = nil
                    return false
                end
            end
            entity['depo'] = depo
            return true
        end

        function entity.DepoIsViable(depo)
            if entity['depos']['self'] then
                entity['depo'] = entity
                return true
            elseif depo and not depo:IsNull() then
                if not depo['takingConfigured'] then
                    manager.Depo(depo)
                    if not depo['takingConfigured'] then
                        return false
                    end
                end

                if entity['depos'][depo['entityName']] then
                    entity['depo'] = depo
                    return true
                end
            end
            return false
        end

        function entity.PackAdd(node)
            local total = 0
            for resource, amount in pairs((node['value'] or {})) do
                if entity['pack'][resource] then
                    if (entity['pack'][resource] + amount) > entity['capacity'][resource] then
                        amount = (amount + entity['pack'][resource]) - entity['capacity'][resource]
                    end

                    if (total + amount ) > entity['capacity']['total'] then
                        amount = (amount + entity['pack']['total']) - entity['capacity']['total']
                    end

                    total = total + amount
                    entity['pack'][resource] = entity['pack'][resource] + amount

                    for modifier, bool in pairs((entity['modifier'] or {})) do
                        entity:SetModifierStackCount(modifier, entity, amount)
                    end
                end
            end
            return
        end

        function entity.PackCheckCapacity()
            local total = 0
            for resource, amount in pairs((entity['pack'] or {})) do
                if amount >= entity['capacity'][resource] then
                    return true
                else
                    total = total + amount
                end
            end
            if entity['capacity']['total'] and total >= entity['capacity']['total'] then
                return true
            end
            return false
        end

        function entity.PackDeposit()
            local player = entity['owningPlayer'] or nil
            if player then
                for resource, amount in pairs((entity['pack'] or {})) do
                    print('\n#################################################')
                    print('\t', type(amount), 'PackDeposit', amount)
                    player[resource] = player[resource] + amount
                    print('\t', type(resource), 'resource in PackDeposit', resource)
                    print('\t', type(player[resource]), 'player[resource] in PackDeposit', player[resource])

                    entity.PackPopup(resource, amount)
                    entity['pack'][resource] = 0
                    print('#################################################')
                end
                return true
            end
            return false
        end

        function entity.PackPopup(resource, amount)
            local color = manager['colors'][resource] or manager['colors']['default'] or Vector(255, 255, 255)

            local particle = ParticleManager:CreateParticleForPlayer(
                'particles/msg_fx/msg_damage_numbers_outgoing.vpcf',
                PATTACH_ABSORIGIN,
                entity['depo'] or entity,
                entity['owningPlayer']
            )

            ParticleManager:SetParticleControl(particle, 1, Vector(0, amount, nil))
            ParticleManager:SetParticleControl(particle, 2, Vector(4.0, (#tostring(amount)+1), 0))
            ParticleManager:SetParticleControl(particle, 3, color)
            return
        end

        function entity.AI_Idle()
            entity:Stop()
            entity:SetVelocity(Vector(0, 0, 0))
            entity:StartGesture((entity['animation']['ai_idle'] or entity['animation']['default']))

            FireGameEventLocal('tm_ai_idle', entity['index'])
            return
        end

        function entity.AI_TakingTake()
            entity:CastAbilityOnTarget(entity['node'], entity['ai_takingTake'], entity['id'])
            return
        end

        function entity.AI_TakingDeposit()
            entity:CastAbilityOnTarget(entity['depo'], entity['ai_takingDeposit'], entity['id'])
            return
        end

        -- Configuration        
        local setup = manager['setup'][entity['name']] or {}
        for key, value in pairs(setup) do
            if key == 'abilities' then
                for kkey, vvalue in pairs(value) do
                    local ability = entity:FindAbilityByName(vvalue) or nil
                    if ability then
                        entity[kkey] = ability or nil
                    else
                        entity[kkey] = entity.AbilityAdd(vvalue) or nil
                    end
                end
            elseif key == 'modifier' then
                for modifier, bool in pairs(setup['modifier']) do
                    if not entity:HasModifier(modifier) then
                        entity:AddNewModifier(entity, nil, modifier, {})
                    end
                end
            elseif type(value) == 'table' then
                entity[key] = {}
                for key1, value1 in pairs(value) do
                    entity[key][key1] = value1 or nil
                end
            else
                entity[key] = value
            end
        end
        entity['node'] = entity['node'] or {}
        entity['depo'] = entity['depo'] or {}

        -- Final touch(s), return entity
        entity['takingConfigured'] = true
        manager['indexed'][entity['index']] = entity
        FireGameEventLocal('tm_taker_configured', {['index'] = entity['index']})
        return(entity)
    end



    --[[
        manager NODE
    ]]--
    function manager.Node(node)
        local setup
        node['className'] = node['className'] or node:GetClassname() or node:GetDebugName() or ''
        if manager['setup'][node['className']] then
            node['entityName'] = node['className']
            setup = manager['setup'][node['className']] or nil
        else
            node['entityName'] = node['entityName'] or node:GetUnitName() or node:GetName() or ''
            setup = manager['setup'][node['entityName']] or nil
        end

        if not setup then
            return
        end

        node['index'] = node:GetEntityIndex() or nil
        node['location'] = node:GetAbsOrigin()

        for key, value in pairs(setup) do
            node[key] = value or nil
        end

        -- Final touch(s), return node
        node['takingConfigured'] = true
        manager['indexed'][node['index']] = node
        FireGameEventLocal('tm_node_configured', {['index'] = node['index']})
        return(node)
    end



    --[[
        manager DEPO
    ]]--
    function manager.Depo(depo)
        local setup = manager['setup'][depo['name']] or {}

        for key, value in pairs(setup) do
            if key == 'abilities' then
                for kkey, vvalue in pairs(value) do
                    local ability = depo:GetAbilityByName(vvalue)
                    if ability then
                        depo[kkey] = ability or nil
                    else
                        depo[kkey] = depo.AbilityAdd(vvalue) or nil
                    end
                end
            else
                depo[key] = value
            end
        end

        -- Final touch(s), return depo
        depo['takingConfigured'] = true
        manager['indexed'][depo['index']] = depo
        FireGameEventLocal('tm_depo_configured', {['index'] = depo['index']})
        return(depo)
    end



    --[[
        Manager FUNCTIONS
    ]]--
    function manager.ToBoolean(variable)
        bool = string.lower(tostring(variable))

        local TRUE = {['1'] = true, ['true'] = true, ['t'] = true}
        local FALSE = {['0'] = true, ['false'] = true, ['f'] = true}

        if TRUE[bool] then
            return true
        elseif FALSE[bool] then
            return false
        else
            return nil
        end
    end

    function manager.ToCorrectType(variable)
        local integer = tonumber(variable) or nil
        if integer then
            return(integer)
        end

        local boolean = manager.ToBoolean(variable)
        if boolean == true or boolean == false then
            return(boolean)
        end

        return(variable or nil)
    end

    function manager.StartUp()
        manager['setup'] = manager['setup'] or {}
        manager['kv']['EntityManager'] = {}

        -- Parse EntityManager and build a table for any entity with a taking table
        for entityName, entityData in pairs((EntityManager['kv']['entities'] or {})) do
            if (entityData['taking'] or entityData['Taking'] or entityData['TAKING']) and not manager['kv']['EntityManager'][entityName] then
                manager['kv']['EntityManager'][entityName] = {
                    [entityName] = (entityData['taking'] or entityData['Taking'] or entityData['TAKING']) or {}
                }
            end
        end

        -- Parse through tables and configure manager setup
            -- tm_nodes.kv
            -- tm_takers.kv
            -- EntityManager

        local kvTable = {
            [0] = (manager['kv']['nodes'] or {}), 
            [1] = (manager['kv']['takers'] or {}), 
            [2] = (manager['kv']['EntityManager'] or {})
        }
        for i=0, #kvTable do
            for className, classData in pairs(kvTable[i]) do
                for entityName, entityData in pairs(classData) do
                    manager['setup'][entityName] = {['className'] = className, ['entityName'] = entityName, ['name'] = entityName}
                    local setup = manager['setup'][entityName]

                    for key, value in pairs(entityData) do
                        if type(value) == 'table' then
                            setup[key] = {}
                            for key1, value1 in pairs(value) do
                                setup[key][key1] = manager.ToCorrectType(value1)
                            end
                        else
                            setup[key] = manager.ToCorrectType(value)
                        end
                    end

                    if setup['capacity'] then
                        setup['pack'] = {}
                        for resource, amount in pairs((setup['capacity'] or {})) do
                            if resource ~= 'total' then
                                setup['pack'][resource] = 0
                            end
                        end
                    end
                end
            end
        end
        manager['initialized'] = true
    end



    --[[
        manager EVENTS
    ]]--
    local function EventPlayerConfigured(args)
    end

    local function EventEntityConfigured(args)
        local entity = EntityManager['indexed'][args['index']]
        local setup = manager['setup'][entity['name']] or {}

        if (setup['category'] or '') == 'taker' then
            manager.Taker(entity)
        elseif (setup['category'] or '') == 'depo' then
            manager.Depo(entity)
        elseif (setup['category'] or '') == 'node' then
            manager.Node(entity)
        end
    end

    local function EventGameStateChange(args)
        if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
            return
        else
            if not manager['initialized'] then
                return
            end

            for entityName, entityData in pairs((manager['setup'] or {})) do
                local setup = manager['setup'][entityName] or {}
                if setup['configureOnStartup'] then
                    local entities
                    if setup['className'] then
                        entities = Entities:FindAllByClassname(setup['className'])
                    elseif setup['entityName'] or setup['name'] then
                        entities = Entities:FindAllByName((setup['entityName'] or setup['name']))
                    end

                    for i=0, #entities+1 do
                        local entity = entities[i] or nil
                        if entity then
                            for key, value in pairs(entityData) do
                                entity[key] = value
                            end

                            if setup['category'] == 'node' then
                                manager.Node(entity)
                            elseif setup['category'] == 'taker' then
                                manager.Taker(entity)
                            elseif  setup['category'] == 'depo' then
                                manager.Depo(entity)
                            end
                        end
                    end
                end
            end
        end
    end

    ListenToGameEvent('game_rules_state_change', EventGameStateChange, self)
    ListenToGameEvent('em_player_configured', EventPlayerConfigured, self)
    ListenToGameEvent('em_entity_configured', EventEntityConfigured, self)



    --[[
        Manager Configuraton
    ]]--
    manager['colors'] = {
        ['default'] = Vector(0, 0 ,0),
        ['lumber'] = Vector(10, 200, 90),
        ['gold'] = Vector(225, 225, 100)
    }

    --Final touch(s), return manager
    FireGameEventLocal('tm_manager_configured', {['name'] = 'TakingManager'})
    return(manager)
end


function TakingOnSpellStart(data)
    if data['caster']['takingConfigured'] then
        data['caster'].TakingSpellStart(data)
    end
    return
end

function TakingOnChannelSucceeded(data)
    if data['caster']['takingConfigured'] then
        data['caster'].TakingChannelSucceeded(data)
    else
        return
    end
end

function DepositOnSpellStart(data)
    if data['caster']['takingConfigured'] then
        data['caster'].DepositSpellStart(data)
    else
        return
    end
end

function DepositOnChannelSucceeded(data)
    if data['caster']['takingConfigured'] then
        data['caster'].DepositChannelSucceeded(data)
    else
        return
    end
end