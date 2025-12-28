local types = require("./types")

local function parseError(err: string): types.Error
	return {
		type = "Error",
		raw = err,
		message = string.gsub(err, "^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2),
	}
end

return parseError
