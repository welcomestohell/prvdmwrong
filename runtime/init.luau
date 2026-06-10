-- Son its just Roblox
-- local implementations = require("@self/implementations")
-- local task = require("@self/libs/task")
local threadpool = require "@self/threadpool"
-- local warn = require("@self/libs/warn")

-- export type RuntimeName = implementations.RuntimeName

return table.freeze {
	name = "roblox",

	task = task,
	warn = warn,

	threadpool = threadpool,
}
