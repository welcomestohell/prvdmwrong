local threadpool = require("@self/batteries/threadpool")

-- TODO 0.3: support other runtimes
return table.freeze({
	name = "Roblox",

	task = task,
	warn = warn,

	threadpool = threadpool,
})
