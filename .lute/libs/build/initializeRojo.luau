local buildRojoProject = require "./buildRojoProject"
local fs = require "@std/fs"
local json = require "@std/json"
local types = require "@scripts/libs/types"

local function initializeRojo(ctx: types.BuildContext)
	fs.writeStringToFile(ctx.outputProjectPath, json.serialize(buildRojoProject("output", ctx.rojoMembers), true))
	fs.writeStringToFile(ctx.sourcemapProjectPath, json.serialize(buildRojoProject("source", ctx.rojoMembers), true))
end

return initializeRojo
