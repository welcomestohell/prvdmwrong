local cli = require "@batteries/cli"
local log = require "@scripts/libs/log"
local run = require "@scripts/libs/run"
local task = require "@std/task"
local useMonorepo = require "@scripts/libs/monorepo/useMonorepo"

local args = cli.parser { description = "Runs a command across all monorepo members" }
args:parse { ... }

local monorepo = useMonorepo()
local forwarded = args:forwarded() or {} :: { string }
table.remove(forwarded, 1)
local program = forwarded[1]
table.remove(forwarded, 1)

for _, member in monorepo do
	log.verbose(member.dirName)
	task.spawn(run, program, forwarded, { cwd = member.dirPath, ignoreFailure = true } :: run.Options)
end
