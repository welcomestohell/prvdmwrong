local DEPENDENCY = require("./luau_packages/dependencies")
export type Dependency<Self, Dependencies = nil, NewArgs... = ()> = DEPENDENCY.Dependency<Self, Dependencies, NewArgs...>
return DEPENDENCY
