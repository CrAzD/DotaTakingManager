

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

            if entity.NodeIsViable(node) then
                entity:StartGesture((entity['animation'][node['name']] or entity['animation']['default'] ))
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

            if entity.PackFull() then
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
            entity.LocationRefresh()

            local node
            if entity['node'] and entity['node']['type'] then
                node = Entities:FindByClassnameNearest(entity['node']['type'], entity['loc'], (entity['searchRadius']['all'] or entity['searchRadius'][entity['node']['type']]))
                if node then
                    entity['node'] = node
                    return true
            end

            if not node then
                for key, value in pairs(entity['nodeTable']) do
                    if value == true then
                        node = Entities:FindByClassnameNearest(key, entity['local'], (entity['searchRadius']['all'] or entity['searchRadius'][key]))
                        if node then
                            break
                        end
                    end
                end
            end

            if node then
                if not node['takingConfigured'] then
                    manager.Node(node)
                end
                entity['node'] = node
                return true
            else
                entity['node'] = nil
                return false
            end
        end

        function entity.NodeIsViable(node)
            if node then
                if node['takingConfigured'] and not node:IsNull() and entity['pack'][node['name']] then
                    return true
                else
                    if not node['takingConfigured'] and not node['checkOnce'] then
                        manager.Node(node)
                        if node['takingConfigured'] then
                            node['checkOnce'] = true
                            if entity.NodeIsViable(node) then
                                return true
                            else
                                return false
                            end
                        else
                            return false
                        end
                    else
                        node['checkOnce'] = false
                        return false
                    end
                end
            end
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
            entity.LocationRefresh()

            local depo
            for i=0, #entity['depoTable'] do
                depo = Entities:FindByClassnameNearest(entity['depoTable'][i], entity['loc'], entity['ai_depoSearchRadius'])
                if depo then
                    break
                end
            end

            if depo then
                entity['depo'] = depo
                return true
            else
                return false
            end
        end

        function entity.DepoIsViable(depo)
            if entity['depoTable']['self'] then
                entity['depo'] = entity
                return true
            elseif depo then
                if entity['depoTable']['self'] then
                    entity['depo'] = entity
                    return true
                elseif depo['takingConfigured'] and not depo:IsNull() and entity['depoTable'][depo['name']] then
                    entity['depo'] = depo
                    return true
                else
                    if not depo['takingConfigured'] and not depo['checkOnce'] then
                        manager.Depo(depo)
                        if depo['takingConfigured'] then
                            depo['checkOnce'] = true
                            if entity.DepoIsViable(depo) then
                                return true
                            else
                                return false
                            end
                        else
                            return false
                        end
                    else
                        depo['checkOnce'] = false
                        return false
                    end
                end
                return false
            else
                return false
            end
        end

        function entity.PackAdd(node)
            for i=0, #node['resources'] do
                local resource = node['resources'][i]

                entity['pack'][resource['name']] = entity['pack'][resource['name']] + resource['amountPerTaking']
                entity:SetModifierStackCount(resource['modifier'], entity, entity['pack'][resource['name']])
            end
            return
        end

        function entity.PackEmpty()
            for i=0, #entity['resourceTable'] do 
                entity[entity['resourceTable'][i]] = 0
            end
            return
        end

        function entity.PackFull()
            local total = 0
            for i=0, #entity['resourceTable'] do
                total = total + entity[entity['resourceTable'][i]]
            end

            if total >= entity['packCapacity'] then
                return true
            else
                return false
            end
        end

        function entity.PackDeposit()
            if entity['owningPlayer'] then
                for resource, _ in pairs(entity['nodeTable']) do
                    player[resource] = player[resource] + entity['pack'][resource]
                    entity.Popup(entity['pack'][resource])

                    CustomGameEventManager:Send_ServerToPlayer(
                        player, 
                        'taking_resource_changed', 
                        {
                            ['player'] = player, 
                            ['entity'] = entity, 
                            ['resource'] = resource
                        }
                    )
                    entity['pack'][resource] = 0
                end
                return true
            else
                return false
            end
        end

        function entity.AI_Idle()
            entity:Stop()
            entity:SetVelocity(0)
            entity:StartGesture((entity['animation']['ai_idle'] or entity['animation']['default']))
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
                    local ability = entity:GetAbilityByName(vvalue)
                    if ability then
                        entity[kkey] = ability or nil
                    else
                        entity[kkey] = entity.AbilityAdd(vvalue) or nil
                    end
                end
            elseif type(value) == 'table' then
                for kkey, vvalue in pairs(value) do
                    entity[kkey] = vvalue or nil
                end
            else
                entity[key] = value
            end
        end

        -- Final touch(s), return entity
        entity['takingConfigured'] = true
        FireGameEventLocal('tm_taker_configured', {['index'] = entity['index']})
        return(entity)
        end
    end


    --[[
        manager NODE
    ]]--
    function manager.Node(node)
        local setup = manager['setup'][node['name']] or {}

        for key, value in pairs(setup) do
            node[key] = value or nil
        end

        -- Final touch(s), return node
        node['takingConfigured'] = true
        node['checkOnce'] = false
        node['index'] = node:GetEntityIndex() or nil
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
        depo['checkOnce'] = false
        FireGameEventLocal('tm_depo_configured', {['index'] = depo['index']})
        return(depo)
    end

    function manager.ToBoolean(variable)
        variable = string.lower(tostring(variable))

        local TRUE = {['1'] = true, ['true'] = true, ['t'] = true}
        local FALSE = {['0'] = true, ['false'] = true, ['f'] = true}

        if TRUE[variable] then
            return true
        elseif FALSE[variable] then
            return false
        else
            return nil
        end
    end

    function manager.ToCorrectType(variable)
        local boolean = manager.ToBoolean(variable)
        if boolean == true or boolean == false then
            return boolean
        end

        local integer = tonumber(variable) or nil
        if integer then
            return integer
        end

        return tostring(variable) or nil
    end

    function manager.Startup()
        local tempTables = {
            [0] = EntityManager['kv']['entities'],
            [1] = manager['kv']['nodes']
        }
        for i=0, #tempTables do
            local kvTable = tempTables[i]
            for entityName, entityData in pairs(kvTable) do
                if entityData['Taking'] or entityData['taking'] then
                    manager['setup'][entityName] = {}
                    for key, value in pairs((entityData['Taking'] or entityData['taking'])) do
                        if type(value) == 'table' then
                            manager['setup'][entityName][key] = {}
                            for key1, value1 in pairs(value) do
                                manager['setup'][entityName][key][key1] = manager.ToCorrectType(value1)
                            end
                        else
                            manager['setup'][entityName][key] = manager.ToCorrectType(value)
                        end

                        if i == 1 and key1 == 'configureAtGameStart' and manager.ToBoolean(value) then
                            local nodes = Entities:FindAllbyClassname(entityName)
                            for i=0, #nodes+1 do
                                local node = nodes[i] or nil
                                if node then
                                    manager.Node(node)
                                end
                            end
                        end
                    end
                end
            end
        end

        if manager['configureNodesAtStartup'] then
            local trees = GridNav:GetAllTreesAroundPoint(tMound['origin'], 500000000, false)
            for key, value in pairs(trees) do
                manager.Node(value)
            end
            tress = nil
        end
    end


    --[[
        manager EVENTS
    ]]--
    local function EventPlayerConfigured(args)
    end

    local function EventEntityConfigured(args)
        local entity = EntityManager['indexed'][args['index']]

        local setup = manager['setup'][entity['name']] or nil
        if setup then
            if setup['type'] == 'taker' then
                manager.Taker(entity)
            elseif setup['type'] == 'depo' then
                manager.Depo(entity)
            elseif setup['type'] == 'node' then
                manager.Node(entity)
            end
        end
    end

    local function EventEntityManagerConfigured(args)
        manager.Startup()
    end

    ListenToGameEvent('em_player_configured', EventPlayerConfigured, self)
    ListenToGameEvent('em_entity_configured', EventEntityConfigured, self)
    ListenToGameEvent('em_manager_configured', EventEntityManagerConfigured, self)


    --[[
        Final touch(s), return manager
    ]]--
    FireGameEventLocal('tm_manager_configured', {['name'] = 'TakingManager'})
    return(manager)
end


function TakingOnSpellStart(data)
    local entity = data['caster']

    if entity['takingConfigured'] then
        entity.TakingSpellStart(data)
    else
        return
    end
end

function TakingOnChannelSucceeded(data)
    local entity = data['caster']

    if entity['takingConfigured'] then
        entity.TakingChannelSucceeded(data)
    else
        return
    end
end

function DepositOnSpellStart(data)
    local entity = data['caster']

    if entity['takingConfigured'] then
        entity.DepositSpellStart(data)
    else
        return
    end
end

function DepositOnChannelSucceeded(data)
    local entity = data['caster']

    if entity['takingConfigured'] then
        entity.DepositChannelSucceeded(data)
    else
        return
    end
end