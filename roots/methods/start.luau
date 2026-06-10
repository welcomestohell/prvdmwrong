local dependencies = require "../../dependencies"
local lifecycles = require "../../lifecycles"
local logger = require "../logger"
local providers = require "../../providers"
local rootFinished = require("../hooks/root-finished").callbacks
local rootStarted = require("../hooks/root-started").callbacks
local types = require "../types"

local function bindLifecycle(lifecycle: lifecycles.Lifecycle<...any>, provider: providers.Provider<any>)
	local lifecycleMethod = (provider :: any)[lifecycle.method]
	if typeof(lifecycleMethod) == "function" then
		-- local isProfiling = _G.PRVDMWRONG_PROFILE_LIFECYCLES

		-- if isProfiling then
		-- 	lifecycle:register(function(...)
		-- 		debug.profilebegin(memoryCategory)
		-- 		debug.setmemorycategory(memoryCategory)
		-- 		lifecycleMethod(provider, ...)
		-- 		debug.resetmemorycategory()
		-- 		debug.profileend()
		-- 	end)
		-- else
		lifecycle:register(function(...) lifecycleMethod(provider, ...) end)
		-- end
	end
end

local function nameOf(provider: providers.Provider<unknown>, extension: string?): string
	return if extension then `{tostring(provider)}.{extension}` else tostring(provider)
end

local function start(root: types.Self): types.StartedRoot
	local processed = dependencies.processDependencies(root._rootProviders)
	local sortedProviders = processed.sortedDependencies :: { providers.Provider<any> }
	local processedLifecycles = processed.lifecycles
	table.move(root._rootLifecycles, 1, #root._rootLifecycles, #processedLifecycles + 1, processedLifecycles)

	dependencies.sortByPriority(sortedProviders)

	local constructedProviders = {}

	-- PHASE 1: Instantiate everything first so they all exist in memory
	for _, provider in sortedProviders do
		-- If your provider.new() strictly REQUIRES dependencies immediately at creation,
		-- pass an empty table that we mutate in Phase 2, or construct them with a placeholder.
		local constructed = provider.new {}
		constructedProviders[provider] = constructed
	end

	-- PHASE 2: Resolve dependencies and bind lifecycles now that everyone exists
	for _, provider in sortedProviders do
		local constructed = constructedProviders[provider]
		local providerDependencies = (provider :: any).dependencies

		if typeof(providerDependencies) == "table" then
			-- Rebuild the actual dependency table with the INSTANCES we created in Phase 1
			local resolvedDeps = {}
			for key, dependencyBlueprint in providerDependencies do
				local instance = constructedProviders[dependencyBlueprint]
				if not instance then
					logger:fatalError { template = "Missing dependency: " .. tostring(dependencyBlueprint) }
				end
				resolvedDeps[key] = instance
			end

			-- Inject the resolved dependencies into the constructed instance
			-- (Assuming your framework allows injecting post-init, or via a method)
			constructed.dependencies = resolvedDeps
		end

		-- Now safe to bind lifecycles
		bindLifecycle(root._start, constructed)
		bindLifecycle(root._finish, constructed)

		for _, lifecycle in processedLifecycles do
			bindLifecycle(lifecycle, constructed)
		end
	end

	local subRoots: { types.StartedRoot } = {}
	for root in root._subRoots do
		table.insert(subRoots, root:start())
	end

	root._start:fire()

	local startedRoot = {} :: types.StartedRoot
	startedRoot.type = "StartedRoot"

	local didFinish = false

	function startedRoot:finish()
		if didFinish then return logger:fatalError { template = logger.alreadyFinished } end

		didFinish = true
		root._finish:fire()

		-- NOTE(znotfireman): Assume the user cleans up their own lifecycles
		root._start:clear()
		root._finish:clear()

		for _, subRoot in subRoots do
			subRoot:finish()
		end

		for _, hook in rootFinished do
			hook(root)
		end
	end

	for _, hook in rootStarted do
		hook(root)
	end

	return startedRoot
end

return start
