local DEPENDENCY = require("./roblox_packages/lifecycles")
export type Lifecycle<Args... = ...unknown> = DEPENDENCY.Lifecycle<Args...>
return DEPENDENCY
