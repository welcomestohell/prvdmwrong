local DEPENDENCY = require("./luau_packages/lifecycles")
export type Lifecycle<Args... = ...unknown> = DEPENDENCY.Lifecycles<Args...>
return DEPENDENCY
