local richterm = require "@batteries/richterm"

const LINE = "―"

local function divider(label: string?, length: number?)
	length = length or 60

	if label then
		local labelLength = string.len(label)
		local lineLength = (length - labelLength) * 0.5

		-- we add an extra line at the end if the label is uneven
		local endPadding = labelLength % 2

		return richterm.dim(`{string.rep(LINE, lineLength)} {label} {string.rep(LINE, lineLength + endPadding)}`)
	end

	return string.rep(richterm.dim(LINE), length)
end

return divider
