local configure = require("@lune-lib/configure")

return configure.package({
	name = "roots",
	description = "Roots implementation for Prvd 'M Wrong",

	types = {
		Root = true,
		StartedRoot = true,
	},

	dependencies = configure.dependencies({
		dependencies = true,
		logger = true,
		lifecycles = true,
		runtime = true,
		providers = true,
	}),
})
