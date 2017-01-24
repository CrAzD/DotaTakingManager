

function toboolean(variable)
	variable = string.lower(tostring(variable))
	if variable == 'true' or variable == '1' then
		return true
	else
		return false
	end
end