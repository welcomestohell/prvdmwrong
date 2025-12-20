local DEPENDENCY = require("./Packages/lifecycles")
export type Lifecycle<Args... = ...unknown> = DEPENDENCY.Lifecycles<Args...>
return DEPENDENCY
