local path = require "@std/path"
local types = require "@scripts/libs/types"

local function getMemberFromPath(monorepo: types.Monorepo, filepath: path.Pathlike): types.MonorepoMember
	local firstPart = path.parse(filepath).parts[1]
	for _, member in ipairs(monorepo) do
		if member.dirName == firstPart then
			return member
		end
	end
	return error "unreachable"
end

return getMemberFromPath
