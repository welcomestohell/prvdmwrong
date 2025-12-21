local DEPENDENCY = require("./Packages/lifecycles")
export type Lifecycle<Args... = ...unknown> = DEPENDENCY.Lifecycle<Args...>
return DEPENDENCY
