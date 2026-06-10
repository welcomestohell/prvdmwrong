local findCommentRegion = require "@scripts/libs/findCommentRegion"
local fs = require "@std/fs"
local json = require "@std/json"
local path = require "@std/path"
local pp = require "@batteries/pp"
local run = require "@scripts/libs/run"
local useMonorepo = require "@scripts/libs/monorepo/useMonorepo"

local monorepo = useMonorepo()

local luauAliases = {}
for _, member in ipairs(monorepo) do
	luauAliases[member.dirName] = path.format(member.dirPath)
end

local configLuau = fs.readFileToString ".config.luau"
local aliasesStart, aliasesEnd = findCommentRegion(configLuau, "aliases")

configLuau = string.sub(configLuau, 1, assert(aliasesStart) - 1)
	.. `-- #region aliases\nlocal aliases = {pp(luauAliases)}\n-- #endregion`
	.. string.sub(configLuau, assert(aliasesEnd) + 1)

fs.writeStringToFile(".config.luau", configLuau)
run("stylua", { ".config.luau" })
