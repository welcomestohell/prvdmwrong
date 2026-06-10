local fs = require "@std/fs"
local path = require "@std/path"

local function copyInto(from: path.Pathlike, to: path.Pathlike)
	if fs.type(from) == "dir" then
		if not fs.exists(to) then
			fs.createDirectory(to)
		end

		for _, entry in fs.listDirectory(from) do
			local entryPath = path.join(from, entry.name)
			local entryDestination = path.join(to, entry.name)

			if entry.type == "dir" then
				copyInto(entryPath, entryDestination)
			else
				fs.copy(entryPath, entryDestination)
			end
		end
	else
		fs.copy(from, to)
	end
end

return copyInto
