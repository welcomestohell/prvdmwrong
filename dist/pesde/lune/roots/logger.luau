local DEPENDENCY = require("./lune_packages/logger")
export type Logger<Templates> = DEPENDENCY.Logger<Templates>
export type Log = DEPENDENCY.Log
export type Error = DEPENDENCY.Error
return DEPENDENCY
