local fs = require "@std/fs"
local log = require "@scripts/libs/log"
local luau = require "@std/luau"
local path = require "@std/path"
local types = require "@scripts/libs/types"
local useRepositoryConfig = require "./useRepositoryConfig"

local function useMonorepo(): types.Monorepo
	local repository = useRepositoryConfig()
	local monorepo: types.Monorepo = {}

	for _, entry in fs.listDirectory "." do
		if entry.type ~= "dir" then
			continue
		end

		local configPath = path.join(entry.name, ".config.luau")
		if not fs.exists(configPath) or fs.type(configPath) ~= "file" then
			continue
		end

		local config: types.LuauConfig = luau.loadModule(configPath)
		local wthConfig = config.wth
		if not wthConfig then
			continue
		end

		local placeConfig, placeMixinConfig = wthConfig.place, wthConfig.placeMixin
		if placeConfig and placeMixinConfig then
			log.warn(entry.name, "config specifies place AND placeMixin, which is mutually exclusive")
			continue
		elseif not (placeConfig or placeMixinConfig) then
			continue
		end

		local folderName = if placeConfig
			then placeConfig.folderName
			elseif placeMixinConfig then placeMixinConfig.folderName
			else log.throw(`Missing folderName for {entry.name}`)

		local member: types.MonorepoMember = {
			place = placeConfig,
			placeMixin = placeMixinConfig,

			folderName = folderName,
			dirName = entry.name,
			dirPath = entry.name,
			configPath = configPath,
			outputDirPath = path.join(repository.wth.paths.output, entry.name),

			rojoMappings = {
				source = {},
				output = {},
			},
		}

		for key in repository.wth.rojo.mappings :: any do
			member.rojoMappings.source[key] = path.join(member.dirPath, key)
			member.rojoMappings.output[key] = path.join(repository.wth.paths.output, member.dirPath, key)
		end

		table.insert(monorepo, member)
		monorepo[entry.name] = member
	end

	table.sort(monorepo, function(lhs: types.MonorepoMember, rhs: types.MonorepoMember)
		return lhs.dirName < rhs.dirName
	end)

	return monorepo
end

return useMonorepo
