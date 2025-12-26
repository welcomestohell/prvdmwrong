local DEPENDENCY = require("./roblox_packages/prvdmwrong")
export type Root = DEPENDENCY.Root
export type Lifecycle<Args... = ...unknown> = DEPENDENCY.Lifecycle<Args...>
export type StartedRoot = DEPENDENCY.StartedRoot
export type Provider<Self, Dependencies = nil> = DEPENDENCY.Provider<Self, Dependencies>
return DEPENDENCY
