

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

            if nodeOld then
                node = Entities:FindByClassnameNearest(nodeOld['classname'], nodeOld['origin'], (entity['searchRadius']['all'] or entity['searchRadius'][entity['node']['type']]))
                if not node then
                    node = Entities:FindByClassnameNearest(nodeOld['classname'], entity['location'], (entity['searchRadius']['all'] or entity['searchRadius'][entity['node']['type']]))
                end
            else
                for classname, _ in pairs((entity['nodes'] or {})) do
                    node = Entities:FindByClassnameNearest(classname, entity['location'], (entity['searchRadius']['all'] or entity['searchRadius'][entity['node']['type']]))
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

                if entity['nodes'][node['entityname']] then
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
            entity.LocationRefresh()

            local depo
            for depo, _ in pairs((entity['depos'] or {})) do
                depo = Entities:FindByClassnameNearest(key, entity['loc'], (entity['searchRadius']['all'] or entity['searchRadius'][key]))
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
            if entity['depos']['self'] then
                entity['depo'] = entity
                return true
            elseif depo then
                if not depo:IsNull() then
                    if not depo['takingConfigured'] then
                        manager.Depo(depo)
                        if not depo['takingConfigured'] then
                            return false
                        end
                    end

                    if entity['depos'][depo['name']] then
                        entity['depo'] = depo
                        return true
                    end
                end
            end
            return false
        end

        function entity.PackAdd(node)
            for resource, amount in pairs(node['value']) do
                if entity['pack'][resource] then
                    if (entity['pack'][resource] + amount) > entity['capacity'][resource] then
                        amount = (amount + entity['pack'][resource]) - entity['capacity'][resource]
                    end

                    if (entity['pack']['total'] + amount ) > entity['capacity']['total'] then
                        amount = (amount + entity['pack']['total']) - entity['capacity']['total']
                    end

                    entity['pack'][resource] = entity['pack'][resource] + amount
                    entity['pack']['total'] = entity['pack']['total'] + amount

                    for modifier, bool in pairs((entity['modifier'] or {})) do
                        entity:SetModifierStackCount(modifier, entity, amount)
                    end
                end
            end
            return
        end

        function entity.PackCheckCapacity()
            --#TO DO 
                -- check total
                -- check against individual resources
            for resource, amount in pairs(entity['capacity']) do
                if entity['pack'][resource] >= entity['capacity'][resource] then
                    return true
                end
            end
            return false
        end

        function entity.PackDeposit()
            local player = entity['owningPlayer'] or nil
            if player then
                for resource, amount in pairs((entity['pack'] or {})) do
                    if resource ~= 'total' then
                        player[resource] = player[resource] + amount

                        entity.PackPopup(amount, resource)
                        entity['pack'][resource] = 0
                    end
                end
                entity['pack']['total'] = 0
                return true
            end
            return false
        end

        function entity.PackPopup(amount, resource)
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
                for kkey, vvalue in pairs(value) do
                    entity[key][kkey] = vvalue or nil
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



    --[[
        manager NODE
    ]]--
    function manager.Node(node)
        if not node['entityname'] then
            return
        end

        node['classname'] = node['classname'] or node:GetClassname() or node:GetDebugName() or ''
        node['index'] = node:GetEntityIndex() or nil
        node['location'] = node:GetAbsOrigin()

        local setup = manager['setup'][node['entityname']] or {}
        for key, value in pairs(setup) do
            node[key] = value or nil
        end

        -- Final touch(s), return node
        node['takingConfigured'] = true
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



    --[[
        Manager FUNCTIONS
    ]]--
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
        local integer = tonumber(variable) or nil
        if integer then
            return integer
        end

        local boolean = manager.ToBoolean(variable)
        if boolean == true or boolean == false then
            return boolean
        end

        return tostring(variable) or nil
    end

    function manager.StartUp()
        manager['setup'] = manager['setup'] or {}

        for classname, classdata in pairs((manager['kv']['nodes'] or {})) do
            for entityname, entitydata in pairs(classdata) do
                manager['setup'][entityname] = {['classname'] = classname, ['entityname'] = entityname, ['name'] = entityname}
                local setup = manager['setup'][entityname]

                for key, value in pairs(entitydata) do
                    if type(value) == 'table' then
                        setup[key] = {}
                        for key1, value1 in pairs(value) do
                            setup[key][key1] = manager.ToCorrectType(value1)
                        end
                    else
                        setup[key] = manager.ToCorrectType(value)
                    end
                end
            end
        end

        for entityName, entityData in pairs(EntityManager['kv']['entities'] and pairs(manager['kv']['entities'])) do
            if entityData['Taking'] or entityData['taking'] then
                manager['setup'][entityName] = {}
                local setup = manager['setup'][entityName]
                for key, value in pairs((entityData['Taking'] or entityData['taking'])) do
                    if type(value) == 'table' then
                        setup[key] = {}
                        for key1, value1 in pairs(value) do
                            setup[key][key1] = manager.ToCorrectType(value1)

                            if key == 'nodes' and manager['setup'][value1] then
                                setup['modifier'] = setup['modifier'] or {}
                                for modifier, bool in pairs((manager['setup'][value1]['modifier'] or {})) do
                                    setup['modifier'][modifier] = bool
                                end
                            end
                        end
                    else
                        setup[key] = manager.ToCorrectType(value)
                    end
                end

                if string.lower(setup['type']) == 'taker' then
                    setup['pack'] = {['total'] = 0}
                    for node, bool in pairs((setup['capacity'] or {})) do
                        if bool then
                            setup['pack'][node] = 0
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

        if setup['value'] then
            manager.Node(entity)
        elseif (setup['type'] or '') == 'taker' then
            manager.Taker(entity)
        elseif (setup['type'] or '') == 'depo' then
            manager.Depo(entity)
        end
    end

    local function EventGameStateChange(args)
        if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
            return
        else
            for classname, classdata in pairs((manager['kv']['nodes'] or {})) do
                for entityname, entitydata in pairs(classdata) do
                    local setup = manager['setup'][entityname] or {}
                    if setup['configureOnStartup'] then
                        local nodes = Entities:FindAllByClassname(classname)
                        for i=0, #nodes+1 do
                            local node = nodes[i] or nil
                            if node then
                                if classname == entityname then
                                    manager.Node(node)
                                elseif entityname == (node['name'] or '') then
                                    manager.Node(node)
                                end
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