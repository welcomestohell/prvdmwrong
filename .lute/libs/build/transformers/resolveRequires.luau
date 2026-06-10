local luau = require "@std/luau"
local path = require "@std/path"
local query = require "@std/syntax/query"
local richterm = require "@batteries/richterm"
local syntax = require "@std/syntax"
local types = require "@scripts/libs/types"
local utils = require "@std/syntax/utils"

local function resolveRequires(ctx: types.TransfomerContext)
	return query
		.findAllFromRoot(ctx.tree, utils.isExprCall)
		:filter(function(call: syntax.AstExprCall): boolean
			return call.func.tag == "global" and call.func.name.text == "require"
		end)
		:replace(function(call: syntax.AstExprCall)
			local pathArgument = call.arguments[1]
			if not pathArgument or pathArgument.node.tag ~= "string" then
				return nil
			end

			local resolveSuccess, resolvedOrError =
				pcall(luau.resolveModule, pathArgument.node.token.text, ctx.filepath)

			if not resolveSuccess then
				print(richterm.yellow(`! Failed to resolve require {pathArgument.node.token.text}:`))
				print(richterm.yellow(`  {resolvedOrError}`))
				print(richterm.yellow(`  in {path.format(ctx.filepath)}`))
				return nil
			end

			local requirePath = ctx.build.sourcemapIndices[path.format(resolvedOrError)]
			return if requirePath then `require {string.format("%q", requirePath)}` else nil
		end)
end

return resolveRequires
