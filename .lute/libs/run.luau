local io = require "@std/io"
local path = require "@std/path"
local process = require "@std/process"
-- local richterm = require "@batteries/richterm"

export type Options = {
	cwd: path.Pathlike?,
	env: { [string]: string }?,
	quiet: boolean?,
	ignoreFailure: boolean?,
	captureOutput: boolean?,
}

local function run(program: string, args: { any }, options: Options?)
	options = options or {} :: Options

	local stringifiedArgs = table.create(#args + 1) :: { string }
	for index, arg in args do
		stringifiedArgs[index] = tostring(arg)
	end
	table.insert(stringifiedArgs, 1, program)

	-- if not options.quiet then
	-- print(richterm.dim(`$ {table.concat(stringifiedArgs, " ")}`))
	-- end

	local result = process.run(stringifiedArgs, {
		cwd = options.cwd and tostring(options.cwd),
		env = options.env,
		stdio = if options.captureOutput or options.quiet then "default" else "inherit",
	})

	-- lute doesn't stream output when using `default` stdio; so we print it
	-- here for ergonomics
	if options.captureOutput and not options.quiet then
		io.write(result.stdout, result.stderr)
	end

	return if result.ok or options.ignoreFailure then result else error(result.stderr)
end

return run
