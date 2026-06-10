local types = require "@scripts/libs/types"

local function usePlaceDependencies(monorepo: types.Monorepo, member: types.MonorepoMember)
	local resolved = {}
	local resolvedSet = {}
	local visiting = {}

	local function visit(current: types.MonorepoMember, stack: { string })
		local place = current.place
		if not place then
			return
		end

		if visiting[current.dirName] then
			local cycleStart = table.find(stack, current.dirName) or 1
			local cycle = table.move(stack, cycleStart, #stack, 1, {})
			table.insert(cycle, current.dirName)

			error(`Place has cyclic dependency: {table.concat(cycle, " -> ")}`)
		end

		if resolvedSet[current.dirName] then
			return
		end

		visiting[current.dirName] = true
		table.insert(stack, current.dirName)

		for _, dependencyName in place.dependencies or {} do
			local dependency = monorepo[dependencyName]
				or error(`Place {current.dirName} has unknown dependency named {dependencyName}`)
			visit(dependency, stack)

			if not resolvedSet[dependency.dirName] then
				resolvedSet[dependency.dirName] = true
				table.insert(resolved, dependency)
			end
		end

		visiting[current.dirName] = nil
		table.remove(stack)
	end

	visit(member, {})

	return resolved
end

return usePlaceDependencies
