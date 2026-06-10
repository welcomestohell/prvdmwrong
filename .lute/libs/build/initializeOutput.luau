local copyInto = require "@scripts/libs/copyInto"
local emptyDir = require "@scripts/libs/emptyDir"
local richterm = require "@batteries/richterm"
local types = require "@scripts/libs/types"

local function initializeOutput(ctx: types.BuildContext)
	pcall(emptyDir, ctx.outputPath)
	for _, member in ctx.rojoMembers do
		if member.place or (member.placeMixin and member.placeMixin.transpile) then
			print(richterm.cyan(`Copying {member.dirName} to output`))
			copyInto(member.dirPath, member.outputDirPath)
		end
	end
end

return initializeOutput
