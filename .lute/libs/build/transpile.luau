local path = require "@std/path"
local printer = require "@std/syntax/printer"
local richterm = require "@batteries/richterm"
local syntax = require "@std/syntax"
local types = require "@scripts/libs/types"

local transformers: { types.Transformer } = {
	require "@scripts/libs/build/transformers/resolveGlobals",
	require "@scripts/libs/build/transformers/resolveRequires",
}

local function transpile(ctx: types.BuildContext, filepath: path.Pathlike, source: string)
	for _, transformer in transformers do
		local parseSuccess, treeOrError = pcall(syntax.parse, source)
		if not parseSuccess then
			print(richterm.yellow(`! Failed to parse {filepath}:`))
			print(richterm.yellow(`  {treeOrError}`))
			return source
		end

		source = printer.printFile(
			treeOrError,
			transformer {
				build = ctx,
				filepath = filepath,
				source = source,
				tree = treeOrError,
			}
		)
	end

	return source
end

return transpile
