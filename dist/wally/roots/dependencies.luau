local DEPENDENCY = require("./Packages/dependencies")
export type Dependency<Self, Dependencies = nil, NewArgs... = ()> = DEPENDENCY.Dependency<Self, Dependencies, NewArgs...>
return DEPENDENCY
