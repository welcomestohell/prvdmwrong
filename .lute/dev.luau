local cli = require "@scripts/libs/cli"
local divider = require "@scripts/libs/ui/divider"
local fs = require "@std/fs"
local initializeOutput = require "@scripts/libs/build/initializeOutput"
local initializeRojo = require "@scripts/libs/build/initializeRojo"
local io = require "@lute/io"
local path = require "@std/path"
local process = require "@std/process"
local richterm = require "@batteries/richterm"
local run = require "@scripts/libs/run"
local shouldFileBeTranspiled = require "@scripts/libs/build/shouldFileBeTranspiled"
local task = require "@std/task"
local transpile = require "@scripts/libs/build/transpile"
local types = require "./libs/types"
local useMonorepo = require "@scripts/libs/monorepo/useMonorepo"
local usePlaceDependencies = require "@scripts/libs/monorepo/usePlaceDependencies"
local useRepositoryConfig = require "@scripts/libs/monorepo/useRepositoryConfig"
local useSourcemapIndices = require "@scripts/libs/sourcemap/useSourcemapIndices"
local useSourcemapWatcher = require "@scripts/libs/sourcemap/useSourcemapWatcher"

local args = cli.parser { description = "Launches and observes the given place for development" }
args:add("place", "positional", { help = "Name of place to build", required = true })
args:parse { ... }

local cwd = process.cwd()

local repository = useRepositoryConfig()
local outputPath = repository.wth.paths.output
local outputProjectPath = repository.wth.paths.outputProject
local sourcemapPath = repository.wth.paths.sourcemap
local sourcemapProjectPath = repository.wth.paths.sourcemapProject

local monorepo = useMonorepo()
local member = monorepo[args:get "place"] or error(`Unknown place named {args:get "place"}`)
local memberPlace = member.place or error(`Member {member.dirName} is not a place (does it have a place field?)`)
local placeId = memberPlace.placeId or error(`{memberPlace.title} is an abstract place (does it have a placeId?)`)

local memberDependencies = usePlaceDependencies(monorepo, member)
local rojoMembers = table.clone(memberDependencies)
table.insert(rojoMembers, 1, member)

local ctx: types.BuildContext = {
	monorepo = monorepo,
	repository = repository,

	member = member,
	memberPlace = memberPlace,
	memberDependencies = memberDependencies,
	rojoMembers = rojoMembers,

	outputPath = outputPath,
	outputProjectPath = outputProjectPath,
	sourcemapPath = sourcemapPath,
	sourcemapProjectPath = sourcemapProjectPath,

	sourcemapIndices = {},

	globals = {
		__DEV__ = true,
		WTH_DIR_NAME = member.dirName,
		WTH_PLACE_FOLDER = memberPlace.folderName,
		WTH_PLACE_TITLE = memberPlace.title,
		WTH_PLACE_SUBTITLE = memberPlace.subtitle,
	},
}

print(divider "Initializing output...")
initializeOutput(ctx)

print(divider "Initializing assets...")
run("asphalt", { "sync", "studio" })

print(divider "Initializing .blink files...")
for _, member in rojoMembers do
	local blinkFilepath = path.join(member.dirPath, ".blink")
	if fs.exists(blinkFilepath) then
		print(richterm.dim(richterm.bold(`Compiling {blinkFilepath}`)))
		run("blink", { blinkFilepath })
		task.spawn(run, "blink", { blinkFilepath }, { quiet = true } :: run.Options)
	end
end

print(divider "Initializing Rojo projects...")
initializeRojo(ctx)

local sourcemapWatcher = useSourcemapWatcher(sourcemapPath)
local sourcemapFileWatcher = fs.watch(sourcemapPath)

local sourcemapArgs = {
	"sourcemap",
	"--absolute",
	"--include-non-scripts",
	"--output",
	sourcemapPath,
	sourcemapProjectPath,
}

run("rojo", sourcemapArgs)
table.insert(sourcemapArgs, 2, "--watch")
task.spawn(run, "rojo", sourcemapArgs, { quiet = true } :: run.Options)

local function processChanges()
	for absolutePath, fileWatcher in sourcemapWatcher.watchers do
		local event = fileWatcher:next()
		if event then
			if event.change then
				sourcemapWatcher.changes[absolutePath] = "changed"
			end
		end
	end

	local event = sourcemapFileWatcher:next()
	if event and event.change then
		ctx.sourcemapIndices = useSourcemapIndices(sourcemapPath)
		sourcemapWatcher.onChanged(ctx.sourcemapIndices)
	end

	for filepath, action in sourcemapWatcher.changes do
		if (action == "removed" or fs.exists(filepath)) and shouldFileBeTranspiled(monorepo, filepath) then
			local relativePath = path.relative(cwd, filepath)
			local outputFilepath = path.join(outputPath, relativePath)

			local formatter: richterm.Formatter, marker: string
			if action == "added" then
				formatter, marker = richterm.green, "+"
				local outputDir = path.dirname(outputFilepath)
				if not fs.exists(outputDir) then
					fs.createDirectory(outputDir, { makeParents = true })
				end
				fs.writeStringToFile(outputFilepath, transpile(ctx, filepath, fs.readFileToString(filepath)))
			elseif action == "changed" then
				formatter, marker = richterm.cyan, "↻"
				fs.writeStringToFile(outputFilepath, transpile(ctx, filepath, fs.readFileToString(filepath)))
			elseif action == "removed" then
				formatter, marker = richterm.red, "-"
				fs.remove(outputFilepath)
			end

			print(formatter(`{marker} {relativePath}`))
		end
	end

	table.clear(sourcemapWatcher.changes)
end

print(divider "Running initial transpilation...")
processChanges()

print(divider())
task.spawn(run, "rojo", { "serve" })

task.delay(0.1, function()
	print(richterm.blue(`Press {richterm.bold "Enter"} to open {memberPlace.title} in Roblox Studio.`))
	print(divider "Polling for changes...")
	while task.wait(0.05) do
		processChanges()
	end
end)

while io.read() do
	run("lute", { "ropen", placeId })
end
