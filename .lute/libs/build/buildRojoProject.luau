local json = require "@std/json"
local log = require "@scripts/libs/log"
local path = require "@std/path"
local types = require "@scripts/libs/types"
local useRepositoryConfig = require "@scripts/libs/monorepo/useRepositoryConfig"

local function insertMapping(
	tree: types.RojoNode,
	segments: { types.RojoMappingSegment },
	sourceName: string?,
	sourcePath: path.Pathlike?
)
	local current = tree

	for _, segment in segments do
		if not current[segment.name] then
			current[segment.name] = {}
		end

		current = current[segment.name]

		if segment.className then
			current["$className"] = segment.className
		end
	end

	if sourceName and sourcePath then
		if not current[sourceName] then
			current[sourceName] = {}
		end

		current = current[sourceName]

		current["$path"] = {
			optional = path.format(sourcePath),
		}
	end
end

local function buildRojoProject(kind: "source" | "output", members: { types.MonorepoMember }): json.Object
	local firstMember = members[1] or log.throw "Must specify atleast 1 member to build Rojo"
	local place = firstMember.place or log.throw "First Rojo member must be a place"

	local repository = useRepositoryConfig()
	local mappings = repository.wth.rojo.mappings :: types.RojoMappings
	local tree: types.RojoNode = { ["$className"] = "DataModel" }

	for _, member in members do
		if member.place then
			for dir, segments in mappings do
				insertMapping(tree, segments, member.folderName, member.rojoMappings[kind][dir])
			end
		elseif member.placeMixin then
			insertMapping(
				tree,
				member.placeMixin.rojo,
				member.folderName,
				if kind == "output" and member.placeMixin.transpile then member.outputDirPath else member.dirPath
			)
		end
	end

	return {
		name = `Welcome To Hell: {place.title}`,
		emitLegacyScripts = false,
		servePlaceIds = { tonumber(place.placeId) },
		placeId = tonumber(place.placeId),
		globIgnorePaths = { "**/.config.luau" },
		tree = tree,
	}
end

return buildRojoProject
