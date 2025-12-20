local DEPENDENCY = require("./luau_packages/providers")
export type Provider<Self, Dependencies = nil> = DEPENDENCY.Provider<Self, Dependencies>
return DEPENDENCY
