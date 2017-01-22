

--
function TakingManager:EntityGetNewNode(entity)
	EntityManager:EntityUpdateVector(entity)

	local nodePrevious = entity['taking']['node']
	entity['taking']['node'] = nil

	if nodePrevious and nodePrevious['name'] then
		local nodeList = Entities:FindAllByClassnameWithin(nodePrevious['name'], entity['vector'], entity['taking']['searchRadius']['node'])
		local nearest = {
			['distance'] = -1
		}

		for i=0, #nodeList do
			if nodeList[i] then
				local node = nodeList[i]
				local distance = GridNav:FindPathLength(entity['vector'], node['origin'])

				if distance < nearest['distance'] or nearest['distance'] == -1 then
					nearest['distance'] = distance
					nearest['node'] = node
				end
			end
		end
		return nearest['node'] or nil
	else
		return nil
	end
	return nil
end