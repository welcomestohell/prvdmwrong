local DEPENDENCY = require("./roblox_packages/providers")
export type Provider<Self, Dependencies = nil> = DEPENDENCY.Provider<Self, Dependencies>
return DEPENDENCY
