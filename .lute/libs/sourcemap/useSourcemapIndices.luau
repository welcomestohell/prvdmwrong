-- From https://github.com/checkraisefold/warmluau/blob/8299341613adfef565a19b8ee7da25c1c66ccb10/src/ingredients/resolve_require/init.luau

local fs = require "@std/fs"
local json = require "@std/json"
local path = require "@std/path"
local sanitizeQuotes = require "@scripts/libs/sourcemap/sanitizeQuotes"
local types = require "@scripts/libs/types"

local function sourcemapIndices(sourcemapPath: path.Pathlike): types.SourcemapIndices
	local sourcemap = json.deserialize(fs.readFileToString(sourcemapPath)) :: types.SourcemapNode
	local indices: { [string]: string } = {}

	local nodes = sourcemap.children
	if not nodes then
		return {}
	end

	local lenNodes = #nodes
	for index = 1, lenNodes do
		local service = nodes[index]
		service.name = `@game/{service.name}`
	end

	local index = 0
	while index < lenNodes do
		index += 1
		local node = nodes[index]
		local nodeName = node.name

		local filePaths = node.filePaths
		if filePaths then
			local lenFilePaths = #filePaths
			for filePathsIndex = 1, lenFilePaths do
				local filePath = filePaths[filePathsIndex]
				local absolutePath = path.format(filePath)
				indices[absolutePath] = nodeName
			end
		end

		local children = node.children
		if children then
			local children_count = #children
			for children_index = 1, children_count do
				local child = children[children_index]
				child.name = `{nodeName}/{child.name}`
			end
			table.move(children, 1, children_count, lenNodes + 1, nodes)
			lenNodes += children_count
		end
	end

	return indices
end

return sourcemapIndices
