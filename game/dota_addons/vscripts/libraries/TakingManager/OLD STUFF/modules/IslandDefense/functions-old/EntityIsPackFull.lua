

-- Check if the entities pack has reached capactiy
	-- Here is where you could add custom checks to see if the entity needs to return and deposit the contents of it's pack.
		-- IE: Is the pack at it's weight limit
		-- IE: Is the pack full, size wise
		-- IE: Is the pack full size and/or weight wise
		-- or anything your heart can imagine

	-- However it is in it's most simple form, as that is all IslandDefense needs.
function TakingManager:EntityIsPackFull(entity)
	if entity['pack']['total'] >= entity['pack']['capacity'] then
		return true
	else
		return false
	end
end