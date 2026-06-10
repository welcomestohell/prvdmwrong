local pp = require "@batteries/pp"
local query = require "@std/syntax/query"
local syntax = require "@std/syntax"
local types = require "@scripts/libs/types"
local utils = require "@std/syntax/utils"

local function resolveGlobals(ctx: types.TransfomerContext)
	return query
		.findAllFromRoot(ctx.tree, utils.isExprIndexName)
		:filter(function(expr: syntax.AstExprIndexName): boolean
			return expr.expression.tag == "global" and expr.expression.name.text == "_G"
		end)
		:replace(function(expr: syntax.AstExprIndexName)
			local globalKey = expr.index.text
			local global = ctx.build.globals[globalKey]
			return if global == nil then nil else pp(global)
		end)
end

return resolveGlobals
