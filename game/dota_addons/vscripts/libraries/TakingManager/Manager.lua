

--[[
]]--
function TakingManagerInitialization(manager)
	--[[
		manager TAKER
	]]--
	function manager.Taker(entity, player)
		-- Functions

		function entity.TakingSpellStart(data)
			local node = data['target']

			if entity.NodeIsViable(node) then
				entity:StartGesture(entity['animations'][node['name']])
				return
			else
				if entity.NodeGetViable() then
					entity.AI_ResourceTake()
					return
				else
					entity.AI_GoToSleep()
					return
				end
			end
		end

		function entity.TakingChannelSucceeded(data)
			local node = data['target']

			entity.PackAdd(node)

			if entity.PackFull() then
				if entity.DepoIsViable() then
					entity.AI_ResourceDeposit()
					return
				else
					if entity.DepoGetViable() then
						entity.AI_ResourceDeposit()
						return
					else
						entity.AI_GoToSleep()
						return
					end
				end
			else
				if entity.NodeIsViable(entity['node']) then
					entity.AI_ResourceTake()
					return
				else
					if entity.NodeGetViable() then
						entity.AI_ResourceTake()
						return
					else
						entity.AI_GoToSleep()
						return
					end
				end
			end
		end

		function entity.NodeGetViable()
			entity.LocationRefresh()

			local node
			for i=0, #entity['nodeTable'] do
				node = Entities:FindByClassnameNearest(entity['nodeTable'][i], entity['loc'], entity['ai_nodeSearchRadius'])
				if node then
					break
				end
			end

			if node then
				entity['node'] = node
				return true
			else
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
				entity:StartGesture(entity['animations'][depo['name']])
				return
			else
				if entity.DepoGetViable() then
					entity.AI_ResourceDeposit()
					return
				else
					entity.AI_GoToSleep()
					return
				end
			end
		end

		function entity.DepositChannelSucceeded(data)
			local depo = data['target']

			entity.PackDeposit()

			if entity.NodeIsViable(entity['node']) then
				entity.AI_ResourceTake()
				return
			else
				if entity.NodeGetViable() then
					entity.AI_ResourceTake()
					return
				else
					entity.AI_GoToSleep()
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
			if depo then
				if depo['takingConfigured'] and not depo:IsNull() and entity['deposAllowed'][depo['name']] then
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
			for i=0, #entity['resourceTable'] do
				local resource = entity['resourceTable'][i]

				player[resource['name']] = player[resource['name']] + entity['pack'][resource['name']]
				entity.Popup()
				CustomGameEventManager:Send_ServerToPlayer(
					player, 
					'taking_resource_changed', 
					{
						['player'] = player, 
						['entity'] = entity, 
						['resource'] = math.floor(entity['pack'][resource['name']])
					}
				)
				entity['pack'][resource['name']] = 0
			end
			return
		end

		function entity.AI_GoToSleep()
			entity:CastAbilityOnTarget(entity, entity['ai_takingSleep'], entity['id'])
			return
		end

		function entity.AI_ResourceTake()
			entity:CastAbilityOnTarget(entity['node'], entity['ai_takingTake'], entity['id'])
			return
		end

		function entity.AI_ResourceDeposit()
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
			else
				entity[key] = value
			end
		end

		-- Final touch(s), return entity
		entity['takingConfigured'] = true
		return(entity)


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
		return(node)
	end

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
		return(depo)
	end


	--[[
		Final touch(s), return manager
	]]--
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