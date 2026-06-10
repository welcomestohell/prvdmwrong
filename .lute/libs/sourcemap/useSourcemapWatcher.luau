local fs = require "@std/fs"
local types = require "@scripts/libs/types"

--[=[
    Watches the project's sourcemap.json for files added and removed. Also
    watches all listed files in the sourcemap for file changes. 
    
    Although limited, this is significantly more reliable than Lute's `fs.watch`
    and more performant than long polling.
]=]
local function useSourcemapWatcher()
	local oldIndices: types.SourcemapIndices = {}
	local changes: { [string]: "added" | "changed" | "removed" } = {}
	local watchers: { [string]: types.Watcher } = {}

	local function onChanged(newIndices: types.SourcemapIndices)
		for absolutePath in newIndices do
			if not oldIndices[absolutePath] and not changes[absolutePath] then
				changes[absolutePath] = "added"

				local watcher = fs.watch(absolutePath)
				watchers[absolutePath] = watcher
			end
		end

		for absolutePath, hash in oldIndices do
			if not newIndices[absolutePath] and not changes[absolutePath] then
				changes[absolutePath] = "removed"

				local watcher = watchers[absolutePath]
				if watcher then
					watcher:close()
					watchers[absolutePath] = nil
				end
			end
		end

		oldIndices = newIndices
	end

	return {
		changes = changes,
		watchers = watchers,
		onChanged = onChanged,
	}
end

return useSourcemapWatcher
