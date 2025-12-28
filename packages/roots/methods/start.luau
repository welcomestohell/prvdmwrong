local dependencies = require("../../dependencies")
local lifecycles = require("../../lifecycles")
local logger = require("../logger")
local providers = require("../../providers")
local rootFinished = require("../hooks/root-finished").callbacks
local rootStarted = require("../hooks/root-started").callbacks
local types = require("../types")

local function bindLifecycle(lifecycle: lifecycles.Lifecycle<...any>, provider: providers.Provider<any, any>)
	local lifecycleMethod: (self: any, ...any) -> () = (provider :: any)[lifecycle.method]
	if typeof(lifecycleMethod) == "function" then
		local isProfiling = _G.PRVDMWRONG_PROFILE_LIFECYCLES

		if isProfiling then
			lifecycle:register(function(...)
				local memoryCategory = providers.nameOf(provider) .. ":" .. lifecycle.method
				debug.profilebegin(memoryCategory)
				debug.setmemorycategory(memoryCategory)
				lifecycleMethod(provider, ...)
				debug.resetmemorycategory()
				debug.profileend()
			end)
		else
			lifecycle:register(function(...)
				lifecycleMethod(provider, ...)
			end)
		end
	end
end
local function start(root: types.Self): types.StartedRoot
	local processed = dependencies.processDependencies(root._rootProviders :: any)
	local sortedProviders = processed.sortedDependencies :: { providers.Provider<any> }
	local processedLifecycles = processed.lifecycles
	table.move(root._rootLifecycles, 1, #root._rootLifecycles, #processedLifecycles + 1, processedLifecycles)

	dependencies.sortByPriority(sortedProviders :: any)

	local constructedProviders = {}
	for _, provider in sortedProviders do
		local providerDependencies = (provider :: any).dependencies
		if typeof(providerDependencies) == "table" then
			providerDependencies = table.clone(providerDependencies)
			for key, value in providerDependencies do
				providerDependencies[key] = constructedProviders[value]
			end
		end

		local constructed = (provider.new :: any)(providerDependencies)
		constructedProviders[provider] = constructed
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
		if didFinish then
			logger:fatalError({ template = logger.alreadyFinished })
			return
		end

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
