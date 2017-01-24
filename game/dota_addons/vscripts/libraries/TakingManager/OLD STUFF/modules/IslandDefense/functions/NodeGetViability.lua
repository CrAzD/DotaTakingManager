

--
function TakingManager:NodeGetViability(node)
	if node and not node:IsNull() and node['isNode'] == true and entity['taking']['nodes'][node['name']] and entity['taking']['type'] == 'taker' then
		return true
	else
		return false
	end
end