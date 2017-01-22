

--
function TakingManager:EntityGetNewDepo(entity)
	EntityManager:EntityUpdateVector(entity)

	local depoPrevious = entity['taking']['depo']
	entity['taking']['depo'] = nil

	if depoPrevious and depoPrevious['name'] then
		local depoList = Entities:FindAllByClassnameWithin(depoPrevious['name'], entity['vector'], entity['taking']['searchRadius']['depo'])
		local nearest = {
			['distance'] = -1
		}

		for i=0, #depoList do
			if depoList[i] then
				local depo = depoList[i]
				local distance = GridNav:FindPathLength(entity['vector'], depo['origin'])

				if distance < nearest['distance'] or nearest['distance'] == -1 then
					nearest['distance'] = distance
					nearest['depo'] = depo
				end
			end
		end
		return nearest['depo'] or nil
	else
		return nil
	end
	return nil
end