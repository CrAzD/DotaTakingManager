

--
function TakingManager:ConfigureEntity(entity)
	if self['ENTITIES'][entity['name']] then
		for key, variable in self['ENTITIES'] do
			entity['taking'][key] = variable
		end
	end
end