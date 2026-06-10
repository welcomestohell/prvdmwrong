local getMemberFromPath = require "@scripts/libs/monorepo/getMemberFromPath"
local path = require "@std/path"
local process = require "@std/process"
local types = require "@scripts/libs/types"

local function shouldFileBeTranspiled(monorepo: types.Monorepo, absolutePath: path.Pathlike)
	local filepath = path.relative(process.cwd(), absolutePath)
	local member = getMemberFromPath(monorepo, filepath)

	return not member.placeMixin or member.placeMixin.transpile
end

return shouldFileBeTranspiled
