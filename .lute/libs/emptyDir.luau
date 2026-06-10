local fs = require "@std/fs"
local path = require "@std/path"

local function emptyDir(dir: path.Pathlike)
	for _, file in fs.listDirectory(dir) do
		local filepath = path.join(dir, file.name)
		if fs.type(filepath) == "dir" then
			fs.removeDirectory(filepath, { recursive = true })
		else
			fs.remove(filepath)
		end
	end
end

return emptyDir
